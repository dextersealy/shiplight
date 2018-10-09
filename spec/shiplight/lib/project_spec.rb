require 'spec_helper'
require 'project'

describe Shiplight::Project do
  let(:builds) { [{ 'id' => '1' }, { 'id' => '2' }] }
  let(:data) { { 'uuid' => '123', 'name' => 'abc', 'random' => 'value' } }
  let(:client) { double(:client) }
  let(:organization) { double(:organization, client: client, path: 'path') }

  before do
    allow(client).to receive(:get).with(
      "#{organization.path}/projects/#{data['uuid']}/builds"
    ).and_return('builds' => builds)
  end

  subject { described_class.new(organization, data) }

  context '#repo' do
    it 'returns name' do
      expect(subject.repo).to eq(data['name'])
    end
  end

  context '#builds' do
    it 'returns each build' do
      subject.builds.each_with_index do |build, idx|
        expect(build.id).to eq(builds[idx]['id'])
      end
    end

    it 'returns all builds' do
      expect(subject.builds.count).to be(builds.length)
    end

    it 'sets build\'s project' do
      subject.builds.each { |build| expect(build.project).to be(subject) }
    end
  end

  context '#method' do
    it 'returns corresponding data item' do
      data.each do |key, value|
        expect(subject.send(key.to_sym)).to eq(value)
      end
    end
  end

  context '#respond_to?' do
    it 'returns true for corresponding data items' do
      data.each_key do |key|
        expect(subject.respond_to?(key.to_sym)).to eq(true)
      end
    end
  end
end
