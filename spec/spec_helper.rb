require 'roda'

Roda.plugin :container

# Namespace holding all objects created during specs
module Test
  def self.remove_constants
    constants.each(&method(:remove_const))
  end
end

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.after do
    Test.remove_constants
  end
end
