# encoding: utf-8
require 'spec_helper'

describe DynamoLocalRuby::DynamoDBLocal do
  let(:dynamo_instance) { described_class.up }

  describe '.up' do
    before do
      stub_const("#{described_class}::PATH_TO_JAR", SPEC_JAR_DIR)
    end

    after(:each) do
      described_class.down
    end

    context 'local db comes up' do
      it 'returns instance' do
        expect(dynamo_instance).to be_a(described_class)
      end

      it 'is running' do
        pid = dynamo_instance.instance_variable_get('@pid')
        expect { Process.getpgid(pid) }.to_not raise_error
      end

      let(:uri) { URI.parse(described_class::ENDPOINT) }
      let(:response) { Net::HTTP.get_response(uri) }

      it 'responds to requests' do
        # I'd like this to be in a before block but couldn't get it working
        dynamo_instance
        sleep(2) # remove this once retry is enabled
        expect { response }.to_not raise_error
      end
    end
  end

  describe '.down' do
    it 'kills the instance' do
      pid = dynamo_instance.instance_variable_get('@pid')
      dynamo_instance.down
      expect(dynamo_instance.instance_variable_get('@pid')).to be_nil
      expect { Process.getpgid(pid) }.to raise_error(Errno::ESRCH)
    end
  end
end
