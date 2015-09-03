# encoding: utf-8
require "logstash/codecs/base"
require "logstash/codecs/json_lines"

class LogStash::Codecs::GoogleAppengine < LogStash::Codecs::Base
  config_name "google_appengine"

  public

  def register
    @json_lines = LogStash::Codecs::JSONLines.new
  end

  def decode(data)
    @json_lines.decode(data) do |event|
      if is_parse_failure(event)
        return yield event
      end

      flatten(event).each { |flattenedEvent|
        yield LogStash::Event.new(flattenedEvent)
      }
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
  payload.delete('line')
  lines.map { |line| payload.merge(line) }
end
