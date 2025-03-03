local _, farkle = ...

local L = farkle.L
local C_Farkle = farkle.API

string.startswith = function(self, str)
    ---@diagnostic disable-next-line: param-type-mismatch
	return self:find('^' .. str) ~= nil
end

local function decline_name(name, gender)
    if gender == 3 then
        gender = "female"
    else
        gender = "male"
    end
    local endings = {
        female = {
            ["а"] = "у", ["й"] = "ю", ["я"] = "ю",
            ["б"] = "бу", ["в"] = "ву", ["г"] = "гу", ["д"] = "ду",
            ["ж"] = "жу", ["з"] = "зу", ["к"] = "ку", ["л"] = "лу",
            ["м"] = "му", ["н"] = "ну", ["п"] = "пу", ["р"] = "ру",
            ["с"] = "су", ["т"] = "т", ["е"] = "е", ["ё"] = "ё",
            ["и"] = "и", ["о"] = "о", ["у"] = "у", ["ф"] = "ф",
            ["х"] = "х", ["ц"] = "ц", ["ч"] = "ч", ["ш"] = "ш",
            ["щ"] = "щ", ["ъ"] = "ъ", ["ы"] = "ы", ["ь"] = "ь",
            ["э"] = "э", ["ю"] = "ю"
        },
        male = {
            ["а"] = "у", ["й"] = "я", ["я"] = "ю",
            ["б"] = "ба", ["в"] = "ва", ["г"] = "га", ["д"] = "да",
            ["ж"] = "жа", ["з"] = "за", ["к"] = "ка", ["л"] = "ла",
            ["м"] = "ма", ["н"] = "на", ["п"] = "па", ["р"] = "ра",
            ["с"] = "са", ["т"] = "та", ["е"] = "е", ["ё"] = "ё",
            ["и"] = "и", ["о"] = "о", ["у"] = "у", ["ф"] = "фа",
            ["х"] = "ха", ["ц"] = "ца", ["ч"] = "ча", ["ш"] = "ша",
            ["щ"] = "ща", ["ъ"] = "ъ", ["ы"] = "ы", ["ь"] = "я",
            ["э"] = "э", ["ю"] = "ю"
        }
    }

    local exceptions = {
        female = {"кс", "ль", "ик"}
    }

    local last_char, last_two = name:sub(-2), name:sub(-4)

    if gender == "female" and exceptions.female then
        for _, exception in ipairs(exceptions.female) do
            if name:sub(-#exception) == exception then
                return name
            end
        end
    end

    if endings[gender][last_two] then
        return name:sub(1, -5) .. endings[gender][last_two]
    elseif endings[gender][last_char] then
        return name:sub(1, -3) .. endings[gender][last_char]
    else
        return name
    end
end

function C_Farkle:CreateTimer()
    if C_Farkle.IsPvP() then
        local count = 30; FarkleBoard.TimerFrame:Show()
        if C_Farkle.IsPlayerTurn() then
            FarkleBoard.TimerFrame.Text:SetTextColor(1.000, 0.820, 0.000)
        else
            FarkleBoard.TimerFrame.Text:SetTextColor(1.000, 0.250, 0.250)
        end
        C_Farkle.Timer = C_Timer.NewTicker(1, function()
            FarkleBoard.TimerFrame.Text:SetText(count - 1); count = count - 1
            if count == 10 then
                if C_Farkle.IsPlayerTurn() then
                    S_Sound.Play("Interface\\AddOns\\Farkle\\Media\\Audio\\clockTicking.mp3", "Master")
                end
            elseif count == 5 then
                if not C_Farkle.IsPlayerTurn() then
                    C_Farkle.CheckOnline()
                end
            elseif count == -1 then
                C_Farkle:CancelTimer(); C_Farkle:AddWarningMessage("CENTER", L["TIME_OVER"], 2.5); C_Farkle:ClearBoard()
                if C_Farkle.IsPlayerTurn() then
                    C_Farkle:SetScore("player", farkle.player.total, 0, 0); farkle.player.selected = 0
                    FarkleBoard.Input_Key_Q:Hide(); FarkleBoard.Input_Key_E:Hide()
                    S_Timer.After(2.5, function()
                        C_Farkle:SwitchPlayerTurn(); C_Farkle.CheckOnline()
                    end)
                end
            end
        end)
    end
end

function C_Farkle:CancelTimer()
    if C_Farkle.Timer and not C_Farkle.Timer:IsCancelled() then
        C_Farkle.Timer:Cancel(); FarkleBoard.TimerFrame:Hide();
        S_Sound.Stop("Interface\\AddOns\\Farkle\\Media\\Audio\\clockTicking.mp3")
        FarkleBoard.TimerFrame.Text:SetText(30)
    end
end

function C_Farkle:NewBoard(name, realm, class, sex, mode, total, safety)
    UIFrameFadeIn(FarkleBoard, 0.100, 0, 1);
    FarkleBoard.Logo:Show(); C_Farkle:ClearBoard();
    C_Timer.After(0.100, function() FarkleBoard:Show() end)
    C_Farkle:SetBoardInfo("total", total); C_Farkle:SetBoardInfo("safety", safety)
    C_Farkle:SetOpponentInfo("name", name); C_Farkle:SetOpponentInfo("realm", realm);
    C_Farkle:SetOpponentInfo("class", class); C_Farkle:SetOpponentInfo("sex", sex);
    C_Farkle:SetBoardInfo("stage", "start"); C_Farkle:SetBoardInfo("mode", mode);

    FarkleBoard.TutorialFrame.CurrentPage = 1; FarkleBoard.TutorialFrame:Hide();
    FarkleBoard.ReadyPlayerButton:Show(); FarkleBoard.ReadyPlayerButton:Enable()
    FarkleBoard.ReadyOpponentButton:Show(); FarkleBoard.ReadyOpponentButton:Enable()
    FarkleBoard.ReadyKeyButton:Show(); FarkleBoard.TutorialKeyButton:Show()

    if C_Farkle.GetBoardInfo("mode") == "PvE" then
        farkle.opponent.ready = true; FarkleBoard.ReadyOpponentButton:Disable()
    end

    for i = 1, 12 do
        farkle.board["dices"][i] = CreateFrame("Frame", nil, FarkleBoard);farkle.board["dices"][i]:SetSize(75, 75)
        farkle.board["dices"][i].texture = farkle.board["dices"][i]:CreateTexture()
        farkle.board["dices"][i].texture:SetTexture("Interface\\AddOns\\Farkle\\Media\\dice_" .. math.random(1, 6))
        farkle.board["dices"][i].texture:SetAllPoints(); farkle.board["dices"][i].texture:SetPoint("CENTER")
        if i > 6 then
            farkle.board["dices"][i]:SetPoint("TOP", -65 + (i - 6) * 103.5 - 350, -80)
        else
            farkle.board["dices"][i]:SetPoint("BOTTOM", 35 + i * 104.5 - 350, 80)
        end
    end

    FarkleBoard.Coin:Hide(); FarkleBoard.PlayerBoard:Hide(); FarkleBoard.OpponentBoard:Hide()
end

function C_Farkle:ResetValues(tbl)
    for key, value in pairs(tbl) do
        if type(value) == "string" then
            tbl[key] = nil
        elseif type(value) == "boolean" then
            tbl[key] = false
        elseif type(value) == "number" then
            tbl[key] = 0
        elseif type(value) == "table" then
            tbl[key] = {}
        end
    end
end

function C_Farkle:ResetBoard()
    self:ResetValues(farkle.player)
    self:ResetValues(farkle.opponent)
    self:ResetValues(farkle.board)
end

function C_Farkle:StartGame()
    if C_Farkle.IsPlayerTurn() then
        FarkleBoard.Input_Key_Q:Show(); FarkleBoard.Input_Key_E:Show(); FarkleBoard.Input_Key_ESC:Show(); FarkleBoard.Input_Key_T:Show()
        C_Farkle:DisableButton(FarkleBoard.Input_Key_Q); C_Farkle:DisableButton(FarkleBoard.Input_Key_E);
        FarkleBoard.PlayerBoard:SetAlpha(1); FarkleBoard.OpponentBoard:SetAlpha(0.50);
        S_Timer.After(0.25, function() C_Farkle.RollDice(C_Farkle.GetBoardInfo("roll"), 6) end)
    else
        FarkleBoard.PlayerBoard:SetAlpha(0.50); FarkleBoard.OpponentBoard:SetAlpha(1);
        FarkleBoard.Input_Key_ESC:Show(); FarkleBoard.Input_Key_T:Show(); if C_Farkle.IsPvE() then
            S_Timer.After(0.25, function() C_Farkle.RollDice(C_Farkle.GetBoardInfo("roll"), 6) end)
        end
    end

    C_Farkle.CheckOnline()

    farkle.player.ready = false; farkle.opponent.ready = false

    FarkleBoard.PlayerBoard:Show(); FarkleBoard.OpponentBoard:Show()

    FarkleBoard.PlayerBoard.TotalPlayerLabel:SetText(format("%s / |cffffd100%s", L["TOTAL_LABEL"], C_Farkle.GetBoardInfo("total")))
    FarkleBoard.OpponentBoard.TotalOpponentLabel:SetText(format("%s / |cffff3E3E%s", L["TOTAL_LABEL"], C_Farkle.GetBoardInfo("total")))

    FarkleBoard.PlayerBoard.TotalPlayer:SetText("0"); FarkleBoard.PlayerBoard.RoundPlayer:SetText("0"); FarkleBoard.PlayerBoard.HoldPlayer:SetText("0")
    FarkleBoard.OpponentBoard.TotalOpponent:SetText("0"); FarkleBoard.OpponentBoard.RoundOpponent:SetText("0"); FarkleBoard.OpponentBoard.HoldOpponent:SetText("0")

    farkle.player.isPlaying = true; C_Farkle:SetBoardInfo("stage", "game")
end

OriginalGetNextToast = C_EventToastManager.GetNextToastToDisplay

function C_Farkle.Victory(type)
    local toastInfo = {
        title = L["YOU_WON"],
        subtitle = L["GAME_NAME"],
        displayType = Enum.EventToastDisplayType.NormalTitleAndSubTitle,
        colorTint = { r = 1, g = 1, b = 1 },
        flags = 0,
    }

    if type == "offline" then
        toastInfo.displayType = Enum.EventToastDisplayType.NormalBlockText
        toastInfo.title = LIGHTGRAY_FONT_COLOR:GenerateHexColorMarkup() .. L["OPPONENT_OFFLINE"]
        toastInfo.colorTint = {r = 0.8, g = 0.8, b = 0.8}; toastInfo.desaturated = true
    elseif type == "gave_up" then
        if GetLocale() == "ruRU" then
            if C_Farkle.GetOpponentInfo("sex") == 1 or C_Farkle.GetOpponentInfo("sex") == 2 then
                toastInfo.title = format(L["OPPONENT_GAVE_UP_MALE"], C_Farkle.GetOpponentInfo("name"))
            elseif C_Farkle.GetOpponentInfo("sex") == 3 then
                toastInfo.title = format(L["OPPONENT_GAVE_UP_FEMALE"], C_Farkle.GetOpponentInfo("name"))
            end
        else
            toastInfo.title = format(L["OPPONENT_GAVE_UP"], C_Farkle.GetOpponentInfo("name"))
        end
    elseif type == "won" then
        toastInfo.title = L["YOU_WON"]
    end

    if C_Farkle.IsPvP() and type ~= "offline" then
        if GetLocale() == "ruRU" then
            SendChatMessage(format(L["EMOTE_MESSAGE_TEXT_RU"], decline_name(C_Farkle.GetOpponentInfo("name"), C_Farkle.GetOpponentInfo("sex")) .. "-" .. C_Farkle.GetOpponentInfo("realm")), "EMOTE")
        else
            SendChatMessage(format(L["EMOTE_MESSAGE_TEXT"], C_Farkle.GetOpponentInfo("name") .. "-" .. C_Farkle.GetOpponentInfo("realm")), "EMOTE")
        end
    end

    StaticPopup_Hide("GIVE_UP_POPUP"); C_Farkle:ExitGame()

    if type == "gave_up" or type == "won" then
        PlayMusic("Interface\\AddOns\\Farkle\\Media\\Audio\\silent_5.mp3")
        S_Sound.Play("Interface\\AddOns\\Farkle\\Media\\Audio\\resultVictory.mp3", "Master")
        C_Timer.After(5, function() S_Sound.StopAll() end)
    end

    if not EventToastManagerFrame:IsCurrentlyToasting() then
        ---@diagnostic disable-next-line: duplicate-set-field
        C_EventToastManager.GetNextToastToDisplay = function()
            ---@diagnostic disable-next-line: duplicate-set-field
            C_EventToastManager.GetNextToastToDisplay = function() return nil end
            return toastInfo
        end
        EventToastManagerFrame:DisplayToast(); EventToastManagerFrame:SetAnimStartDelay(0)
        EventToastManagerFrame.currentDisplayingToast:SetAnimInStartDelay(0.25)
        EventToastManagerFrame.currentDisplayingToast:SetAnimInEndDelay(1.75)
        C_EventToastManager.GetNextToastToDisplay = OriginalGetNextToast
    end
end

function C_Farkle.Defeat(type)
    local toastInfo = {
        title = L["YOU_LOSE"],
        subtitle = L["GAME_NAME"],
        displayType = Enum.EventToastDisplayType.NormalTitleAndSubTitle,
        colorTint = { r = 1, g = 0.125, b = 0.125 },
        flags = 0,
    }

    if type == "gave_up" then
        toastInfo.title = RED_FONT_COLOR:GenerateHexColorMarkup() .. L["YOU_GAVE_UP"]
    elseif type == "lose" then
        toastInfo.title = RED_FONT_COLOR:GenerateHexColorMarkup() .. L["YOU_LOSE"]
    end

    StaticPopup_Hide("GIVE_UP_POPUP"); C_Farkle:ExitGame()

    PlayMusic("Interface\\AddOns\\Farkle\\Media\\Audio\\silent_5.mp3")
    S_Sound.Play("Interface\\AddOns\\Farkle\\Media\\Audio\\resultDefeat.mp3", "Master")
    C_Timer.After(5, function() S_Sound.StopAll() end)

    if not EventToastManagerFrame:IsCurrentlyToasting() then
        ---@diagnostic disable-next-line: duplicate-set-field
        C_EventToastManager.GetNextToastToDisplay = function()
            ---@diagnostic disable-next-line: duplicate-set-field
            C_EventToastManager.GetNextToastToDisplay = function() return nil end
            return toastInfo
        end
        EventToastManagerFrame:DisplayToast(); EventToastManagerFrame:SetAnimStartDelay(0)
        EventToastManagerFrame.currentDisplayingToast:SetAnimInStartDelay(0.25)
        EventToastManagerFrame.currentDisplayingToast:SetAnimInEndDelay(1.75)
        C_EventToastManager.GetNextToastToDisplay = OriginalGetNextToast
    end
end

function C_Farkle.CoinFlip(coinResult)
    StaticPopup_Hide("EXIT_GAME_POPUP"); C_Farkle:SetBoardInfo("stage", "coin-flip");
    if FarkleBoard.TutorialFrame:IsShown() then FarkleBoard.TutorialFrame:Hide() end
    if C_Farkle.IsPvP() then
        if C_Farkle.GetValue("requester") then
            C_Farkle:SetValue("requester", false)
        else
            C_Farkle:SetValue("requester", true)
        end
    end
    S_Timer.After(1, function()
        S_Sound.Play("Interface\\AddOns\\Farkle\\Media\\Audio\\coinFlip.mp3", "Master");
        FarkleBoard.ReadyKeyButton:Hide(); FarkleBoard.TutorialKeyButton:Hide(); FarkleBoard.Logo:Hide();
        farkle.ChatMessageFrame["player"]:ClearAllPoints(); farkle.ChatMessageFrame["player"]:SetPoint("BOTTOM", FarkleBoard, "BOTTOM", 0, 100)
        farkle.ChatMessageFrame["opponent"]:ClearAllPoints(); farkle.ChatMessageFrame["opponent"]:SetPoint("TOP", FarkleBoard, "TOP", 0, -100)
        FarkleBoard.ReadyPlayerButton:Hide(); FarkleBoard.ReadyOpponentButton:Hide(); C_Farkle:ClearBoard()
    end)
    S_Timer.After(2, function()
        FarkleBoard.Coin:Show(); FarkleBoard.Coin:SetAlpha(1);
        FarkleBoard.Coin.Texture:SetTexture("Interface\\AddOns\\Farkle\\Media\\coin_" .. coinResult)
        if coinResult == 1 then
            farkle.player.turn = true; farkle.opponent.turn = false; C_Farkle:AddInfoMessage("CENTER-BOTTOM", L["FIRST"], 3)
        elseif coinResult == 2 then
            farkle.player.turn = false; farkle.opponent.turn = true; C_Farkle:AddInfoMessage("CENTER-BOTTOM", format(L["FIRST_OPPONENT"], farkle.opponent.name), 3)
        end
        PlayMusic("Interface\\AddOns\\Farkle\\Media\\Audio\\theme.mp3")
    end)
    S_Timer.After(5, function()
        StaticPopup_Hide("EXIT_GAME_POPUP")
        UIFrameFadeIn(FarkleBoard.Coin, 0.25, 1, 0)
        S_Timer.After(0.25, function()
            FarkleBoard.Coin:Hide()
        end)
        C_Farkle:StartGame();
    end)
end

EventRegistry:RegisterFrameEventAndCallback("PLAYER_REGEN_DISABLED", function(ownerID, ...)
    if C_Farkle.IsPlaying() then
        C_Farkle.SendAddonMessage("combat"); C_Farkle:ExitGame();
        DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. L.COMBAT_STARTED, 1.000, 0.125, 0.125)
    end
end)

EventRegistry:RegisterFrameEventAndCallback("PLAYER_ENTERING_WORLD", function(ownerID, isInitialLogin, isReloadingUi)
    if (IsInRaid() or IsInInstance()) and C_Farkle.IsPlaying() then
        C_Farkle:ExitGame(1); DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. L.INSTANCE, 1.000, 1.000, 0.000)
    end
end)

EventRegistry:RegisterFrameEventAndCallback("PLAYER_DEAD", function()
    if C_Farkle.HasOpponent() then
        C_Farkle.SendAddonMessage("combat"); C_Farkle:ExitGame();
        DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. L.DIED, 1.000, 0.125, 0.125)
    end
end)

EventRegistry:RegisterFrameEventAndCallback("GROUP_ROSTER_UPDATE", function()
    if C_Farkle.HasOpponent() and C_Farkle.GetBoardInfo("safety") then
        C_Farkle:ExitGame(); local toastInfo = {
            title = RED_FONT_COLOR:GenerateHexColorMarkup() .. L["GROUP_CHANGED"],
            subtitle = L["GAME_NAME"],
            displayType = Enum.EventToastDisplayType.NormalBlockText,
            colorTint = { r = 1, g = 0.125, b = 0.125 },
            flags = 0,
        }

        if not EventToastManagerFrame:IsCurrentlyToasting() then
            ---@diagnostic disable-next-line: duplicate-set-field
            C_EventToastManager.GetNextToastToDisplay = function()
                ---@diagnostic disable-next-line: duplicate-set-field
                C_EventToastManager.GetNextToastToDisplay = function() return nil end
                return toastInfo
            end
            EventToastManagerFrame:DisplayToast(); EventToastManagerFrame:SetAnimStartDelay(0)
            EventToastManagerFrame.currentDisplayingToast:SetAnimInStartDelay(0.25)
            EventToastManagerFrame.currentDisplayingToast:SetAnimInEndDelay(1.75)
            C_EventToastManager.GetNextToastToDisplay = OriginalGetNextToast
        end
    end
end)

EventToastManagerFrame:SetScript("OnShow", function(self)
    if EventToastManagerFrame:IsCurrentlyToasting() then
        if EventToastManagerFrame.currentDisplayingToast.toastInfo.desaturated then
            EventToastManagerFrame.GLine:SetDesaturated(true); EventToastManagerFrame.GLine2:SetDesaturated(true)
        elseif EventToastManagerFrame.GLine:IsDesaturated() and EventToastManagerFrame.GLine2:IsDesaturated() then
            EventToastManagerFrame.GLine:SetDesaturated(false); EventToastManagerFrame.GLine2:SetDesaturated(false)
        end
    end
end)