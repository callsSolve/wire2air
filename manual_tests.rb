#!/usr/bin/env ruby
# encoding: UTF-8

require 'bundler/setup'
require 'trollop'
require './lib/wire2air'
require 'rspec'


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

def test_section(section_name)
  puts "testing #{section_name}"
  res = yield
  if res
    puts "#{section_name} working correctly"
  else
    puts "FAILED: #{section_name}"
    exit 1
  end
end

opts = Trollop::options do
  opt :username, "The username to log in as", :type => :string, :required => true
  opt :password, "The password to log in as", :type => :string, :required => true
  opt :profile_id, "The profile_id to log in as", :type => :string, :required => true
  opt :short_code, "The short_code to log in as", :type => :string, :required => true
  opt :vasid, "The vasid to log in as", :type => :string, :required => true
  opt :test_number, "The mobile number to test with", :type => :string, :required => true

  opt :dont_test_sending_sms, "Prevent the sending of sms from being tested"
end



connection_opts = opts.dup

connection_opts = { :username => opts[:username], :password => opts[:password],
                    :profile_id => opts[:profile_id], :short_code => opts[:short_code],
                    :vasid => opts[:vasid]
}
connection  = Wire2Air.new connection_opts

describe "sms api" do
  unless opts[:dont_test_sending_sms]
    it "should send a single sms message" do
      msg = "test message #{Time.now}"
      puts connection.send_sms(opts[:test_number], msg)

     true_false_prompt("Did a message with the text '#{msg}' get sent?").should be_true
    end
  end


  it 'can add more credits to the account' do
    current_credits = prompt "Enter the number of available credits currently: "

    puts connection.subscribe_credits(4)
    true_false_prompt("Are there now #{current_credits.to_i + 4} credits available?").should be_true
  end

  it 'can find if a keyword is available' do
    connection.is_keyword_available?("testing_keyword_34551").should be_true
  end

  it "can register a keyword and unregister a keyword" do
    service_name = "A service name"
    service_keyword = 'testing_keyword'
    service_id = connection.register_keyword(
        :service_name => service_name,
        :keyword => service_keyword,
        :processor_url => 'http://example.com/processor',
        :help_msg => "help message",
        :stop_msg => "stop message"
    )

    true_false_prompt("Did a new service get registered with name '#{service_name}'").should be_true
    connection.delete_service(service_id, service_keyword)
    true_false_prompt("Did the service '#{service_name}' get deleted?").should be_true


  end
end








