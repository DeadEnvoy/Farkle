local _, farkle = ...

local L = farkle.L
local C_Farkle = farkle.API

DUIQuestFrame = DUIQuestFrame

local originalHandleGossip = nil
local originalForceGossip = C_GossipInfo.ForceGossip

local diceGameState = nil

local function emulateClick(button, callback)
    if button.PlayKeyFeedback then button:PlayKeyFeedback() end
    C_Timer.After(0.500, function()
        if button and button:IsShown() and callback then
            callback(button)
        end
    end)
end

local function IsFarklePlayer(unitId)
    if not farkle.innkeepers then return false end
    for _, npc in ipairs(farkle.innkeepers) do
        if tonumber(unitId) == npc.id then
            return true
        end
    end
    return false
end

---@diagnostic disable-next-line: duplicate-set-field
C_GossipInfo.ForceGossip = function()
    local shouldForce = false
    if UnitExists("target") then
        local guid = UnitGUID("target")
        if guid then
            local unitId = select(6, strsplit("-", guid))
            if unitId then
                shouldForce = IsFarklePlayer(unitId)
            end
        end
    end
    local originalResult = false
    if originalForceGossip then
        originalResult = originalForceGossip()
    end
    return originalResult or shouldForce
end

local SelectDifficultyEasy, SelectDifficultyNormal, SelectDifficultyHard

local function StartFarkleGame(goal)
    local npcName = UnitName("target")
    local sex = UnitSex("target")

    if npcName and sex and C_Farkle and C_Farkle.NewBoard then
        local opponentName = npcName:gsub("Innkeeper ", "")
        C_Farkle:NewBoard(opponentName, "none", nil, sex, "PvE", goal, false)
    end
    if C_CVar.GetCVarBool("Sound_EnableDialog") and not UnitAffectingCombat("player") then
        C_CVar.SetCVar("Sound_EnableDialog", 0); C_GossipInfo.CloseGossip(); C_CVar.SetCVar("Sound_EnableDialog", 1);
    else
        C_GossipInfo.CloseGossip()
    end
    if DUIQuestFrame and DUIQuestFrame:IsShown() then DUIQuestFrame:Hide() end
    return true
end

SelectDifficultyEasy = function(button) return StartFarkleGame(2000) end
SelectDifficultyNormal = function(button) return StartFarkleGame(4000) end
SelectDifficultyHard = function(button) return StartFarkleGame(8000) end

local function DisplayDifficultyOptions(duiFrame)
    if C_CVar.GetCVarBool("Sound_EnableSFX") and not UnitAffectingCombat("player") then
        C_CVar.SetCVar("Sound_EnableSFX", 0);
        duiFrame:ReleaseAllObjects(); duiFrame:FadeInContentFrame();
        C_CVar.SetCVar("Sound_EnableSFX", 1);
    else
        duiFrame:ReleaseAllObjects(); duiFrame:FadeInContentFrame();
    end

    local offsetY = 0
    local firstObject, lastObject

    offsetY, firstObject, lastObject = duiFrame:FormatParagraph(offsetY, L["DURATION_LABEL"])

    local initialButtonSpacing = -17
    if lastObject and duiFrame.PARAGRAPH_BUTTON_SPACING then
         initialButtonSpacing = -(duiFrame.PARAGRAPH_BUTTON_SPACING) + (initialButtonSpacing)
    end

    local buttons = {
        { text = format("%s (2,000 %s)", L["DURATION_1"], L["POINTS"]), handler = SelectDifficultyEasy,   icon = "Interface/AddOns/Farkle/Media/Icons/challenges-medal-small-bronze" },
        { text = format("%s (4,000 %s)", L["DURATION_2"], L["POINTS"]), handler = SelectDifficultyNormal, icon = "Interface/AddOns/Farkle/Media/Icons/challenges-medal-small-silver" },
        { text = format("%s (8,000 %s)", L["DURATION_3"], L["POINTS"]), handler = SelectDifficultyHard,   icon = "Interface/AddOns/Farkle/Media/Icons/challenges-medal-small-gold" },
    }

    for i, data in ipairs(buttons) do
        local difficultyButton = duiFrame:AcquireOptionButton()
        if difficultyButton then
            local hotkeyString = (i <= 9) and tostring(i) or nil
            local buttonText = data.text
            if hotkeyString then
                buttonText = hotkeyString .. ". " .. buttonText
            end

            local gossipData = { name = buttonText, icon = data.icon }
            difficultyButton:SetGossip(gossipData, nil)
            difficultyButton.onClickFunc = function(self)
                emulateClick(self, data.handler); self:Disable()
                return true
            end

            difficultyButton:SetScript("OnKeyDown", function(self, button)
                if not self:IsEnabled() then return end
                if button == hotkeyString and not UnitAffectingCombat("player") then
                    self:SetPropagateKeyboardInput(false); self:Click()
                elseif button == hotkeyString then
                    self:SetPropagateKeyboardInput(true); self:Click()
                else
                    self:SetPropagateKeyboardInput(true)
                end
            end)

            local currentSpacing = (i == 1) and initialButtonSpacing or -0.5
            difficultyButton:ClearAllPoints()
            difficultyButton:SetPoint("TOPLEFT", lastObject, "BOTTOMLEFT", 0, currentSpacing)
            lastObject = difficultyButton

            if duiFrame.IndexGamePadObject then
               duiFrame:IndexGamePadObject(difficultyButton)
            end
        end
    end

    if duiFrame.AcceptButton then duiFrame.AcceptButton:Hide() end

    local contentHeight = 0
    if firstObject and lastObject then
         contentHeight = duiFrame.ContentFrame:GetTop() - lastObject:GetBottom() + 20
    end
    duiFrame:SetScrollRange(contentHeight)
end

local function PlayDiceOnClick(button)
    diceGameState = 1
    local duiFrame = button.owner
    if duiFrame then
        DisplayDifficultyOptions(duiFrame)
    end
    return true
end

local function IsNumberedOptionType(buttonType)
    return buttonType == "gossip" or buttonType == "availableQuest" or buttonType == "activeQuest"
end

local function HookedHandleGossip(duiFrame, ...)
    if diceGameState == 1 then
        DisplayDifficultyOptions(duiFrame)
        return true
    end

    ---@diagnostic disable-next-line: need-check-nil
    local shouldShowOriginalUI = originalHandleGossip(duiFrame, ...)

    local shouldAddDiceButton = false
    if shouldShowOriginalUI then
        if UnitExists("target") then
            local guid = UnitGUID("target")
            if guid then
                local unitId = select(6, strsplit("-", guid))
                if unitId then
                    shouldAddDiceButton = IsFarklePlayer(unitId)
                end
            end
        end
    end

    if shouldAddDiceButton and not duiFrame.questLayout and not duiFrame.requireGossipConfirm and duiFrame.selectedGossipIndex == nil then
        local relevantButtonCount = 0
        local lowestRelevantButton = nil
        local lowestRelevantButtonBottom = math.huge

        if duiFrame.optionButtonPool then
            for _, button in duiFrame.optionButtonPool:EnumerateActive() do
                if button:IsShown() and IsNumberedOptionType(button.type) then
                    relevantButtonCount = relevantButtonCount + 1
                    local bottom = button:GetBottom()
                    if bottom < lowestRelevantButtonBottom then
                        lowestRelevantButtonBottom = bottom
                        lowestRelevantButton = button
                    end
                end
            end
        end
        local nextIndex = relevantButtonCount + 1

        local hotkeyString = (nextIndex <= 9) and tostring(nextIndex) or nil
        local buttonText = L["DICE_OPTION"]
        if hotkeyString then
            buttonText = hotkeyString .. ". " .. buttonText
        end

        local lastObject = nil
        local spacing = -1
        if lowestRelevantButton then
            lastObject = lowestRelevantButton
        else
            local lowestText = nil
            local lowestTextBottom = math.huge
            if duiFrame.fontStringPool then
                 for _, fs in duiFrame.fontStringPool:EnumerateActive() do
                     if fs:IsShown() then
                         local bottom = fs:GetBottom()
                         if bottom < lowestTextBottom then
                             lowestTextBottom = bottom
                             lowestText = fs
                         end
                     end
                 end
            end
            if lowestText then
                 lastObject = lowestText
                 spacing = -(duiFrame.PARAGRAPH_BUTTON_SPACING or 17)
            end
        end

        if lastObject then
            local diceButton = duiFrame:AcquireOptionButton()
            if diceButton then
                local diceGossipData = { name = buttonText, icon = "Interface/Buttons/UI-GroupLoot-Dice-Up" }
                diceButton:SetGossip(diceGossipData, nil)
                diceButton.type = "gossip"
                diceButton.onClickFunc = function(self)
                    emulateClick(self, PlayDiceOnClick); self:Disable()
                    return true
                end

                diceButton:SetScript("OnKeyDown", function(self, button)
                    if not self:IsEnabled() then return end
                    if button == hotkeyString and not UnitAffectingCombat("player") then
                        self:SetPropagateKeyboardInput(false); self:Click()
                    elseif button == hotkeyString then
                        self:SetPropagateKeyboardInput(true); self:Click()
                    else
                        self:SetPropagateKeyboardInput(true)
                    end
                end)

                diceButton:ClearAllPoints(); diceButton:SetPoint("TOPLEFT", lastObject, "BOTTOMLEFT", 0, spacing)

                local contentTop = duiFrame.ContentFrame:GetTop()
                local newButtonBottom = diceButton:GetBottom()
                local newContentHeight = math.max(duiFrame.contentHeight or 0, contentTop - newButtonBottom + 20)
                duiFrame:SetScrollRange(newContentHeight)

                if duiFrame.IndexGamePadObject then
                   duiFrame:IndexGamePadObject(diceButton)
                end
            end
        end
    end

    return shouldShowOriginalUI
end

local function OnGossipClosed()
    diceGameState = nil
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("GOSSIP_CLOSED")

eventFrame:SetScript("OnEvent", function(self, event, addonName)
    if event == "ADDON_LOADED" and addonName == "DialogueUI" then
        originalHandleGossip = DUIQuestFrame.HandleGossip
        DUIQuestFrame.HandleGossip = HookedHandleGossip

        local originalOnHide = DUIQuestFrame.OnHide
        DUIQuestFrame.OnHide = function(frameSelf, ...)
            OnGossipClosed(); return originalOnHide(frameSelf, ...)
        end
    elseif event == "GOSSIP_CLOSED" and C_AddOns.IsAddOnLoaded("DialogueUI") then
        OnGossipClosed()
    end
end)