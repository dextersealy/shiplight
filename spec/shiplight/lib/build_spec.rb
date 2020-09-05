# frozen_string_literal: true

require 'spec_helper'
require 'build'

describe Shiplight::Build do
  let(:project) { double(:project, name: 'something') }
  let(:data) do
    {
      'username' => 'xyz',
      'status' => 'success',
      'branch' => 'master'
    }
  end

  subject { described_class.new(project, data) }

  context '#initialize' do
    it 'stores the project' do
      expect(subject.project).to be(project)
    end
  end

  context '#repo' do
    it 'returns the project name' do
      expect(subject.repo).to be(project.name)
    end
  end

  context '#user' do
    it 'returns username' do
      expect(subject.user).to eq(data['username'])
    end
  end

  context '#method' do
    it 'returns corresponding data items' do
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
