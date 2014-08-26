require "anki_auto_lookup/version"
require 'rest-client'
require 'open-uri'
require 'uri'
require 'CSV'

class AnkiAutoLookup
  attr_reader :english, :character, :pinyin, :audio_file_name, :temp_db
  
  @@english_url = 'https://translate.google.com/translate_a/single?client=t&sl=en&tl=zh-CN&hl=en&dt=bd&dt=ex&dt=ld&dt=md&dt=qc&dt=rw&dt=rm&dt=ss&dt=t&dt=at&dt=sw&ie=UTF-8&oe=UTF-8&oc=1&otf=2&rom=1&ssel=5&tsel=5&q='
  @@chinese_url = 'https://translate.google.com/translate_a/single?client=t&sl=zh-CN&tl=en&hl=en&dt=bd&dt=ex&dt=ld&dt=md&dt=qc&dt=rw&dt=rm&dt=ss&dt=t&dt=at&dt=sw&ie=UTF-8&oe=UTF-8&pc=1&oc=1&otf=1&ssel=0&tsel=0&q='
  @@match_google = /\p{Word}+\s*\p{Word}*\s*\p{Word}*\s*\p{Word}*\s*\p{Word}*\s*\p{Word}*\s*\p{Word}*\s*\p{Word}*\s*\p{Word}*\s*\p{Word}*\s*\p{Word}*\s*\p{Word}*/
  @@audio_url = 'https://translate.google.com/translate_tts?ie=UTF-8&q=<CHINESE_WORD>&tl=zh-CN&total=1&idx=0&textlen=6&client=t'
  
  def self.start
    puts "Would you like to type in the Chinese or the English word? c/e"
    self.new(gets.downcase =~ /c/ ? 'Chinese' : 'English')
  end
  
  def initialize(language)
    @language = language
    @temp_db = []
    get_and_process_input
  end
  
  def get_and_process_input
    puts "Type the #{@language} word you'd like to translate, or type 'q' to exit and save.\n"
    @word = gets.chomp
    quit_and_push if @word.downcase == 'q'
    @percent_encoded_word = URI::encode(@word)
    get_def_and_pinyin
  end
  
  def get_def_and_pinyin
    url = (@language == "Chinese") ? @@chinese_url : @@english_url
    raw_xhr = RestClient.get("#{url}#{@percent_encoded_word}", 'User-Agent' => 'Ruby')
    google_results_arr = raw_xhr.force_encoding("UTF-8").scan(@@match_google)
    parse_google_results(google_results_arr)
  end
  
  def parse_google_results(arr)
    @english = (@language == "Chinese") ? arr[0] : @word
    @character = (@language == "Chinese") ? @word : arr[0]
    @pinyin = arr[2]
    puts "#{arr[0]} #{@pinyin}"
    get_audio(URI::encode(@character))
  end
  
  def get_audio(percent_encoded_character)
    @percent_encoded_character = percent_encoded_character
    audio_url = @@audio_url.sub('<CHINESE_WORD>', @percent_encoded_character)
    sanitized_english_word = @english.gsub(' ', '_')
    File.open("#{sanitized_english_word}.mp3", "wb") do |file|
      file.print open(audio_url).read
    end
    @audio_file_name = "#{sanitized_english_word}.mp3"
    add_to_temp_db
  end
  
  def add_to_temp_db
    @temp_db << [@english, @character, @pinyin, @audio_file_name]
    get_and_process_input
  end
  
  def quit_and_push
    db = CSV.read('dictionary.txt')
    @temp_db.each { |entry| db << entry }
    CSV.open('dictionary.txt', 'w') do |csv|
      db.each { |line| csv << line }
    end
    puts "Good job today! Do you want to create a new Anki file to add to your deck? y/n"
    convert_to_anki if gets.downcase =~ /y/
  end
  
  def convert_to_anki
    dict = CSV.read('dictionary.txt')
    anki = File.open('anki.txt', 'w')
    dict.each do |row| 
      anki.puts "#{row[0]}\t#{row[1]}&nbsp;#{row[2]}&nbsp;[sound:#{row[3]}]"
    end
    anki.close
    exit
  end
end

AnkiAutoLookup.start