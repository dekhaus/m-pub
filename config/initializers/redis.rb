uri = URI.parse(ENV["REDISTOGO_URL"])
REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
REDIS_PUB = PubSubRedis.new(:host => uri.host, :port => uri.port, :password => uri.password)