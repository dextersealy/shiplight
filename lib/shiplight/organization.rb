# frozen_string_literal: true

require_relative 'project_factory'

module Shiplight
  class Organization
    attr_reader :client

    def initialize(client, data)
      @client = client
      @data = data
    end

    def name
      @data['name']
    end

    def uuid
      @data['uuid']
    end

    def path
      "/organizations/#{uuid}"
    end

    def projects
      return [] unless (data = client.get("#{path}/projects"))

      ProjectFactory.new(self, data.fetch('projects'))
    end

    def match?(name)
      name.nil? || Regexp.new(name, Regexp::IGNORECASE).match?(self.name)
    end
  end
end
