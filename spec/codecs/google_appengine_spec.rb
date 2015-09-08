require "logstash/devutils/rspec/spec_helper"
require "logstash/codecs/google_appengine"
require "logstash/event"
require "logstash/json"
require "insist"
require 'digest'

describe LogStash::Codecs::GoogleAppengine do
  subject do
    next LogStash::Codecs::GoogleAppengine.new
  end



context "#decode" do
  md5 = Digest::MD5.new

  it "should return an event from json data" do
    data = File.open("spec/codecs/appengine.logs.jsonl", "rb").read
    subject.decode(data) do |event|
      insist { event.is_a? LogStash::Event }
      insist { event["@type"] } == "type.googleapis.com/google.appengine.logging.v1.RequestLog"
    end
  end

  it "should merge the request payload with the reuest lines data" do
    data = File.open("spec/codecs/appengine.logs.jsonl", "rb").read
    collector = Array.new
    subject.decode(data) do |event|
      collector.push(event)
    end

    expect(collector.size).to eq(3)

    expect(collector[0]["message"]).to eq("IdentityFilter logUserIdentity: [[meta]] <anonymous:true>\n")
    expect(collector[0]["_id"]).to eq(md5.hexdigest collector[0]["requestId"] + "0")
    expect(collector[0]["time"]).to eq("2015-09-03T10:59:40.589Z")

    expect(collector[0]["@type"]).to be_nil

    expect(collector[1]["message"]).to eq("HttpOnlyFilter getSession: add additional Set-Cookie with httpOnly-flag for JSESSIONID\n")
    expect(collector[1]["_id"]).to eq(md5.hexdigest collector[1]["requestId"] + "1")
    expect(collector[1]["@type"]).to be_nil
    expect(collector[1]["time"]).to eq("2015-09-03T10:59:40.65Z")
  end

  it "should handle logs even when they have no lines" do

    data = File.open("spec/codecs/appengine.logs-without-lines.jsonl", "rb").read

    collector = Array.new

    subject.decode(data) do |event|
      collector.push(event)
    end

    expect(collector.size).to eq(1)

    expect(collector[0]["resource"]).to eq("/images/website/welcome/keyFeatures/objectives.jpg")
    expect(collector[0]["_id"]).to eq(md5.hexdigest  collector[0]["requestId"])
    expect(collector[0]["time"]).to eq(collector[0]["endTime"])
    expect(collector[0]["@type"]).to be_nil
  end

  it "falls not emit an event when it can't be parsed" do
    decoded = false
    subject.decode("something that isn't json") do |event|
      decoded = true
    end
    insist { decoded } == false
  end
end


end
