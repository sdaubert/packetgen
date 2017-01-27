module PacketGen
  module Types

    # Class to handle Type-Length-Value attributes
    # == Subclasses
    # A subclass may defined a constant hash TYPES. This hash defined human readable
    # types versus their integer values. Hash keys are ineteger values, and hash values
    # are types as strings.
    #
    # If TYPES is defined, a subclass may:
    # * print human readable type using {#human_type},
    # * set type as String with {#type=}.
    # @author Sylvain Daubert
    class TLV < Fields
      # @!attribute type
      #  @return [Integer]
      define_field :type, Int8
      # @!attribute length
      #  @return [Integer]
      define_field :length, Int8
      # @!attribute value
      #  @return [String]
      define_field :value, String,
                   builder: ->(tlv) { String.new('', length_from: tlv[:length]) }

      # @param [Hash] options
      # @option options [Integer] :type
      # @option options [Integer] :length
      # @option options [String] :value
      # @option options [Class] :t {Int} subclass for +:type+ attribute.
      #   Default: {Int8}.
      # @option options [Class] :l {Int} subclass for +:length+ attribute.
      #   Default: {Int8}.
      def initialize(options={})
        super
        self[:type] = options[:t].new(type) if options[:t]
        if options[:l]
          self[:length] = options[:l].new(length)
          self[:value] = String.new('', length_from: self[:length])
        end
      end

      # @private
      alias old_type= type=

      # Set type
      # @param [::String,Integer] val
      # @return [Integer]
      # @raise [TypeError] class does not define TYPES
      # @raise [ArgumentError] unknown string type
      def type=(val)
        case val
        when Integer
          self.old_type = val
        else
          unless has_human_types?
            raise TypeError, "no human types defined for #{self.class}"
          end
          new_val = self.class::TYPES[val.to_s]
          raise ArgumentError, "unknown #{val.to_s} type" if new_val.nil?
          self.old_type = new_val
        end
      end

      # Return human readable type, if TYPES is defined
      # @return [String]
      def human_type
        if has_human_types?
          htype = self.class::TYPES[type]
          htype = type if htype.nil?
          htype.to_s
        else
          type.to_s
        end
      end

      # @return [String]
      def to_human
        name = self.class.to_s.gsub(/.*::/, '')
        @typestr ||= if has_human_types?
                       types = self.class::TYPES.values
                       "%-#{types.max { |a,b| a.length <=> b.length }.size}s"
                     else
                       "%s"
                     end
        @lenstr ||= "%-#{(2**(self[:length].width*8) - 1).to_s.size}u"
        "#{name} type:#@typestr length:#@lenstr value:#{value.inspect}" % [human_type,
                                                                           length]
      end

      private

      def has_human_types?
        self.class.const_defined? :TYPES
      end
    end
  end
end