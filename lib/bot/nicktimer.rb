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

class Nicktimer
  include Cinch::Plugin
  listen_to :connect, method: :on_connect

  def on_connect
    Timer(90) {
      if @bot.nick != $config["bot"]["nick"]
        if User($config["bot"]["nick"]).unknown? == false
          Target('NickServ').send "GHOST #{$config["bot"]["nick"]} #{$config["bot"]["nickserv"]}"
          sleep 3
        end
        @bot.nick = $config["bot"]["nick"]
      end
    }
  end

end
