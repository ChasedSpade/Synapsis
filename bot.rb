#!/usr/bin/env ruby

# Synapsis` Ruby IRC Bot
# Copyright (C) 2015  Chris Tyrrel

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.

$:.unshift File.dirname(__FILE__)

require 'cinch'
require 'rubygems'
require 'lib/channelmanagement'
require 'lib/administration'
require 'lib/minecraft'
require 'lib/events'

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
			c.plugins.plugins = [Events, Minecraft, ChannelManagement, Administration, SongOfTheMonth, Cinch::Plugins::Identify]
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
			c.port = server["port"]
			c.password = "Synapsis/Monitor:#{server["password"]}"
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
