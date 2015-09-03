require "logstash/devutils/rspec/spec_helper"
require "logstash/codecs/google-appengine"
require "logstash/event"
require "logstash/json"
require "insist"

describe LogStash::Codecs::GoogleAppengine do
  subject do
    next LogStash::Codecs::GoogleAppengine.new
  end

  data = File.open("spec/codecs/appengine.logs.jsonl", "rb").read

  context "#decode" do
    it "should return an event from json data" do
      subject.decode(data) do |event|
        insist { event.is_a? LogStash::Event }
        insist { event["@type"] } == "type.googleapis.com/google.appengine.logging.v1.RequestLog"
      end
    end

    it "should merge the request payload with the reuest lines data" do
      collector = Array.new
      subject.decode(data) do |event|
        collector.push(event)
      end

      expect(collector.size).to eq(3)

      expect(collector[0]["@type"]).to eq("type.googleapis.com/google.appengine.logging.v1.RequestLog")
      expect(collector[0]["logMessage"]).to eq("IdentityFilter logUserIdentity: [[meta]] <anonymous:true>\n")

      expect(collector[1]["@type"]).to eq("type.googleapis.com/google.appengine.logging.v1.RequestLog")
      expect(collector[1]["logMessage"]).to eq("HttpOnlyFilter getSession: add additional Set-Cookie with httpOnly-flag for JSESSIONID\n")
    end
  end

  it "falls back to plain text" do
    decoded = false
    subject.decode("something that isn't json\n") do |event|
      decoded = true
      insist { event.is_a? LogStash::Event }
      insist { event["message"] } == "something that isn't json"
      insist { event["tags"] }.include?("_jsonparsefailure")
    end
    insist { decoded } == true
  end
end
