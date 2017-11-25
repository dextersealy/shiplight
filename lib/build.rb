class Build
  attr_reader :project

  def initialize(project, data)
    @project = project
    @data = data
  end

  def repo
    project ? project.repo : nil
  end

  def user
    @data['github_username']
  end

  def method_missing(method_name, *args)
    @data.fetch(method_name.to_s) { super }
  end

  def respond_to_missing?(method_name, *)
    @data.key?(method_name.to_s) || super
  end
end
