require_relative 'organization'

module Shiplight
  class OrganizationFactory
    include Enumerable

    def initialize(client, data = nil)
      @client = client
      @data = data || []
    end

    def each
      uuids = []
      @data.each do |organization|
        next if uuids.include?(organization['uuid'])
        yield Organization.new(@client, organization)
        uuids << organization['uuid']
      end
    end
  end
end
