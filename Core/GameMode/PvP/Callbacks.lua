local addonName, farkle = ...

local L = farkle.L
local C_Farkle = farkle.API
local S_Timer = farkle.API

local timer = nil

function farkle.CancelOfferTimer()
    if timer and not timer:IsCancelled() then
        timer:Cancel(); timer = nil
    end
    farkle.status["offer"].isSent = nil
end

function farkle.CreateOfferTimer()
    if timer and not timer:IsCancelled() then
        timer:Cancel(); timer = nil
    end
    timer = C_Timer.NewTimer(10 + 1, farkle.CancelOfferTimer)
end

local function toboolean(str)
    return str == "true"
end

function C_Farkle.SendAddonMessage(prefix)
    if prefix:startswith("checkup") then
        local _, unit = strsplit(":", prefix, 2)
        local name, realm = strsplit("-", unit, 2)
        if not UnitInParty(realm == GetNormalizedRealmName() and name or unit) then
            C_ChatInfo.SendAddonMessage("Farkle", "checkup", "WHISPER", realm == GetNormalizedRealmName() and name or unit)
        elseif UnitInParty(realm == GetNormalizedRealmName() and name or unit) then
            C_ChatInfo.SendAddonMessage("Farkle", format("checkup:%s", unit), IsInInstance() and "INSTANCE_CHAT" or "RAID")
        end
    elseif prefix:startswith("offer") then
        local _, unit, goal, safety = strsplit(":", prefix, 4)
        local name, realm = strsplit("-", unit, 2)
        if not UnitInParty(realm == GetNormalizedRealmName() and name or unit) then
            C_ChatInfo.SendAddonMessage("Farkle", format("offer:%s:%s:%s:%s", select(2, UnitClass("player")), UnitSex("player"), goal, safety), "WHISPER", realm == GetNormalizedRealmName() and name or unit)
        elseif UnitInParty(realm == GetNormalizedRealmName() and name or unit) then
            C_ChatInfo.SendAddonMessage("Farkle", format("offer:%s:%s:%s:%s:%s", unit, select(2, UnitClass("player")), UnitSex("player"), goal, safety), IsInInstance() and "INSTANCE_CHAT" or "RAID")
        end
        farkle.CreateOfferTimer()
    elseif prefix:startswith("cancel_offer") then
        local _, unit = strsplit(":", prefix, 2)
        local name, realm = strsplit("-", unit, 2)
        if not UnitInParty(realm == GetNormalizedRealmName() and name or unit) then
            C_ChatInfo.SendAddonMessage("Farkle", "cancel_offer", "WHISPER", realm == GetNormalizedRealmName() and name or unit)
        elseif UnitInParty(realm == GetNormalizedRealmName() and name or unit) then
            C_ChatInfo.SendAddonMessage("Farkle", format("cancel_offer:%s", unit), IsInInstance() and "INSTANCE_CHAT" or "RAID")
        end
        farkle.CancelOfferTimer()
    elseif prefix:startswith("accepted") then
        local _, unit, goal, safety = strsplit(":", prefix, 4)
        local name, realm = strsplit("-", unit)
        if not UnitInParty(realm == GetNormalizedRealmName() and name or unit) then
            C_ChatInfo.SendAddonMessage("Farkle", format("accepted:%s:%s:%s:%s", select(2, UnitClass("player")), UnitSex("player"), goal, safety), "WHISPER", realm == GetNormalizedRealmName() and name or unit)
        elseif UnitInParty(realm == GetNormalizedRealmName() and name or unit) then
            C_ChatInfo.SendAddonMessage("Farkle", format("accepted:%s-%s:%s:%s:%s:%s", name, realm, select(2, UnitClass("player")), UnitSex("player"), goal, safety), IsInInstance() and "INSTANCE_CHAT" or "RAID")
        end
    elseif prefix:startswith("declined") then
        local _, unit = strsplit(":", prefix, 2)
        local name, realm = strsplit("-", unit)
        if not UnitInParty(realm == GetNormalizedRealmName() and name or unit) then
            C_ChatInfo.SendAddonMessage("Farkle", format("declined:%s", UnitSex("player")), "WHISPER", realm == GetNormalizedRealmName() and name or unit)
        elseif UnitInParty(realm == GetNormalizedRealmName() and name or unit) then
            C_ChatInfo.SendAddonMessage("Farkle", format("declined:%s-%s:%s", name, realm, UnitSex("player")), IsInInstance() and "INSTANCE_CHAT" or "RAID")
        end
    elseif prefix:startswith("playing") then
        local _, unit = strsplit(":", prefix, 2)
        local name, realm = strsplit("-", unit, 2)
        if not UnitInParty(realm == GetNormalizedRealmName() and name or unit) then
            C_ChatInfo.SendAddonMessage("Farkle", "playing:%s", "WHISPER", realm == GetNormalizedRealmName() and name or unit)
        elseif UnitInParty(realm == GetNormalizedRealmName() and name or unit) then
            C_ChatInfo.SendAddonMessage("Farkle", format("playing:%s", unit), IsInInstance() and "INSTANCE_CHAT" or "RAID")
        end
    elseif prefix:startswith("status") then
        local _, unit = strsplit(":", prefix, 2)
        local name, realm = strsplit("-", unit)
        if not UnitInParty(realm == GetNormalizedRealmName() and name or unit) then
            C_ChatInfo.SendAddonMessage("Farkle", format("status:%s", StaticPopup_Visible("FARKLE_PLAY_OFFER") and "isActive" or "isSent"), "WHISPER", realm == GetNormalizedRealmName() and name or unit)
        elseif UnitInParty(realm == GetNormalizedRealmName() and name or unit) then
            C_ChatInfo.SendAddonMessage("Farkle", format("status:%s:%s", unit, StaticPopup_Visible("FARKLE_PLAY_OFFER") and "isActive" or "isSent"), IsInInstance() and "INSTANCE_CHAT" or "RAID")
        end
    end
    if C_Farkle.HasOpponent() and C_Farkle.IsPvP() then
        if prefix == "ready:yes" then
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "ready:yes", "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "ready:yes", IsInInstance() and "INSTANCE_CHAT" or "RAID")
            end
        elseif prefix == "quit" then
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "quit", "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "quit", IsInInstance() and "INSTANCE_CHAT" or "RAID")
            end
        elseif prefix:startswith('coin') then
            local _, coinResult = strsplit(":", prefix, 2)
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", format("coin:%s", coinResult), "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", format("coin:%s", coinResult), IsInInstance() and "INSTANCE_CHAT" or "RAID")
            end
        elseif prefix == "lose" then
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "lose", "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "lose", IsInInstance() and "INSTANCE_CHAT" or "RAID")
            end
        elseif prefix == "won" then
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "won", "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "won", IsInInstance() and "INSTANCE_CHAT" or "RAID")
            end
        elseif prefix == "combat" then
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "combat", "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "combat", IsInInstance() and "INSTANCE_CHAT" or "RAID")
            end
        elseif prefix == "modified_code" then
            if UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "modified_code", IsInInstance() and "INSTANCE_CHAT" or "RAID")
            end
        elseif prefix == "surrender" then
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "surrender", "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "surrender", IsInInstance() and "INSTANCE_CHAT" or "RAID")
            end
        elseif prefix:startswith('score') then
            local _, total, round, hold = strsplit(":", prefix, 4)
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", format("score:%s:%s:%s", total, round, hold), "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", format("score:%s:%s:%s", total, round, hold), IsInInstance() and "INSTANCE_CHAT" or "RAID")
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
                    C_ChatInfo.SendAddonMessage("Farkle", format("roll:%s:%s:%s", delay, roll, dices), IsInInstance() and "INSTANCE_CHAT" or "RAID")
                else
                    C_ChatInfo.SendAddonMessage("Farkle", format("roll:%s:%s", delay, roll), IsInInstance() and "INSTANCE_CHAT" or "RAID")
                end
            end
        elseif prefix:startswith('hold') then
            local _, delay, diceHoldStrings = strsplit(":", prefix, 3)
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", format("hold:%s:%s", delay, diceHoldStrings), "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", format("hold:%s:%s", delay, diceHoldStrings), IsInInstance() and "INSTANCE_CHAT" or "RAID")
            end
        elseif prefix == 'online-check' then
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "online-check", "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "online-check", IsInInstance() and "INSTANCE_CHAT" or "RAID")
            end
        elseif prefix == 'online-confirm' then
            if not UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "online-confirm", "WHISPER", farkle.opponent.unit)
            elseif UnitInParty(farkle.opponent.unit) then
                C_ChatInfo.SendAddonMessage("Farkle", "online-confirm", IsInInstance() and "INSTANCE_CHAT" or "RAID")
            end
        end
    end
end

C_ChatInfo.RegisterAddonMessagePrefix("Farkle")

EventRegistry:RegisterFrameEventAndCallback("CHAT_MSG_ADDON", function(_, prefix, text, channel, sender, _, _, _, _, _)
    if prefix == "Farkle" then
        local senderName, senderRealm = strsplit("-", sender, 2)
        -- print(format("%s: %s [%s]", sender, text, channel))
        if channel == "WHISPER" then
            if text:startswith('checkup') then
                C_ChatInfo.SendAddonMessage("Farkle", "playable", "WHISPER", senderRealm == GetNormalizedRealmName() and senderName or sender)
                if not farkle.players[sender] then
                    farkle.players[sender] = true
                end
            elseif text:startswith('playable') then
                if not farkle.players[sender] then
                    farkle.players[sender] = true
                end
            elseif text:startswith('offer') then
                local _, class, sex, goal, safety = strsplit(":", text, 5)
                if not C_Farkle.HasOpponent() and not UnitAffectingCombat("player") and not GameMenuFrame:IsShown() then
                    if not StaticPopup_Visible("FARKLE_PLAY_OFFER") and not farkle.status["offer"].isSent then
                        FlashClientIcon(); StaticPopupDialogs["FARKLE_PLAY_OFFER"] = {
                            text = format(L["OFFER_LABEL"], senderRealm == GetNormalizedRealmName() and senderName or sender),
                            subText = format(L["OFFER_SUBTEXT"], goal, toboolean(safety) and L["ON"] or L["OFF"]),
                            button1 = ACCEPT,
                            button2 = DECLINE,
                            OnAccept = function()
                                C_Farkle.SendAddonMessage(format("accepted:%s:%s:%s", sender, goal, safety));
                                C_Farkle:NewBoard(senderName, senderRealm, class, tonumber(sex), "PvP", tonumber(goal), toboolean(safety));
                            end,
                            OnCancel = function()
                                C_Farkle.SendAddonMessage(format("declined:%s", sender));
                            end,
                            timeout = 10,
                            whileDead = false,
                            hideOnEscape = true,
                            requester = sender,
                            goal = tonumber(goal),
                            safety = toboolean(safety)
                        }
                        StaticPopup_Show("FARKLE_PLAY_OFFER")
                    else
                        C_Farkle.SendAddonMessage(format("status:%s", sender))
                    end
                elseif C_Farkle.HasOpponent() and not UnitAffectingCombat("player") then
                    C_Farkle.SendAddonMessage(format("playing:%s", sender))
                else
                    C_Farkle.SendAddonMessage(format("declined:%s", sender))
                end
            elseif text == "cancel_offer" then
                if StaticPopup_Visible("FARKLE_PLAY_OFFER") and StaticPopupDialogs["FARKLE_PLAY_OFFER"].requester == sender then
                    StaticPopup_Hide("FARKLE_PLAY_OFFER"); StaticPopupDialogs["FARKLE_PLAY_OFFER"].OnCancel()
                end
            elseif text:startswith('playing') and (farkle.status["offer"].isSent and farkle.status["offer"].isSent == sender) then
                farkle.CancelOfferTimer(); DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. format(L["OFFER_PLAYING"], UnitName("target")), 1.000, 1.000, 0.000)
            elseif text:startswith('accepted') and (farkle.status["offer"].isSent and farkle.status["offer"].isSent == sender) then
                local _, class, sex, goal, safety = strsplit(":", text, 5)
                if not UnitAffectingCombat("player") then
                    C_Farkle:ResetBoard(); C_Farkle:SetValue("requester", true);
                    C_Farkle:NewBoard(senderName, senderRealm, class, tonumber(sex), "PvP", tonumber(goal), toboolean(safety))
                end
                farkle.CancelOfferTimer()
            elseif text:startswith('declined') and (farkle.status["offer"].isSent and farkle.status["offer"].isSent == sender) then
                local _, sex = strsplit(":", text, 3)
                if GetLocale() == "ruRU" then
                    if tonumber(sex) == 2 then
                        DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. format(L["OFFER_DECLINED_MALE"], senderRealm == GetNormalizedRealmName() and senderName or sender), 1.000, 1.000, 0.000)
                    elseif tonumber(sex) == 3 then
                        DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. format(L["OFFER_DECLINED_FEMALE"], senderRealm == GetNormalizedRealmName() and senderName or sender), 1.000, 1.000, 0.000)
                    end
                else
                    DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. format(L["OFFER_DECLINED"], senderRealm == GetNormalizedRealmName() and senderName or sender), 1.000, 1.000, 0.000)
                end
                farkle.CancelOfferTimer()
            elseif text:startswith('status') and (farkle.status["offer"].isSent and farkle.status["offer"].isSent == sender) then
                local _, status = strsplit(":", text, 2)
                if status == "isActive" then
                    DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. format(L["OFFER_HAS_ACTIVE_REQUEST"], senderRealm == GetNormalizedRealmName() and senderName or sender), 1.000, 1.000, 0.000)
                elseif status == "isSent" then
                    DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. format(L["OFFER_HAS_SENT_REQUEST"], senderRealm == GetNormalizedRealmName() and senderName or sender), 1.000, 1.000, 0.000)
                end
                farkle.CancelOfferTimer()
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
                        DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. format(L["QUIT_MALE"], farkle.opponent.unit), 1.000, 1.000, 0.000)
                    elseif GetLocale() == "ruRU" and C_Farkle.GetOpponentInfo("sex") == 3 then
                        DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. format(L["QUIT_FEMALE"], farkle.opponent.unit), 1.000, 1.000, 0.000)
                    else
                        DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. format(L["QUIT"], farkle.opponent.unit), 1.000, 1.000, 0.000)
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
                        DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. L.COMBAT_STARTED, 1.000, 0.125, 0.125)
                    else
                        DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. L.OPPONNENT_ATTACKED, 1.000, 0.125, 0.125)
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
                elseif C_Farkle.IsPlaying() and text:startswith('hold') then
                    local textParts = {strsplit(":", text)}
                    local switch = toboolean(textParts[2])
                    local delay = tonumber(textParts[3])
                    local dices = {}

                    C_Farkle:CancelTimer()

                    for i = 4, #textParts, 2 do
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
                            C_Farkle:ClearBoard();
                            if switch and C_Farkle.GetScore("opponent") < C_Farkle.GetBoardInfo("total") then
                                C_Farkle:SwitchPlayerTurn()
                            end
                        end)
                    end)
                elseif text == "online-check" then
                    C_Farkle.SendAddonMessage("online-confirm")
                elseif text == "online-confirm" then
                    farkle.status.isOffline = false;
                end
            end
        elseif sender ~= format("%s-%s", UnitName("player"), GetNormalizedRealmName()) then
            if text:startswith('checkup') then
                local _, target = strsplit(":", text, 2)
                if target == format("%s-%s", UnitName("player"), GetNormalizedRealmName()) then
                    C_ChatInfo.SendAddonMessage("Farkle", "playable", IsInInstance() and "INSTANCE_CHAT" or "RAID")
                end
                if not farkle.players[sender] then
                    farkle.players[sender] = true
                end
            elseif text == "playable" then
                if not farkle.players[sender] then
                    farkle.players[sender] = true
                end
            elseif text:startswith('offer') then 
                local _, target, class, sex, goal, safety = strsplit(":", text, 6)
                if not C_Farkle.HasOpponent() and target == format("%s-%s", UnitName("player"), GetNormalizedRealmName()) then
                    if not C_Farkle.HasOpponent() and not UnitAffectingCombat("player") and not GameMenuFrame:IsShown() then
                        if not StaticPopup_Visible("FARKLE_PLAY_OFFER") and not farkle.status["offer"].isSent then
                            FlashClientIcon(); StaticPopupDialogs["FARKLE_PLAY_OFFER"] = {
                                text = format(L["OFFER_LABEL"], senderRealm == GetNormalizedRealmName() and senderName or sender),
                                subText = format(L["OFFER_SUBTEXT"], goal, toboolean(safety) and L["ON"] or L["OFF"]),
                                button1 = ACCEPT,
                                button2 = DECLINE,
                                OnAccept = function()
                                    C_Farkle.SendAddonMessage(format("accepted:%s:%s:%s", sender, goal, safety));
                                    C_Farkle:NewBoard(senderName, senderRealm, class, tonumber(sex), "PvP", tonumber(goal), toboolean(safety));
                                end,
                                OnCancel = function()
                                    C_Farkle.SendAddonMessage(format("declined:%s", sender));
                                end,
                                timeout = 10,
                                whileDead = false,
                                hideOnEscape = true,
                                requester = sender,
                                goal = tonumber(goal),
                                safety = toboolean(safety)
                            }
                            StaticPopup_Show("FARKLE_PLAY_OFFER")
                        else
                            C_Farkle.SendAddonMessage(format("status:%s", sender))
                        end
                    elseif C_Farkle.HasOpponent() and not UnitAffectingCombat("player") then
                        C_Farkle.SendAddonMessage(format("playing:%s", sender))
                    else
                        C_Farkle.SendAddonMessage(format("declined:%s", sender))
                    end
                end
            elseif text == "cancel_offer" then
                local _, target = strsplit(":", text, 2)
                if target == format("%s-%s", UnitName("player"), GetNormalizedRealmName()) then
                    if StaticPopup_Visible("FARKLE_PLAY_OFFER") and StaticPopupDialogs["FARKLE_PLAY_OFFER"].requester == sender then
                        StaticPopup_Hide("FARKLE_PLAY_OFFER"); StaticPopupDialogs["FARKLE_PLAY_OFFER"].OnCancel()
                    end
                end
            elseif text:startswith('playing') and (farkle.status["offer"].isSent and farkle.status["offer"].isSent == sender) then
                local _, target = strsplit(":", text, 2)
                if target == format("%s-%s", UnitName("player"), GetNormalizedRealmName()) then
                    farkle.CancelOfferTimer(); DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. format(L["OFFER_PLAYING"], UnitName("target")), 1.000, 1.000, 0.000)
                end
            elseif text:startswith('accepted') and (farkle.status["offer"].isSent and farkle.status["offer"].isSent == sender) then
                local _, target, class, sex, goal, safety = strsplit(":", text, 6)
                if target == format("%s-%s", UnitName("player"), GetNormalizedRealmName()) and not UnitAffectingCombat("player") then
                    C_Farkle:ResetBoard(); C_Farkle:SetValue("requester", true);
                    C_Farkle:NewBoard(senderName, senderRealm, class, tonumber(sex), "PvP", tonumber(goal), toboolean(safety));
                    farkle.CancelOfferTimer()
                end
            elseif text:startswith('declined') and (farkle.status["offer"].isSent and farkle.status["offer"].isSent == sender) then
                local _, target, sex = strsplit(":", text, 3)
                if target == format("%s-%s", UnitName("player"), GetNormalizedRealmName()) then
                        if GetLocale() == "ruRU" then
                            if tonumber(sex) == 2 then
                                DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. format(L["OFFER_DECLINED_MALE"], senderRealm == GetNormalizedRealmName() and senderName or sender), 1.000, 1.000, 0.000)
                            elseif tonumber(sex) == 3 then
                                DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. format(L["OFFER_DECLINED_FEMALE"], senderRealm == GetNormalizedRealmName() and senderName or sender), 1.000, 1.000, 0.000)
                            end
                        else
                            DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. format(L["OFFER_DECLINED"], senderRealm == GetNormalizedRealmName() and senderName or sender), 1.000, 1.000, 0.000)
                        end
                        farkle.CancelOfferTimer()
                    end
                elseif text:startswith('status') and (farkle.status["offer"].isSent and farkle.status["offer"].isSent == sender) then
                    local _, target, status = strsplit(":", text, 2)
                    if target == format("%s-%s", UnitName("player"), GetNormalizedRealmName()) then
                        if status == "isActive" then
                            DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. format(L["OFFER_HAS_ACTIVE_REQUEST"], senderRealm == GetNormalizedRealmName() and senderName or sender), 1.000, 1.000, 0.000)
                        elseif status == "isSent" then
                            DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. format(L["OFFER_HAS_SENT_REQUEST"], senderRealm == GetNormalizedRealmName() and senderName or sender), 1.000, 1.000, 0.000)
                        end
                        farkle.CancelOfferTimer()
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
                        DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. format(L["QUIT_MALE"], farkle.opponent.unit), 1.000, 1.000, 0.000)
                    elseif GetLocale() == "ruRU" and C_Farkle.GetOpponentInfo("sex") == 3 then
                        DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. format(L["QUIT_FEMALE"], farkle.opponent.unit), 1.000, 1.000, 0.000)
                    else
                        DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. format(L["QUIT"], farkle.opponent.unit), 1.000, 1.000, 0.000)
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
                        DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. L.COMBAT_STARTED, 1.000, 0.125, 0.125)
                    else
                        DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. L.OPPONNENT_ATTACKED, 1.000, 0.125, 0.125)
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
                elseif C_Farkle.IsPlaying() and text:startswith('hold') then
                    local textParts = {strsplit(":", text)}
                    local switch = toboolean(textParts[2])
                    local delay = tonumber(textParts[3])
                    local dices = {}

                    C_Farkle:CancelTimer()

                    for i = 4, #textParts, 2 do
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
                            C_Farkle:ClearBoard();
                            if switch and C_Farkle.GetScore("opponent") < C_Farkle.GetBoardInfo("total") then
                                C_Farkle:SwitchPlayerTurn()
                            end
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
                    farkle.status.isOffline = false;
                end
            end
        end
    end
end)