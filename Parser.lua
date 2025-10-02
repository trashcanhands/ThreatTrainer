DEFAULT_CHAT_FRAME:AddMessage("Loading Parser.lua...")

function ThreatTrainer:ParseCombatLog(event, message)
    if not self.inCombat then return end
    if not message then return end
    
    local mobName, damage, healing
    
    if event == "CHAT_MSG_COMBAT_SELF_HITS" then
        mobName, damage = string.match(message, "You hit (.+) for (%d+)%.")
        if mobName and damage then
            self:AddThreat(mobName, self:CalculateDamageThreat(tonumber(damage)))
            return
        end
        
        mobName, damage = string.match(message, "You crit (.+) for (%d+)%.")
        if mobName and damage then
            self:AddThreat(mobName, self:CalculateDamageThreat(tonumber(damage)))
            return
        end
        
    elseif event == "CHAT_MSG_SPELL_SELF_DAMAGE" then
        local spell, target, dmg = string.match(message, "Your (.+) hits (.+) for (%d+)")
        if spell and target and dmg then
            self:AddThreat(target, self:CalculateAbilityThreat(spell, tonumber(dmg)))
            return
        end
        
        spell, target, dmg = string.match(message, "Your (.+) crits (.+) for (%d+)")
        if spell and target and dmg then
            self:AddThreat(target, self:CalculateAbilityThreat(spell, tonumber(dmg)))
            return
        end
        
        target, spell = string.match(message, "(.+) is afflicted by (.+)%.")
        if target and spell then
            self:AddThreat(target, self:CalculateDamageThreat(1))
            return
        end
        
        target = string.match(message, "(.+) resists your")
        if target then
            self:AddThreat(target, 0)
            return
        end
        
    elseif event == "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE" then
        local target, dmg = string.match(message, "(.+) suffers (%d+) .+ damage from your")
        if target and dmg then
            self:AddThreat(target, self:CalculateDamageThreat(tonumber(dmg)))
            return
        end
        
    elseif event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE" then
        local target, dmg = string.match(message, "(.+) suffers (%d+) .+ damage from your")
        if target and dmg then
            self:AddThreat(target, self:CalculateDamageThreat(tonumber(dmg)))
            return
        end
        
    elseif event == "CHAT_MSG_SPELL_SELF_BUFF" or event == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS" then
        local buffName = string.match(message, "You gain (.+)%.")
        
        if buffName then
            if buffName == "Power Word: Shield" then
                local numMobs = 0
                for mob, _ in pairs(self.activeMobs) do
                    numMobs = numMobs + 1
                end
                
                if numMobs > 0 then
                    local threatPerMob = 10 / numMobs
                    for mob, _ in pairs(self.activeMobs) do
                        self:AddThreat(mob, threatPerMob)
                    end
                end
                return
            end
            
            local fadeValues = {
                ["Fade"] = 150,
                ["Fade II"] = 240,
                ["Fade III"] = 380,
                ["Fade IV"] = 500,
                ["Fade V"] = 675,
                ["Fade VI"] = 800
            }
            
            if fadeValues[buffName] then
                local baseThreat = fadeValues[buffName]
                local modifier = self:GetThreatModifier()
                local actualReduction = baseThreat * modifier
                
                for mob, threat in pairs(self.myThreat) do
                    self.myThreat[mob] = math.max(0, threat - actualReduction)
                    self:BroadcastThreat(mob, self.myThreat[mob])
                end
                
                self:ShowThreatChange(-actualReduction)
                self:UpdateDisplay()
                return
            end
        end
        
        local spell, heal = string.match(message, "Your (.+) heals you for (%d+)%.")
        if spell and heal then
            local currentHP = UnitHealth("player")
            local maxHP = UnitHealthMax("player")
            local actualHeal = math.min(tonumber(heal), maxHP - currentHP)
            
            if actualHeal > 0 then
                local numMobs = 0
                for mob, _ in pairs(self.activeMobs) do
                    numMobs = numMobs + 1
                end
                
                if numMobs > 0 then
                    local threatPerMob = self:CalculateHealThreat(actualHeal) / numMobs
                    for mob, _ in pairs(self.activeMobs) do
                        self:AddThreat(mob, threatPerMob)
                    end
                end
            end
            return
        end
        
        healing = string.match(message, "You gain (%d+) health from")
        if healing then
            local currentHP = UnitHealth("player")
            local maxHP = UnitHealthMax("player")
            local actualHeal = math.min(tonumber(healing), maxHP - currentHP)
            
            if actualHeal > 0 then
                local numMobs = 0
                for mob, _ in pairs(self.activeMobs) do
                    numMobs = numMobs + 1
                end
                
                if numMobs > 0 then
                    local threatPerMob = self:CalculateHealThreat(actualHeal) / numMobs
                    for mob, _ in pairs(self.activeMobs) do
                        self:AddThreat(mob, threatPerMob)
                    end
                end
            end
            return
        end
        
    elseif event == "CHAT_MSG_SPELL_PARTY_DAMAGE" then
        local playerName = UnitName("player")
        local caster, spell, target, dmg = string.match(message, "(.+)'s (.+) hits (.+) for (%d+)")
        
        if caster == playerName and target and dmg then
            self:AddThreat(target, self:CalculateDamageThreat(tonumber(dmg)))
            return
        end
        
    elseif event == "CHAT_MSG_SPELL_PARTY_BUFF" or event == "CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS" then
        local playerName = UnitName("player")
        
        local caster, spell, target, heal = string.match(message, "(.+)'s (.+) heals (.+) for (%d+)%.")
        if caster == playerName and heal then
            local numMobs = 0
            for mob, _ in pairs(self.activeMobs) do
                numMobs = numMobs + 1
            end
            
            if numMobs > 0 then
                local threatPerMob = self:CalculateHealThreat(tonumber(heal)) / numMobs
                for mob, _ in pairs(self.activeMobs) do
                    self:AddThreat(mob, threatPerMob)
                end
            end
            return
        end
        
        caster, heal = string.match(message, "(.+) gains (%d+) health from your")
        if caster and heal then
            local numMobs = 0
            for mob, _ in pairs(self.activeMobs) do
                numMobs = numMobs + 1
            end
            
            if numMobs > 0 then
                local threatPerMob = self:CalculateHealThreat(tonumber(heal)) / numMobs
                for mob, _ in pairs(self.activeMobs) do
                    self:AddThreat(mob, threatPerMob)
                end
            end
            return
        end
    end
end