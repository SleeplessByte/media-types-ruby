# frozen_string_literal: true

require 'delegate'
require 'singleton'

module MediaTypes
  class ConstructableMimeType < SimpleDelegator

    def initialize(klazz, **opts)
      super klazz
      self.opts = opts
    end

    def type(name = NO_ARG)
      return opts[:type] if name == NO_ARG
      ConstructableMimeType.new(__getobj__, **with(type: name))
    end

    def version(version = NO_ARG)
      return opts[:version] if version == NO_ARG
      ConstructableMimeType.new(__getobj__, **with(version: version))
    end

    def view(view = NO_ARG)
      return opts[:view] if view == NO_ARG
      ConstructableMimeType.new(__getobj__, **with(view: view))
    end

    def suffix(suffix = NO_ARG)
      return opts[:suffix] if suffix == NO_ARG
      ConstructableMimeType.new(__getobj__, **with(suffix: suffix))
    end

    def collection
      view(COLLECTION_VIEW)
    end

    def collection?
      opts[:view] == COLLECTION_VIEW
    end

    def create
      view(CREATE_VIEW)
    end

    def create?
      opts[:view] == CREATE_VIEW
    end

    def index
      view(INDEX_VIEW)
    end

    def index?
      opts[:view] == INDEX_VIEW
    end

    def ===(other)
      to_str.send(:===, other)
    end

    def ==(other)
      to_str.send(:==, other)
    end

    def +(other)
      to_str + other
    end

    def split(pattern = nil, *limit)
      to_str.split(pattern, *limit)
    end

    def hash
      to_str.hash
    end

    def to_str(qualifier = nil)
      # TODO: remove warning by slicing out these arguments if they don't appear in the format
      qualified(qualifier, @to_str ||= format(
        opts.fetch(:format),
        version: opts.fetch(:version),
        suffix: opts.fetch(:suffix) { :json },
        type: opts.fetch(:type),
        view: format_view(opts[:view])
      ))
    end

    def valid?(output, **validation_opts)
      __getobj__.valid?(
        output,
        version: opts[:version],
        **validation_opts
      )
    end

    def validate!(output, **validation_opts)
      __getobj__.validate!(
        output,
        version: opts[:version],
        **validation_opts
      )
    end

    alias inspect to_str
    alias to_s to_str

    private

    class NoArgumentGiven
      include Singleton
    end

    NO_ARG = NoArgumentGiven.instance

    attr_accessor :opts

    def with(more_opts)
      Hash(opts).merge(more_opts).dup
    end

    def qualified(qualifier, media_type)
      return media_type unless qualifier
      format('%<media_type>s; q=%<q>s', media_type: media_type, q: qualifier)
    end

    def format_view(view)
      MediaTypes::Object.new(view).present? && ".#{view}" || ''
    end
  end
end
