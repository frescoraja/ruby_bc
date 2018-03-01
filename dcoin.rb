require_relative 'user.rb'
require_relative 'block.rb'
require 'yaml'
require 'thread_safe'
require 'ostruct'
require 'sinatra'
require 'colorize'
require 'optparse'
require 'byebug'

BALANCES = ThreadSafe::Hash.new
@god = nil
@block = nil

# @param user
get "/balance" do
  login, password = params.values_at("login", "password")
  if BALANCES[login]
    user = YAML.load(BALANCES[login][:user])
    if user.is_password?(password)
      balance = BALANCES[login][:balance]
      puts "#{login} has ∞#{sprintf('%.2f', balance)}".blue
      "#{login} - #{balance}"
    else
      puts "Password is not correct for user: #{login}".red
      "Password not correct for user: #{login}"
    end
  else
    "User: #{login} not found".red
    "User: #{login} not Found"
  end
end

# @param name
post "/users" do
  name, password = params.values_at("login", "password")
  if BALANCES[name]
    puts "username #{name} already taken".red
    "failed to create user: #{name}, already taken"
  else
    begin
      user = User.new(name, password)
      BALANCES[name] = { :user => YAML.dump(user), :balance => 0 }
      puts "created user #{name}".green
      "OK, created user #{name}"
    rescue StandardError => e
      e
    end
  end
end

# @param from
# @param password
# @param to
# @param amount
post "/transfer" do
  from, password, to = params.values_at("from", "password", "to")
  if BALANCES[from] && BALANCES[to]
    amount = params["amount"].to_f
    user = YAML.load(BALANCES[from][:user])
    if user.is_password?(password)
      if BALANCES[from][:balance] <= amount
        puts "#{from} does not have sufficient funds to cover amount: ∞#{amount}".red
        return "Not enough funds to cover #{amount} by user #{from}"
      end
      BALANCES[from][:balance] -= amount
      BALANCES[to][:balance] += amount
      puts "OK.".green
      puts "Transferred #{amount} dcoins from #{from} to #{to}"
    else
      puts "Password not correct for user: #{from}".red
    end
  else
    puts "User #{from} or user #{to} do not exist".red
  end
  str = BALANCES.map do |key, value|
    "#{key}: ∞#{sprintf('%.2f', value[:balance])}"
  end.join("\n")
  puts str.yellow
  BALANCES.map {|k,v| "#{k}: $#{sprintf('%.2f', v[:balance])}"}.join("  |  ")
end

def parse_options
  options = OpenStruct.new
  ARGV.each_cons(2) do |option, value|
    options[option] = value
  end
  # byebug

  options
end


def generate_god_user(options)
  @god = User.new(options.login, options.password)
end

def generate_blockchain(nonce)
  BALANCES[@god.login] = { user: YAML.dump(@god), balance: 1_000_000 }
  @block = Block.new(BALANCES, nonce)
end

if $PROGRAM_NAME == __FILE__
  options = parse_options
  generate_god_user(options)
  generate_blockchain(options.nonce)
end
