require "http/web_socket"

module Wanda
  SOCKET_POOLS = WebSocketConnectionPools.new

  abstract class WebSocketConnection
    @stream_from = ""

    def initialize(@socket : HTTP::WebSocket, @env : HTTP::Server::Context)
      @socket.on_message do |message|
        self.received message
      end
      @socket.on_close do
        Wanda::SOCKET_POOLS.remove_connection_from_the_pool self.streamd_from, self
        self.disconnected
      end
    end

    def env
      @env
    end

    def stream_from(where : String)
      @stream_from = where
    end

    protected def streamed_from
      @stream_from
    end

    protected def reject
      @socket.close
    end

    def stop
      Wanda::SOCKET_POOLS.remove_connection_from_the_pool self.streamd_from, self
      @socket.close
    end

    def channel(name : String)
      Wanda::SOCKET_POOLS[name]
    end

    abstract def authorize

    macro authorized?
        authorize
    end

    
    abstract def connected
    abstract def received(message : String)

    def send_back(message : String)
      @socket.send(message)
    end

    def broadcast(message : String)
        Wanda::SOCKET_POOLS.broadcast_to(self.streamed_from, message)
    end

    abstract def disconnected
  end

  class WebSocketConnectionPools
    def initialize(@pools = {} of String => Array(Wanda::WebSocketConnection))
    end

    def add_connection_to_the_pool(name : String, connection : Wanda::WebSocketConnection)
      pool = @pools[name]?
      if pool
        pool << connection
      else
        @pools[name] = [connection]
      end
    end

    def remove_connection_from_the_pool(name : String, connection : Wanda::WebSocketConnection)
      pool = @pools[name]
      connection.stop
      pool.delete(connection)
      @pools.delete(name) if pool.empty?
    end

    def [](pool_name : String)
      @pools[pool_name]
    end

    def broadcast_to(pool_name : String, message : String)
      @pools[pool_name]?.try(&.each do |connection|
        connection.send_back message
      end)
    end
  end
end
