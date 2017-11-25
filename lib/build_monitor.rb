require 'logger'
require_relative 'codeship_client'
require_relative 'status_indicator'

class BuildMonitor
  EXECUTION_INTERVAL = 50

  def initialize(options = {})
    @user = options[:user]
    @repo = options[:repo]
    @execution_interval = options[:interval] || EXECUTION_INTERVAL
  end

  def run
    loop do
      indicator.status = current_status
      sleep(execution_interval)
    end
  rescue Interrupt
    indicator.status = nil
  end

  private

  attr_accessor :user, :repo, :execution_interval

  def current_status
    builds = builds_by_status
    %w[running error success].find do |status|
      next unless builds.key?(status)
      builds[status].each { |build| log(build) }
    end
  end

  def builds_by_status
    result = Hash.new { |hash, key| hash[key] = [] }
    latest_builds.each_with_object(result) do |build, hash|
      hash[build.status] << build
    end
  end

  def latest_builds
    builds.uniq { |build| [build.repo, build.branch] }
  end

  def builds
    projects.map do |project|
      next project.builds.to_a unless user
      project.builds.select do |build|
        build.user && build.user.match(user)
      end
    end.flatten
  end

  def projects
    return client.projects.to_a unless repo
    client.projects.select do |project|
      project.repo && project.repo.match(repo)
    end
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

  def log(build)
    logger.info(
      "#{build.status.upcase}: #{build.repo}, #{build.branch}," \
      " #{build.user}"
    )
  end
end
