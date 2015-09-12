Gem::Specification.new do |s|

  s.name = 'logstash-codec-google_appengine'
  s.version = '1.15.0'
  s.licenses = ['Apache License (2.0)']
  s.summary = "This codec may be used to decode via inputs appengine logs"
  s.description = "This gem is a logstash plugin required to be installed on top of the Logstash core pipeline using $LS_HOME/bin/plugin install gemname. This gem is not a stand-alone program"
  s.authors = ["Small Improvements"]
  s.email = 'mruhwedel@small-improvements.com'
  s.homepage = "https://github.com/MichaelRuhwedel/logstash-codec-google-appengine"
  s.require_paths = ["lib"]

  s.files = `git ls-files`.split($\)

  s.test_files = s.files.grep(%r{^(test|spec|features)/})

  s.metadata = {"logstash_plugin" => "true", "logstash_group" => "codec"}

  s.add_runtime_dependency "logstash-core", '>= 1.4.0', '< 2.0.0'

  s.add_development_dependency 'logstash-devutils'
end

