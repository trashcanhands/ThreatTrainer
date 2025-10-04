DEFAULT_CHAT_FRAME:AddMessage("Loading UI.lua...")

function ThreatTrainer:CreateUI()
    local frame = CreateFrame("Frame", "ThreatTrainerMainFrame", UIParent)
    frame:SetWidth(350)
    frame:SetHeight(150)
    
    ThreatTrainerDB = ThreatTrainerDB or {}
    ThreatTrainerDB.autoShow = ThreatTrainerDB.autoShow or true
    ThreatTrainerDB.autoHide = ThreatTrainerDB.autoHide or true
    
    if ThreatTrainerDB.position then
        frame:SetPoint(ThreatTrainerDB.position.point, UIParent, ThreatTrainerDB.position.relativePoint, ThreatTrainerDB.position.xOfs, ThreatTrainerDB.position.yOfs)
    else
        frame:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
    end
    
    frame:SetBackdrop({
        bgFile = "Interface\\DialogFrame\\UI-DialogBox-Background",
        edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
        tile = true, tileSize = 32, edgeSize = 32,
        insets = { left = 11, right = 12, top = 12, bottom = 11 }
    })
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetScript("OnDragStart", function()
        ThreatTrainerMainFrame:StartMoving()
    end)
    frame:SetScript("OnDragStop", function()
        ThreatTrainerMainFrame:StopMovingOrSizing()
        ThreatTrainer:SavePosition()
    end)
    frame:SetClampedToScreen(true)
    frame:Hide()
    
    local title = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", frame, "TOP", 0, -15)
    title:SetText("Threat Trainer")
    
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    
    frame.mobFrames = {}
    frame.noMobsLabel = nil
    
    self.mainFrame = frame
    self.maxThreatSeen = 100
end

function ThreatTrainer:SavePosition()
    if not self.mainFrame then return end
    
    local point, _, relativePoint, xOfs, yOfs = self.mainFrame:GetPoint()
    ThreatTrainerDB.position = {
        point = point,
        relativePoint = relativePoint,
        xOfs = xOfs,
        yOfs = yOfs
    }
end

function ThreatTrainer:UpdateDisplay()
    if not self.mainFrame then return end
    
    for _, mobFrame in pairs(self.mainFrame.mobFrames) do
        mobFrame:Hide()
    end
    self.mainFrame.mobFrames = {}
    
    if self.mainFrame.noMobsLabel then
        self.mainFrame.noMobsLabel:Hide()
        self.mainFrame.noMobsLabel = nil
    end
    
    local activeMobList = {}
    for mobName, _ in pairs(self.activeMobs) do
        table.insert(activeMobList, mobName)
    end
    table.sort(activeMobList)
    
    local numMobs = table.getn(activeMobList)
    
    if numMobs == 0 then
        self.mainFrame:SetHeight(100)
        local noMobsLabel = self.mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        noMobsLabel:SetPoint("CENTER", self.mainFrame, "CENTER", 0, 0)
        noMobsLabel:SetText("No active mobs")
        noMobsLabel:SetTextColor(0.7, 0.7, 0.7)
        self.mainFrame.noMobsLabel = noMobsLabel
        return
    end
    
    local yPos = -50
    local _, classEnglish = UnitClass("player")
    local isTank = classEnglish == "WARRIOR"
    local myName = UnitName("player")
    local partnerName = self.partnerName or "Partner"
    
    for i, mobName in ipairs(activeMobList) do
        local mobFrame = CreateFrame("Frame", nil, self.mainFrame)
        mobFrame:SetWidth(320)
        mobFrame:SetHeight(80)
        mobFrame:SetPoint("TOPLEFT", self.mainFrame, "TOPLEFT", 15, yPos)
        
        local bg = mobFrame:CreateTexture(nil, "BACKGROUND")
        bg:SetAllPoints(mobFrame)
        bg:SetTexture(0.1, 0.1, 0.1, 0.3)
        
        table.insert(self.mainFrame.mobFrames, mobFrame)
        
        local isCurrentTarget = UnitName("target") == mobName and UnitCanAttack("player", "target")
        
        local nameLabel = mobFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        nameLabel:SetPoint("TOPLEFT", mobFrame, "TOPLEFT", 5, -5)
        nameLabel:SetText(mobName)
        if isCurrentTarget then
            nameLabel:SetTextColor(2, 0, 3)
        else
            nameLabel:SetTextColor(.5, .5, .5)
        end
        
        local myLabel = mobFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        myLabel:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -10)
        myLabel:SetText(myName .. ":")
        myLabel:SetWidth(60)
        myLabel:SetJustifyH("LEFT")
        
        local myThreatBar = CreateFrame("StatusBar", nil, mobFrame)
        myThreatBar:SetPoint("LEFT", myLabel, "RIGHT", 5, 0)
        myThreatBar:SetWidth(160)
        myThreatBar:SetHeight(16)
        myThreatBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        myThreatBar:SetMinMaxValues(0, 100)
        myThreatBar:SetValue(0)
        
        local myBg = myThreatBar:CreateTexture(nil, "BACKGROUND")
        myBg:SetAllPoints(myThreatBar)
        myBg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
        myBg:SetVertexColor(0.1, 0.1, 0.1, 0.8)
        
        local myValue = myThreatBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        myValue:SetPoint("CENTER", myThreatBar, "CENTER", 0, 0)
        myValue:SetText("0")
        
        local partnerLabel = mobFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        partnerLabel:SetPoint("TOPLEFT", myLabel, "BOTTOMLEFT", 0, -22)
        partnerLabel:SetText(partnerName .. ":")
        partnerLabel:SetWidth(60)
        partnerLabel:SetJustifyH("LEFT")
        
        local partnerThreatBar = CreateFrame("StatusBar", nil, mobFrame)
        partnerThreatBar:SetPoint("LEFT", partnerLabel, "RIGHT", 5, 0)
        partnerThreatBar:SetWidth(160)
        partnerThreatBar:SetHeight(16)
        partnerThreatBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        partnerThreatBar:SetStatusBarColor(0.2, 0.4, 0.8)
        partnerThreatBar:SetMinMaxValues(0, 100)
        partnerThreatBar:SetValue(0)
        
        local partnerBg = partnerThreatBar:CreateTexture(nil, "BACKGROUND")
        partnerBg:SetAllPoints(partnerThreatBar)
        partnerBg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
        partnerBg:SetVertexColor(0.1, 0.1, 0.1, 0.8)
        
        local partnerValue = partnerThreatBar:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        partnerValue:SetPoint("CENTER", partnerThreatBar, "CENTER", 0, 0)
        partnerValue:SetText("0")
        
        local statusLabel = mobFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        statusLabel:SetPoint("LEFT", myThreatBar, "RIGHT", 10, 0)
        statusLabel:SetText("")
        
        local myThreat = self.myThreat[mobName] or 0
        local partnerThreat = self.partnerThreat[mobName] or 0
        
        local currentMax = math.max(myThreat, partnerThreat)
        if currentMax > self.maxThreatSeen then
            self.maxThreatSeen = currentMax
        end
        
        local scale = math.max(self.maxThreatSeen, 100)
        local myPercent = (myThreat / scale) * 100
        local partnerPercent = (partnerThreat / scale) * 100
        
        myValue:SetText(string.format("%d", myThreat))
        partnerValue:SetText(string.format("%d", partnerThreat))
        myThreatBar:SetValue(myPercent)
        partnerThreatBar:SetValue(partnerPercent)
        
        local inMeleeRange = isCurrentTarget and CheckInteractDistance("target", 3)
        local pullThreshold = inMeleeRange and 110 or 130
        
        if isTank then
            local partnerRatio = 0
            if myThreat > 0 then
                partnerRatio = (partnerThreat / myThreat) * 100
            end
            
            if partnerRatio >= pullThreshold then
                statusLabel:SetText("LOSING!")
                statusLabel:SetTextColor(1.0, 0.0, 0.0)
                myThreatBar:SetStatusBarColor(1.0, 0.0, 0.0)
            elseif partnerRatio >= 100 then
                statusLabel:SetText("Close")
                statusLabel:SetTextColor(1.0, 1.0, 0.0)
                myThreatBar:SetStatusBarColor(1.0, 1.0, 0.0)
            else
                statusLabel:SetText("Tanking")
                statusLabel:SetTextColor(0.0, 1.0, 0.0)
                myThreatBar:SetStatusBarColor(0.3, 0.8, 0.3)
            end
        else
            local threatRatio = 0
            if partnerThreat > 0 then
                threatRatio = (myThreat / partnerThreat) * 100
            end
            
            if threatRatio >= pullThreshold then
                statusLabel:SetText(string.format("%.0f%% - PULL!", threatRatio))
                statusLabel:SetTextColor(1.0, 0.0, 0.0)
                myThreatBar:SetStatusBarColor(1.0, 0.0, 0.0)
            elseif threatRatio >= 100 then
                statusLabel:SetText(string.format("%.0f%% - Caution", threatRatio))
                statusLabel:SetTextColor(1.0, 1.0, 0.0)
                myThreatBar:SetStatusBarColor(1.0, 1.0, 0.0)
            else
                statusLabel:SetText(string.format("%.0f%% - Safe", threatRatio))
                statusLabel:SetTextColor(0.0, 1.0, 0.0)
                myThreatBar:SetStatusBarColor(0.3, 0.8, 0.3)
            end
        end
        
        yPos = yPos - 85
    end
    
    local newHeight = 65 + (numMobs * 85)
    self.mainFrame:SetHeight(newHeight)
end