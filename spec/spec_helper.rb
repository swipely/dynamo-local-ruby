$LOAD_PATH << File.join(File.dirname(__FILE__), '..', 'lib')
FIXTURES_PATH = File.join(File.dirname(__FILE__), 'fixtures')

require 'dynamo-local-ruby'
require 'pry'

# Load rspec support files
Dir['./spec/support/**/*.rb'].sort.each { |f| require f }

RSpec.configure do |config|
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  if ENV['PRY_RESCUE_RSPEC'] == 'true'
    config.around(:each) do |example|
      Pry.rescue do
        err = example.run
        pending = err.is_a?(RSpec::Core::Pending::PendingExampleFixedError)
        Pry.rescued(err) if err && !pending && $stdin.tty? && $stdout.tty?
      end
    end
  end
end

def fixture_each_line(fixture_name)
  fixture_file = File.join(FIXTURES_PATH, fixture_name)
  File.readlines(fixture_file).each { |line| yield line if block_given? }
end
