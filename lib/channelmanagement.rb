class ChannelManagement
    include Cinch::Plugin
    match /topic (.+)/, method: :topic
    match /kick (.+) (.+)/, method: :kick
    match /kickban (.+) (.+)/, method: :kickban
    match /ban (.+)/, method: :ban
    match /unban (.+)/, method: :unban
    match /voice (.+)/, method: :voice
    match /devoice (.+)/, method: :devoice

    def topic(m, topic)
        if permissions(m)
          Channel(m.channel).topic = topic
        end
      end

    def kick(m, target, reason)
      permissions(m)
      if Channel(m.channel).has_user?(target) == false
        Target(m.user).notice "There is no user #{Format(:bold, target)} on #{Format(:bold, m.channel.name)}."
        return false
      end
      Channel(m.channel).kick(target, reason + " (#{m.user.nick})")
      Target(m.user).notice "Kicked #{Format(:bold, "#{target}")} from #{Format(:bold, "#{m.channel}")}."
    end

    def kickban(m, target, reason)
      permissions(m)
      if Channel(m.channel).has_user?(target) == false
        Target(m.user).notice "There is no user #{Format(:bold, target)} on #{Format(:bold, m.channel.name)}."
        return false
      end
      Channel(m.channel).bans.each do |banmask, blah|
        if User(target).match(banmask)
          Channel(m.channel).kick(target, reason + " (#{m.user.nick})")
          Target(m.user).notice "Kicked #{Format(:bold, "#{target}")} from #{Format(:bold, "#{m.channel}")}."
        end
        return false
      end
      Channel(m.channel).ban("*!*@"+User(target).host)
      Channel(m.channel).kick(target, reason + " (#{m.user.nick})")
      Target(m.user).notice "Kickbanned #{Format(:bold, "#{target}")} from #{Format(:bold, "#{m.channel}")}."
    end

    def ban(m, target)
      permissions(m)
      if Channel(m.channel).has_user?(target) == false
        Target(m.user).notice "There is no user #{Format(:bold, target)} on #{Format(:bold, m.channel.name)}."
        return false
      end
      bancount = 0
      Channel(m.channel).bans.each do |banmask, blah|
        if User(target).match(banmask)
          bancount = bancount + 1
        end
      end
      if bancount != 0
        Target(m.user).notice "#{Format(:bold, "#{bancount}")} bans matching #{Format(:bold, "#{target}")} found on #{Format(:bold, "#{m.channel}")}."
        return false
      end
      Channel(m.channel).ban("*!*@"+User(target).host)
      Target(m.user).notice "Banned #{Format(:bold, "#{target}")} on #{Format(:bold, "#{m.channel}")}."
    end

    def unban(m, target)
      permissions(m)
      if Channel(m.channel).has_user?(target) == false
        if User(target).unknown?
          Target(m.user).notice "There is no user #{Format(:bold, target)}."
          return false
        end
      end
      bancount = 0
      Channel(m.channel).bans.each do |banmask, blah|
        if User(target).match(banmask)
          Channel(m.channel).unban(banmask)
          bancount = bancount + 1
        end
      end
      if bancount == 0
        Target(m.user).notice "#{Format(:bold, "#{bancount}")} bans matching #{Format(:bold, "#{target}")} on #{Format(:bold, "#{m.channel}")}."
        return false
      end
      if bancount != 0
        Target(m.user).notice "#{Format(:bold, "#{bancount}")} bans matching #{Format(:bold, "#{target}")} removed on #{Format(:bold, "#{m.channel}")}."
        return false
      end
    end

    def voice(m, target)
        permissions(m)
        if Channel(m.channel).has_user?(target) == false
          Target(m.user).notice "There is no user #{Format(:bold, target)} on #{Format(:bold, m.channel.name)}."
          return false
        end
        if Channel(m.channel).voiced?(target)
          Target(m.user).notice "#{Format(:bold, target)} is already voiced on #{Format(:bold, m.channel.name)}."
          return false
        end
        Channel(m.channel).voice(target)
        Target(m.user).notice "Voiced #{Format(:bold, "#{target}")} on #{Format(:bold, "#{m.channel}")}."
      end

    def devoice(m, target)
      permissions(m)
      if Channel(m.channel).has_user?(target) == false
        Target(m.user).notice "There is no user #{Format(:bold, target)} on #{Format(:bold, m.channel.name)}."
        return false
      end
      if Channel(m.channel).voiced?(target) == false
        Target(m.user).notice "#{Format(:bold, target)} does not have voice on #{Format(:bold, m.channel.name)}."
        return false
      end
      Channel(m.channel).devoice(target)
      Target(m.user).notice "Devoiced #{Format(:bold, "#{target}")} on #{Format(:bold, "#{m.channel}")}."
    end

#Helper Methods

    def permissions(m)
      if Channel(m.channel).opped?(m.user)
        if Channel(m.channel).opped?(bot.nick) or Channel(m.channel).half_opped?(bot.nick)
          return true
        else
          return false
        end
      else
        return false
      end
    end
end
