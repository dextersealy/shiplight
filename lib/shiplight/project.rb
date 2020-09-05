# frozen_string_literal: true

require_relative 'build_factory'

module Shiplight
  class Project
    def initialize(organization, data)
      @organization = organization
      @data = data
    end

    def repo
      @data['name']
    end

    def path
      "#{organization.path}/projects/#{uuid}"
    end

    def builds
      return [] unless (data = client.get("#{path}/builds"))

      BuildFactory.new(self, data.fetch('builds'))
    end

    def match?(name)
      name.nil? || repo && Regexp.new(name, Regexp::IGNORECASE).match?(repo)
    end

    def method_missing(method_name, *args)
      @data.fetch(method_name.to_s) { super }
    end

    def respond_to_missing?(method_name, *)
      @data.key?(method_name.to_s) || super
    end

    private

    attr_reader :organization

    def client
      organization.client
    end
  end
end
