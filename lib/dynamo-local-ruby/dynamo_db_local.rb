# encoding: utf-8
# Start dynamo DB local
module DynamoLocalRuby
  # Wrapper around Dynamo DB local process
  class DynamoDBLocal
    PORT = 9389

    def initialize(pid)
      @pid = pid
    end

    class << self
      def endpoint(port = PORT)
        "http://localhost:#{port}"
      end

      def up(port = PORT)
        local_path = File.expand_path('../../../lib/jars/dynamodb_local',
                                      __FILE__)
        lib_path = File.join(local_path, 'DynamoDBLocal_lib')
        jar_path = File.join(local_path, 'DynamoDBLocal.jar')
        pid = spawn("java -Djava.library.path=#{lib_path} -jar #{jar_path} "\
                    "-sharedDb -inMemory -port #{port}")
        @instance = DynamoDBLocal.new(pid)

        @instance
      end

      def down
        @instance.down if defined? @instance
      end
    end

    # rubocop:disable HandleExceptions
    def down
      return unless @pid
      begin
        Process.kill('SIGINT', @pid)
        Process.waitpid2(@pid)
      rescue Errno::ECHILD, Errno::ESRCH
        # child process is dead
      end
      @pid = nil
    end
    # rubocop:enable HandleExceptions
  end
end
