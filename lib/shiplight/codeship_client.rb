# frozen_string_literal: true

require 'HTTParty'
require 'json'
require 'inifile'
require 'logger'
require_relative 'organization_factory'

module Shiplight
  class CodeshipClient
    HOST = 'api.codeship.com/v2'
    HTTP_CLIENT_ERRORS = [
      Errno::EADDRNOTAVAIL,
      Errno::ECONNRESET,
      Errno::ENETDOWN,
      Errno::ENETUNREACH,
      Errno::ETIMEDOUT,
      Errno::EHOSTUNREACH,
      HTTParty::ResponseError,
      OpenSSL::SSL::SSLError,
      SocketError,
      Timeout::Error,
      Zlib::DataError
    ].freeze

    def initialize
      ensure_credentials
      login
    end

    def get(endpoint)
      response = HTTParty.get(
        path_to(endpoint), headers: { authorization: access_token }, format: :json
      )
      return response.parsed_response if response.success?

      login if response.unauthorized?
      nil
    rescue *HTTP_CLIENT_ERRORS => e
      logger.warn("ignoring error #{e.message}")
      nil
    end

    def organization
      organizations.first
    end

    private

    attr_reader :access_token

    def login
      response = HTTParty.post(
        path_to('auth'),
        basic_auth: { username: username, password: password }
      )
      raise 'login failed' unless response.success?

      @access_token = response.parsed_response['access_token']
      @data = response.parsed_response['organizations']
    end

    def organizations
      OrganizationFactory.new(self, @data)
    end

    def path_to(endpoint)
      "https://#{HOST}/#{endpoint}"
    end

    def ensure_credentials
      return if username && password

      logger.error("CodeShip credentials not found in #{inifile_path}")
      raise Interrupt
    end

    def username
      credentials['username']
    end

    def password
      credentials['password']
    end

    def credentials
      @credentials ||= load_credentials
    end

    def load_credentials
      section = ENV['SHIPLIGHT_DEFAULT'] || 'default'
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
