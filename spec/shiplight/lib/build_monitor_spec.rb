require 'spec_helper'
require 'build_monitor'

class DummyClient
  def initialize(projects, countdown = 1)
    @countdown = countdown
    @projects = projects
  end

  def projects
    raise Interrupt if @countdown.zero?
    @countdown -= 1
    @projects
  end
end

describe Shiplight::BuildMonitor do
  let(:builds1) { [{ 'status' => nil, 'branch' => 'X', 'user' => 'a' }] }
  let(:builds2) { [{ 'status' => nil, 'branch' => 'Y', 'user' => 'b' }] }
  let(:builds3) { [{ 'status' => nil, 'branch' => 'Z', 'user' => 'c' }] }
  let(:projects) do
    [
      { 'uuid' => 1, 'repository_name' => 'A', 'builds' => builds1 },
      { 'uuid' => 2, 'repository_name' => 'B', 'builds' => builds2 },
      { 'uuid' => 3, 'repository_name' => 'C', 'builds' => builds3 }
    ]
  end
  let(:repeat_count) { 1 }
  let(:client) do
    DummyClient.new(Shiplight::ProjectFactory.new(projects), repeat_count)
  end
  let(:indicator) { double(:indicator) }
  let(:logger) { double(:logger) }

  before do
    allow(Shiplight::CodeshipClient).to receive(:new).and_return(client)
    allow(Shiplight::StatusIndicator).to receive(:new).and_return(indicator)
    allow(Logger).to receive(:new).and_return(logger)
    allow(indicator).to receive(:status=)
    allow(logger).to receive(:info)
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

    describe 'with \'testing\', \'error\' and \'success\' builds' do
      before do
        set(builds1 => 'error', builds2 => 'success', builds3 => 'testing')
      end

      include_examples :sets_the_status, 'testing'
    end

    describe 'with \'error\' and \'success\' builds' do
      before do
        set(builds1 => 'success', builds2 => 'success', builds3 => 'error')
      end

      include_examples :sets_the_status, 'error'
    end

    describe 'with \'success\' builds' do
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
