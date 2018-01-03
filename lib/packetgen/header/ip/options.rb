# This file is part of PacketGen
# See https://github.com/sdaubert/packetgen for more informations
# Copyright (C) 2016 Sylvain Daubert <sylvain.daubert@laposte.net>
# This program is published under MIT license.

module PacketGen
  module Header
    class IP
      
      # Class to handle IP options
      # @author Sylvain Daubert
      class Options < Types::Array
        set_of Option
        
        HUMAN_SEPARATOR = ';'

        # Read IP header options from a string
        # @param [String] str binary string
        # @return [self]
        def read(str)
          clear
          return self if str.nil?
          PacketGen.force_binary str

          i = 0
          types = Option.types
          while i < str.to_s.length
            type = str[i, 1].unpack('C').first
            this_option = if types[type].nil?
                            Option.new
                          else
                            types[type].new
                          end
            this_option.read str[i, str.size]
            self << this_option
            i += this_option.sz
          end
          self
        end
      end
    end
  end
end
