DEFAULT_CHAT_FRAME:AddMessage("Loading Parser.lua...")

function ThreatTrainer:ParseCombatLog(event, message)
    if not self.inCombat then return end
    if not message then return end
    
    local mobName, damage, healing
    
    if event == "CHAT_MSG_COMBAT_SELF_HITS" then
        _, _, mobName, damage = string.find(message, "You hit (.+) for (%d+)%.")
        if mobName and damage then
            self:AddThreat(mobName, self:CalculateDamageThreat(tonumber(damage)))
            return
        end
        
        _, _, mobName, damage = string.find(message, "You crit (.+) for (%d+)%.")
        if mobName and damage then
            self:AddThreat(mobName, self:CalculateDamageThreat(tonumber(damage)))
            return
        end
        
    elseif event == "CHAT_MSG_SPELL_SELF_DAMAGE" then
        local spell, target, dmg
        _, _, spell, target, dmg = string.find(message, "Your (.+) hits (.+) for (%d+)")
        if spell and target and dmg then
            self:AddThreat(target, self:CalculateAbilityThreat(spell, tonumber(dmg)))
            return
        end
        
        _, _, spell, target, dmg = string.find(message, "Your (.+) crits (.+) for (%d+)")
        if spell and target and dmg then
            self:AddThreat(target, self:CalculateAbilityThreat(spell, tonumber(dmg)))
            return
        end
        
        local target, spell
        _, _, target, spell = string.find(message, "(.+) is afflicted by (.+)%.")
        if target and spell then
            self:AddThreat(target, self:CalculateDamageThreat(1))
            return
        end
        
        _, _, target = string.find(message, "(.+) resists your")
        if target then
            self:AddThreat(target, 0)
            return
        end
        
    elseif event == "CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE" then
        local target, dmg
        _, _, target, dmg = string.find(message, "(.+) suffers (%d+) .+ damage from your")
        if target and dmg then
            self:AddThreat(target, self:CalculateDamageThreat(tonumber(dmg)))
            return
        end
        
    elseif event == "CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE" then
        local target, dmg
        _, _, target, dmg = string.find(message, "(.+) suffers (%d+) .+ damage from your")
        if target and dmg then
            self:AddThreat(target, self:CalculateDamageThreat(tonumber(dmg)))
            return
        end
        
    elseif event == "CHAT_MSG_SPELL_SELF_BUFF" or event == "CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS" then
        local buffName
        _, _, buffName = string.find(message, "You gain (.+)%.")
        
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
        
        local spell, heal
        _, _, spell, heal = string.find(message, "Your (.+) heals you for (%d+)%.")
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
        
        _, _, healing = string.find(message, "You gain (%d+) health from")
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
        local caster, spell, target, dmg
        _, _, caster, spell, target, dmg = string.find(message, "(.+)'s (.+) hits (.+) for (%d+)")
        
        if caster == playerName and target and dmg then
            self:AddThreat(target, self:CalculateDamageThreat(tonumber(dmg)))
            return
        end
        
    elseif event == "CHAT_MSG_SPELL_PARTY_BUFF" or event == "CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS" then
        local playerName = UnitName("player")
        
        local caster, spell, target, heal
        _, _, caster, spell, target, heal = string.find(message, "(.+)'s (.+) heals (.+) for (%d+)%.")
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
        
        _, _, caster, heal = string.find(message, "(.+) gains (%d+) health from your")
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
