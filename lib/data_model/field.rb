module Moon
  module DataModel
    class Field
      class << self
        attr_accessor :type_validator
      end

      # @return [Array, Hash, Class] type
      attr_reader :type
      # @return [Proc, Object] default
      attr_reader :default
      # @return [Boolean] allow_nil  are nils allowed for the value?
      attr_reader :allow_nil
      # @return [Boolean] is_key  Is this a key field (such as an id)?
      attr_reader :is_key

      def initialize(options)
        @type      = options.fetch(:type)
        @default   = options.fetch(:default, nil)
        @allow_nil = options.fetch(:allow_nil, false)
        @is_key    = options.fetch(:is_key, false)
      end

      alias :is_key? :is_key

      def type_validator
        self.class.type_validator
      end

      def type_class(type = @type)
        if type.is_a?(Hash)
          Hash
        elsif type.is_a?(Array)
          Array
        else
          type
        end
      end

      def make_default(model = nil)
        @default.is_a?(Proc) ? @default.call(@type, model) : @default
      end

      def check_type(key, value, quiet = false)
        type_validator.check_type(@type, key, value,
                                  quiet: quiet,
                                  allow_nil: @allow_nil)
      end

      def run_validators(key, value, quiet)
      end

      def validate(key, value, quiet = false)
        check_type(key, value, quiet)
        run_validators(key, value, quiet)
      end

      alias :allow_nil? :allow_nil

      def self.default_proc
        lambda do |klass, _|
          case klass
          # if its a Array instance
          when Array then []
          # if its a Hash instance
          when Hash  then {}
          else
            # Integer, Numeric and Float cannot be created using .new
            if klass == Integer then 0
            elsif klass == Numeric then 0
            elsif klass == Float then 0.0
            else
              klass.new
            end
          end
        end
      end
    end
  end
end
