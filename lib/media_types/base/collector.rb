# frozen_string_literal: true

require 'delegate'

module MediaTypes
  class Base
    class Collector < SimpleDelegator

      def index(*args, **options)
        view(INDEX_VIEW, *args, **options)
      end

      def create(*args, **options, &block)
        view(CREATE_VIEW, *args, **options, &block)
      end

      def collection(*args, **options)
        view(COLLECTION_VIEW, *args, **options)
      end

      def view(view, *args, **options)
        register_type(*args, **options.merge(view: view))
      end

      def version(*args, **options, &block)
        register_version(*args, **options, &block)
      end

      private

      # This is similar to having a decorator / interface only exposing certain methods. In this private section
      #   the +register_type+ and +register_version+ methods are made available
      #

      def register_type(*args, **options, &block)
        __getobj__.instance_exec { register_type(*args, options, &block) }
      end

      def register_version(*args, **options, &block)
        __getobj__.instance_exec { register_version(*args, options, &block) }
      end
    end
  end
end
