#!/usr/bin/env ruby

require 'fileutils'
require 'json'
require 'time'

CLAUDE_LOG_FILE = File.expand_path('~/.local/state/claude_code/claude-api.log')
TIME_LIMIT_SECONDS = 10 * 60

def parse_last_request_time
  return nil unless File.exist?(CLAUDE_LOG_FILE)
  
  begin
    File.foreach(CLAUDE_LOG_FILE).reverse_each do |line|
      json = JSON.parse(line) rescue next
      return Time.parse(json['timestamp']) if json.key?('timestamp')
    end
  rescue Errno::ENOENT
  end
  
  nil
end

def format_status(last_time)
  return '' unless last_time
  
  elapsed = Time.now - last_time
  return '' if elapsed > TIME_LIMIT_SECONDS
  
  if elapsed < 60
    "Claude: #{elapsed.to_i}s ago"
  else
    minutes = (elapsed / 60).to_i
    "Claude: #{minutes}m ago"
  end
end

last_time = parse_last_request_time
status = format_status(last_time)
puts status unless status.empty?