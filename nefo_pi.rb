#!/usr/bin/env ruby
# -*- encoding: utf-8 -*-
 
require 'yaml'
require 'ostruct'
require 'user_stream'
require 'twitter'

def ip
  `/sbin/ifconfig -a | grep -w inet |grep "192\|172" | cut -d ' ' -f2`
end
 
config_path = File.expand_path(File.dirname(__FILE__) + '/config.yml')
config = OpenStruct.new YAML.load_file(config_path)
 
UserStream.configure do |c|
  c.consumer_key = config.consumer_key
  c.consumer_secret = config.consumer_secret
  c.oauth_token = config.oauth_token
  c.oauth_token_secret = config.oauth_token_secret
end

Twitter.configure do |c|
  c.consumer_key = config.consumer_key
  c.consumer_secret = config.consumer_secret
  c.oauth_token = config.oauth_token
  c.oauth_token_secret = config.oauth_token_secret
end

client = UserStream.client

client.user do |status|
  if config.name == status.in_reply_to_screen_name
    unless status.user.nil?
      if config.targets.include? status.user.screen_name
        case status.text
        when %r(.*(ip|IP).*)
          Twitter.update "@#{status.user.screen_name} ほらよ つ #{ip}"
        end
      end
    end
  end
end
