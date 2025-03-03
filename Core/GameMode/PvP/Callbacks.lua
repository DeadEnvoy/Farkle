local addonName, farkle = ...

local L = farkle.L

local function toboolean(str)
    return str == "true"
end

local function getGroupType()
    if IsInInstance() then
        return "INSTANCE_CHAT"
    else
        return "RAID"
    end
end

local getFullName = function(name, realm)
    if realm == nil then realm = GetNormalizedRealmName() end
    return format("%s-%s", name, realm)
end

function C_Farkle.SendAddonMessage(prefix)
    if prefix:startswith("checkup") then
        if UnitExists("target") and not UnitInParty("target") then
            C_ChatInfo.SendAddonMessage("Farkle", "checkup", "WHISPER", UnitName("target"))
        elseif UnitExists("target") and UnitInParty("target") then
            C_ChatInfo.SendAddonMessage("Farkle", format("checkup:%s", getFullName(UnitFullName("target"))), getGroupType())
        end
    elseif prefix:startswith("offer") then
        local _, goal, safety = strsplit(":", prefix, 3)
        if not UnitInParty("target") then
            C_ChatInfo.SendAddonMessage("Farkle", format("offer:%s:%s:%s:%s", select(2, UnitClass("player")), UnitSex("player"), goal, safety), "WHISPER", UnitName("target"))
        elseif UnitInParty("target") then
            C_ChatInfo.SendAddonMessage("Farkle", format("offer:%s:%s:%s:%s:%s", getFullName(UnitFullName("target")), select(2, UnitClass("player")), UnitSex("player"), goal, safety), getGroupType())
        end
    elseif prefix:startswith("accepted") then
        local _, unit, goal, safety = strsplit(":", prefix, 4)
        local name, realm = strsplit("-", unit)
        if realm == GetNormalizedRealmName() then
            unit = name
        else
            unit = format("%s-%s", name, realm)
        end
        if not UnitInParty(unit) then
            C_ChatInfo.SendAddonMessage("Farkle", format("accepted:%s:%s:%s:%s", select(2, UnitClass("player")), UnitSex("player"), goal, safety), "WHISPER", name)
        elseif UnitInParty(unit) then
            C_ChatInfo.SendAddonMessage("Farkle", format("accepted:%s-%s:%s:%s:%s:%s", name, realm, select(2, UnitClass("player")), UnitSex("player"), goal, safety), getGroupType())
        end
    elseif prefix:startswith("declined") then
        local _, unit = strsplit(":", prefix, 2)
        local name, realm = strsplit("-", unit)
        if realm == GetNormalizedRealmName() then
            unit = name
        else
            unit = format("%s-%s", name, realm)
        end
        if not UnitInParty(unit) then
            C_ChatInfo.SendAddonMessage("Farkle", format("declined:%s", UnitSex("player")), "WHISPER", unit)
        elseif UnitInParty(unit) then
            C_ChatInfo.SendAddonMessage("Farkle", format("declined:%s-%s:%s", name, realm, UnitSex("player")), getGroupType())
        end
    elseif prefix:startswith("playing") then
        local _, unit = strsplit(":", prefix, 2)
        local name, realm = strsplit("-", unit, 2)
        if realm == GetNormalizedRealmName() then
            unit = name
        else
            unit = format("%s-%s", name, realm)
        end
        if not UnitInParty(unit) then
            C_ChatInfo.SendAddonMessage("Farkle", "playing:%s", "WHISPER", unit)
        elseif UnitInParty(unit) then
            C_ChatInfo.SendAddonMessage("Farkle", format("playing:%s", unit), getGroupType())
        end
    end
    if C_Farkle.HasOpponent() and C_Farkle.IsPvP() then
        if prefix == "ready:yes" then
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "ready:yes", "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "ready:yes", getGroupType())
            end
        elseif prefix == "quit" then
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "quit", "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "quit", getGroupType())
            end
        elseif prefix:startswith('coin') then
            local _, coinResult = strsplit(":", prefix, 2)
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", format("coin:%s", coinResult), "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", format("coin:%s", coinResult), getGroupType())
            end
        elseif prefix == "lose" then
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "lose", "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "lose", getGroupType())
            end
        elseif prefix == "won" then
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "won", "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "won", getGroupType())
            end
        elseif prefix == "combat" then
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "combat", "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "combat", getGroupType())
            end
        elseif prefix == "modified_code" then
            if UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "modified_code", getGroupType())
            end
        elseif prefix == "surrender" then
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "surrender", "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "surrender", getGroupType())
            end
        elseif prefix:startswith('score') then
            local _, total, round, hold = strsplit(":", prefix, 4)
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", format("score:%s:%s:%s", total, round, hold), "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", format("score:%s:%s:%s", total, round, hold), getGroupType())
            end
        elseif prefix:startswith('roll') then
            local _, delay, roll, dices = strsplit(":", prefix, 4)
            if not UnitInParty(farkle.opponent.unit) then
                if not C_Farkle.GetBoardInfo("safety") then
                    C_ChatInfo.SendAddonMessage("Farkle", format("roll:%s:%s:%s", delay, roll, dices), "WHISPER", farkle.opponent.unit)
                else
                    C_ChatInfo.SendAddonMessage("Farkle", format("roll:%s:%s", delay, roll), "WHISPER", farkle.opponent.unit)
                end
            elseif UnitInParty(farkle.opponent.unit) then
                if not C_Farkle.GetBoardInfo("safety") then
                    C_ChatInfo.SendAddonMessage("Farkle", format("roll:%s:%s:%s", delay, roll, dices), getGroupType())
                else
                    C_ChatInfo.SendAddonMessage("Farkle", format("roll:%s:%s", delay, roll), getGroupType())
                end
            end
        elseif prefix == "turn" then
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "turn", "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "turn", getGroupType())
            end
        elseif prefix:startswith('hold') then
            local _, delay, diceHoldStrings = strsplit(":", prefix, 3)
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", format("hold:%s:%s", delay, diceHoldStrings), "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", format("hold:%s:%s", delay, diceHoldStrings), getGroupType())
            end
        elseif prefix == 'online-check' then
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "online-check", "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "online-check", getGroupType())
            end
        elseif prefix == 'online-confirm' then
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "online-confirm", "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "online-confirm", getGroupType())
            end
        elseif prefix == "create_timer" then
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "create_timer", "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "create_timer", getGroupType())
            end
        elseif prefix == "cancel_timer" then
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "cancel_timer", "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "cancel_timer", getGroupType())
            end
        end
    end
end

C_ChatInfo.RegisterAddonMessagePrefix("Farkle")

EventRegistry:RegisterFrameEventAndCallback("CHAT_MSG_ADDON", function(_, prefix, text, channel, sender, _, _, _, _, _)
    if prefix == "Farkle" then
        local senderName, senderRealm = strsplit("-", sender, 2)
        if channel == "WHISPER" then
            if text:startswith('checkup') then
                if senderRealm == GetNormalizedRealmName() then
                    C_ChatInfo.SendAddonMessage("Farkle", "playable", "WHISPER", senderName)
                else
                    C_ChatInfo.SendAddonMessage("Farkle", "playable", "WHISPER", format("%s-%s", senderName, senderRealm))
                end
            elseif text:startswith('playable') then
                if not farkle.players[sender] then
                    farkle.players[sender] = true
                end
            elseif text:startswith('offer') then
                local _, class, sex, goal, safety = strsplit(":", text, 5)
                if not C_Farkle.HasOpponent() then
                    local safetyString; if safety == "true" then
                        safetyString = L["ON"]
                    else
                        safetyString = L["OFF"]
                    end
                    FlashClientIcon()
                    StaticPopupDialogs["PLAY_OFFER"] = {
                        text = format(L["OFFER_LABEL"], senderName),
                        subText = format(L["OFFER_SUBTEXT"], goal, safetyString),
                        button1 = ACCEPT,
                        button2 = DECLINE,
                        OnAccept = function()
                            C_Farkle.SendAddonMessage(format("accepted:%s-%s:%s:%s", senderName, senderRealm, goal, safety));
                            C_Farkle:NewBoard(senderName, senderRealm, class, tonumber(sex), "PvP", tonumber(goal), toboolean(safety));
                        end,
                        OnCancel = function()
                            C_Farkle.SendAddonMessage(format("declined:%s-%s", senderName, senderRealm));
                        end,
                        OnShow = function(self)
                            if senderRealm == GetNormalizedRealmName() then
                                self.text:SetText(format(L["OFFER_LABEL"], senderName))
                            else
                                self.text:SetText(format(L["OFFER_LABEL"], sender))
                            end
                        end,
                        timeout = 10,
                        whileDead = false,
                        hideOnEscape = true,
                    }
                    StaticPopup_Hide("PLAY_OFFER"); StaticPopup_Show("PLAY_OFFER")
                else
                    C_Farkle.SendAddonMessage(format("playing:%s-%s", senderName, senderRealm))
                end
            elseif text:startswith('playing') then
                DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. format(L["OFFER_PLAYING"], UnitName("target")), 1.000, 1.000, 0.000)
            elseif text:startswith('accepted') then
                local _, class, sex, goal, safety = strsplit(":", text, 5)
                C_Farkle:ResetBoard(); C_Farkle:SetValue("requester", true)
                C_Farkle:NewBoard(senderName, senderRealm, class, tonumber(sex), "PvP", tonumber(goal), toboolean(safety));
            elseif text:startswith('declined') then
                local _, sex = strsplit(":", text, 3)
                local unit
                if senderRealm == GetNormalizedRealmName() then
                    unit = senderName
                else
                    unit = sender
                end
                if GetLocale() == "ruRU" then
                    if tonumber(sex) == 2 then
                        DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. format(L["OFFER_DECLINED_MALE"], unit), 1.000, 1.000, 0.000)
                    elseif tonumber(sex) == 3 then
                        DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. format(L["OFFER_DECLINED_FEMALE"], unit), 1.000, 1.000, 0.000)
                    end
                else
                    DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. format(L["OFFER_DECLINED"], unit), 1.000, 1.000, 0.000)
                end
            end
            if C_Farkle.HasOpponent() and sender == format("%s-%s", C_Farkle.GetOpponentInfo("name"), C_Farkle.GetOpponentInfo("realm")) then
                if text:startswith('ready') then
                    _, text = strsplit(":", text, 2)
                    if text == "yes" then
                        farkle.opponent.ready = true; FarkleBoard.ReadyOpponentButton:Disable()
                    end
                    if (farkle.player.ready and farkle.opponent.ready) and C_Farkle.GetValue("requester") then
                        local coinResult = math.random(1, 2); C_Farkle.CoinFlip(coinResult)
                        C_Farkle.SendAddonMessage(format("coin:%s", coinResult))
                    end
                elseif text:startswith('quit') then
                    if GetLocale() == "ruRU" and C_Farkle.GetOpponentInfo("sex") == 2 then
                        DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. format(L["QUIT_MALE"], farkle.opponent.unit), 1.000, 1.000, 0.000)
                    elseif GetLocale() == "ruRU" and C_Farkle.GetOpponentInfo("sex") == 3 then
                        DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. format(L["QUIT_FEMALE"], farkle.opponent.unit), 1.000, 1.000, 0.000)
                    else
                        DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. format(L["QUIT"], farkle.opponent.unit), 1.000, 1.000, 0.000)
                    end
                    C_Farkle:ExitGame()
                elseif text:startswith('coin') then
                    _, text = strsplit(":", text, 2)
                    text = tonumber(text)
                    if text == 1 then text = 2 else text = 1 end
                    C_Farkle.CoinFlip(text)
                elseif C_Farkle.IsPlaying() and text:startswith('lose') then
                    C_Farkle.Defeat("lose")
                elseif C_Farkle.IsPlaying() and text:startswith('won') then
                    C_Farkle.Victory("won")
                elseif C_Farkle.IsPlaying() and text == "surrender" then
                    S_Timer:CancelAllTimers(); C_Farkle.Victory("gave_up")
                elseif text == "combat" then
                    if UnitAffectingCombat("player") then
                        DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. L.COMBAT_STARTED, 1.000, 0.125, 0.125)
                    else
                        DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. L.OPPONNENT_ATTACKED, 1.000, 0.125, 0.125)
                    end
                    C_Farkle:ExitGame()
                elseif C_Farkle.IsPlaying() and text:startswith('score') then
                    local _, total, round, hold = strsplit(":", text)
                    C_Farkle:SetScore("opponent", tonumber(total), tonumber(round), tonumber(hold))
                elseif (C_Farkle.IsPlaying() or C_Farkle.GetBoardInfo("stage") == "coin-flip") and text:startswith('roll') then
                    local parts = strsplittable(":", text)
                    local delay = tonumber(parts[2])
                    local roll = tonumber(parts[3])
                    local dices = {}
                    for i = 4, #parts do
                        table.insert(dices, tonumber(parts[i]))
                    end
                    C_Farkle.RollDice("math", roll, delay, dices)
                elseif C_Farkle.IsPlaying() and text:startswith('turn') then
                    if not C_Farkle.IsPlayerTurn() then
                        C_Farkle:ClearBoard(); farkle.player.turn = true; farkle.opponent.turn = false;
                        C_Farkle:AddInfoMessage("BOTTOM", L["YOUR_TURN"], 1); S_Timer.After(1, function()
                            FarkleBoard.Input_Key_Q:Show(); FarkleBoard.Input_Key_E:Show()
                            UIFrameFadeIn(FarkleBoard.PlayerBoard, 0.25, 0.65, 1); UIFrameFadeIn(FarkleBoard.OpponentBoard, 0.25, 1, 0.65)
                            C_Farkle:DisableButton(FarkleBoard.Input_Key_Q); C_Farkle:DisableButton(FarkleBoard.Input_Key_E);
                            C_Farkle:SetScore("player", farkle.player.total, farkle.player.round, 0); farkle.player.selected = 0
                            farkle.player["diceHold"] = {}; C_Farkle.RollDice("math", 6)
                        end)
                    end
                elseif C_Farkle.IsPlaying() and text:startswith('hold') then
                    local textParts = {strsplit(":", text)}
                    local delay = tonumber(textParts[2])
                    local dices = {}
                
                    for i = 3, #textParts, 2 do
                        local diceIndex = tonumber(textParts[i])
                        local diceResult = tonumber(textParts[i + 1])
                        ---@diagnostic disable-next-line: need-check-nil
                        dices[diceIndex] = diceResult
                    end

                    local count = 0
                    local diceResults = {}
                    for diceIndex, diceResult in pairs(dices) do
                        S_Timer.After(count, function()
                            farkle.board["dices"][diceIndex].circle:Show()
                            table.insert(diceResults, diceResult)
                            C_Farkle:SetScore("opponent", nil, nil, farkle.calculateScore(diceResults))
                        end)
                        count = count + 0.35
                        diceResults = {}
                    end

                    S_Timer.After(delay, function()
                        for diceIndex, _ in pairs(dices) do
                            farkle.board["dices"][diceIndex]:Hide()
                        end

                        C_Farkle:SetScore("opponent", nil, nil, 0)
                        S_Timer.After(0.8, function()
                            C_Farkle:ClearBoard()
                        end)
                    end)
                elseif text == "online-check" then
                    C_Farkle.SendAddonMessage("online-confirm")
                elseif text == "online-confirm" then
                    farkle.waitingForResponse = false;
                elseif C_Farkle.IsPlaying() and text:startswith('create_timer') then
                    C_Farkle:CreateTimer()
                elseif C_Farkle.IsPlaying() and text:startswith('cancel_timer') then
                    C_Farkle:CancelTimer()
                end
            end
        elseif sender ~= getFullName(UnitFullName("player")) then
            if prefix == "Farkle" and text:startswith('checkup') then
                local _, target = strsplit(":", text, 2)
                if target == getFullName(UnitFullName("player")) then
                    C_ChatInfo.SendAddonMessage("Farkle", "playable", getGroupType())
                end
            elseif text == "playable" then
                if not farkle.players[sender] then
                    farkle.players[sender] = true
                end
            elseif text:startswith('offer') then 
                local _, target, class, sex, goal, safety = strsplit(":", text, 6)
                if not C_Farkle.HasOpponent() and target == getFullName(UnitFullName("player")) then
                    local safetyString; if safety == "true" then
                        safetyString = L["ON"]
                    else
                        safetyString = L["OFF"]
                    end
                    FlashClientIcon(); StaticPopupDialogs["PLAY_OFFER"] = {
                        text = format(L["OFFER_LABEL"], senderName),
                        subText = format(L["OFFER_SUBTEXT"], goal, safetyString),
                        button1 = ACCEPT,
                        button2 = DECLINE,
                        OnAccept = function()
                            C_Farkle.SendAddonMessage(format("accepted:%s-%s:%s:%s", senderName, senderRealm, goal, safety));
                            C_Farkle:NewBoard(senderName, senderRealm, class, tonumber(sex), "PvP", tonumber(goal), toboolean(safety));
                        end,
                        OnCancel = function()
                            C_Farkle.SendAddonMessage(format("declined:%s-%s", senderName, senderRealm));
                        end,
                        OnShow = function(self)
                            if senderRealm == GetNormalizedRealmName() then
                                self.text:SetText(format(L["OFFER_LABEL"], senderName))
                            else
                                self.text:SetText(format(L["OFFER_LABEL"], sender))
                            end
                        end,
                        timeout = 10,
                        whileDead = false,
                        hideOnEscape = true,
                    }
                    StaticPopup_Hide("PLAY_OFFER"); StaticPopup_Show("PLAY_OFFER")
                else
                    C_Farkle.SendAddonMessage(format("playing:%s-%s", senderName, senderRealm))
                end
            elseif text:startswith('playing') then
                local _, unit = strsplit(":", text, 2)
                if unit == getFullName(UnitFullName("player")) then
                    DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. format(L["OFFER_PLAYING"], UnitName("target")), 1.000, 1.000, 0.000)
                end
            elseif text:startswith('accepted') then
                local _, target, class, sex, goal, safety = strsplit(":", text, 6)
                if target == getFullName(UnitFullName("player")) then
                    C_Farkle:ResetBoard(); C_Farkle:SetValue("requester", true)
                    C_Farkle:NewBoard(senderName, senderRealm, class, tonumber(sex), "PvP", tonumber(goal), toboolean(safety));
                end
            elseif text:startswith('declined') then
                local _, target, sex = strsplit(":", text, 3)
                local unit
                if target == getFullName(UnitFullName("player")) then
                        if senderRealm == GetNormalizedRealmName() then
                            unit = senderName
                        else
                            unit = sender
                        end
                        if GetLocale() == "ruRU" then
                            if tonumber(sex) == 2 then
                                DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. format(L["OFFER_DECLINED_MALE"], unit), 1.000, 1.000, 0.000)
                            elseif tonumber(sex) == 3 then
                                DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. format(L["OFFER_DECLINED_FEMALE"], unit), 1.000, 1.000, 0.000)
                            end
                        else
                            DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. format(L["OFFER_DECLINED"], unit), 1.000, 1.000, 0.000)
                        end
                    end
                end
            if C_Farkle.HasOpponent() and sender == format("%s-%s", C_Farkle.GetOpponentInfo("name"), C_Farkle.GetOpponentInfo("realm")) then
                if text:startswith('ready') then
                    _, text = strsplit(":", text, 2)
                    if text == "yes" then
                        farkle.opponent.ready = true; FarkleBoard.ReadyOpponentButton:Disable()
                    end
                    if (farkle.player.ready and farkle.opponent.ready) and C_Farkle.GetValue("requester") then
                        local coinResult = math.random(1, 2); C_Farkle.CoinFlip(coinResult)
                        C_Farkle.SendAddonMessage(format("coin:%s", coinResult))
                    end
                elseif text:startswith('quit') then
                    if GetLocale() == "ruRU" and C_Farkle.GetOpponentInfo("sex") == 2 then
                        DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. format(L["QUIT_MALE"], farkle.opponent.unit), 1.000, 1.000, 0.000)
                    elseif GetLocale() == "ruRU" and C_Farkle.GetOpponentInfo("sex") == 3 then
                        DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. format(L["QUIT_FEMALE"], farkle.opponent.unit), 1.000, 1.000, 0.000)
                    else
                        DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. format(L["QUIT"], farkle.opponent.unit), 1.000, 1.000, 0.000)
                    end
                    C_Farkle:ExitGame()
                elseif text:startswith('coin') then
                    _, text = strsplit(":", text, 2)
                    text = tonumber(text)
                    if text == 1 then text = 2 else text = 1 end
                    C_Farkle.CoinFlip(text)
                elseif C_Farkle.IsPlaying() and text:startswith('lose') then
                    C_Farkle.Defeat("lose")
                elseif C_Farkle.IsPlaying() and text:startswith('won') then
                    C_Farkle.Victory("won")
                elseif C_Farkle.IsPlaying() and text == "surrender" then
                    S_Timer:CancelAllTimers(); C_Farkle.Victory("gave_up")
                elseif text == "combat" then
                    if UnitAffectingCombat("player") then
                        DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. L.COMBAT_STARTED, 1.000, 0.125, 0.125)
                    else
                        DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. L.OPPONNENT_ATTACKED, 1.000, 0.125, 0.125)
                    end
                    C_Farkle:ExitGame()
                elseif C_Farkle.IsPlaying() and text:startswith('score') then
                    local _, total, round, hold = strsplit(":", text)
                    C_Farkle:SetScore("opponent", tonumber(total), tonumber(round), tonumber(hold))
                elseif (C_Farkle.IsPlaying() or C_Farkle.GetBoardInfo("stage") == "coin-flip") and text:startswith('roll') then
                    if not C_Farkle.GetBoardInfo("safety") then
                        local parts = strsplittable(":", text)
                        local delay, roll = tonumber(parts[2]), tonumber(parts[3])
                        local dices = {}
                        for i = 4, #parts do
                            table.insert(dices, tonumber(parts[i]))
                        end
                        C_Farkle.RollDice("math", roll, delay, dices)
                    else
                        local _, delay, roll = strsplit(":", text, 3)
                        C_Farkle.RollDice("random", tonumber(roll), tonumber(delay))
                    end
                elseif C_Farkle.IsPlaying() and text:startswith('turn') then
                    if not C_Farkle.IsPlayerTurn() then
                        C_Farkle:ClearBoard(); farkle.player.turn = true; farkle.opponent.turn = false;
                        C_Farkle:AddInfoMessage("BOTTOM", L["YOUR_TURN"], 1); S_Timer.After(1, function()
                            FarkleBoard.Input_Key_Q:Show(); FarkleBoard.Input_Key_E:Show()
                            UIFrameFadeIn(FarkleBoard.PlayerBoard, 0.25, 0.65, 1); UIFrameFadeIn(FarkleBoard.OpponentBoard, 0.25, 1, 0.65)
                            C_Farkle:DisableButton(FarkleBoard.Input_Key_Q); C_Farkle:DisableButton(FarkleBoard.Input_Key_E);
                            C_Farkle:SetScore("player", farkle.player.total, farkle.player.round, 0); farkle.player.selected = 0
                            farkle.player["diceHold"] = {}; C_Farkle.RollDice(C_Farkle.GetBoardInfo("roll"), 6)
                        end)
                    end
                elseif C_Farkle.IsPlaying() and text:startswith('hold') then
                    local textParts = {strsplit(":", text)}
                    local delay = tonumber(textParts[2])
                    local dices = {}

                    for i = 3, #textParts, 2 do
                        local diceIndex = tonumber(textParts[i])
                        local diceResult = tonumber(textParts[i + 1])
                        ---@diagnostic disable-next-line: need-check-nil
                        dices[diceIndex] = diceResult
                    end

                    local count = 0
                    local diceResults = {}
                    for diceIndex, diceResult in pairs(dices) do
                        S_Timer.After(count, function()
                            farkle.board["dices"][diceIndex].circle:Show()
                            if C_Farkle.GetBoardInfo("safety") and diceResult ~= farkle.opponent["dices"][diceIndex] then
                                C_Farkle.SendAddonMessage("modified_code"); C_Farkle:ExitGame(); local toastInfo = {
                                    title = RED_FONT_COLOR:GenerateHexColorMarkup() .. L["MODIFIED_CODE"],
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
                            table.insert(diceResults, diceResult)
                            C_Farkle:SetScore("opponent", nil, nil, farkle.calculateScore(diceResults))
                        end)
                        count = count + 0.35
                        diceResults = {}
                    end

                    S_Timer.After(delay, function()
                        for diceIndex, _ in pairs(dices) do
                            farkle.board["dices"][diceIndex]:Hide()
                        end

                        C_Farkle:SetScore("opponent", nil, nil, 0)
                        S_Timer.After(0.8, function()
                            C_Farkle:ClearBoard()
                        end)
                    end)
                elseif C_Farkle.IsPlaying() and text == "modified_code" then
                    C_Farkle:ExitGame(); local toastInfo = {
                        title = RED_FONT_COLOR:GenerateHexColorMarkup() .. L["MODIFIED_CODE"],
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
                elseif text == "online-check" then
                    C_Farkle.SendAddonMessage("online-confirm")
                elseif text == "online-confirm" then
                    farkle.waitingForResponse = false;
                elseif C_Farkle.IsPlaying() and text:startswith('create_timer') then
                    C_Farkle:CreateTimer()
                elseif C_Farkle.IsPlaying() and text:startswith('cancel_timer') then
                    C_Farkle:CancelTimer()
                end
            end
        end
    end
end)