# encoding: utf-8
# Start dynamo DB local
module DynamoLocalRuby
  # Wrapper around Dynamo DB local process
  class DynamoDBLocal
    PORT = 9389
    ENDPOINT = "http://localhost:#{PORT}"

    PATH_TO_JAR = '../../../lib/jars/dynamodb_local'

    RETRIES = 5

    def initialize(pid)
      @pid = pid
    end

    class << self
      def up
        local_path = File.expand_path(PATH_TO_JAR, __FILE__)
        lib_path = File.join(local_path, 'DynamoDBLocal_lib')
        jar_path = File.join(local_path, 'DynamoDBLocal.jar')
        pid = spawn("java -Djava.library.path=#{lib_path} -jar #{jar_path} "\
                    "-sharedDb -inMemory -port #{PORT}")
        @instance = DynamoDBLocal.new(pid)
        at_exit { teardown(pid) }

        test_connection

        @instance
      end

      def down
        @instance.down if defined? @instance
      end

      def test_connection
        RETRIES.times do
          begin
            Net::HTTP.get_response(URI.parse(ENDPOINT))
            break
          rescue Errno::ECONNREFUSED
            sleep(0.5)
          end
        end
      end

      def teardown(pid)
        Process.kill('SIGINT', pid)
        Process.waitpid2(pid)
      rescue Errno::ESRCH
        nil
      end
    end

    def down
      return unless @pid
      self.class.teardown(@pid)
      @pid = nil
    end
  end
end
