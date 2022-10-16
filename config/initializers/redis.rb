module RedisPool
  class << self
    def get
      @redis_pool ||= ConnectionPool.new(size: 10) { Redis.new(Rails.application.config_for(:redis)) }
    end
  end
end
