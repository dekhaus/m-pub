require 'redis'
require 'multi_json'

class PubSubRedis < Redis

  def initialize(options = {})
    @timestamp = options[:timestamp].to_f || 0 # 0 means -- no backlog needed
    super
  end

  # Add each event to a Sorted Set with the timestamp as the score
  def publish(channel, message)
    timestamp = Time.now.to_f
    zadd(channel, timestamp, MultiJson.encode([channel, message]))
    super(channel, MultiJson.encode(message))
  end

  # returns the backlog of pending messages [ event, payload ] pairs
  # We do a union of sorted sets because we need to support wild-card channels.
  def backlog(channels, &block)
    return if @timestamp == 0

    # Collect the entire set of events with wild-card support.
    events = channels.collect {|e| keys(e)}.flatten

    return if not events or events.empty? # no events to process

    destination = "backlog-#{Time.now.to_f}"
    zunionstore(destination, events)
    # We want events only after the timestamp so add the (. This ensures that
    # an event with this timestamp will not be sent.
    # TODO: We may have a condition where, multiple events for the same timestamp
    # may be recorded but will be missed out because of the (.
    messages = zrangebyscore(destination, "(#{@timestamp.to_s}", "+inf")

    messages.each do |message|
      event, payload = MultiJson.decode(message)
      block.call(event, payload)
    end

    # cleanup
    del(destination)

  end
end