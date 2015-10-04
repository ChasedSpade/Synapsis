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

class Administration
  include Cinch::Plugin
	match /[Dd][Ii][Ee]/, method: :die
  match /[Ss][Aa][Yy] (#\S+) (.+)/, method: :say
  match /[Aa][Cc][Tt] (#\S+) (.+)/, method: :act
  match /[Jj][Oo][Ii][Nn] (#\S+)/, method: :join
  match /[Pp][Aa][Rr][Tt] (#\S+)/, method: :part
  match /[Nn][Ii][Cc][Kk] (.+)/, method: :nick
  match /[Mm][Ss][Gg] (\S+) (.+)/, method: :msg

  def die(m)
    if permission(m)
      $bots.each do |key, bot|
        puts "Terminating IRC connection for #{key}..."
        adminchan(m, "#{Format(:red, "SHUTDOWN:")} #{Format(:orange, bot.irc.network.name.to_s)}")
        bot.quit "Shutdown requested."
      end

      $zncs.each do |key, bot|
        puts "Terminating ZNC connection for #{key}..."
        bot.quit
      end
    end
  end

  def say(m, channel, message)
    if permission(m) == true
      @bot.channels.each do |channeln, blah|
        if channeln == channel
          Channel(channel).send (message)
          return false
        end
      end

      Target(m.user).notice "#{Format(:bold, @bot.nick)} is not on #{Format(:bold, channel)}."
    end
  end

  def act(m, channel, message)
    if permission(m) == true
      @bot.channels.each do |channeln, blah|
        if channeln == channel
          Channel(channel).action (message)
          return false
        end
      end

      Target(m.user).notice "#{Format(:bold, @bot.nick)} is not on #{Format(:bold, channel)}."
    end
  end

  def msg(m, target, msg)
    if permission(m)
      Target(target).send "#{msg}"
    end
  end

  def nick(m, nicke)
    if permission(m)
      $bots.each do |key, bot|
        bot.nick = nicke
      end
    end
  end

  def join(m, chan)
    if permission(m)
      Channel(chan).join
    end
  end

  def part(m, chan)
    if permission(m)
      Channel(chan).part
    end
  end

	# Private Methods
  def adminchan(m, message)
    $adminbot.irc.send "PRIVMSG #{$config["adminchannel"]} :#{message}"
  end

  def permission(m)
    if User(m.user).authname == $config["ownernickserv"]
      return true
    else
      Target(m.user).notice "You do not have permission to run this command."
      return false
    end
  end

end
