module Sworn
  module ReplayProtector
    class Memory
      def initialize(*options)
        @store ||= Set.new
      end

      def replayed?(oauth)
        return true if @store.include?(oauth)
        @store << oauth
        false
      end
    end
  end
end
