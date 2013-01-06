Dir[File.dirname(__FILE__) + '/seh/*.rb'].each {|file| require file }

module Seh
  class << self
    # @note alias of {EventType::And}
    def and *types
      EventType::And.new *types
    end

    # @note alias of {EventType::Or}
    def or *types
      EventType::Or.new *types
    end

    # @note alias of {EventType::Not}
    def not type
      EventType::Not.new type
    end
  end
end
