local _, farkle = ...

local L = farkle.L

---@diagnostic disable-next-line: duplicate-set-field
C_GossipInfo.ForceGossip = function()
    if UnitExists("target") then
        ---@diagnostic disable-next-line: param-type-mismatch
        local unitId = select(6, strsplit("-", UnitGUID("target")))
        for _, npc in ipairs(farkle.innkeepers) do
            if tonumber(unitId) == npc.id then
                return true
            end
        end
    end
end

local function numButtons()
    local count = 0
    for _, button in ipairs({ GossipFrame.GreetingPanel.ScrollBox.ScrollTarget:GetChildren() }) do
        if button:IsObjectType("Button") and button:IsShown() then
            count = count + 1
        end
    end
    return count
end

local function HideFarkleButtons()
    for _, child in ipairs({ GossipFrame.GreetingPanel.ScrollBox.ScrollTarget:GetChildren() }) do
        if child:IsObjectType("Button") and child:IsShown() and child.FarkleButton then
            child:Hide(); child = nil
        end
    end
end

local function IsFarklePlayer(unitId)
    for _, npc in ipairs(farkle.innkeepers) do
        if tonumber(unitId) == npc.id then
            return true
        end
    end
end

local function HideAllButtons()
    for _, child in ipairs({ GossipFrame.GreetingPanel.ScrollBox.ScrollTarget:GetChildren() }) do
        if child:IsObjectType("Button") and child:IsShown() then
            child:Hide(); child = nil
        end
    end
end

local function CreateCustomGossipButton(buttonText, iconType, iconTexture, iconSize, onClick)
    local customGossipButton = CreateFrame("Button", nil, GossipFrame.GreetingPanel.ScrollBox.ScrollTarget, "GossipTitleButtonTemplate")
    customGossipButton:SetParent(GossipFrame.GreetingPanel.ScrollBox.ScrollTarget); customGossipButton.Text = customGossipButton:GetFontString();
    customGossipButton:SetText(buttonText); customGossipButton.FarkleButton = true

    if QuestUtil.QuestTextContrastUseLightText() then
        customGossipButton.Text:SetTextColor(STONE_MATERIAL_TEXT_COLOR:GetRGB())
    else
        customGossipButton.Text:SetTextColor(PARCHMENT_MATERIAL_TEXT_COLOR:GetRGB())
    end

    customGossipButton.Icon:ClearAllPoints()
    customGossipButton.Icon:SetPoint("LEFT", customGossipButton, 3, 0)
    if iconType == "atlas" then
        customGossipButton.Icon:SetAtlas(iconTexture)
    elseif iconType == "texture" then
        customGossipButton.Icon:SetTexture(iconTexture)
    end
    customGossipButton.Icon:SetSize(iconSize, iconSize)

    local lastButton = nil
    for _, child in ipairs({ GossipFrame.GreetingPanel.ScrollBox.ScrollTarget:GetChildren() }) do
        if child:IsObjectType("Button") and child:IsShown() and child ~= customGossipButton then
            if child.Icon and child.Icon:GetTexture() == 132060 then
                child.Icon:SetAtlas("Food")
                child.Icon:ClearAllPoints()
                child.Icon:SetPoint("LEFT", child, 2, 1)
            end
            lastButton = child
        end
    end

    if lastButton then
        customGossipButton:SetPoint("TOPLEFT", GossipFrame.GreetingPanel.ScrollBox.ScrollTarget, "TOPLEFT", 0, select(5, lastButton:GetPoint()) + -lastButton:GetHeight())
    else
        customGossipButton:SetPoint("TOPLEFT", GossipFrame.GreetingPanel.ScrollBox.ScrollTarget, "TOPLEFT", 0, -58.400)
    end

    customGossipButton:SetScript("OnClick", function(self) onClick() end)

    GossipFrame.GreetingPanel.ScrollBox.ScrollTarget:SetHeight(GossipFrame.GreetingPanel.ScrollBox.ScrollTarget:GetHeight() + 16)
end

EventRegistry:RegisterFrameEventAndCallback("GOSSIP_SHOW", function(ownerID, ...)
    GossipFrame.CurrentStage = GossipFrame.CurrentStage or 0
    if GossipFrame.CurrentStage ~= 0 then
        HideFarkleButtons()
        return
    end

    if UnitExists("target") then
        ---@diagnostic disable-next-line: param-type-mismatch
        local unitId = select(6, strsplit("-", UnitGUID("target")))
        local name, sex = UnitName("target"), UnitSex("target")
        if IsFarklePlayer(unitId) then
            CreateCustomGossipButton(L["DICE_OPTION"], "texture", "Interface/Buttons/UI-GroupLoot-Dice-Up", 15, function()
                C_Timer.After(0.250, function()
                    if GossipFrame:IsShown() and (name and sex) and GossipFrame.CurrentStage == 0 then
                        GossipFrame.CurrentStage = GossipFrame.CurrentStage + 1; HideAllButtons()
                        GossipFrame.GreetingPanel.ScrollBox.ScrollTarget:SetHeight(GossipFrame.GreetingPanel.ScrollBox.ScrollTarget:GetHeight() - 16 * numButtons())
                        GossipFrame.GreetingPanel.ScrollBox.ScrollTarget:GetChildren().GreetingText:SetText(L["DURATION_LABEL"])
                        CreateCustomGossipButton(format("%s (2,000 %s)", L["DURATION_1"], L["POINTS"]), "texture", "Interface/AddOns/Farkle/Media/Icons/challenges-medal-small-bronze", 15, function()
                            C_Timer.After(0.250, function()
                                if GossipFrame:IsShown() and (name and sex) and GossipFrame.CurrentStage ~= 0 then
                                    C_Farkle:NewBoard(name:gsub("Innkeeper ", ""), "none", nil, sex, "PvE", 2000, false)
                                    if C_CVar.GetCVarBool("Sound_EnableDialog") then
                                        C_CVar.SetCVar("Sound_EnableDialog", 0)
                                        C_GossipInfo.CloseGossip()
                                        C_CVar.SetCVar("Sound_EnableDialog", 1)
                                    else
                                        C_GossipInfo.CloseGossip()
                                    end
                                end
                            end)
                        end)
                        CreateCustomGossipButton(format("%s (4,000 %s)", L["DURATION_2"], L["POINTS"]), "texture", "Interface/AddOns/Farkle/Media/Icons/challenges-medal-small-silver", 15, function()
                            C_Timer.After(0.250, function()
                                if GossipFrame:IsShown() and (name and sex) and GossipFrame.CurrentStage ~= 0 then
                                    C_Farkle:NewBoard(name:gsub("Innkeeper ", ""), "none", nil, sex, "PvE", 4000, false)
                                    if C_CVar.GetCVarBool("Sound_EnableDialog") then
                                        C_CVar.SetCVar("Sound_EnableDialog", 0)
                                        C_GossipInfo.CloseGossip()
                                        C_CVar.SetCVar("Sound_EnableDialog", 1)
                                    else
                                        C_GossipInfo.CloseGossip()
                                    end
                                end
                            end)
                        end)
                        CreateCustomGossipButton(format("%s (8,000 %s)", L["DURATION_3"], L["POINTS"]), "texture", "Interface/AddOns/Farkle/Media/Icons/challenges-medal-small-gold", 15, function()
                            C_Timer.After(0.250, function()
                                if GossipFrame:IsShown() and (name and sex) and GossipFrame.CurrentStage ~= 0 then
                                    C_Farkle:NewBoard(name:gsub("Innkeeper ", ""), "none", nil, sex, "PvE", 8000, false)
                                    if C_CVar.GetCVarBool("Sound_EnableDialog") then
                                        C_CVar.SetCVar("Sound_EnableDialog", 0)
                                        C_GossipInfo.CloseGossip()
                                        C_CVar.SetCVar("Sound_EnableDialog", 1)
                                    else
                                        C_GossipInfo.CloseGossip()
                                    end
                                end
                            end)
                        end)
                    end
                end)
            end)
        end
    end
end)

EventRegistry:RegisterFrameEventAndCallback("GOSSIP_CLOSED", function(ownerID, ...)
    GossipFrame.CurrentStage = 0; HideFarkleButtons()
end)

EventRegistry:RegisterFrameEventAndCallback("GOSSIP_CONFIRM_CANCEL", function(ownerID, ...)
    GossipFrame.CurrentStage = (GossipFrame.CurrentStage or 0) + 1
end)