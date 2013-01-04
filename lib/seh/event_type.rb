module Seh
  class EventType
    attr_reader :type

    def initialize type
      @type = type
    end

    # @param types - an Array of types
    def match types
      types.include? self.type
    end

    class And < EventType
      def initialize *types
        @types = []
        types.each { |t| t = EventType.new t unless t.kind_of? EventType ; @types << t }
      end

      def match types
        @types.each { |t| return false unless t.match types }
        true
      end
    end # And

    class Or < EventType
      def initialize *types
        @types = []
        types.each { |t| t = EventType.new t unless t.kind_of? EventType ; @types << t }
      end

      def match types
        @types.each { |t| return true if t.match types }
        false
      end
    end # Or

    class Not < EventType
      def initialize type
        type = EventType.new type unless type.kind_of? EventType
        @type = type
      end

      def match types
        ! @type.match types
      end
    end # Not
  end # EventType
end
