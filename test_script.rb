#!/bin/env ruby
require "net/http"
require "uri"
require "json"

if $0 == __FILE__
  if ARGV.size == 1
    uri = URI.parse(ARGV.first)
    begin
      response = Net::HTTP.get_response(uri)
      content = JSON.parse(response.body)
      if content.has_key? "docker" and content["docker"] == "working"
        puts "Working."
        exit true
      else
        puts "Test failed, content was #{content.inspect}"
        exit false
      end
    rescue Errno::ECONNREFUSED => e
      puts "Connection refused"
      exit false
    end
  else
    puts "Usage: ruby #{__FILE__} URL"
    exit false
  end
end
