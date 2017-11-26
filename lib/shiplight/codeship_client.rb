require 'HTTParty'
require 'json'
require_relative 'project_factory'

module Shiplight
  class CodeshipClient
    HOST = 'codeship.com/api/v1'.freeze

    def initialize
      ensure_api_key
    end

    def projects
      path = get_path('projects')
      response = HTTParty.get(path)
      data = JSON.parse(response.body)
      ProjectFactory.new(data['projects'])
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
