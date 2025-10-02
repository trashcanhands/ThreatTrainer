ThreatTrainer = {}
ThreatTrainer.version = "1.0"
ThreatTrainer.prefix = "ThreatTrainer"

ThreatTrainer.myThreat = {}
ThreatTrainer.partnerThreat = {}
ThreatTrainer.partnerName = nil
ThreatTrainer.inCombat = false
ThreatTrainer.activeMobs = {}
ThreatTrainer.maxThreatSeen = 100

local frame = CreateFrame("Frame", "ThreatTrainerFrame")

frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_REGEN_DISABLED")
frame:RegisterEvent("PLAYER_REGEN_ENABLED")
frame:RegisterEvent("PLAYER_TARGET_CHANGED")
frame:RegisterEvent("CHAT_MSG_ADDON")

frame:RegisterEvent("CHAT_MSG_COMBAT_SELF_HITS")
frame:RegisterEvent("CHAT_MSG_COMBAT_SELF_MISSES")
frame:RegisterEvent("CHAT_MSG_SPELL_SELF_DAMAGE")
frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_DAMAGE")
frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_SELF_BUFFS")
frame:RegisterEvent("CHAT_MSG_SPELL_SELF_BUFF")
frame:RegisterEvent("CHAT_MSG_SPELL_PARTY_DAMAGE")
frame:RegisterEvent("CHAT_MSG_SPELL_PARTY_BUFF")
frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_PARTY_BUFFS")
frame:RegisterEvent("CHAT_MSG_SPELL_PERIODIC_CREATURE_DAMAGE")

frame:SetScript("OnEvent", function()
    if event == "PLAYER_LOGIN" then
        ThreatTrainer:Initialize()
    elseif event == "PLAYER_ENTERING_WORLD" then
        if not ThreatTrainer.mainFrame and ThreatTrainer.CreateUI then
            ThreatTrainer:CreateUI()
        end
        ThreatTrainer:Reset()
    elseif event == "PLAYER_REGEN_DISABLED" then
        ThreatTrainer:EnterCombat()
    elseif event == "PLAYER_REGEN_ENABLED" then
        ThreatTrainer:LeaveCombat()
    elseif event == "PLAYER_TARGET_CHANGED" then
        if ThreatTrainer.UpdateDisplay then
            ThreatTrainer:UpdateDisplay()
        end
    elseif event == "CHAT_MSG_ADDON" then
        if ThreatTrainer.OnAddonMessage then
            ThreatTrainer:OnAddonMessage(arg1, arg2, arg3, arg4)
        end
    else
        if ThreatTrainer.ParseCombatLog then
            ThreatTrainer:ParseCombatLog(event, arg1)
        end
    end
end)

function ThreatTrainer:Initialize()
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00Threat Trainer|r Initializing...")
	
    ThreatTrainerDB = ThreatTrainerDB or {}
    ThreatTrainerDB.autoShow = ThreatTrainerDB.autoShow or true
    ThreatTrainerDB.autoHide = ThreatTrainerDB.autoHide or true

	self:CreateMinimapButton()

    if ThreatTrainer.CreateUI then
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00Threat Trainer|r CreateUI function found, calling it...")
        ThreatTrainer:CreateUI()
        if ThreatTrainer.mainFrame then
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00Threat Trainer|r v" .. self.version .. " loaded. Type /tt to toggle display.")
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cffff0000Threat Trainer|r ERROR: mainFrame is nil after CreateUI!")
        end
    else
        DEFAULT_CHAT_FRAME:AddMessage("|cffff0000Threat Trainer|r ERROR: CreateUI function not found!")
    end
end

function ThreatTrainer:CreateMinimapButton()
    local button = CreateFrame("Button", "TT_MinimapButton", Minimap)
    button:SetWidth(33)
    button:SetHeight(33)
    button:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -10, -10)
    button:SetFrameStrata("MEDIUM")
    button:SetFrameLevel(8)
    button:EnableMouse(true)
    button:RegisterForDrag("RightButton")
    button:RegisterForClicks("LeftButtonUp")
    
    local icon = button:CreateTexture(nil, "BACKGROUND")
    icon:SetTexture("Interface\\Icons\\ability_warrior_battleshout")
    icon:SetWidth(21)
    icon:SetHeight(21)
    icon:SetPoint("CENTER", 0, 0)
    
    local border = button:CreateTexture(nil, "OVERLAY")
    border:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
    border:SetWidth(56)
    border:SetHeight(56)
    border:SetPoint("TOPLEFT", 0, 0)
    
    button:SetScript("OnClick", function()
        if ThreatTrainer.mainFrame then
            if ThreatTrainer.mainFrame:IsShown() then
                ThreatTrainer.mainFrame:Hide()
            else
                ThreatTrainer.mainFrame:Show()
            end
        end
    end)
    
    button:SetScript("OnDragStart", function() this:StartMoving() end)
    button:SetScript("OnDragStop", function() this:StopMovingOrSizing() end)
    
    button:SetScript("OnEnter", function()
        GameTooltip:SetOwner(this, "ANCHOR_LEFT")
        GameTooltip:AddLine("Threat Trainer")
        GameTooltip:AddLine("|cFF00FF00Left-click|r to toggle window", 1, 1, 1)
        GameTooltip:AddLine("|cFF0080FFRight-click|r to drag", 1, 1, 1)
        GameTooltip:Show()
    end)
    
    button:SetScript("OnLeave", function() GameTooltip:Hide() end)
    
    button:Show()
    DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00Threat Trainer|r Minimap button created")
end

function ThreatTrainer:Reset()
    self.myThreat = {}
    self.partnerThreat = {}
    self.activeMobs = {}
    self.maxThreatSeen = 100
    if ThreatTrainer.UpdateDisplay then
        self:UpdateDisplay()
    end
end

function ThreatTrainer:EnterCombat()
    self.inCombat = true
    if ThreatTrainerDB.autoShow and self.mainFrame then
        self.mainFrame:Show()
    end
end

function ThreatTrainer:LeaveCombat()
    self.inCombat = false
    self:Reset()
    if ThreatTrainerDB.autoHide and self.mainFrame then
        self.mainFrame:Hide()
    end
end

SLASH_THREATTRAINER1 = "/threattrainer"
SLASH_THREATTRAINER2 = "/tt"
SlashCmdList["THREATTRAINER"] = function(msg)
    if msg == "reset" then
        ThreatTrainer:Reset()
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00Threat Trainer:|r Threat reset.")
    elseif msg == "auto" then
        ThreatTrainerDB.autoShow = not ThreatTrainerDB.autoShow
        ThreatTrainerDB.autoHide = ThreatTrainerDB.autoShow
        local status = ThreatTrainerDB.autoShow and "enabled" or "disabled"
        DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00Threat Trainer:|r Auto show/hide " .. status)
    elseif msg == "debug" then
        DEFAULT_CHAT_FRAME:AddMessage("CreateUI exists: " .. tostring(ThreatTrainer.CreateUI ~= nil))
        DEFAULT_CHAT_FRAME:AddMessage("mainFrame exists: " .. tostring(ThreatTrainer.mainFrame ~= nil))
        DEFAULT_CHAT_FRAME:AddMessage("UpdateDisplay exists: " .. tostring(ThreatTrainer.UpdateDisplay ~= nil))
        DEFAULT_CHAT_FRAME:AddMessage("ParseCombatLog exists: " .. tostring(ThreatTrainer.ParseCombatLog ~= nil))
    else
        if ThreatTrainer.mainFrame then
            if ThreatTrainer.mainFrame:IsShown() then
                ThreatTrainer.mainFrame:Hide()
            else
                ThreatTrainer.mainFrame:Show()
            end
        else
            DEFAULT_CHAT_FRAME:AddMessage("|cff00ff00Threat Trainer:|r Window not initialized yet. Try /tt debug")
        end
    end
end