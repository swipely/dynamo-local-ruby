require 'spec_helper'

describe DynamoLocalRuby::DynamoSchema do
  describe '.dynamo_table_definition' do
    let(:table_spec) do
      {
        keys: {
          'guest_list_name' => { attribute_type: 'S', key_type: 'HASH' },
          'guest_id' => { attribute_type: 'S', key_type: 'RANGE' }
        },
        local_secondary_indexes: {
          'guest_score' => { attribute_type: 'N' }
        }
      }
    end

    let(:table_name) { 'test_table' }

    let(:expected_definition) do
      {
        attribute_definitions: [
          {
            attribute_name: 'guest_list_name',
            attribute_type: 'S'
          },
          {
            attribute_name: 'guest_id',
            attribute_type: 'S'
          },
          {
            attribute_name: 'guest_score',
            attribute_type: 'N'
          }
        ],
        table_name: table_name,
        key_schema: [
          {
            attribute_name: 'guest_list_name',
            key_type: 'HASH'
          },
          {
            attribute_name: 'guest_id',
            key_type: 'RANGE'
          }
        ],
        local_secondary_indexes: [
          {
            index_name: 'guest_score_index',
            key_schema: [
              {
                attribute_name: 'guest_list_name',
                key_type: 'HASH'
              },
              {
                attribute_name: 'guest_score',
                key_type: 'RANGE'
              }
            ],
            projection: {
              projection_type: 'ALL'
            }
          }
        ],
        provisioned_throughput: {
          read_capacity_units: 10,
          write_capacity_units: 10
        }
      }
    end

    it 'returns expected table definition given a table spec' do
      table_def = described_class.dynamo_table_definition(table_name,
                                                          table_spec)
      expect(table_def).to eq expected_definition
    end
  end
end
