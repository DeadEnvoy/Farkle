local _, farkle = ...

farkle.API = {}

local L = farkle.L
local C_Farkle = farkle.API

DICE_ICON = "|TInterface/Buttons/UI-GroupLoot-Dice-Up:14:14|t"

local getFullName = function(name, realm)
    if realm == nil then realm = GetNormalizedRealmName() end
    return format("%s-%s", name, realm)
end

farkle.waitingForResponse = false

function C_Farkle.CheckOnline()
    if farkle.waitingForResponse then return end; if C_Farkle.IsPvP() then
        C_Farkle.SendAddonMessage("online-check"); farkle.waitingForResponse = true
        C_Timer.After(5, function()
            if farkle.waitingForResponse and (C_Farkle.IsPlaying() and C_Farkle.IsPvP()) then
                C_Farkle.Victory("offline")
            end
            farkle.waitingForResponse = false
        end)
    end
end

S_Timer = {}; S_Timer.activeTimers = {}

function S_Timer.After(delay, callback)
    local timer = C_Timer.NewTimer(delay, function(self)
        if not C_Farkle.GetBoardInfo("stage") then
            return self:Cancel()
        else
            callback()
        end
        S_Timer.activeTimers[self] = nil
    end)
    S_Timer.activeTimers[timer] = true
end

function S_Timer:CancelAllTimers()
    for timer in pairs(S_Timer.activeTimers) do
        timer:Cancel()
    end
    wipe(S_Timer.activeTimers); C_Farkle:CancelTimer()
end

S_Sound = {}; S_Sound.activeSounds = {}

function S_Sound.Play(soundPath, channel)
    if S_Sound.activeSounds[soundPath] then
        StopSound(S_Sound.activeSounds[soundPath], 0)
        S_Sound.activeSounds[soundPath] = nil
    end
    local willPlay, soundHandle = PlaySoundFile(soundPath, channel)
    if willPlay then
        S_Sound.activeSounds[soundPath] = soundHandle
    end
end

function S_Sound.Stop(soundPath)
    local soundHandle = S_Sound.activeSounds[soundPath]
    if soundHandle then
        StopSound(soundHandle, 0)
        S_Sound.activeSounds[soundPath] = nil
    end
end

function S_Sound.StopAll()
    for _, soundHandle in pairs(S_Sound.activeSounds) do
        StopSound(soundHandle, 0)
    end
    wipe(S_Sound.activeSounds); StopMusic()
end

function C_Farkle:DisableButton(button)
    button:Show(); button:SetAlpha(0.5); button:Disable()
end

function C_Farkle:EnableButton(button)
    button:Show(); button:SetAlpha(1); button:Enable()
end

function C_Farkle:SwitchPlayerTurn()
    C_Farkle:ClearBoard(); if C_Farkle.IsPlayerTurn() then
        farkle.player.turn = false; farkle.opponent.turn = true
        C_Farkle:AddInfoMessage("BOTTOM", L["OPPONENT_TURN"], 1)
        if C_Farkle.IsPvP() then C_Farkle.SendAddonMessage("turn") end
        C_Farkle:DisableButton(FarkleBoard.Input_Key_Q); C_Farkle:DisableButton(FarkleBoard.Input_Key_E);
        FarkleBoard.Input_Key_Q:Hide(); FarkleBoard.Input_Key_E:Hide()
        S_Timer.After(1, function()
            UIFrameFadeIn(FarkleBoard.PlayerBoard, 0.25, 1, 0.50); UIFrameFadeIn(FarkleBoard.OpponentBoard, 0.25, 0.50, 1)
        end)
    else
        farkle.player.turn = true; farkle.opponent.turn = false
        C_Farkle:AddInfoMessage("BOTTOM", L["YOUR_TURN"], 1)
        S_Timer.After(1, function()
            FarkleBoard.Input_Key_Q:Show(); FarkleBoard.Input_Key_E:Show()
            UIFrameFadeIn(FarkleBoard.PlayerBoard, 0.25, 0.50, 1); UIFrameFadeIn(FarkleBoard.OpponentBoard, 0.25, 1, 0.50)
            C_Farkle:DisableButton(FarkleBoard.Input_Key_Q); C_Farkle:DisableButton(FarkleBoard.Input_Key_E);
        end)
    end
end

function C_Farkle.IsPlaying()
    return farkle.player.isPlaying
end

function C_Farkle.UnitCanPlay(unit)
    if unit == "target" and farkle.players[getFullName(UnitFullName("target"))] then
        return true
    elseif farkle.players[unit] then
        return true
    end
end

function C_Farkle:ClearBoard()
    if #farkle.board["dices"] > 0 then
        for i = 1, #farkle.board["dices"] do
            if farkle.board["dices"] and farkle.board["dices"][i] then
                farkle.board["dices"][i]:Hide(); farkle.board["dices"][i] = nil
            end
        end
    end
end

function C_Farkle.IsPvP()
    if C_Farkle.GetBoardInfo("mode") == "PvP" then
        return true
    else
        return false
    end
end

function C_Farkle.IsPvE()
    if C_Farkle.GetBoardInfo("mode") == "PvE" then
        return true
    else
        return false
    end
end

function C_Farkle.IsReady()
    return farkle.player.ready
end

function C_Farkle.IsPlayerTurn()
    return farkle.player.turn
end

function C_Farkle:SetScore(unit, total, round, hold)
    if unit == "player" then
        if total and total ~= nil then farkle.player.total = total; FarkleBoard.PlayerBoard.TotalPlayer:SetText(total) end
        if round and round ~= nil then farkle.player.round = round; FarkleBoard.PlayerBoard.RoundPlayer:SetText(round) end
        if hold and hold ~= nil then farkle.player.hold = hold; FarkleBoard.PlayerBoard.HoldPlayer:SetText(hold) end
        C_Farkle.SendAddonMessage(format("score:%s:%s:%s", farkle.player.total, farkle.player.round, farkle.player.hold))
    elseif unit == "opponent" then
        if total and total ~= nil then farkle.opponent.total = total; FarkleBoard.OpponentBoard.TotalOpponent:SetText(total) end
        if round and round ~= nil then farkle.opponent.round = round; FarkleBoard.OpponentBoard.RoundOpponent:SetText(round) end
        if hold and hold ~= nil then farkle.opponent.hold = hold; FarkleBoard.OpponentBoard.HoldOpponent:SetText(hold) end
    end
end

function C_Farkle.GetScore(unit)
    if unit == "player" then
        return farkle.player.total
    elseif unit == "opponent" then
        return farkle.opponent.total
    end
end

function C_Farkle:SetValue(var, value)
    if var == "turn" then
        farkle.player.turn = value
    elseif var == "ready" then
        farkle.player.ready = value
    elseif var == "isPlaying" then
        farkle.player.isPlaying = value
    elseif var == "rolls" then
        farkle.player.rolls = value
    elseif var == "requester" then
        farkle.player.requester = value
    end
end

function C_Farkle.GetValue(var)
    if var == "turn" then
        return farkle.player.turn
    elseif var == "ready" then
        return farkle.player.ready
    elseif var == "isPlaying" then
        return farkle.player.isPlaying
    elseif var == "rolls" then
        return farkle.player.rolls
    elseif var == "requester" then
        return farkle.player.requester
    end
end

function C_Farkle.GetOpponentInfo(var)
    if var == "name" then
        return farkle.opponent.name
    elseif var == "realm" then
        return farkle.opponent.realm
    elseif var == "class" then
        return farkle.opponent.class
    elseif var == "sex" then
        return tonumber(farkle.opponent.sex)
    elseif var == "rolls" then
        return tonumber(farkle.opponent.rolls)
    end
    return farkle.opponent.name, farkle.opponent.realm, farkle.opponent.class, tonumber(farkle.opponent.sex)
end


function C_Farkle:SetOpponentInfo(var, value)
    if var == "name" then
        farkle.opponent.name = value
    elseif var == "realm" then
        farkle.opponent.realm = value
    elseif var == "class" then
        farkle.opponent.class = value
    elseif var == "sex" then
        farkle.opponent.sex = tonumber(value)
    elseif var == "rolls" then
        farkle.opponent.rolls = tonumber(value)
    end
end

function C_Farkle.HasOpponent()
    return farkle.opponent.name
end

function C_Farkle:ClearChat()
    for i = 1, 4 do
        farkle.MessageFrame["info"]:AddMessage("", 0, 0, 0, 0); farkle.MessageFrame["warning"]:AddMessage("", 0, 0, 0, 0);
        farkle.ChatMessageFrame["player"]:AddMessage("", 0, 0, 0, 0); farkle.ChatMessageFrame["opponent"]:AddMessage("", 0, 0, 0, 0);
    end
end

function C_Farkle:ExitGame(type)
    S_Timer:CancelAllTimers(); S_Sound.StopAll();
    if C_Farkle.IsPvE() then
        C_GossipInfo.CloseGossip()
    elseif type == 1 then
        C_Farkle.SendAddonMessage("quit")
    end
    C_Farkle:ClearBoard(); C_Farkle:ResetBoard(); C_Farkle:ClearChat()
    FarkleBoard.Input_Key_ESC:Hide(); FarkleBoard.Input_Key_Q:Hide(); FarkleBoard.Input_Key_E:Hide(); FarkleBoard.Input_Key_T:Hide()
    UIFrameFadeOut(FarkleBoard, 0.100, 1, 0); C_Timer.After(0.100, function() FarkleBoard:Hide() end)
end

function C_Farkle:SetBoardInfo(var, value)
    if var == "total" and value then
        farkle.board.total = value
    elseif var == "mode" and value then
        farkle.board.mode = value
    elseif var == "stage" and value then
        farkle.board.stage = value
    elseif var == "safety" and value then
        farkle.board.safety = value
    end
end

function C_Farkle.GetBoardInfo(type)
    if type and type == "total" then
        return farkle.board.total
    elseif type and type == "mode" then
        return farkle.board.mode
    elseif type and type == "stage" then
        return farkle.board.stage
    elseif type and type == "safety" then
        return farkle.board.safety
    elseif type and type == "roll" then
        if not farkle.board.safety then
            return "math"
        else
            return "random"
        end
    end
    return farkle.board.total, farkle.board.mode, farkle.board.stage, farkle.board.safety
end