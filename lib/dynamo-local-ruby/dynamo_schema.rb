# Start dynamo DB local
module DynamoLocalRuby
  # Handle Dynamo Schemas
  class DynamoSchema
    DEFAULT_INDEX_PROJECTION = 'ALL'
    DEFAULT_CAPACITY = 10

    # DynamoTable
    class DynamoTableSpecError < RuntimeError; end

    class << self
      def register(model_class)
        @model_classes ||= []
        @model_classes << model_class
      end

      def provision_all(env_name, dynamo_client)
        # This guard clause is to help ensure that we don't accidentally create
        # staging or production tables from local machine. Provisioning those
        # should be done explicitly by Ops by commenting out this conditional
        return unless env_name == 'development'
        existing_tables = dynamo_client.list_tables.table_names
        @model_classes.each do |model_class|
          table_name = model_class.table_name
          next if existing_tables.include?(table_name)
          LOG.info("Provisioning dynamo table #{table_name}...")
          definition = dynamo_table_definition(table_name,
                                               model_class.table_spec)
          dynamo_client.create_table(definition)
        end
      end

      # Expand table hash definition into one compatible with
      # DynamoDB's table creation syntax.
      def dynamo_table_definition(table_name, table_spec)
        table_def = {}
        hash_key_schema = write_keys(table_def, table_spec[:keys])
        write_local_secondary(table_def, hash_key_schema,
                              table_spec[:local_secondary_indexes])
        table_def[:table_name] = table_name
        table_def[:provisioned_throughput] = {
          read_capacity_units: DEFAULT_CAPACITY,
          write_capacity_units: DEFAULT_CAPACITY
        }

        table_def
      end

      private

      def write_keys(table_def, key_spec)
        fail DynamoTableSpecError, 'Must provide keys' unless key_spec
        hash_key_schema = nil
        table_def[:attribute_definitions] ||= []
        table_def[:key_schema] ||= []
        key_spec.each do |key, spec|
          exp_spec = spec.merge(attribute_name: key)
          table_def[:attribute_definitions] << \
            exp_spec.select { |k, _| k != :key_type }
          schema = exp_spec.select { |k, _| k != :attribute_type }
          table_def[:key_schema] << schema
          hash_key_schema = schema if exp_spec[:key_type] == 'HASH'
        end

        hash_key_schema
      end

      def write_local_secondary(table_def, hash_key_schema,
                                local_secondary_indexes)
        return if local_secondary_indexes.nil?
        table_def[:attribute_definitions] ||= []
        table_def[:local_secondary_indexes] ||= []
        local_secondary_indexes.each do |key, spec|
          attrib = { attribute_name: key,
                     attribute_type: spec[:attribute_type] }
          table_def[:attribute_definitions] << attrib
          index = {
            index_name: "#{key}_index",
            key_schema: [hash_key_schema,
                         { attribute_name: key, key_type: 'RANGE' }],
            projection: { projection_type: DEFAULT_INDEX_PROJECTION }
          }
          table_def[:local_secondary_indexes] << index
        end
      end
    end
  end
end
