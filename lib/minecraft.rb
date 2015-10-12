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

class Minecraft
  include Cinch::Plugin
  match /breed (.+)/, method: :breed

  def breed(m, animal)
    if animal =~ /[Cc][Hh][Aa][Ss][Ee][Dd][Ss][Pp][Aa][Dd][Ee]/
      Channel(m.channel).kick(m.user, "Bad.")
      return false
    end

    if animal !~ /horse|sheep|cow|mooshroom|pig|chicken|wolf|ocelot|rabbit/
      m.reply "Invalid animal: #{Format(:bold, "#{animal}")}"
      return false
    end

    m.reply "#{Format(:bold, m.user.nick)}: Breeding timer for #{Format(:bold, "#{animal}")} has been created."
    Timer(300, options = {:shots => 1}) {m.reply "#{Format(:bold, m.user.nick)}: You can now rebreed your #{Format(:bold, "#{animal}")}."}
    Timer(1200, options = {:shots => 1}) {m.reply "#{Format(:bold, m.user.nick)}: Your #{Format(:bold, "#{animal}")} is now fully grown."}
  end
end
