# frozen_string_literal: true

require 'spec_helper'
require 'build_factory'

describe Shiplight::BuildFactory do
  context '#each' do
    context 'without data' do
      it 'does not yield' do
        subject = described_class.new(nil, nil)
        expect { |b| subject.each(&b) }.not_to yield_control
      end
    end

    context 'with data' do
      let(:project) { double(:project) }
      let(:data) do
        [{ 'status' => 'error' }, { 'status' => 'success' }]
      end

      subject { described_class.new(project, data) }

      it 'yields input length times' do
        expect { |b| subject.each(&b) }
          .to yield_control.exactly(data.length).times
      end

      it 'yields builds' do
        subject.each { |b| expect(b).to be_a(Shiplight::Build) }
      end

      it 'passes project to build' do
        subject.each { |b| expect(b.project).to be(project) }
      end

      it 'passes data to build' do
        subject.each_with_index do |b, idx|
          expect(b.status).to be(data[idx]['status'])
        end
      end
    end
  end
end
