require_relative 'project'

module Shiplight
  class ProjectFactory
    include Enumerable

    def initialize(data = nil)
      @data = data || []
    end

    def each
      uuids = []
      @data.each do |project|
        next if uuids.include?(project['uuid'])
        yield Project.new(project)
        uuids << project['uuid']
      end
    end
  end
end
