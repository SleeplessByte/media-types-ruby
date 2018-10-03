# frozen_string_literal: true

require 'media_types/object'

module MediaTypes
  class Formatter < DelegateClass(Hash)

    class << self
      def call(*args, **options)
        new(*args, **options).call
      end
    end

    def call
      filtered_arguments = arguments
      return template if MediaTypes::Object.new(filtered_arguments).empty?

      format(rework_template(filtered_arguments), filtered_arguments)
    end

    private

    def template
      fetch(:format)
    end

    def rework_template(filtered_arguments)
      filtered_arguments.reduce(template) do |reworked, (key, value)|
        next reworked if MediaTypes::Object.new(value).present?
        start_of_template_variable = "%<#{key}>"

        # noinspection RubyBlockToMethodReference
        reworked.gsub("[\\.+](#{start_of_template_variable})") { start_of_template_variable }
      end
    end

    def format_view(view)
      MediaTypes::Object.new(view).present? && ".#{view}" || ''
    end

    def arguments
      # noinspection RubyBlockToMethodReference
      {
        version: self[:version],
        suffix: self[:suffix],
        type: self[:type],
        view: self[:view]
      }.select { |argument,| argument_present?(argument) }
    end

    def argument_present?(argument)
      template.include?("%<#{argument}>")
    end
  end
end
