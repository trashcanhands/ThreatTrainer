DEFAULT_CHAT_FRAME:AddMessage("Loading Communication.lua...")

function ThreatTrainer:BroadcastThreat(mobName, threat)
    local msg = string.format("T:%s:%d", mobName, threat)
    SendAddonMessage(self.prefix, msg, "PARTY")
end

function ThreatTrainer:OnAddonMessage(prefix, message, distribution, sender)
    if prefix ~= self.prefix then return end
    if sender == UnitName("player") then return end
    
    local _, _, cmd, mobName, value = string.find(message, "(%w):(.+):(%d+)")
    
    if cmd == "T" and mobName and value then
        if not self.partnerThreat[mobName] then
            self.partnerThreat[mobName] = 0
        end
        
        self.partnerThreat[mobName] = tonumber(value)
        
        if not self.partnerName then
            self.partnerName = sender
        end
        
        self:UpdateDisplay()
    end
end