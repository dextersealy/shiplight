require 'spec_helper'
require 'project_factory'

describe Shiplight::ProjectFactory do
  let(:client) { double(:client) }

  context '#each' do
    subject { described_class.new(client, data) }

    context 'without data' do
      let(:data) { nil }

      it 'does not yield' do
        expect { |b| subject.each(&b) }.not_to yield_control
      end
    end

    context 'with data' do
      let(:data) do
        [
          { 'uuid' => '1', 'name' => 'A' },
          { 'uuid' => '2', 'name' => 'B' }
        ]
      end

      it 'yields {data}.length times' do
        expect { |b| subject.each(&b) }
          .to yield_control.exactly(data.length).times
      end

      it 'yields builds' do
        subject.each { |b| expect(b).to be_a(Shiplight::Project) }
      end

      it 'passes data to project' do
        subject.each_with_index do |b, idx|
          expect(b.name).to be(data[idx]['name'])
        end
      end
    end

    context 'with duplicate uuids' do
      let(:data) do
        [
          { 'uuid' => '1', 'name' => 'A' },
          { 'uuid' => '1', 'name' => 'B' }
        ]
      end

      it 'ignores duplicates' do
        expect { |b| subject.each(&b) }.to yield_control.once
      end

      it 'returns the first item' do
        subject.each { |b| expect(b.name).to be(data[0]['name']) }
      end
    end
  end
end
