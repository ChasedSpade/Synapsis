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

class ChannelManagement
    include Cinch::Plugin
    match /topic (.+)/, method: :topic
    match /kick (\S+) (.+)$/, method: :kick
    match /kickban (\S+) (.+)$/, method: :kickban
    match /ban (.+)/, method: :ban
    match /unban (.+)/, method: :unban
    match /voice (.+)/, method: :voice
    match /devoice (.+)/, method: :devoice
    
    def topic(m, sTopic)
        if Channel(m.channel).opped?(m.user)
            Channel(m.channel).topic = sTopic
        else
            m.reply "You do not have permission to run this command."
        end
    end

    def kick(m, target, reason)
        if Channel(m.channel).opped?(m.user) && Channel(m.channel).opped?(@bot.nick)
            if Channel(m.channel).has_user?(target)
                Channel(m.channel).kick(target, reason)
            else
                Target(m.user).notice "There is no user #{Format(:bold, target)} on #{Format(:bold, m.channel.name)}."
            end
        else
            m.reply "You do not have permission to run this command."
        end
    end

    def kickban(m, target, reason)
        if Channel(m.channel).opped?(m.user) && Channel(m.channel).opped?(@bot.nick)
            if Channel(m.channel).has_user?(target)
                Channel(m.channel).ban(target)
                Channel(m.channel).kick(target, reason)
            else
                Target(m.user).notice("There is no user #{Format(:bold, target)} on #{Format(:bold, m.channel.name)}")
            end
        else
            m.reply "You do not have permission to run this command."
        end
    end

    def ban(m, target)
        if Channel(m.channel).opped?(m.user) && Channel(m.channel).opped?(@bot.nick)
            Channel(m.channel).ban(target)
        else
            m.reply "You do not have permission to run this command."
        end
    end

    def unban(m, target)
        if Channel(m.channel).opped?(m.user) && Channel(m.channel).opped?(@bot.nick)
            Channel(m.channel).unban(target)
        else
            m.reply "You do not have permission to run this command."
        end
    end

    def voice(m, target)
        if Channel(m.channel).opped?(m.user) && Channel(m.channel).opped?(@bot.nick)
            if Channel(m.channel).has_user?(target)
                if Channel(m.channel).voiced?(target)
                    Target(m.user).notice "#{Format(:bold, User(target).nick)} is already voiced."
                else
                    Channel(m.channel).voice(target)
                end
            else
                m.reply "There is no user: #{Format(:bold, target)}"
            end
        else
            m.reply "You do not have permission to run this command."
        end
    end

    def devoice(m, target)
        if Channel(m.channel).opped?(m.user) && Channel(m.channel).opped?(@bot.nick)
            if Channel(m.channel).has_user?(target)
                if Channel(m.channel).voiced?(target)
                    Channel(m.channel).devoice(target)
                else
                    m.reply "#{Format(:bold, User(target).nick)} is not voiced."
                end
            else
                m.reply "There is no user: #{Format(:bold, target)}"
            end
        else
            m.reply "You do not have permission to run this command."
        end
    end
end
