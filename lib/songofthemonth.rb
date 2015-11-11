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

class SongOfTheMonth
  include Cinch::Plugin

  match /artist (.+)/, method: :artist
  match /song (.+)/, method: :song
  match /month (.+)/, method: :month
  match /link (.+)/, method: :link
  match /check/, method: :check
  match /sotmset/, method: :set

  def artist(m, name)
    if permission(m)
      File.write("#{File.dirname(__FILE__)}/sotm/artist", name)
      m.reply "Artist set to #{name}."
    end
  end

  def song(m, name)
    if permission(m)
      File.write("#{File.dirname(__FILE__)}/sotm/song", name)
      m.reply "Song set to #{name}."
    end
  end

  def month(m, name)
    if permission(m)
      File.write("#{File.dirname(__FILE__)}/sotm/month", name)
      m.reply "Month set to #{name}."
    end
  end

  def link(m, name)
    if permission(m)
      File.write("#{File.dirname(__FILE__)}/sotm/link", name)
      m.reply "Link set to #{name}."
    end
  end

  def check(m)
    if permission(m)
      m.reply "#{Format(:purple, File.read("#{File.dirname(__FILE__)}/sotm/song"))} by #{Format(:purple, File.read("#{File.dirname(__FILE__)}/sotm/artist"))} (#{Format(:purple, File.read("#{File.dirname(__FILE__)}/sotm/link"))})."
    end
  end

  def set(m)
    if permission(m)
      $bots.each do |key, bott|
        bott.channels.each do |channel, blah|
          if channel == $config["mainchannel"]
            Channel(channel).topic = "Welcome to #{Format(:blue, "#{$config["mainchannel"]}")}. | #{Format(:blue, "#{$config["channelurl"]}")} | #{Format(:orange, "SOTM:")} #{Format(:orange, File.read("#{File.dirname(__FILE__)}/sotm/song"))} by #{Format(:orange, File.read("#{File.dirname(__FILE__)}/sotm/artist"))} (#{Format(:orange, File.read("#{File.dirname(__FILE__)}/sotm/link"))})"
          end
        end
      end
    end
  end

  # Private Methods

  def permission(m)
    if User(m.user).authname == $config["ownernickserv"]
      return true
    else
      Target(m.user).notice "You do not have permission to run this command."
      return false
    end
  end

end
