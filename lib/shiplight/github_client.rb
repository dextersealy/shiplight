# frozen_string_literal: true

require 'inifile'
require 'logger'
require 'octokit'

module Shiplight
  class GithubClient < Octokit::Client
    def initialize
      ensure_credentials
      super(access_token: access_token)
    end

    def check_runs_for_commit(repo, commit)
      check_runs_for_ref(
        repo.id,
        commit.sha,
        accept: 'application/vnd.github.antiope-preview+json'
      ).check_runs
    end

    private

    def ensure_credentials
      return if access_token

      logger.error("Github access token not found in #{inifile_path}")
      raise Interrupt
    end

    def access_token
      credentials['token']
    end

    def credentials
      @credentials ||= load_credentials
    end

    def load_credentials
      section = ENV['SHIPLIGHT_DEFAULT'] || 'github'
      inifile = IniFile.load(inifile_path)
      inifile ? inifile[section] : {}
    end

    def inifile_path
      File.join(ENV['HOME'], '.shiplight', 'credentials')
    end

    def logger
      @logger ||= Logger.new($stdout)
    end
  end
end
