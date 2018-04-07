require 'logger'
require_relative 'codeship_client'
require_relative 'status_indicator'

module Shiplight
  class BuildMonitor
    EXECUTION_INTERVAL = 30

    def initialize(options = {})
      @user = options[:user]
      @repo = options[:repo]
      @verbose = options[:verbose] || false
      @execution_interval = options[:interval].to_i || EXECUTION_INTERVAL
      @previous_builds = []
    end

    def run
      logger << "=> Starting CodeShip build monitor\n"
      logger << "=> Ctrl-C to stop monitoring\n"
      loop do
        indicator.status = build_status
        sleep(execution_interval)
      end
    rescue Interrupt
      indicator.status = nil
    end

    private

    attr_reader :user, :repo, :execution_interval
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
      uniq_builds.select { |build| build.match?(user) }
    end

    def uniq_builds
      all_builds = projects.map { |project| project.builds.to_a }.flatten
      all_builds.uniq { |build| [build.repo, build.branch] }
    end

    def projects
      client.projects.select { |project| project.match?(repo) }
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
      @logger ||= Logger.new(STDOUT)
    end
  end
end
