require 'rack/cache'
require 'thread'

module Rack
  class CacheWhileRevalidate
    
    def initialize(app, debug = false)
      @app = app
      
      @queue = Queue.new
      
      Thread.new do
        while true
          begin
            env = @queue.pop
            @app.call(env)
          rescue Exception => e
            puts "e: #{e.inspect}"
          end
        end
      end
    end
    
    def call(env)
      
      cache = Rack::Capabilities.after(self)
      request = Rack::Cache::Request.new(env.dup)

      cache.instance_variable_set(:@request, request)
      
      if (request.get? || request.head?) && !env['HTTP_EXPECT'] && (entry = cache.metastore.lookup(request, cache.entitystore)) && cache.send(:fresh_enough?, entry)
        @queue << env
        entry.to_a
      else
        @app.call(env)
      end
      
    end
    
  end
end