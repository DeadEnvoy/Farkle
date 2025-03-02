local addonName, farkle = ...

local L = farkle.L

if GetLocale() == "ruRU" then
    FarkleBoard.Logo:SetTexture("Interface/AddOns/Farkle/Media/Logo_ruRU")
    if UnitSex("player") == 3 then
        L.READY = L.READY_FEMALE
    else
        L.READY = L.READY_MALE
    end
end

---@diagnostic disable-next-line: undefined-global
FarkleBoard.Input_Key_Q = FarkleBoard_Input_Key_Q
---@diagnostic disable-next-line: undefined-global
FarkleBoard.Input_Key_E = FarkleBoard_Input_Key_E
---@diagnostic disable-next-line: undefined-global
FarkleBoard.Input_Key_T = FarkleBoard_Input_Key_T
---@diagnostic disable-next-line: undefined-global
FarkleBoard.Input_Key_ESC = FarkleBoard_Input_Key_ESC

FarkleBoard.Input_Key_Q.fontString.text:SetText(L.PASS)
FarkleBoard.Input_Key_E.fontString.text:SetText(L.HOLD)
FarkleBoard.Input_Key_T.fontString.text:SetText(L.RULES)
FarkleBoard.Input_Key_ESC.fontString.text:SetText(L.GIVE_UP)

FarkleBoard.PlayerBoard.TotalPlayerLabel:SetText(L.TOTAL_LABEL)
FarkleBoard.PlayerBoard.RoundPlayerLabel:SetText(L.ROUND_LABEL)
FarkleBoard.PlayerBoard.HoldPlayerLabel:SetText(L.HOLD_LABEL)

FarkleBoard.OpponentBoard.TotalOpponentLabel:SetText(L.TOTAL_LABEL)
FarkleBoard.OpponentBoard.RoundOpponentLabel:SetText(L.ROUND_LABEL)
FarkleBoard.OpponentBoard.HoldOpponentLabel:SetText(L.HOLD_LABEL)

FarkleBoard = FarkleBoard

local function CheckKey(key)
    local keys = {
        "MOVEFORWARD", "STRAFELEFT", "MOVEBACKWARD", "STRAFERIGHT", "JUMP", "EXTRAACTIONBUTTON1",
        "ACTIONBUTTON1", "ACTIONBUTTON2", "ACTIONBUTTON3", "ACTIONBUTTON4", "ACTIONBUTTON5", "ACTIONBUTTON6", "ACTIONBUTTON7", "ACTIONBUTTON8", "ACTIONBUTTON9", "ACTIONBUTTON10", "ACTIONBUTTON11", "ACTIONBUTTON12",
        "MULTIACTIONBAR1BUTTON1", "MULTIACTIONBAR1BUTTON2", "MULTIACTIONBAR1BUTTON3", "MULTIACTIONBAR1BUTTON4", "MULTIACTIONBAR1BUTTON5", "MULTIACTIONBAR1BUTTON6", "MULTIACTIONBAR1BUTTON7", "MULTIACTIONBAR1BUTTON8", "MULTIACTIONBAR1BUTTON9", "MULTIACTIONBAR1BUTTON10", "MULTIACTIONBAR1BUTTON11", "MULTIACTIONBAR1BUTTON12", "MULTIACTIONBAR2BUTTON1", "MULTIACTIONBAR2BUTTON2", "MULTIACTIONBAR2BUTTON3", "MULTIACTIONBAR2BUTTON4", "MULTIACTIONBAR2BUTTON5", "MULTIACTIONBAR2BUTTON6", "MULTIACTIONBAR2BUTTON7", "MULTIACTIONBAR2BUTTON8", "MULTIACTIONBAR2BUTTON9", "MULTIACTIONBAR2BUTTON10", "MULTIACTIONBAR2BUTTON11", "MULTIACTIONBAR2BUTTON12", "MULTIACTIONBAR3BUTTON1", "MULTIACTIONBAR3BUTTON2", "MULTIACTIONBAR3BUTTON3", "MULTIACTIONBAR3BUTTON4", "MULTIACTIONBAR3BUTTON5", "MULTIACTIONBAR3BUTTON6", "MULTIACTIONBAR3BUTTON7", "MULTIACTIONBAR3BUTTON8", "MULTIACTIONBAR3BUTTON9", "MULTIACTIONBAR3BUTTON10", "MULTIACTIONBAR3BUTTON11", "MULTIACTIONBAR3BUTTON12", "MULTIACTIONBAR4BUTTON1", "MULTIACTIONBAR4BUTTON2", "MULTIACTIONBAR4BUTTON3", "MULTIACTIONBAR4BUTTON4", "MULTIACTIONBAR4BUTTON5", "MULTIACTIONBAR4BUTTON6", "MULTIACTIONBAR4BUTTON7", "MULTIACTIONBAR4BUTTON8", "MULTIACTIONBAR4BUTTON9", "MULTIACTIONBAR4BUTTON10", "MULTIACTIONBAR4BUTTON11", "MULTIACTIONBAR4BUTTON12", "MULTIACTIONBAR5BUTTON1", "MULTIACTIONBAR5BUTTON2", "MULTIACTIONBAR5BUTTON3", "MULTIACTIONBAR5BUTTON4", "MULTIACTIONBAR5BUTTON5", "MULTIACTIONBAR5BUTTON6", "MULTIACTIONBAR5BUTTON7", "MULTIACTIONBAR5BUTTON8", "MULTIACTIONBAR5BUTTON9", "MULTIACTIONBAR5BUTTON10", "MULTIACTIONBAR5BUTTON11", "MULTIACTIONBAR5BUTTON12", "MULTIACTIONBAR6BUTTON1", "MULTIACTIONBAR6BUTTON2", "MULTIACTIONBAR6BUTTON3", "MULTIACTIONBAR6BUTTON4", "MULTIACTIONBAR6BUTTON5", "MULTIACTIONBAR6BUTTON6", "MULTIACTIONBAR6BUTTON7", "MULTIACTIONBAR6BUTTON8", "MULTIACTIONBAR6BUTTON9", "MULTIACTIONBAR6BUTTON10", "MULTIACTIONBAR6BUTTON11", "MULTIACTIONBAR6BUTTON12", "MULTIACTIONBAR7BUTTON1", "MULTIACTIONBAR7BUTTON2", "MULTIACTIONBAR7BUTTON3", "MULTIACTIONBAR7BUTTON4", "MULTIACTIONBAR7BUTTON5", "MULTIACTIONBAR7BUTTON6", "MULTIACTIONBAR7BUTTON7", "MULTIACTIONBAR7BUTTON8", "MULTIACTIONBAR7BUTTON9", "MULTIACTIONBAR7BUTTON10", "MULTIACTIONBAR7BUTTON11", "MULTIACTIONBAR7BUTTON12"
    }
    for _, bindingKey in pairs(keys) do
        if GetBindingKey(bindingKey) == key then
            return true
        end
    end
end

local function Input_Key_Q()
    if not C_Farkle.IsPlaying() then return end
    if FarkleBoard.TutorialFrame:IsShown() then return end
    if not FarkleBoard.Input_Key_Q:IsEnabled() then return end
    C_Farkle:CancelTimer(); C_Farkle.SendAddonMessage("cancel_timer");
    if farkle.calculateScore(farkle.player["diceHold"]) > 0 then
        local dices, score, delay = {}, {}, 0
            for i, y in pairs(farkle.player["diceHold"]) do
                table.insert(dices, tonumber(y))
                S_Timer.After(delay, function() 
                    table.insert(score, tonumber(y))
                    farkle.board["dices"][i]:Hide();
                    farkle.player["diceHold"][i] = nil
                end)
                delay = delay + 0.5
            end

            for i = 1, 6 do
                if farkle.board["dices"] and farkle.board["dices"][i] then
                    farkle.board["dices"][i]:SetScript("OnMouseUp", function() end)
                end
            end

            local diceHoldStrings = {}
            for i, y in pairs(farkle.player["diceHold"]) do
                table.insert(diceHoldStrings, i .. ":" .. y)
            end
            
            delay = #dices / 2 + 0.5
            C_Farkle.SendAddonMessage(format("hold:%s:%s", delay, table.concat(diceHoldStrings, ":")))
            S_Timer.After(delay, function()
                if C_Farkle.IsPlaying() then
                    for i = 1, #dices do farkle.player["diceHold"][i] = nil end
                    C_Farkle:SetScore("player", farkle.player.total + (farkle.player.hold + farkle.player.round), 0, 0);
                    dices, score, delay = {}, {}, 0
                    S_Timer.After(0.8, function()
                        if C_Farkle.IsPlayerTurn() and farkle.player.total >= C_Farkle.GetBoardInfo("total") then
                            C_Farkle.SendAddonMessage("lose"); C_Farkle.Victory("won")
                        else
                            C_Farkle:SwitchPlayerTurn()
                            if C_Farkle.IsPvP() then
                                C_Farkle.CheckOnline()
                            elseif C_Farkle.IsPvE() then
                                S_Timer.After(1.5, function()
                                    C_Farkle.RollDice(C_Farkle.GetBoardInfo("roll"), 6)
                                end)
                            end
                        end
                        C_Farkle:ClearBoard(); farkle.player["diceHold"] = {}; farkle.player.selected = 0
                    end)
                end
            end)
    else
        C_Farkle:SetValue("rolls", 0)
        C_Farkle:SetScore("player", farkle.player.total + (farkle.player.hold + farkle.player.round), 0, 0);
        if C_Farkle.IsPlayerTurn() and farkle.player.total >= C_Farkle.GetBoardInfo("total") then
            C_Farkle.SendAddonMessage("lose"); C_Farkle.Victory("won")
        else
            C_Farkle:SwitchPlayerTurn()
        end
    end
    C_Farkle:DisableButton(FarkleBoard.Input_Key_Q); C_Farkle:DisableButton(FarkleBoard.Input_Key_E);
end

local function Input_Key_R()
    if C_Farkle.IsReady() then return end
    if C_Farkle.HasOpponent() and C_Farkle.GetBoardInfo("stage") == "start" then
        C_Timer.After(.01, function() FarkleBoard.ReadyPlayerButton:Disable() end)
        C_Farkle.SendAddonMessage("ready:yes"); farkle.player.ready = true
        if (farkle.player.ready and farkle.opponent.ready) and (C_Farkle.IsPvE() or C_Farkle.GetValue("requester")) then
            local coinResult = math.random(1, 2); C_Farkle.CoinFlip(coinResult)
            C_Farkle.SendAddonMessage(format("coin:%s", coinResult))
        end
    end
end

local function Input_Key_E()
    if not C_Farkle.IsPlaying() then return end
    if FarkleBoard.TutorialFrame:IsShown() then return end
    if not FarkleBoard.Input_Key_E:IsEnabled() then return end
    C_Farkle:CancelTimer(); C_Farkle.SendAddonMessage("cancel_timer");
    C_Farkle:DisableButton(FarkleBoard.Input_Key_Q); C_Farkle:DisableButton(FarkleBoard.Input_Key_E);
    if C_Farkle.IsPlayerTurn() then
        local dices, score, delay = {}, {}, 0

        for i = 1, 6 do
            if farkle.board["dices"] and farkle.board["dices"][i] then
                farkle.board["dices"][i]:SetScript("OnMouseUp", function() end)
            end
        end

        local diceHoldStrings = {}
        for i, y in pairs(farkle.player["diceHold"]) do
            table.insert(diceHoldStrings, i .. ":" .. y)
        end

        for i, y in pairs(farkle.player["diceHold"]) do
            table.insert(dices, tonumber(y))
            S_Timer.After(delay, function()
                table.insert(score, tonumber(y))
                farkle.board["dices"][i]:Hide();
                farkle.player["diceHold"][i] = nil
            end)
            delay = delay + 0.5
        end

        delay = #dices / 2 + 0.5
        C_Farkle.SendAddonMessage(format("hold:%s:%s", delay, table.concat(diceHoldStrings, ":")))

        S_Timer.After(delay + 0.8, function ()
            C_Farkle:ClearBoard();
            if farkle.player.selected == 6 then
                farkle.player.selected = 0;
                C_Farkle.RollDice(C_Farkle.GetBoardInfo("roll"), 6, delay);
                C_Farkle:SetValue("rolls", C_Farkle.GetValue("rolls") + 1)
            else
                C_Farkle.RollDice(C_Farkle.GetBoardInfo("roll"), 6 - farkle.player.selected, delay)
            end
        end)

        S_Timer.After(delay, function()
            if C_Farkle.IsPlaying() then
                for i = 1, #dices do farkle.player["diceHold"][i] = nil end
                C_Farkle:SetScore("player", farkle.player.total, farkle.player.round + farkle.calculateScore(score), 0)
                dices, score, delay = {}, {}, 0
                S_Timer.After(1, function()
                    C_Farkle:ClearBoard(); farkle.player["diceHold"] = {}
                end)
            end
        end)
    end
end

local function Input_Key_T()
    if C_Farkle.GetBoardInfo("stage") ~= "coin-flip" then
        if not FarkleBoard.TutorialFrame:IsShown() then
            FarkleBoard.TutorialFrame:Show()
            if FarkleBoard.TutorialFrame.CurrentPage == 1 then
                FarkleBoard.TutorialFrame.CurrentPage = 1
                FarkleBoard.TutorialFrame.Page:SetText("(1/2)")
                FarkleBoard.TutorialFrame.Label:SetText(L.TUTORIAL_BASIC_LABEL);
                FarkleBoard.TutorialFrame.Text:SetText(L.TUTORIAL_BASIC);
                FarkleBoard.TutorialFrame.Text:SetSpacing(4)

                C_Farkle:DisableButton(FarkleBoard.TutorialFrame.PrevPageButton)
                C_Farkle:EnableButton(FarkleBoard.TutorialFrame.NextPageButton)
            end
        else
            FarkleBoard.TutorialFrame:Hide()
        end
    end
end

local function Input_Key_ESC()
    if C_Farkle.IsPlaying() then
        StaticPopupDialogs["GIVE_UP_POPUP"] = {
            text = L["GIVE_UP_OFFER"],
            button1 = YES,
            button2 = NO,
            OnAccept = function()
                S_Timer:CancelAllTimers();
                C_Farkle.SendAddonMessage("surrender")
                C_Farkle.Defeat("gave_up");
            end,
            OnCancel = function() end,
            timeout = 10,
            whileDead = false,
            hideOnEscape = true,
            preferredIndex = 3,
            OnShow = function(self)
                self:ClearAllPoints(); self:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            end,
        }
        StaticPopup_Show("GIVE_UP_POPUP")
    elseif C_Farkle.HasOpponent() then
        StaticPopupDialogs["EXIT_GAME_POPUP"] = {
            text = L["EXIT_GAME_OFFER"],
            button1 = YES,
            button2 = NO,
            OnAccept = function()
                C_Farkle:ExitGame(1)
            end,
            OnCancel = function() end,
            timeout = 10,
            whileDead = false,
            hideOnEscape = true,
            preferredIndex = 3,
            OnShow = function(self)
                self:ClearAllPoints(); self:SetPoint("CENTER", UIParent, "CENTER", 0, 0)
            end,
        }
        StaticPopup_Show("EXIT_GAME_POPUP")
    else
        C_Farkle:ExitGame(1)
    end
end

local function Input_Key_D()
    if FarkleBoard.TutorialFrame:IsShown() and FarkleBoard.TutorialFrame.CurrentPage == 1 then
        FarkleBoard.TutorialFrame.CurrentPage = 2
        FarkleBoard.TutorialFrame.Page:SetText("(2/2)")
        FarkleBoard.TutorialFrame.Label:SetText(L.TUTORIAL_COMBINATIONS_LABEL)
        FarkleBoard.TutorialFrame.Text:SetText(L.TUTORIAL_COMBINATIONS);
        FarkleBoard.TutorialFrame.Text:SetSpacing(2)

        C_Farkle:DisableButton(FarkleBoard.TutorialFrame.NextPageButton)
        C_Farkle:EnableButton(FarkleBoard.TutorialFrame.PrevPageButton)
    end
end

local function Input_Key_A()
    if FarkleBoard.TutorialFrame:IsShown() and FarkleBoard.TutorialFrame.CurrentPage == 2 then
        FarkleBoard.TutorialFrame.CurrentPage = 1
        FarkleBoard.TutorialFrame.Page:SetText("(1/2)")
        FarkleBoard.TutorialFrame.Label:SetText(L.TUTORIAL_BASIC_LABEL)
        FarkleBoard.TutorialFrame.Text:SetText(L.TUTORIAL_BASIC);
        FarkleBoard.TutorialFrame.Text:SetSpacing(4)

        C_Farkle:DisableButton(FarkleBoard.TutorialFrame.PrevPageButton)
        C_Farkle:EnableButton(FarkleBoard.TutorialFrame.NextPageButton)
    end
end

FarkleBoard:SetScript("OnKeyDown", function(self, key)
    if key == "Q" then
        self:SetPropagateKeyboardInput(false); Input_Key_Q()
    elseif key == "E" then
        self:SetPropagateKeyboardInput(false); Input_Key_E()
    elseif key == "R" then
        self:SetPropagateKeyboardInput(false); Input_Key_R()
    elseif key == "T" then
        self:SetPropagateKeyboardInput(false); Input_Key_T()
    elseif key == "D" then
        self:SetPropagateKeyboardInput(false); Input_Key_D()
    elseif key == "A" then
        self:SetPropagateKeyboardInput(false); Input_Key_A()
    elseif key == "ESCAPE" then
        self:SetPropagateKeyboardInput(false); Input_Key_ESC()
    elseif CheckKey(key) then
        self:SetPropagateKeyboardInput(false)
    else
        self:SetPropagateKeyboardInput(true)
    end
end)

FarkleBoard.CloseButton:SetScript("OnClick", function()
    Input_Key_ESC()
end)

FarkleBoard.ReadyPlayerButton:SetScript("OnClick", function(self)
    if C_Farkle.HasOpponent() then
        self.Highlight:SetAlpha(0); Input_Key_R()
    end
end)

FarkleBoard.ReadyPlayerButton.Highlight = CreateFrame("Frame", nil, FarkleBoard.ReadyPlayerButton); FarkleBoard.ReadyPlayerButton.Highlight:SetAlpha(0)
FarkleBoard.ReadyPlayerButton.Highlight:SetSize(80, 80); FarkleBoard.ReadyPlayerButton.Highlight:SetPoint("CENTER", FarkleBoard.ReadyPlayerButton)

FarkleBoard.ReadyPlayerButton.Highlight.Texture = FarkleBoard.ReadyPlayerButton.Highlight:CreateTexture(nil, "ARTWORK"); FarkleBoard.ReadyPlayerButton.Highlight.Texture:SetDesaturated(true)
FarkleBoard.ReadyPlayerButton.Highlight.Texture:SetAllPoints(); FarkleBoard.ReadyPlayerButton.Highlight.Texture:SetAtlas("UI-LFG-RoleIcon-Incentive")

FarkleBoard.ReadyPlayerButton:SetScript("OnEnter", function(self)
    if not C_Farkle.HasOpponent() then return end
    GameTooltip:SetOwner(self, "ANCHOR_TOP", 0, 10)
    GameTooltip:SetText(L.READY, 1, 1, 1); GameTooltip:Show()
    UIFrameFadeIn(FarkleBoard.ReadyPlayerButton.Highlight, 0.25, FarkleBoard.ReadyPlayerButton.Highlight:GetAlpha(), 0.25)
end)

FarkleBoard.ReadyPlayerButton:SetScript("OnLeave", function(self)
    GameTooltip:Hide(); UIFrameFadeIn(FarkleBoard.ReadyPlayerButton.Highlight, 0.25, FarkleBoard.ReadyPlayerButton.Highlight:GetAlpha(), 0)
end)

farkle.ChatMessageFrame = {
    ["player"] = nil,
    ["opponent"] = nil
}

farkle.ChatMessageFrame["player"] = CreateFrame("MessageFrame", nil, FarkleBoard)
farkle.ChatMessageFrame["player"]:SetSize(450, 100); farkle.ChatMessageFrame["player"]:SetPoint("BOTTOM", FarkleBoard, "BOTTOM", 0, 100)
farkle.ChatMessageFrame["player"]:SetFont("Interface/AddOns/Farkle/Fonts/VINQUE.OTF", 18, ""); farkle.ChatMessageFrame["player"]:SetInsertMode("BOTTOM")
farkle.ChatMessageFrame["player"]:SetShadowOffset(1, -1); farkle.ChatMessageFrame["player"]:SetShadowColor(0, 0, 0); farkle.ChatMessageFrame["player"]:SetSpacing(2)
farkle.ChatMessageFrame["player"]:SetTimeVisible(5); farkle.ChatMessageFrame["player"]:SetFadeDuration(0.25);

farkle.ChatMessageFrame["opponent"] = CreateFrame("MessageFrame", nil, FarkleBoard)
farkle.ChatMessageFrame["opponent"]:SetSize(450, 100); farkle.ChatMessageFrame["opponent"]:SetPoint("TOP", FarkleBoard, "TOP", 0, -80)
farkle.ChatMessageFrame["opponent"]:SetFont("Interface/AddOns/Farkle/Fonts/VINQUE.OTF", 18, ""); farkle.ChatMessageFrame["opponent"]:SetInsertMode("TOP")
farkle.ChatMessageFrame["opponent"]:SetShadowOffset(1, -1); farkle.ChatMessageFrame["opponent"]:SetShadowColor(0, 0, 0); farkle.ChatMessageFrame["opponent"]:SetSpacing(2)
farkle.ChatMessageFrame["opponent"]:SetTimeVisible(5); farkle.ChatMessageFrame["opponent"]:SetFadeDuration(0.25)

farkle.MessageFrame = {
    ["info"] = nil,
    ["warning"] = nil
}

farkle.MessageFrame["info"] = CreateFrame("MessageFrame", nil, FarkleBoard)
farkle.MessageFrame["info"]:SetSize(450, 50); farkle.MessageFrame["info"]:SetPoint("CENTER", FarkleBoard, "CENTER")
farkle.MessageFrame["info"]:SetFont("Interface/AddOns/Farkle/Fonts/VINQUE.OTF", 20, ""); farkle.MessageFrame["info"]:SetInsertMode("BOTTOM")
farkle.MessageFrame["info"]:SetShadowOffset(1, -1); farkle.MessageFrame["info"]:SetShadowColor(0, 0, 0); farkle.MessageFrame["info"]:SetFrameLevel(farkle.ChatMessageFrame["player"]:GetFrameLevel() + 1)
farkle.MessageFrame["info"]:SetTimeVisible(1.5); farkle.MessageFrame["info"]:SetFadeDuration(0.25)

farkle.MessageFrame["warning"] = CreateFrame("MessageFrame", nil, FarkleBoard)
farkle.MessageFrame["warning"]:SetSize(450, 50); farkle.MessageFrame["warning"]:SetPoint("CENTER", FarkleBoard, "CENTER")
farkle.MessageFrame["warning"]:SetFont("Interface/AddOns/Farkle/Fonts/VINQUE.OTF", 20, ""); farkle.MessageFrame["warning"]:SetInsertMode("BOTTOM")
farkle.MessageFrame["warning"]:SetShadowOffset(1, -1); farkle.MessageFrame["warning"]:SetShadowColor(0, 0, 0)
farkle.MessageFrame["warning"]:SetTimeVisible(1.5); farkle.MessageFrame["warning"]:SetFadeDuration(0.25)

function C_Farkle:AddInfoMessage(point, text, time)
    if point == "TOP" then
        farkle.MessageFrame["info"]:ClearAllPoints(); farkle.MessageFrame["info"]:SetPoint("TOP", FarkleBoard, "TOP", 0, -180)
    elseif point == "CENTER" then
        farkle.MessageFrame["info"]:ClearAllPoints(); farkle.MessageFrame["info"]:SetPoint("CENTER", FarkleBoard, "CENTER", 0, 0)
    elseif point == "CENTER-BOTTOM" then
        farkle.MessageFrame["info"]:ClearAllPoints(); farkle.MessageFrame["info"]:SetPoint("CENTER", FarkleBoard, "CENTER", 0, -80)
    elseif point == "BOTTOM" then
        farkle.MessageFrame["info"]:ClearAllPoints(); farkle.MessageFrame["info"]:SetPoint("BOTTOM", FarkleBoard, "BOTTOM", 0, 125)
        UIFrameFadeIn(farkle.ChatMessageFrame["player"], 0.25, farkle.ChatMessageFrame["player"]:GetAlpha(), 0.25); C_Timer.After(1.5, function()
            UIFrameFadeOut(farkle.ChatMessageFrame["player"], 0.25, farkle.ChatMessageFrame["player"]:GetAlpha(), 1)
        end)
    end
    farkle.MessageFrame["info"]:SetTimeVisible(time or 1.5); farkle.MessageFrame["info"]:AddMessage(text, 1, 0.82, 0)
end

function C_Farkle:AddWarningMessage(point, text, time)
    if point == "CENTER" then
        farkle.MessageFrame["warning"]:ClearAllPoints(); farkle.MessageFrame["warning"]:SetPoint("CENTER", FarkleBoard, "CENTER", 0, 0)
    elseif point == "CENTER-BOTTOM" then
        farkle.MessageFrame["warning"]:ClearAllPoints(); farkle.MessageFrame["warning"]:SetPoint("CENTER", FarkleBoard, "CENTER", 0, -80)
    elseif point == "BOTTOM" then
        farkle.MessageFrame["warning"]:ClearAllPoints(); farkle.MessageFrame["warning"]:SetPoint("BOTTOM", FarkleBoard, "BOTTOM", 0, 125)
    end
    farkle.MessageFrame["warning"]:SetTimeVisible(time or 1.5)
    farkle.MessageFrame["warning"]:AddMessage(text, 1, 0.25, 0.25)
end

function C_Farkle:AddChatMessage(type, unit, text)
    if unit == "player" then
        if C_Farkle.GetBoardInfo("stage") == "start" then
            farkle.ChatMessageFrame["player"]:ClearAllPoints(); farkle.ChatMessageFrame["player"]:SetPoint("BOTTOM", FarkleBoard, "BOTTOM", 0, 180)
        else
            farkle.ChatMessageFrame["player"]:ClearAllPoints(); farkle.ChatMessageFrame["player"]:SetPoint("BOTTOM", FarkleBoard, "BOTTOM", 0, 100)
        end
        if type == "say" then
            local classColor = RAID_CLASS_COLORS[select(2, UnitClass("player"))]
            local colorRGB = CreateColor(classColor.r, classColor.g, classColor.b)
            farkle.ChatMessageFrame["player"]:AddMessage(format("%s: %s", colorRGB:WrapTextInColorCode(UnitName("player")), text), 1, 1, 1)
        elseif type == "emote" then
            farkle.ChatMessageFrame["player"]:AddMessage(text, 1, 0.5, 0.25)
        end
    elseif unit == "opponent" then
        if C_Farkle.GetBoardInfo("stage") == "start" then
            farkle.ChatMessageFrame["opponent"]:ClearAllPoints(); farkle.ChatMessageFrame["opponent"]:SetPoint("TOP", FarkleBoard, "TOP", 0, -180)
        else
            farkle.ChatMessageFrame["opponent"]:ClearAllPoints(); farkle.ChatMessageFrame["opponent"]:SetPoint("TOP", FarkleBoard, "TOP", 0, -100)
        end
        if type == "say" then
            if C_Farkle.IsPvP() then
                local classColor = RAID_CLASS_COLORS[C_Farkle.GetOpponentInfo("class")]
                local colorRGB = CreateColor(classColor.r, classColor.g, classColor.b)
                ---@diagnostic disable-next-line: param-type-mismatch
                farkle.ChatMessageFrame["opponent"]:AddMessage(format("%s: %s", colorRGB:WrapTextInColorCode(C_Farkle.GetOpponentInfo("name")), text), 1, 1, 1)
            else
                farkle.ChatMessageFrame["opponent"]:AddMessage(format("|cffe6b300%s|r: %s", C_Farkle.GetOpponentInfo("name"), text), 1, 1, 1)
            end
        elseif type == "emote" then
            farkle.ChatMessageFrame["opponent"]:AddMessage(text, 1, 0.5, 0.25)
        end
    end
end

EventRegistry:RegisterFrameEventAndCallback("CHAT_MSG_SAY", function(ownerID, text, playerName, ...)
    if C_Farkle.GetBoardInfo("stage") and C_Farkle.HasOpponent() then
        if playerName == UnitName("player") or playerName == ("%s-%s"):format(UnitFullName("player")) then
            C_Farkle:AddChatMessage("say", "player", text)
        elseif playerName == C_Farkle.GetOpponentInfo("name") or playerName == format("%s-%s", C_Farkle.GetOpponentInfo("name"), C_Farkle.GetOpponentInfo("realm")) then
            C_Farkle:AddChatMessage("say", "opponent", text)
        end
    end
end)

EventRegistry:RegisterFrameEventAndCallback("CHAT_MSG_TEXT_EMOTE", function(ownerID, text, playerName, ...)
    if C_Farkle.GetBoardInfo("stage") == "start" or C_Farkle.GetBoardInfo("stage") == "game" and C_Farkle.HasOpponent() then
        if playerName == UnitName("player") or playerName == ("%s-%s"):format(UnitFullName("player")) then
            C_Farkle:AddChatMessage("emote", "player", text)
        elseif playerName == C_Farkle.GetOpponentInfo("name") or playerName == format("%s-%s", C_Farkle.GetOpponentInfo("name"), C_Farkle.GetOpponentInfo("realm")) then
            C_Farkle:AddChatMessage("emote", "opponent", text)
        end
    end
end)

EventRegistry:RegisterFrameEventAndCallback("CHAT_MSG_EMOTE", function(ownerID, text, playerName, ...)
    if C_Farkle.GetBoardInfo("stage") == "start" or C_Farkle.GetBoardInfo("stage") == "game" and C_Farkle.HasOpponent() then
        if playerName == UnitName("player") or playerName == ("%s-%s"):format(UnitFullName("player")) then
            C_Farkle:AddChatMessage("emote", "player", format("%s %s", UnitName("player"), text))
        elseif playerName == C_Farkle.GetOpponentInfo("name") or playerName == format("%s-%s", C_Farkle.GetOpponentInfo("name"), C_Farkle.GetOpponentInfo("realm")) then
            C_Farkle:AddChatMessage("emote", "opponent", format("%s %s", C_Farkle.GetOpponentInfo("name"), text))
        end
    end
end)


FarkleBoard.Input_Key_Q:SetScript("OnClick", function(self)
    Input_Key_Q();
end)

FarkleBoard.Input_Key_E:SetScript("OnClick", function(self)
    Input_Key_E();
end)

FarkleBoard.Input_Key_T:SetScript("OnClick", function(self)
    Input_Key_T();
end)

FarkleBoard.Input_Key_ESC:SetScript("OnClick", function(self)
    Input_Key_ESC();
end)

FarkleBoard.ReadyKeyButton = CreateFrame("Button", nil, FarkleBoard); FarkleBoard.ReadyKeyButton:SetPoint("LEFT", FarkleBoard, 90, 0)
FarkleBoard.ReadyKeyButton:SetSize(32, 29); FarkleBoard.ReadyKeyButton:SetParent(FarkleBoard);
FarkleBoard.ReadyKeyButton:SetNormalTexture("Interface/AddOns/Farkle/Media/Keys/KEY_R_NORMAL")
FarkleBoard.ReadyKeyButton:SetHighlightTexture("Interface/AddOns/Farkle/Media/Keys/KEY_SINGLE_HIGHLIGHT")
FarkleBoard.ReadyKeyButton:SetPushedTexture("Interface/AddOns/Farkle/Media/Keys/KEY_R_PUSHED")
FarkleBoard.ReadyKeyButton:SetScript("OnClick", function() Input_Key_R() end)
FarkleBoard.ReadyKeyButton.Text = FarkleBoard.ReadyKeyButton:CreateFontString(nil, "OVERLAY"); FarkleBoard.ReadyKeyButton.Text:SetParent(FarkleBoard.ReadyKeyButton)
FarkleBoard.ReadyKeyButton.Text:SetFont("Interface/AddOns/Farkle/Fonts/VINQUE.OTF", 18); FarkleBoard.ReadyKeyButton.Text:SetPoint("LEFT", FarkleBoard.ReadyKeyButton, "RIGHT", 10, 0)
FarkleBoard.ReadyKeyButton.Text:SetShadowColor(0, 0, 0); FarkleBoard.ReadyKeyButton.Text:SetShadowOffset(1, -1); FarkleBoard.ReadyKeyButton.Text:SetTextColor(0.800, 0.800, 0.800)
FarkleBoard.ReadyKeyButton.Text:SetText(L.READY)

FarkleBoard.TutorialKeyButton = CreateFrame("Button", nil, FarkleBoard); FarkleBoard.TutorialKeyButton:SetPoint("RIGHT", FarkleBoard, -90, 0)
FarkleBoard.TutorialKeyButton:SetSize(32, 29); FarkleBoard.TutorialKeyButton:SetParent(FarkleBoard);
FarkleBoard.TutorialKeyButton:SetNormalTexture("Interface/AddOns/Farkle/Media/Keys/KEY_T_NORMAL")
FarkleBoard.TutorialKeyButton:SetHighlightTexture("Interface/AddOns/Farkle/Media/Keys/KEY_SINGLE_HIGHLIGHT")
FarkleBoard.TutorialKeyButton:SetPushedTexture("Interface/AddOns/Farkle/Media/Keys/KEY_T_PUSHED")
FarkleBoard.TutorialKeyButton:SetScript("OnClick", function() Input_Key_T() end)
FarkleBoard.TutorialKeyButton.Text = FarkleBoard.TutorialKeyButton:CreateFontString(nil, "OVERLAY"); FarkleBoard.TutorialKeyButton.Text:SetParent(FarkleBoard.TutorialKeyButton)
FarkleBoard.TutorialKeyButton.Text:SetFont("Interface/AddOns/Farkle/Fonts/VINQUE.OTF", 18); FarkleBoard.TutorialKeyButton.Text:SetPoint("RIGHT", FarkleBoard.TutorialKeyButton, "LEFT", -10, 0)
FarkleBoard.TutorialKeyButton.Text:SetShadowColor(0, 0, 0); FarkleBoard.TutorialKeyButton.Text:SetShadowOffset(1, -1); FarkleBoard.TutorialKeyButton.Text:SetTextColor(0.800, 0.800, 0.800)
FarkleBoard.TutorialKeyButton.Text:SetText(L.RULES)

-- Tutorial Frame
FarkleBoard.TutorialFrame = CreateFrame("Frame", nil, FarkleBoard); FarkleBoard.TutorialFrame:SetPoint("CENTER"); FarkleBoard.TutorialFrame:SetSize(763, 575.3)
FarkleBoard.TutorialFrame:SetFrameStrata("HIGH"); FarkleBoard.TutorialFrame:Hide(); FarkleBoard.TutorialFrame:EnableMouse(true);
FarkleBoard.TutorialFrame.Background = FarkleBoard.TutorialFrame:CreateTexture(); FarkleBoard.TutorialFrame.Background:SetTexture("Interface/AddOns/Farkle/Media/Board_Mask")
FarkleBoard.TutorialFrame.Background:SetAllPoints(); FarkleBoard.TutorialFrame.CurrentPage = 1

FarkleBoard.TutorialFrame.Control = CreateFrame("Frame", nil, FarkleBoard); FarkleBoard.TutorialFrame.Control:SetSize(750, 750);
FarkleBoard.TutorialFrame.Control:SetPoint("CENTER", FarkleBoard, "CENTER"); FarkleBoard.TutorialFrame.Control:SetParent(FarkleBoard.TutorialFrame)

FarkleBoard.TutorialFrame.Button = CreateFrame("Button", nil, FarkleBoard); FarkleBoard.TutorialFrame.Button:SetPoint("TOPLEFT", FarkleBoard, "TOPLEFT", 75, -71.5)
FarkleBoard.TutorialFrame.Button:SetSize(32, 29); FarkleBoard.TutorialFrame.Button:SetParent(FarkleBoard.TutorialFrame);
FarkleBoard.TutorialFrame.Button:SetNormalTexture("Interface/AddOns/Farkle/Media/Keys/KEY_T_NORMAL")
FarkleBoard.TutorialFrame.Button:SetHighlightTexture("Interface/AddOns/Farkle/Media/Keys/KEY_SINGLE_HIGHLIGHT")
FarkleBoard.TutorialFrame.Button:SetPushedTexture("Interface/AddOns/Farkle/Media/Keys/KEY_T_PUSHED")
FarkleBoard.TutorialFrame.Button:SetScript("OnClick", function() FarkleBoard.TutorialFrame:Hide() end)

FarkleBoard.TutorialFrame.Label = FarkleBoard.TutorialFrame:CreateFontString(nil, "OVERLAY"); FarkleBoard.TutorialFrame.Label:SetParent(FarkleBoard.TutorialFrame)
FarkleBoard.TutorialFrame.Label:SetFont("Interface/AddOns/Farkle/Fonts/VINQUE.OTF", 24); FarkleBoard.TutorialFrame.Label:SetPoint("TOPLEFT", FarkleBoard, "TOPLEFT", 115, -75)
FarkleBoard.TutorialFrame.Label:SetShadowColor(0, 0, 0); FarkleBoard.TutorialFrame.Label:SetShadowOffset(1, -1); FarkleBoard.TutorialFrame.Label:SetTextColor(0.902, 0.800, 0.600)
FarkleBoard.TutorialFrame.Label:SetText(L.TUTORIAL_BASIC_LABEL)

FarkleBoard.TutorialFrame.Page = FarkleBoard.TutorialFrame:CreateFontString(nil, "OVERLAY"); FarkleBoard.TutorialFrame.Page:SetParent(FarkleBoard.TutorialFrame)
FarkleBoard.TutorialFrame.Page:SetFont("Interface/AddOns/Farkle/Fonts/VINQUE.OTF", 20); FarkleBoard.TutorialFrame.Page:SetPoint("LEFT", FarkleBoard.TutorialFrame.Label, "RIGHT", 4, -1)
FarkleBoard.TutorialFrame.Page:SetShadowColor(0, 0, 0); FarkleBoard.TutorialFrame.Page:SetShadowOffset(1, -1); FarkleBoard.TutorialFrame.Page:SetTextColor(0.902, 0.800, 0.600)
FarkleBoard.TutorialFrame.Page:SetText("(1/2)")

FarkleBoard.TutorialFrame.NextPageButton = CreateFrame("Button", nil, FarkleBoard); FarkleBoard.TutorialFrame.NextPageButton:SetPoint("BOTTOMRIGHT", FarkleBoard, "BOTTOMRIGHT", -75, 80)
FarkleBoard.TutorialFrame.NextPageButton:SetSize(32, 29); FarkleBoard.TutorialFrame.NextPageButton:SetParent(FarkleBoard.TutorialFrame);
FarkleBoard.TutorialFrame.NextPageButton:SetNormalTexture("Interface/AddOns/Farkle/Media/Keys/KEY_D_NORMAL")
FarkleBoard.TutorialFrame.NextPageButton:SetDisabledTexture("Interface/AddOns/Farkle/Media/Keys/KEY_D_NORMAL")
FarkleBoard.TutorialFrame.NextPageButton:SetHighlightTexture("Interface/AddOns/Farkle/Media/Keys/KEY_SINGLE_HIGHLIGHT")
FarkleBoard.TutorialFrame.NextPageButton:SetPushedTexture("Interface/AddOns/Farkle/Media/Keys/KEY_D_PUSHED")
FarkleBoard.TutorialFrame.NextPageButton:SetScript("OnClick", function() Input_Key_D() end)
FarkleBoard.TutorialFrame.NextPageButton.Text = FarkleBoard.TutorialFrame.NextPageButton:CreateFontString(nil, "OVERLAY"); FarkleBoard.TutorialFrame.NextPageButton.Text:SetParent(FarkleBoard.TutorialFrame.NextPageButton)
FarkleBoard.TutorialFrame.NextPageButton.Text:SetFont("Interface/AddOns/Farkle/Fonts/VINQUE.OTF", 18); FarkleBoard.TutorialFrame.NextPageButton.Text:SetPoint("RIGHT", FarkleBoard.TutorialFrame.NextPageButton, "LEFT", -10, 0)
FarkleBoard.TutorialFrame.NextPageButton.Text:SetShadowColor(0, 0, 0); FarkleBoard.TutorialFrame.NextPageButton.Text:SetShadowOffset(1, -1); FarkleBoard.TutorialFrame.NextPageButton.Text:SetTextColor(0.800, 0.800, 0.800)
FarkleBoard.TutorialFrame.NextPageButton.Text:SetText(L.NEXT_PAGE)

FarkleBoard.TutorialFrame.PrevPageButton = CreateFrame("Button", nil, FarkleBoard); FarkleBoard.TutorialFrame.PrevPageButton:SetPoint("BOTTOMRIGHT", FarkleBoard, "BOTTOMRIGHT", -75, 125)
FarkleBoard.TutorialFrame.PrevPageButton:SetSize(32, 29); FarkleBoard.TutorialFrame.PrevPageButton:SetParent(FarkleBoard.TutorialFrame);
FarkleBoard.TutorialFrame.PrevPageButton:SetNormalTexture("Interface/AddOns/Farkle/Media/Keys/KEY_A_NORMAL")
FarkleBoard.TutorialFrame.PrevPageButton:SetDisabledTexture("Interface/AddOns/Farkle/Media/Keys/KEY_A_NORMAL")
FarkleBoard.TutorialFrame.PrevPageButton:SetHighlightTexture("Interface/AddOns/Farkle/Media/Keys/KEY_SINGLE_HIGHLIGHT")
FarkleBoard.TutorialFrame.PrevPageButton:SetPushedTexture("Interface/AddOns/Farkle/Media/Keys/KEY_A_PUSHED")
FarkleBoard.TutorialFrame.PrevPageButton:SetScript("OnClick", function() Input_Key_A() end)
FarkleBoard.TutorialFrame.PrevPageButton.Text = FarkleBoard.TutorialFrame.PrevPageButton:CreateFontString(nil, "OVERLAY"); FarkleBoard.TutorialFrame.PrevPageButton.Text:SetParent(FarkleBoard.TutorialFrame.PrevPageButton)
FarkleBoard.TutorialFrame.PrevPageButton.Text:SetFont("Interface/AddOns/Farkle/Fonts/VINQUE.OTF", 18); FarkleBoard.TutorialFrame.PrevPageButton.Text:SetPoint("RIGHT", FarkleBoard.TutorialFrame.PrevPageButton, "LEFT", -10, 0)
FarkleBoard.TutorialFrame.PrevPageButton.Text:SetShadowColor(0, 0, 0); FarkleBoard.TutorialFrame.PrevPageButton.Text:SetShadowOffset(1, -1); FarkleBoard.TutorialFrame.PrevPageButton.Text:SetTextColor(0.800, 0.800, 0.800)
FarkleBoard.TutorialFrame.PrevPageButton.Text:SetText(L.PREVIOUS_PAGE)

FarkleBoard.TutorialFrame.Text = FarkleBoard.TutorialFrame:CreateFontString(nil, "OVERLAY"); FarkleBoard.TutorialFrame.Text:SetParent(FarkleBoard.TutorialFrame)
FarkleBoard.TutorialFrame.Text:SetFont("Interface/AddOns/Farkle/Fonts/VINQUE.OTF", 17.5); FarkleBoard.TutorialFrame.Text:SetPoint("TOPLEFT", FarkleBoard, "TOPLEFT", 75, -115)
FarkleBoard.TutorialFrame.Text:SetShadowColor(0, 0, 0); FarkleBoard.TutorialFrame.Text:SetShadowOffset(1, -1); FarkleBoard.TutorialFrame.Text:SetTextColor(0.950, 0.9175, 0.850)
FarkleBoard.TutorialFrame.Text:SetWordWrap(true); FarkleBoard.TutorialFrame.Text:SetSpacing(4); FarkleBoard.TutorialFrame.Text:SetJustifyH("LEFT")
FarkleBoard.TutorialFrame.Text:SetText(L.TUTORIAL_BASIC); FarkleBoard.TutorialFrame.Text:SetWidth(710);