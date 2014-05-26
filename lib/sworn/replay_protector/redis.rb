module Sworn
  module ReplayProtector
    class Redis
      def initialize(*args)
        options, _ = args.flatten
        @connection = options.fetch(:redis_connection)
      end

      def replayed?(oauth)
        key = nonce_key(oauth)

        return true if @connection.exists(key)
        @connection.setex(key, Sworn.configuration.max_drift, 1)

        false
      end

      private

      def nonce_key(oauth)
        timestamp = oauth.fetch(:timestamp)
        nonce     = oauth.fetch(:nonce)

        "nonce:#{timestamp}:#{nonce}"
      end
    end
  end
end
