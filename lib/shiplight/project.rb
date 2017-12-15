require_relative 'build_factory'

module Shiplight
  class Project
    def initialize(data)
      @data = data
    end

    def repo
      @data['repository_name']
    end

    def builds
      BuildFactory.new(self, @data['builds'])
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
  end
end
