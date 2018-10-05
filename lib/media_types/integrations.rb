# frozen_string_literal: true

module MediaTypes
  INTEGRATION_METHODS = %i[register].freeze

  module_function

  def integrate(integration)
    INTEGRATION_METHODS.each do |method|
      next unless integration.respond_to?(method)
      self.integrations = (integrations || {}).tap do |x|
        x.merge!(method => (x[method] || []).concat([integration]))
      end
    end
  end

  # @!method register(registerable)
  INTEGRATION_METHODS.each do |method|
    define_singleton_method method do |*args, &block|
      (integrations || {}).fetch(method) { [] }.each do |integration|
        integration.send(method, *args, &block)
      end
    end

  end

  class << self
    private

    attr_accessor :integrations
  end
end
