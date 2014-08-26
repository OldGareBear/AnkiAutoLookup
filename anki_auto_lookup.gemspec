# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'anki_auto_lookup/version'

Gem::Specification.new do |spec|
  spec.name          = "anki_auto_lookup"
  spec.version       = AnkiAutoLookup::VERSION
  spec.authors       = ["Gary Bethea"]
  spec.email         = ["betheagary@gmail.com"]

  spec.summary       = %q{anki_auto_lookup automatically translates English or Chinese words, downloads Chinese audio files, and generate Anki-compatible text files}

  spec.description   = %q{Anki_auto_lookup scrapes Google Translate. Whether you type in an English or Chinese word, it will find the definition, pinyin, and a recording of the Chinese word being spoken. Anki_auto_lookup stores all this information in a CSV text database for portability before creating a text file that can be uploaded to your Anki decks. The Anki deck's notes will have the English word on one side and the Chinese characters, pinyin, and recording on the other.}

  spec.homepage      = "https://github.com/OldGareBear/anki_auto_lookup"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.6"
  spec.add_development_dependency "rake"
end
