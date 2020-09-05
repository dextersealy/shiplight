# frozen_string_literal: true

require_relative 'build'

module Shiplight
  class BuildFactory
    include Enumerable

    def initialize(project, data)
      @data = data || []
      @project = project
    end

    def each
      @data.each do |build|
        yield Build.new(project, build)
      end
    end

    private

    attr_reader :project
  end
end
