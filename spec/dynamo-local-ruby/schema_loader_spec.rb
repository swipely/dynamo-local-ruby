# encoding: utf-8
require 'spec_helper'

describe DynamoLocalRuby::SchemaLoader do
  before do
    stub_const('DynamoLocalRuby::DynamoDBLocal::PATH_TO_JAR', SPEC_JAR_DIR)
  end

  let(:dynamo_client) do
    endpoint = DynamoLocalRuby::DynamoDBLocal::ENDPOINT
    Aws::DynamoDB::Client.new(region: 'us-east-1', endpoint: endpoint)
  end

  subject { described_class.new(dynamo_client) }

  before(:each) do
    DynamoLocalRuby::DynamoDBLocal.up
    sleep(2) # remove once retries are enabled
  end

  after(:each) do
    DynamoLocalRuby::DynamoDBLocal.down
  end

  let(:table_name) { 'table_1' }
  let(:schema_definition) do
    {
      keys: { 'store_pretty_url' => { attribute_type: 'S', key_type: 'HASH' } }
    }
  end

  let(:test_schema) do
    {
      table_name => schema_definition
    }
  end

  describe '#load' do
    context 'table does not exist' do
      let(:expected_status) { 'ACTIVE' }

      it 'creates the table' do
        subject.load(test_schema)
        expect(subject.send(:load_table, table_name, schema_definition)).to \
          eq(expected_status)
      end
    end
  end
end
