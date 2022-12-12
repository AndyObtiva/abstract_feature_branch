module AbstractFeatureBranch
  module Redis
    # Adapts a ConnectionPool instance to the Redis object interface
    class ConnectionPoolToRedisAdapter
      attr_reader :connection_pool
      
      def initialize(connection_pool)
        @connection_pool = connection_pool
      end
      
      def respond_to?(method_name, include_private = false, &block)
        result = false
        @connection_pool.with do |connection|
          result ||= connection.respond_to?(method_name, include_private, &block)
        end
        result || super
      end
      
      def method_missing(method_name, *args, &block)
        connection_can_respond_to = nil
        result = nil
        @connection_pool.with do |connection|
          connection_can_respond_to = connection.respond_to?(method_name, true)
          result = connection.send(method_name, *args, &block) if connection_can_respond_to
        end
        if connection_can_respond_to
          result
        else
          super
        end
      end
    end
  end
end
