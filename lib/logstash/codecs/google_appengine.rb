# encoding: utf-8
require "logstash/codecs/base"
require "logstash/namespace"
require "logstash/codecs/json"

class LogStash::Codecs::GoogleAppengine < LogStash::Codecs::Base
  config_name "google_appengine"

  public

  def register
    @json = LogStash::Codecs::JSON.new
  end

  def decode(data)
    begin
      @json.decode(data) do |json|
        if is_parse_failure(json)
          return yield json
        end
        flatten(json).each { |flattenedJson|
          yield LogStash::Event.new(flattenedJson)
        }
      end
    rescue => e
      @logger.info("Failed to process data", :error => e, :data => data)
      yield LogStash::Event.new("message" => data, "tags" => ["_googleappengineparsefailure"])
    end
  end
end

private

def is_parse_failure(event)
  event["tags"] && event["tags"].include?("_jsonparsefailure")
end

def flatten(event)
  payload = event['protoPayload']
  lines = payload['line']
  if lines
    payload.delete('line')
    lines.map { |line| payload.merge(line) }
  else
    [payload]
  end
end
