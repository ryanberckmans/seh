module Seh
  class EventType
    attr_accessor :type

    def initialize( type )
      @type = type
    end

    def match(types)
      types = [types] unless types.respond_to? :each
      _match types
    end

    private
    def _match(types)
      types.each { |t| return true if t == self.type }
      false
    end

    class And < EventType
      def initialize(*types)
        @types = []
        types.each { |t| t = EventType.new t unless t.kind_of? EventType ; @types << t }
      end

      private
      def _match(types)
        @types.each { |t| return false unless t.match types }
        true
      end
    end # And

    class Or < EventType
      def initialize(*types)
        @types = []
        types.each { |t| t = EventType.new t unless t.kind_of? EventType ; @types << t }
      end

      private
      def _match(types)
        @types.each { |t| return true if t.match types }
        false
      end
    end # Or

    class Not < EventType
      def initialize(type)
        type = EventType.new type unless type.kind_of? EventType
        @type = type
      end

      private
      def _match(types)
        ! @type.match types
      end
    end # Not
  end # EventType
end
