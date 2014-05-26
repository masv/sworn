module Sworn
  module ReplayProtector
    class Custom
      def initialize(*options)
        @evaluator, _ = options.flatten
      end

      def replayed?(oauth)
        @evaluator.call(oauth)
      end
    end
  end
end
