require 'spec_helper'
require 'build_monitor'

class MockOrganization
  def initialize(client, projects, countdown)
    @client = client
    @projects = projects
    @countdown = countdown
  end

  attr_reader :client

  def projects
    raise Interrupt if @countdown.zero?
    @countdown -= 1
    Shiplight::ProjectFactory.new(self, @projects)
  end

  def path
    'org_path'
  end
end

class MockClient
  def initialize(projects, countdown = 1)
    @organization = MockOrganization.new(self, projects, countdown)
    @projects = projects
  end

  attr_reader :organization

  def get(path)
    @projects.each do |project|
      if path == "#{organization.path}/projects/#{project['uuid']}/builds"
        break { 'builds' => project['builds'] }
      end
    end
  end
end

describe Shiplight::BuildMonitor do
  let(:builds1) { [{ 'status' => nil, 'branch' => 'X', 'user' => 'a' }] }
  let(:builds2) { [{ 'status' => nil, 'branch' => 'Y', 'user' => 'b' }] }
  let(:builds3) { [{ 'status' => nil, 'branch' => 'Z', 'user' => 'c' }] }
  let(:projects) do
    [
      { 'uuid' => 1, 'name' => 'A', 'builds' => builds1 },
      { 'uuid' => 2, 'name' => 'B', 'builds' => builds2 },
      { 'uuid' => 3, 'name' => 'C', 'builds' => builds3 }
    ]
  end
  let(:repeat_count) { 1 }
  let(:client) { MockClient.new(projects, repeat_count) }
  let(:indicator) { double(:indicator, status: nil) }
  let(:logger) { double(:logger, info: nil, '<<' => nil) }

  before do
    allow(Shiplight::CodeshipClient).to receive(:new).and_return(client)
    allow(Shiplight::StatusIndicator).to receive(:new).and_return(indicator)
    allow(Logger).to receive(:new).and_return(logger)
    allow(indicator).to receive(:status=)
  end

  def set(builds)
    builds.each { |build, status| build.first['status'] = status }
  end

  context '#run' do
    shared_examples :sets_the_status do |status|
      it "sets the status to '#{status}'" do
        expect(indicator).to receive(:status=).with(status)
        subject.run
      end
    end

    subject { described_class.new(interval: 0.1) }

    describe "with 'testing', 'error' and 'success' builds" do
      before do
        set(builds1 => 'error', builds2 => 'success', builds3 => 'testing')
      end

      include_examples :sets_the_status, 'testing'
    end

    describe "with 'error' and 'success' builds" do
      before do
        set(builds1 => 'success', builds2 => 'success', builds3 => 'error')
      end

      include_examples :sets_the_status, 'error'
    end

    describe "with 'success' builds" do
      before do
        set(builds1 => 'success', builds2 => 'success', builds3 => 'success')
      end

      include_examples :sets_the_status, 'success'
    end

    describe 'when not interrupted' do
      let(:repeat_count) { 3 }
      it 'sets the status periodically' do
        expect(indicator).to receive(:status=).exactly(repeat_count + 1).times
        subject.run
      end
    end
  end
end
