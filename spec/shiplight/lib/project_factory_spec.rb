require 'spec_helper'
require 'project_factory'

describe Shiplight::ProjectFactory do
  context '#each' do
    context 'without data' do
      it 'does not yield' do
        subject = described_class.new(nil)
        expect { |b| subject.each(&b) }.not_to yield_control
      end
    end

    context 'with data' do
      let(:data) do
        [
          { 'uuid' => '1', 'repository_name' => 'A' },
          { 'uuid' => '2', 'repository_name' => 'B' }
        ]
      end

      subject { described_class.new(data) }

      it 'yields {data}.length times' do
        expect { |b| subject.each(&b) }
          .to yield_control.exactly(data.length).times
      end

      it 'yields builds' do
        subject.each { |b| expect(b).to be_a(Shiplight::Project) }
      end

      it 'passes data to project' do
        subject.each_with_index do |b, idx|
          expect(b.repo).to be(data[idx]['repository_name'])
        end
      end
    end

    context 'with duplicate uuids' do
      let(:data) do
        [
          { 'uuid' => '1', 'repository_name' => 'A' },
          { 'uuid' => '1', 'repository_name' => 'B' }
        ]
      end

      subject { described_class.new(data) }

      it 'ignores duplicates' do
        expect { |b| subject.each(&b) }.to yield_control.once
      end

      it 'returns the first item' do
        subject.each { |b| expect(b.repo).to be(data[0]['repository_name']) }
      end
    end
  end
end
