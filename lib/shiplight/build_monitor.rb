# frozen_string_literal: true

require 'logger'
require_relative 'github_client'
require_relative 'status_indicator'

module Shiplight
  class BuildMonitor
    POLL_INTERVAL = 30
    HTTP_CLIENT_ERRORS = [
      Errno::EADDRNOTAVAIL,
      Errno::ECONNRESET,
      Errno::ENETDOWN,
      Errno::ENETUNREACH,
      Errno::ETIMEDOUT,
      Errno::EHOSTUNREACH,
      Timeout::Error
    ].freeze

    def initialize(options = {})
      @user = options[:user]
      @target = options[:repo]
      @exclude = options[:exclude]
      @verbose = options[:verbose] || false
      @cutoff = options[:within].to_i * 60 * 60 if options[:within]
      @interval = options[:interval] ? options[:interval].to_i : POLL_INTERVAL
      @history = {}
    end

    def run
      logger << "=> Starting Github build monitor\n"
      logger << "=> Ctrl-C to stop monitoring\n"

      loop do
        indicator.status = handle_network_errors { status }
        sleep(interval)
      end
    rescue Interrupt
      indicator.status = nil
    end

    private

    attr_reader :user, :target, :exclude, :interval, :cutoff, :history

    def handle_network_errors
      yield
    rescue *HTTP_CLIENT_ERRORS => e
      logger.warn("ignoring error #{e.message}")
    end

    def status
      each_repo do |repo|
        each_commit(repo) do |branch, commit|
          if match?(commit) && (status = commit_status(repo, commit))
            log(repo, branch, commit, status)
            return status if status != 'success'
          end
        end
      end

      'success'
    end

    def each_repo
      client.org_repos('CardFlight', sort: :pushed).each do |repo|
        next if target && !repo.name.match?(target)
        next if exclude && repo.name.match?(exclude)

        yield repo
      end
    end

    def each_commit(repo)
      client.branches(repo.id).each do |branch|
        yield branch, client.commit(repo.id, branch.commit.sha)
      end
    end

    def match?(commit)
      return unless (author = commit.author)
      return if user && !author.login.match?(user)
      return if cutoff && commit.commit.author.date < Time.now - cutoff

      true
    end

    def commit_status(repo, commit)
      return if (runs = client.check_runs_for_commit(repo, commit)).empty?

      if runs.map(&:status).uniq != ['completed']
        'pending'
      elsif runs.map(&:conclusion).uniq == ['success']
        'success'
      else
        'failure'
      end
    end

    def log(repo, branch, commit, status)
      return unless verbose? || history[commit.sha] != status

      history[commit.sha] = status

      logger.info(<<~HEREDOC.gsub(/\s+/, ' '))
        #{status.upcase}:
        #{repo.name},
        #{branch.name},
        #{commit.author.login}
      HEREDOC
    end

    def verbose?
      @verbose
    end

    def client
      @client ||= Shiplight::GithubClient.new
    end

    def indicator
      @indicator ||= StatusIndicator.new
    end

    def logger
      @logger ||= Logger.new($stdout)
    end
  end
end
