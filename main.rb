#!/usr/bin/env ruby
# a fraternity house management application

require 'rubygems'
require 'sinatra' # ruby web framework
require 'omniauth' # ruby authorization gem
require 'omniauth-google-oauth2'
require 'mongo' # No-SQL database

include Mongo

# Connect to local MongoDB server
mongo_client = MongoClient.new('localhost', 27017)
mongo_db = mongo_client.db("sincity_db")
users_coll = mongo_db.collection("users")

configure do
  enable :sessions
end

# use google-oauth2 via Google's provided API key
use OmniAuth::Builder do
  provider :google_oauth2, '627491560710-078pmbbnlslccdnuaemg4kdbh857ahvb.apps.googleusercontent.com', '5JaYYqktXXztzBSBgui1R5aa'
end

# require user authentication for all pages
#?! ALLOW ONLY APPROVED EMAILS ###
before do
  if request.path_info != '/auth/google_oauth2/callback'
    redirect '/auth/google_oauth2' unless session[:uid]
  end
end

# index derp
get '/' do
  erb :index
end


#-> LOGIN SHIT <-#
get '/auth/google_oauth2/callback' do
  # this page is accessed after authentication
  # auth_hash is provided by Google
  auth_hash = env['omniauth.auth']
  
  session[:uid] = auth_hash['uid']
  
  session[:uid] = env['omniauth.auth']['uid']
  session[:email] = env['omniauth.auth']['info']['email']
  redirect '/'
end

get '/logout' do
  session[:uid] = nil
  redirect '/'
end

#-> ADMINISTRATION <-#

before '/admin' do
  #?! insert admin only shit
end

get '/admin' do
  erb :admin
end

get '/admin/accounts' do
  valid_emails = Array.new
  users_coll.find.each do |user|
    valid_emails.push(user["email"])
  end
  
  erb :accounts, :locals => {:valid_emails => valid_emails}
end

#-> STEWARD <-#

get '/steward' do
  erb :steward
end