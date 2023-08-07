# frozen_string_literal: true

module MediaTypes
  module Errors
    # Raised when trying to set a module key expectation twice
    class KeyExpectationSetError < StandardError
      def initialize(mod:)
        super(format('%<mod>s already has a key expectation set', mod: mod.name))
      end
    end

    # Raised when trying to set a module key expectation while default expectation already used
    class KeyExpectationUsedError < StandardError
      def initialize(mod:)
        super(format('Unable to change key type expectation for %<mod>s since its current expectation is already used', mod: mod.name))
      end
    end

    class CollectionDefinitionNotFound < StandardError
      def initialize(current, target)
        super(format('Unable to use %<target>s as a collection inside %<current>s, no such schema has been defined.', current: current, target: target))
      end
    end
  end
end
