module MediaTypes
  class Hash < SimpleDelegator
    def class
      __getobj__.class
    end

    def ===(other)
      __getobj__ === other # rubocop:disable Style/CaseEquality
    end

    def slice(*keep_keys)
      if __getobj__.respond_to?(:slice)
        return __getobj__.slice(*keep_keys)
      end

      h = {}
      keep_keys.each { |key| h[key] = fetch(key) if key?(key) }
      h
    end
  end
end
