# frozen_string_literal: true

require 'delegate'
require 'singleton'

require 'media_types/formatter'

module MediaTypes
  class Constructable < SimpleDelegator

    def initialize(klazz, **opts)
      super klazz
      self.opts = opts
    end

    def type(name = NO_ARG)
      return opts[:type] if name == NO_ARG
      with(type: name)
    end

    def version(version = NO_ARG)
      return opts[:version] if version == NO_ARG
      with(version: version)
    end

    def view(view = NO_ARG)
      return opts[:view] if view == NO_ARG
      with(view: view)
    end

    def suffix(suffix = NO_ARG)
      return opts[:suffix] if suffix == NO_ARG
      with(suffix: suffix)
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
      qualified(
        qualifier,
        Formatter.call(opts)
      )
    end

    def valid?(output, **validation_opts)
      __getobj__.valid?(
        output,
        self,
        **validation_opts
      )
    end

    def validate!(output, **validation_opts)
      __getobj__.validate!(
        output,
        self,
        **validation_opts
      )
    end

    def validatable?
      __getobj__.validatable?(self)
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
      merged_options = Kernel::Hash(opts).clone.tap do |cloned|
        cloned.merge!(more_opts)
      end

      Constructable.new(__getobj__, **merged_options)
    end

    def qualified(qualifier, media_type)
      return media_type unless qualifier
      format('%<media_type>s; q=%<q>s', media_type: media_type, q: qualifier)
    end
  end
end
