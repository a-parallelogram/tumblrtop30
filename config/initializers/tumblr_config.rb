#Set Tumblr variables
Tumblr.configure do |config|
  config.consumer_key = ENV["key"]
  config.consumer_secret = ENV["secret"]
  config.oauth_token = ENV["oauth_token"]
  config.oauth_token_secret = ENV["oauth_token_secret"]
end