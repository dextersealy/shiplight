require 'HTTParty'
require 'json'
require_relative 'project_factory'

module Shiplight
  class CodeshipClient
    HOST = 'codeship.com/api/v1'.freeze
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
      ensure_api_key
    end

    def projects
      response = HTTParty.get(get_path('projects'), format: :json)
      parsed_response = if response.success?
                          response.parsed_response['projects']
                        else
                          []
                        end
      ProjectFactory.new(parsed_response)
    rescue *HTTP_CLIENT_ERRORS
      ProjectFactory.new
    end

    private

    def ensure_api_key
      return if api_key
      puts 'error: CODESHIP_API_KEY not defined'
      raise Interrupt
    end

    def api_key
      @api_key ||= ENV['CODESHIP_API_KEY']
    end

    def get_path(endpoint)
      "https://#{HOST}/#{endpoint}.json?api_key=#{api_key}"
    end
  end
end
