DEFAULT_CHAT_FRAME:AddMessage("Loading UI.lua...")

function ThreatTrainer:CreateUI()
    local frame = CreateFrame("Frame", "ThreatTrainerMainFrame", UIParent)
    frame:SetWidth(350)
    frame:SetHeight(260)
    
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
    
    local dragHint = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    dragHint:SetPoint("TOP", frame, "TOP", 0, -32)
    dragHint:SetText("|cff888888(Drag to move)|r")
    
    local targetLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    targetLabel:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -55)
    targetLabel:SetText("Target:")
    frame.targetLabel = targetLabel
    
    local targetName = frame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    targetName:SetPoint("LEFT", targetLabel, "RIGHT", 5, 0)
    targetName:SetText("None")
    frame.targetName = targetName
    
    local rangeLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    rangeLabel:SetPoint("TOPLEFT", targetLabel, "BOTTOMLEFT", 0, -5)
    rangeLabel:SetText("Range: Unknown")
    frame.rangeLabel = rangeLabel
    
    local myThreatLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    myThreatLabel:SetPoint("TOPLEFT", rangeLabel, "BOTTOMLEFT", 0, -15)
    myThreatLabel:SetText("You:")
    frame.myThreatLabel = myThreatLabel
    
    local myThreatBar = CreateFrame("StatusBar", nil, frame)
    myThreatBar:SetPoint("CENTER", frame, "CENTER", 0, 24)
    myThreatBar:SetWidth(200)
    myThreatBar:SetHeight(20)
    myThreatBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    myThreatBar:SetStatusBarColor(0.2, 0.8, 0.2)
    myThreatBar:SetMinMaxValues(0, 100)
    myThreatBar:SetValue(0)
    
    local myThreatBarBg = myThreatBar:CreateTexture(nil, "BACKGROUND")
    myThreatBarBg:SetAllPoints(myThreatBar)
    myThreatBarBg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    myThreatBarBg:SetVertexColor(0.1, 0.1, 0.1, 0.5)
    
    local myThreatBarBorder = CreateFrame("Frame", nil, myThreatBar)
    myThreatBarBorder:SetPoint("TOPLEFT", myThreatBar, "TOPLEFT", -1, 1)
    myThreatBarBorder:SetPoint("BOTTOMRIGHT", myThreatBar, "BOTTOMRIGHT", 1, -1)
    myThreatBarBorder:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    
    local myThreatValue = myThreatBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    myThreatValue:SetPoint("CENTER", myThreatBar, "CENTER", 0, 0)
    myThreatValue:SetText("0")
    frame.myThreatValue = myThreatValue
    frame.myThreatBar = myThreatBar
    
    local partnerThreatLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    partnerThreatLabel:SetPoint("TOPLEFT", myThreatLabel, "BOTTOMLEFT", 0, -30)
    partnerThreatLabel:SetText("Partner:")
    frame.partnerThreatLabel = partnerThreatLabel
    
    local partnerThreatBar = CreateFrame("StatusBar", nil, frame)
    partnerThreatBar:SetPoint("CENTER", frame, "CENTER", 0, -18)
    partnerThreatBar:SetWidth(200)
    partnerThreatBar:SetHeight(20)
    partnerThreatBar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
    partnerThreatBar:SetStatusBarColor(0.2, 0.2, 0.8)
    partnerThreatBar:SetMinMaxValues(0, 100)
    partnerThreatBar:SetValue(0)
    
    local partnerThreatBarBg = partnerThreatBar:CreateTexture(nil, "BACKGROUND")
    partnerThreatBarBg:SetAllPoints(partnerThreatBar)
    partnerThreatBarBg:SetTexture("Interface\\TargetingFrame\\UI-StatusBar")
    partnerThreatBarBg:SetVertexColor(0.1, 0.1, 0.1, 0.5)
    
    local partnerThreatBarBorder = CreateFrame("Frame", nil, partnerThreatBar)
    partnerThreatBarBorder:SetPoint("TOPLEFT", partnerThreatBar, "TOPLEFT", -1, 1)
    partnerThreatBarBorder:SetPoint("BOTTOMRIGHT", partnerThreatBar, "BOTTOMRIGHT", 1, -1)
    partnerThreatBarBorder:SetBackdrop({
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        edgeSize = 12,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    
    local partnerThreatValue = partnerThreatBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    partnerThreatValue:SetPoint("CENTER", partnerThreatBar, "CENTER", 0, 0)
    partnerThreatValue:SetText("0")
    frame.partnerThreatValue = partnerThreatValue
    frame.partnerThreatBar = partnerThreatBar
    
    local partnerThreatPercent = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    partnerThreatPercent:SetPoint("LEFT", partnerThreatBar, "RIGHT", 5, 0)
    partnerThreatPercent:SetText("0%")
    frame.partnerThreatPercent = partnerThreatPercent
    
    local threatDiffLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    threatDiffLabel:SetPoint("TOP", partnerThreatBar, "BOTTOM", 0, -10)
    threatDiffLabel:SetText("You are at 0% of partner threat")
    frame.threatDiffLabel = threatDiffLabel
    
    local separatorLine = frame:CreateTexture(nil, "ARTWORK")
    separatorLine:SetHeight(1)
    separatorLine:SetWidth(280)
    separatorLine:SetPoint("TOP", threatDiffLabel, "BOTTOM", 0, -8)
    separatorLine:SetTexture(0.5, 0.5, 0.5, 0.8)
    
    local statusLabel = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    statusLabel:SetPoint("TOP", threatDiffLabel, "BOTTOM", 0, -28)
    statusLabel:SetText("Status: Safe")
    frame.statusLabel = statusLabel
    
    local closeButton = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
    closeButton:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -5, -5)
    
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
    
    local myName = UnitName("player")
    local partnerName = self.partnerName or "Partner"
    
    self.mainFrame.myThreatLabel:SetText(myName .. ":")
    self.mainFrame.partnerThreatLabel:SetText(partnerName .. ":")
    
    local target = UnitName("target")
    
    if not target or not UnitCanAttack("player", "target") then
        self.mainFrame.targetName:SetText("None")
        self.mainFrame.rangeLabel:SetText("Range: Unknown")
        self.mainFrame.myThreatValue:SetText("0")
        self.mainFrame.partnerThreatValue:SetText("0")
        self.mainFrame.partnerThreatPercent:SetText("0%")
        self.mainFrame.partnerThreatPercent:SetTextColor(0.7, 0.7, 0.7)
        self.mainFrame.myThreatBar:SetValue(0)
        self.mainFrame.partnerThreatBar:SetValue(0)
        self.mainFrame.myThreatBar:SetStatusBarColor(0.2, 0.8, 0.2)
        self.mainFrame.threatDiffLabel:SetText(string.format("You are at 0%% of %s's threat", partnerName))
        self.mainFrame.threatDiffLabel:SetTextColor(0.7, 0.7, 0.7)
        self.mainFrame.statusLabel:SetText("Status: No Target")
        self.mainFrame.statusLabel:SetTextColor(0.7, 0.7, 0.7)
        return
    end
    
    self.mainFrame.targetName:SetText(target)
    
    local inMeleeRange = CheckInteractDistance("target", 3)
    if inMeleeRange then
        self.mainFrame.rangeLabel:SetText("|cffff8800Range: Melee (110% to pull)|r")
    else
        self.mainFrame.rangeLabel:SetText("|cff8888ffRange: Ranged (130% to pull)|r")
    end
    
    local myThreat = self.myThreat[target] or 0
    local partnerThreat = self.partnerThreat[target] or 0
    
    local currentMax = math.max(myThreat, partnerThreat)
    
    if currentMax > self.maxThreatSeen then
        self.maxThreatSeen = currentMax
    end
    
    local scale = math.max(self.maxThreatSeen, 100)
    
    local myPercent = (myThreat / scale) * 100
    local partnerPercent = (partnerThreat / scale) * 100
    
    self.mainFrame.myThreatValue:SetText(string.format("%d", myThreat))
    self.mainFrame.partnerThreatValue:SetText(string.format("%d", partnerThreat))
    
    self.mainFrame.myThreatBar:SetValue(myPercent)
    self.mainFrame.partnerThreatBar:SetValue(partnerPercent)
    
    local threatRatio = 0
    if partnerThreat > 0 then
        threatRatio = (myThreat / partnerThreat) * 100
    end
    
    local pullThreshold = inMeleeRange and 110 or 130
    
    local _, classEnglish = UnitClass("player")
    local isTank = classEnglish == "WARRIOR"
    
    if isTank then
        local partnerRatio = 0
        if myThreat > 0 then
            partnerRatio = (partnerThreat / myThreat) * 100
        end
        
        self.mainFrame.partnerThreatPercent:SetText(string.format("%.0f%%", partnerRatio))
        self.mainFrame.threatDiffLabel:SetText(string.format("%s is at %.0f%% of your threat", partnerName, partnerRatio))
        
        if partnerRatio >= pullThreshold then
            self.mainFrame.partnerThreatPercent:SetTextColor(1.0, 0.0, 0.0)
            self.mainFrame.threatDiffLabel:SetTextColor(1.0, 0.0, 0.0)
            self.mainFrame.statusLabel:SetText("Status: Losing Aggro!")
            self.mainFrame.statusLabel:SetTextColor(1.0, 0.0, 0.0)
            self.mainFrame.myThreatBar:SetStatusBarColor(1.0, 0.0, 0.0)
        elseif partnerRatio >= 100 then
            self.mainFrame.partnerThreatPercent:SetTextColor(1.0, 1.0, 0.0)
            self.mainFrame.threatDiffLabel:SetTextColor(1.0, 1.0, 0.0)
            self.mainFrame.statusLabel:SetText("Status: Close")
            self.mainFrame.statusLabel:SetTextColor(1.0, 1.0, 0.0)
            self.mainFrame.myThreatBar:SetStatusBarColor(1.0, 1.0, 0.0)
        else
            self.mainFrame.partnerThreatPercent:SetTextColor(0.0, 1.0, 0.0)
            self.mainFrame.threatDiffLabel:SetTextColor(0.0, 1.0, 0.0)
            self.mainFrame.statusLabel:SetText("Status: Tanking")
            self.mainFrame.statusLabel:SetTextColor(0.0, 1.0, 0.0)
            self.mainFrame.myThreatBar:SetStatusBarColor(0.2, 0.8, 0.2)
        end
    else
        self.mainFrame.partnerThreatPercent:SetText(string.format("%.0f%%", threatRatio))
        self.mainFrame.threatDiffLabel:SetText(string.format("You are at %.0f%% of %s's threat", threatRatio, partnerName))
        
        if threatRatio >= pullThreshold then
            self.mainFrame.partnerThreatPercent:SetTextColor(1.0, 0.0, 0.0)
            self.mainFrame.threatDiffLabel:SetTextColor(1.0, 0.0, 0.0)
            self.mainFrame.statusLabel:SetText("Status: PULLING AGGRO!")
            self.mainFrame.statusLabel:SetTextColor(1.0, 0.0, 0.0)
            self.mainFrame.myThreatBar:SetStatusBarColor(1.0, 0.0, 0.0)
        elseif threatRatio >= 100 then
            self.mainFrame.partnerThreatPercent:SetTextColor(1.0, 1.0, 0.0)
            self.mainFrame.threatDiffLabel:SetTextColor(1.0, 1.0, 0.0)
            self.mainFrame.statusLabel:SetText("Status: Caution")
            self.mainFrame.statusLabel:SetTextColor(1.0, 1.0, 0.0)
            self.mainFrame.myThreatBar:SetStatusBarColor(1.0, 1.0, 0.0)
        else
            self.mainFrame.partnerThreatPercent:SetTextColor(0.0, 1.0, 0.0)
            self.mainFrame.threatDiffLabel:SetTextColor(0.0, 1.0, 0.0)
            self.mainFrame.statusLabel:SetText("Status: Safe")
            self.mainFrame.statusLabel:SetTextColor(0.0, 1.0, 0.0)
            self.mainFrame.myThreatBar:SetStatusBarColor(0.2, 0.8, 0.2)
        end
    end
end