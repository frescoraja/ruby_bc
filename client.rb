require 'faraday'
require 'yaml'
require_relative 'user.rb'

URL = "http://localhost"
PORT = 4567

def create_user(name, password)
  Faraday.post("#{URL}:#{PORT}/users", login: name, password: password).body
end

def get_balance(user, password)
  Faraday.get("#{URL}:#{PORT}/balance", login: user, password: password).body
end

def transfer(from, password, to, amount)
  Faraday.post("#{URL}:#{PORT}/transfer", from: from, password: password, to: to, amount: amount).body
end
