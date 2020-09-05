# frozen_string_literal: true

require 'logger'
require_relative 'codeship_client'
require_relative 'status_indicator'

module Shiplight
  class BuildMonitor
    POLL_INTERVAL = 30

    def initialize(options = {})
      @user = options[:user]
      @repo = options[:repo]
      @exclude = options[:exclude]
      @verbose = options[:verbose] || false
      @cutoff = options[:within] ? options[:within].to_i : 0
      @interval = options[:interval] ? options[:interval].to_i : POLL_INTERVAL
      @previous_builds = []
    end

    def run
      logger << "=> Starting CodeShip build monitor\n"
      logger << "=> Ctrl-C to stop monitoring\n"
      loop do
        indicator.status = build_status
        sleep(interval)
      end
    rescue Interrupt
      indicator.status = nil
    end

    private

    attr_reader :user, :repo, :exclude, :interval, :cutoff
    attr_accessor :previous_builds

    def build_status
      builds = current_builds.group_by(&:status)
      %w[testing error success].find do |status|
        next unless builds.key?(status)

        log_build_status(builds[status])
        true
      end
    end

    def current_builds
      return filtered_builds unless cutoff.positive?

      since = Time.now - cutoff * 60 * 60
      filtered_builds.reject do |build|
        build.finished_at && Time.parse(build.finished_at) < since
      end
    end

    def filtered_builds
      builds = projects.map { |project| project.builds.to_a }.flatten
      builds = builds.uniq { |build| [build.repo, build.branch] }
      builds.select { |build| build.match?(user) }
    end

    def projects
      projects = organization.projects
      projects = projects.select { |p| p.match?(repo) } if repo
      projects = projects.reject { |p| p.match?(exclude) } if exclude
      projects
    end

    def organization
      client.organization
    end

    def verbose?
      @verbose
    end

    def log_build_status(current_builds)
      current_builds.each do |build|
        next unless verbose? || !previous_builds.include?(build)

        log(build)
      end
      self.previous_builds = current_builds
    end

    def log(build)
      logger.info(
        "#{build.status.upcase}: #{build.repo}, #{build.branch}," \
        " #{build.user}"
      )
    end

    def client
      @client ||= CodeshipClient.new
    end

    def indicator
      @indicator ||= StatusIndicator.new
    end

    def logger
      @logger ||= Logger.new($stdout)
    end
  end
end
