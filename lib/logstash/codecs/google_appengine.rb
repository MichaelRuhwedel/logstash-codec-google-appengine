# encoding: utf-8
require "logstash/codecs/base"
require "logstash/namespace"
require "logstash/json"
require 'digest'

class LogStash::Codecs::GoogleAppengine < LogStash::Codecs::Base
  config_name "google_appengine"

  public

  def register
    @md5 = Digest::MD5.new
  end

  def decode(data)
    begin
      data = LogStash::Json.load(data)
      flatten(data).each { |flattenedJson|
        yield(LogStash::Event.new(flattenedJson))
      }
    rescue => e
      @logger.error "Failed to process data", :error => e, :data => data
    end
  end
end

private

def is_parse_failure(event)
  event["tags"] && event["tags"].include?("_jsonparsefailure")
end

def flatten(event)
  payload = event['protoPayload']
  payload.delete '@type'
  lines = payload.delete 'line'
  if lines
    lines.map.with_index { |line, i|
      merged = payload.merge line
      merged['_id'] = @md5.hexdigest merged['requestId'] + i.to_s
      merged['message'] = merged.delete 'logMessage'
      merged
    }
    [lines[0]]
  else
    payload['_id'] = @md5.hexdigest payload['requestId']
    payload['time'] = payload['endTime']
    [payload]
  end
end
