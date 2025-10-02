DEFAULT_CHAT_FRAME:AddMessage("Loading Calculator.lua...")

function ThreatTrainer:GetThreatModifier()
    local _, classEnglish = UnitClass("player")
    local modifier = 1.0
    
    if classEnglish == "WARRIOR" then
        local stance = 0
        local numForms = GetNumShapeshiftForms()
        
        for i = 1, numForms do
            local _, name, active = GetShapeshiftFormInfo(i)
            if active then
                stance = i
                break
            end
        end
        
        if stance == 2 then
            modifier = 1.3
            
            local _, _, _, _, rank = GetTalentInfo(3, 9)
            if rank and rank > 0 then
                modifier = modifier * (1.0 + (rank * 0.03))
            end
        elseif stance == 1 or stance == 3 then
            modifier = 0.8
        end
        
    elseif classEnglish == "PRIEST" then
        local _, _, _, _, silentResolve = GetTalentInfo(1, 11)
        if silentResolve and silentResolve > 0 then
            modifier = modifier * (1.0 - (silentResolve * 0.04))
        end
    end
    
    return modifier
end

function ThreatTrainer:CalculateDamageThreat(damage)
    local modifier = self:GetThreatModifier()
    return damage * modifier
end

function ThreatTrainer:CalculateHealThreat(healing)
    local modifier = self:GetThreatModifier()
    local baseThreat = healing * 0.5
    return baseThreat * modifier
end

function ThreatTrainer:CalculateAbilityThreat(abilityName, damage)
    local baseThreat = damage or 0
    local modifier = self:GetThreatModifier()
    
    local fixedThreat = 0
    
    if abilityName == "Sunder Armor" then
        fixedThreat = 260
    elseif abilityName == "Heroic Strike" then
        fixedThreat = 145
    elseif abilityName == "Revenge" then
        fixedThreat = 315
    elseif abilityName == "Shield Bash" then
        fixedThreat = 180
    elseif abilityName == "Shield Slam" then
        fixedThreat = 250
    elseif abilityName == "Battle Shout" then
        fixedThreat = 55
    elseif abilityName == "Demoralizing Shout" then
        fixedThreat = 43
    elseif abilityName == "Thunder Clap" then
        fixedThreat = 130
    end
    
    local totalThreat = (baseThreat + fixedThreat) * modifier
    
    return totalThreat
end

function ThreatTrainer:AddThreat(mobName, threat)
    if not mobName or mobName == "" then return end
    
    self.myThreat[mobName] = (self.myThreat[mobName] or 0) + threat
    self.activeMobs[mobName] = true
    
    self:BroadcastThreat(mobName, self.myThreat[mobName])
    self:UpdateDisplay()
    
    if threat > 100 then
        self:ShowThreatChange(threat)
    end
end

function ThreatTrainer:ShowThreatChange(amount)
    if amount >= 0 then
        UIErrorsFrame:AddMessage(string.format("+%d threat", amount), 1.0, 0.5, 0.0, 1.0, 3)
    else
        UIErrorsFrame:AddMessage(string.format("%d threat", amount), 0.0, 1.0, 0.0, 1.0, 3)
    end
end