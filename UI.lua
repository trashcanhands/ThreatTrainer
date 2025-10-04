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
    frame.title = title
    
    local dragHint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dragHint:SetPoint("TOP", frame, "TOP", 0, -32)
    dragHint:SetText("|cff888888(Drag to move)|r")
    frame.dragHint = dragHint
    
    local contentFrame = CreateFrame("Frame", nil, frame)
    contentFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -55)
    contentFrame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -55)
    contentFrame:SetHeight(1)
    frame.contentFrame = contentFrame
    
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    
    frame.mobFrames = {}
    
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

function ThreatTrainer:CreateMobFrame(mobName, yOffset)
    local contentFrame = self.mainFrame.contentFrame
    local mobFrame = CreateFrame("Frame", nil, contentFrame)
    mobFrame:SetWidth(310)
    mobFrame:SetHeight(85)
    mobFrame:SetPoint("TOPLEFT", contentFrame, "TOPLEFT", 0, yOffset)
    
    local nameLabel = mobFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    nameLabel:SetPoint("TOPLEFT", mobFrame, "TOPLEFT", 0, 0)
    nameLabel:SetText(mobName)
    mobFrame.nameLabel = nameLabel
    
    local rangeLabel = mobFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rangeLabel:SetPoint("TOPLEFT", nameLabel, "BOTTOMLEFT", 0, -3)
    rangeLabel:SetText("Range: Unknown")
    mobFrame.rangeLabel = rangeLabel
    
    local myName = UnitName("player")
    local partnerName = self.partnerName or "Partner"
    
    local myThreatLabel = mobFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    myThreatLabel:SetPoint("TOPLEFT", rangeLabel, "BOTTOMLEFT", 0, -8)
    myThreatLabel:SetText(myName .. ":")
    mobFrame.myThreatLabel = myThreatLabel
    
    local myThreatBar = CreateFrame("StatusBar", nil, mobFrame)
    myThreatBar:SetPoint("LEFT", myThreatLabel, "RIGHT", 5, 0)
    myThreatBar:SetWidth(150)
    myThreatBar:SetHeight(16)
    myThreatBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    myThreatBar:SetStatusBarColor(0.2, 0.8, 0.2)
    myThreatBar:SetMinMaxValues(0, 100)
    myThreatBar:SetValue(0)
    
    local myThreatBarBg = myThreatBar:CreateTexture(nil, "BACKGROUND")
    myThreatBarBg:SetAllPoints(myThreatBar)
    myThreatBarBg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    myThreatBarBg:SetVertexColor(0.1, 0.1, 0.1, 0.5)
    
    local myThreatValue = myThreatBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    myThreatValue:SetPoint("CENTER", myThreatBar, "CENTER", 0, 0)
    myThreatValue:SetText("0")
    mobFrame.myThreatValue = myThreatValue
    mobFrame.myThreatBar = myThreatBar
    
    local partnerThreatLabel = mobFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    partnerThreatLabel:SetPoint("TOPLEFT", myThreatLabel, "BOTTOMLEFT", 0, -20)
    partnerThreatLabel:SetText(partnerName .. ":")
    mobFrame.partnerThreatLabel = partnerThreatLabel
    
    local partnerThreatBar = CreateFrame("StatusBar", nil, mobFrame)
    partnerThreatBar:SetPoint("LEFT", partnerThreatLabel, "RIGHT", 5, 0)
    partnerThreatBar:SetWidth(150)
    partnerThreatBar:SetHeight(16)
    partnerThreatBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    partnerThreatBar:SetStatusBarColor(0.2, 0.2, 0.8)
    partnerThreatBar:SetMinMaxValues(0, 100)
    partnerThreatBar:SetValue(0)
    
    local partnerThreatBarBg = partnerThreatBar:CreateTexture(nil, "BACKGROUND")
    partnerThreatBarBg:SetAllPoints(partnerThreatBar)
    partnerThreatBarBg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    partnerThreatBarBg:SetVertexColor(0.1, 0.1, 0.1, 0.5)
    
    local partnerThreatValue = partnerThreatBar:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    partnerThreatValue:SetPoint("CENTER", partnerThreatBar, "CENTER", 0, 0)
    partnerThreatValue:SetText("0")
    mobFrame.partnerThreatValue = partnerThreatValue
    mobFrame.partnerThreatBar = partnerThreatBar
    
    local statusLabel = mobFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    statusLabel:SetPoint("LEFT", partnerThreatBar, "RIGHT", 8, 0)
    statusLabel:SetText("Safe")
    mobFrame.statusLabel = statusLabel
    
    return mobFrame
end

function ThreatTrainer:UpdateDisplay()
    if not self.mainFrame then return end
    
    for _, mobFrame in pairs(self.mainFrame.mobFrames) do
        mobFrame:Hide()
    end
    self.mainFrame.mobFrames = {}
    
    local activeMobList = {}
    for mobName, _ in pairs(self.activeMobs) do
        table.insert(activeMobList, mobName)
    end
    table.sort(activeMobList)
    
    if table.getn(activeMobList) == 0 then
        self.mainFrame:SetHeight(100)
        local noMobsLabel = self.mainFrame.contentFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        noMobsLabel:SetPoint("TOP", self.mainFrame.contentFrame, "TOP", 0, -20)
        noMobsLabel:SetText("No active mobs")
        noMobsLabel:SetTextColor(0.7, 0.7, 0.7)
        return
    end
    
    local yOffset = 0
    local _, classEnglish = UnitClass("player")
    local isTank = classEnglish == "WARRIOR"
    
    for _, mobName in ipairs(activeMobList) do
        local mobFrame = self:CreateMobFrame(mobName, yOffset)
        table.insert(self.mainFrame.mobFrames, mobFrame)
        
        local isCurrentTarget = UnitName("target") == mobName
        if isCurrentTarget then
            mobFrame.nameLabel:SetTextColor(1, 1, 0)
        else
            mobFrame.nameLabel:SetTextColor(1, 1, 1)
        end
        
        local inMeleeRange = false
        if isCurrentTarget and UnitCanAttack("player", "target") then
            inMeleeRange = CheckInteractDistance("target", 3)
        end
        
        if inMeleeRange then
            mobFrame.rangeLabel:SetText("|cffff8800Melee (110% to pull)|r")
        else
            mobFrame.rangeLabel:SetText("|cff8888ffRanged (130% to pull)|r")
        end
        
        local myThreat = self.myThreat[mobName] or 0
        local partnerThreat = self.partnerThreat[mobName] or 0
        
        local currentMax = math.max(myThreat, partnerThreat)
        if currentMax > self.maxThreatSeen then
            self.maxThreatSeen = currentMax
        end
        
        local scale = math.max(self.maxThreatSeen, 100)
        local myPercent = (myThreat / scale) * 100
        local partnerPercent = (partnerThreat / scale) * 100
        
        mobFrame.myThreatValue:SetText(string.format("%d", myThreat))
        mobFrame.partnerThreatValue:SetText(string.format("%d", partnerThreat))
        mobFrame.myThreatBar:SetValue(myPercent)
        mobFrame.partnerThreatBar:SetValue(partnerPercent)
        
        local pullThreshold = inMeleeRange and 110 or 130
        
        if isTank then
            local partnerRatio = 0
            if myThreat > 0 then
                partnerRatio = (partnerThreat / myThreat) * 100
            end
            
            if partnerRatio >= pullThreshold then
                mobFrame.statusLabel:SetText("LOSING!")
                mobFrame.statusLabel:SetTextColor(1.0, 0.0, 0.0)
                mobFrame.myThreatBar:SetStatusBarColor(1.0, 0.0, 0.0)
            elseif partnerRatio >= 100 then
                mobFrame.statusLabel:SetText("Close")
                mobFrame.statusLabel:SetTextColor(1.0, 1.0, 0.0)
                mobFrame.myThreatBar:SetStatusBarColor(1.0, 1.0, 0.0)
            else
                mobFrame.statusLabel:SetText("Tanking")
                mobFrame.statusLabel:SetTextColor(0.0, 1.0, 0.0)
                mobFrame.myThreatBar:SetStatusBarColor(0.2, 0.8, 0.2)
            end
        else
            local threatRatio = 0
            if partnerThreat > 0 then
                threatRatio = (myThreat / partnerThreat) * 100
            end
            
            if threatRatio >= pullThreshold then
                mobFrame.statusLabel:SetText("PULLING!")
                mobFrame.statusLabel:SetTextColor(1.0, 0.0, 0.0)
                mobFrame.myThreatBar:SetStatusBarColor(1.0, 0.0, 0.0)
            elseif threatRatio >= 100 then
                mobFrame.statusLabel:SetText("Caution")
                mobFrame.statusLabel:SetTextColor(1.0, 1.0, 0.0)
                mobFrame.myThreatBar:SetStatusBarColor(1.0, 1.0, 0.0)
            else
                mobFrame.statusLabel:SetText("Safe")
                mobFrame.statusLabel:SetTextColor(0.0, 1.0, 0.0)
                mobFrame.myThreatBar:SetStatusBarColor(0.2, 0.8, 0.2)
            end
        end
        
        yOffset = yOffset - 90
    end
    
    local numMobs = table.getn(activeMobList)
    local newHeight = 70 + (numMobs * 90)
    self.mainFrame:SetHeight(newHeight)
end
