require_relative 'project'

class ProjectFactory
  include Enumerable

  def initialize(data)
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
