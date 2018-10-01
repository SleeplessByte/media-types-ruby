# frozen_string_literal: true

module MediaTypes
  class Object < SimpleDelegator
    def class
      __getobj__.class
    end

    def ===(other)
      __getobj__ === other # rubocop:disable Style/CaseEquality
    end

    def blank?
      if __getobj__.respond_to?(:blank?)
        return __getobj__.blank?
      end

      if __getobj__.respond_to?(:empty?)
        return __getobj__.empty?
      end

      if __getobj__.respond_to?(:length)
        return __getobj__.length.zero?
      end

      !__getobj__
    end

    alias empty? blank?

    def present?
      !blank?
    end
  end
end
