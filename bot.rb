#!/usr/bin/env ruby

$:.unshift File.dirname(__FILE__)

require 'cinch'
require 'rubygems'
require 'lib/channelmanagement'

$config = YAML.load_file("config/config.yaml")
$bots = Hash.new
$zncs = Hash.new
$threads = Array.new

$config["servers"].each do |name, server|
	bot = Cinch::Bot.new do
		configure do |c|
			c.nick = $config["bot"]["nick"]
			c.server = server["server"]
			c.port = server["port"]
			c.user = $config["bot"]["user"]
			c.ssl.use = true
			c.sasl.username = $config["bot"]["nick"]
			c.sasl.password = $config["bot"]["nickserv"]
			c.channels = $config["bot"]["channels"]+server["channels"]
			c.plugins.plugins = [ChannelManagement, Cinch::Plugins::Identify]
			c.plugins.prefix = /^~/
			c.plugins.options[Cinch::Plugins::Identify] = {
				:password => "#{$config["bot"]["nickserv"]}",
				:type => :nickserv,
			}
		end
	end
	if $config["adminnet"] == name
		$adminbot = bot
	end
	$bots[name] = bot
end

$config["zncs"].each do |name, server|
	bot = Cinch::Bot.new do
		configure do |c|
			c.nick = $config["bot"]["nick"]
			c.server = server["server"]
			c.port = $config["bot"]["zncport"]
			c.password = "Synapsis/Monitor:#{$config["bot"]["zncpass"]}"
			c.ssl.use = true
			c.plugins.plugins = [ZNCCommands, ZNCEvents]
			c.plugins.prefix = /^%/
		end
	end
	$zncs[name] = bot
end


$bots.each do |key, bot|
	puts "Starting IRC connection for #{key}..."
	$threads << Thread.new { bot.start }
end

$zncs.each do |key, bot|
	puts "Starting ZNC connection for #{key}..."
	$threads << Thread.new { bot.start }
end

puts "Connected!"
sleep 5

$threads.each { |t| t.join }
