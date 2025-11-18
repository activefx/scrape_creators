# frozen_string_literal: true

module ScrapeCreators
  # Utility methods for the ScrapeCreators gem
  module Util
    # Convert a string from camelCase to snake_case
    #
    # @param str [String] The string to convert
    # @return [String] The converted string
    #
    # @example
    #   Util.underscore("camelCase")  # => "camel_case"
    #   Util.underscore("someVeryLongName")  # => "some_very_long_name"
    def self.underscore(str)
      str.gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
         .gsub(/([a-z\d])([A-Z])/, '\1_\2')
         .downcase
    end

    # Recursively convert all keys in a hash from camelCase to snake_case
    #
    # @param value [Hash, Array, Object] The value to convert
    # @return [Hash, Array, Object] The value with converted keys
    #
    # @example
    #   Util.deep_transform_keys({ "firstName" => "John", "lastName" => "Doe" })
    #   # => { first_name: "John", last_name: "Doe" }
    #
    # @example With symbol keys
    #   Util.deep_transform_keys({ firstName: "John", lastName: "Doe" })
    #   # => { first_name: "John", last_name: "Doe" }
    def self.deep_transform_keys(value)
      case value
      when Hash
        value.each_with_object({}) do |(k, v), result|
          # Convert both string and symbol keys to snake_case symbols
          key_str = k.is_a?(Symbol) ? k.to_s : k.to_s
          new_key = underscore(key_str).to_sym
          result[new_key] = deep_transform_keys(v)
        end
      when Array
        value.map { |v| deep_transform_keys(v) }
      else
        value
      end
    end
  end
end
