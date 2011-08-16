#!/usr/bin/env ruby
# encoding: UTF-8

require 'bundler/setup'
require 'trollop'
require './lib/txtimpact_sms'

def prompt(string)
  STDOUT.sync = true
  print string
  res = gets
  STDOUT.sync = false
  res
end

def true_false_prompt(string)
  res = prompt(string + "(y/n)")
  res[0].downcase != "n"
end

def fail_with_message(msg)
  puts msg
  exit 1
end

opts = Trollop::options do
  opt :username, "The username to log in as", :type => :string
  opt :password, "The password to log in as", :type => :string
  opt :profile_id, "The profile_id to log in as", :type => :string
  opt :short_code, "The short_code to log in as", :type => :string
  opt :vasid, "The vasid to log in as", :type => :string
  opt :test_number, "The mobile number to test with", :type => :int
end

test_number = opts['test-number']

connection_opts = opts.dup
connection_opts.delete :test_number
connection_opts.delete :help

puts connection_opts.keys

connection = TxtImpact.new({
    :username => opts[:username],
    :password => opts[:password],
    :profile_id => opts['profile-id'],
    :short_code => opts['short-code'],
    :vasid => opts[:vasid]
})

puts "Testing sending a message"
msg = "test message #{Time.now}"
puts connection.send_sms(opts[:test_number], msg)

sms_working = true_false_prompt "Did a message with the text '#{msg}' get sent?"
fail_with_message "sending sms not working" unless sms_working

puts "Testing subscribing for more credits"

current_credits = prompt "Enter the number of available credits currently: "

puts connection.subscribe_credits(4)
puts "The next part doesn't work as the credit card isn't accepted"
subscribe_credits_working = true_false_prompt "Are there now #{current_credits.to_i + 4} credits available?"
fail_with_message "subscribe for more credits not working" unless subscribe_credits_working

puts "Testing keyword lookup api"
res = connection.is_keyword_available? "testing_keyword_34551"
fail_with_message "is_keyword_available? should have returned true" unless res


puts "Testing keyword registration api"
res = connection.register_keyword(
    :service_name => "Test service name",
    :keyword => 'test_keyword',
    :processor_url => 'http://example.com/processor',
    :help_msg => "help message",
    :stop_msg => "stop message"
)

res = true_false_prompt "Did a new keyword get registered with name 'test_keyword'"
fail_with_message "new keyword" unless res






