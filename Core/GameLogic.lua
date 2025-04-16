local _, farkle = ...

local L = farkle.L
local C_Farkle = farkle.API
local S_Timer = farkle.API
local S_Sound = farkle.API

farkle.player = {
    requester = false,
    isPlaying = false,

    turn = false,
    ready = false,

    rolls = 0,
    total = 0,
    round = 0,
    hold = 0,
    ["dices"] = {},
    ["diceHold"] = {}
}

farkle.opponent = {
    name = nil,
    realm = nil,
    class = nil,
    sex = nil,

    turn = false,
    ready = false,

    rolls = 0,
    total = 0,
    round = 0,
    hold = 0,
    ["dices"] = {},
    ["diceHold"] = {},
}

local mt = {
    __index = function(t, k)
        if k == "unit" and (t.name and t.realm) then
            if t.realm == GetNormalizedRealmName() then
                return t.name
            else
                return t.name .. "-" .. t.realm
            end
        end
    end
}

setmetatable(farkle.opponent, mt)

farkle.board = {
    total = nil,
    safety = false,
    mode = nil,
    stage = nil,
    ["dices"] = {}
}

function farkle.calculateScore(diceHold)
    local counts = {0, 0, 0, 0, 0, 0} -- Счётчик для каждого значения кубика (1-6)
    for _, value in pairs(diceHold) do
        counts[tonumber(value)] = counts[tonumber(value)] + 1
    end

    local score = 0

    -- Комбинация из всех значений 1-6
    if counts[1] >= 1 and counts[2] >= 1 and counts[3] >= 1 and counts[4] >= 1 and counts[5] >= 1 and counts[6] >= 1 then
        score = score + 1500
        return score
    end

    -- Комбинации [1, 2, 3, 4, 5]
    if counts[1] >= 1 and counts[2] >= 1 and counts[3] >= 1 and counts[4] >= 1 and counts[5] >= 1 then
        if counts[2] > 1 or counts[3] > 1 or counts[4] > 1 then
            return 0
        end
        score = score + 500
        counts[1] = counts[1] - 1
        counts[2] = counts[2] - 1
        counts[3] = counts[3] - 1
        counts[4] = counts[4] - 1
        counts[5] = counts[5] - 1
    end

    local pairs = 0
    for i = 1, 6 do
        if counts[i] == 2 then
            pairs = pairs + 1
        end
    end
    if pairs == 3 then
        score = score + 750
        return score
    end

    -- Комбинации [2, 3, 4, 5, 6]
    if counts[2] >= 1 and counts[3] >= 1 and counts[4] >= 1 and counts[5] >= 1 and counts[6] >= 1 then
        if counts[2] > 1 or counts[3] > 1 or counts[4] > 1 or counts[6] > 1 then
            return 0
        end
        score = score + 750
        counts[2] = counts[2] - 1
        counts[3] = counts[3] - 1
        counts[4] = counts[4] - 1
        counts[5] = counts[5] - 1
        counts[6] = counts[6] - 1
    end

    -- Подсчёт очков за комбинации
    for i = 1, 6 do
        if counts[i] >= 3 then
            if i == 1 then
                score = score + 1000 * (2 ^ (counts[i] - 3))
            else
                score = score + (i * 100) * (2 ^ (counts[i] - 3))
            end
            counts[i] = 0  -- Обнуляем счетчик, чтобы не учитывать эти кости в дальнейшем
        end
    end

    -- Подсчёт очков за 1 и 5
    score = score + counts[1] * 100
    score = score + counts[5] * 50

    -- Проверка на неиспользуемые числа
    for i = 1, 6 do
        if counts[i] > 0 and (i ~= 1 and i ~= 5) then
            return 0
        end
    end

    return score
end

local xOffsets = {-127, -72, 110, -55, 70, 50}
local yOffsets = {-22, 88, 10, -100, -100, 110}

local function diceRoll(roll, dices)
    local diceResults = {}
    for i = 1, roll do
        table.insert(diceResults, dices[i])
        local rotation = math.random() * 2 * math.pi
        farkle.board["dices"][i] = CreateFrame("Frame", nil, FarkleBoard)
        farkle.board["dices"][i]:SetPoint("CENTER", xOffsets[i], yOffsets[i])
        farkle.board["dices"][i]:SetSize(100, 80)
        farkle.board["dices"][i].texture = farkle.board["dices"][i]:CreateTexture()
        farkle.board["dices"][i].texture:SetTexture("Interface\\AddOns\\Farkle\\Media\\dice_" .. dices[i])
        farkle.board["dices"][i].texture:SetWidth(75); farkle.board["dices"][i].texture:SetHeight(75)
        farkle.board["dices"][i].texture:SetPoint("CENTER")
        farkle.board["dices"][i].texture:SetRotation(rotation)

        farkle.board["dices"][i].circle = CreateFrame("Frame", nil, farkle.board["dices"][i])
        farkle.board["dices"][i].circle = farkle.board["dices"][i].circle:CreateTexture()
        farkle.board["dices"][i].circle:SetPoint("CENTER", farkle.board["dices"][i])
        farkle.board["dices"][i].circle:SetTexture("Interface\\AddOns\\Farkle\\Media\\dice_border")
        farkle.board["dices"][i].circle:SetWidth(95); farkle.board["dices"][i].circle:SetHeight(95)
        farkle.board["dices"][i].circle:SetRotation(rotation); farkle.board["dices"][i].circle:Hide()

        if C_Farkle.IsPlayerTurn() then
            farkle.player["diceHold"] = {}
            farkle.board["dices"][i]:SetScript("OnMouseUp", function(self, button)
                if button == "LeftButton" then
                    if self.circle:IsShown() then
                        self.circle:Hide(); farkle.player["diceHold"][i] = nil
                    else
                        self.circle:Show(); farkle.player["diceHold"][i] = dices[i]
                    end
                    farkle.player.hold = farkle.calculateScore(farkle.player["diceHold"]);
                    FarkleBoard.PlayerBoard.HoldPlayer:SetText(farkle.player.hold)

                    if farkle.player.hold == 0 then
                        C_Farkle:DisableButton(FarkleBoard.Input_Key_Q); C_Farkle:DisableButton(FarkleBoard.Input_Key_E);
                    else
                        C_Farkle:EnableButton(FarkleBoard.Input_Key_Q); C_Farkle:EnableButton(FarkleBoard.Input_Key_E);
                    end
                end
            end)
        else
            farkle.board["dices"][i].circle:SetVertexColor(1.000, 0.125, 0.125)
        end
    end

    local counts = {0, 0, 0, 0, 0, 0}
    for _, value in pairs(diceResults) do
        counts[value] = counts[value] + 1
    end

    local hasCombination = false

    if counts[1] > 0 or counts[5] > 0 then
        hasCombination = true
    end

    for i = 1, #counts do
        if counts[i] >= 3 then
            hasCombination = true
            break
        end
    end

    local pairsCount = 0
    for i = 1, #counts do
        if counts[i] >= 2 then
            pairsCount = pairsCount + 1
        end
    end

    if pairsCount == 3 then
        hasCombination = true
    end

    if not hasCombination then
        C_Farkle:AddWarningMessage("CENTER", L["BUST"], 2.5)
        if C_Farkle.IsPlayerTurn() then
            C_Farkle:SetValue("rolls", 0)
            C_Farkle:SetScore("player", farkle.player.total, 0, 0)
            FarkleBoard.Input_Key_Q:Hide(); FarkleBoard.Input_Key_E:Hide()
        else
            C_Farkle:SetOpponentInfo("rolls", 0)
            C_Farkle:SetScore("opponent", farkle.opponent.total, 0, 0)
        end
        S_Timer.After(2.5, function()
            C_Farkle:SwitchPlayerTurn()
        end)
        S_Timer.After(2.5, function()
            C_Farkle:ClearBoard()
        end)
    else
        C_Farkle:CreateTimer()
        if not C_Farkle.IsPlayerTurn() and C_Farkle.IsPvE() then
            S_Timer.After(3, function() C_Farkle.AISelectDice(dices) end)
        end
    end
end

function C_Farkle.RollDice(type, roll, delay, dices)
    C_Farkle:ClearBoard(); dices, delay = dices or {}, delay or 0
    farkle.player["dices"] = {}; farkle.opponent["dices"] = {}
    if type == "math" then
        S_Sound.Play("Interface\\AddOns\\Farkle\\Media\\Audio\\diceShaking.mp3", "Master")
        if C_Farkle.IsPlayerTurn() or C_Farkle.IsPvE() then
            for i = 1, roll do
                table.insert(dices, math.random(1, 6))
            end
            if C_Farkle.IsPvP() then
                C_Farkle.SendAddonMessage(format("roll:%s:%s:%s", delay, roll, table.concat(dices, ":")))
            end
        end
        S_Timer.After(delay + 1.8, function()
            diceRoll(roll, dices); S_Sound.Play("Interface\\AddOns\\Farkle\\Media\\Audio\\diceRoll.mp3", "Master")
        end)
    elseif type == "random" then
        local pattern = "^" .. (C_Farkle.IsPlayerTurn() and UnitName("player") or C_Farkle.GetOpponentInfo("name")) .. "%s+%S+%s+(%d+)%s+%(1%-6%)$"
        local function chatFilter(self, event, msg, ...)
            if C_Farkle.IsPlaying() then
                if msg:match(pattern) then
                    return true
                end
            else
                ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", self)
            end
        end
        local frame = CreateFrame("Frame"); frame:RegisterEvent("CHAT_MSG_SYSTEM")
        local function chatHandler(self, event, msg)
            if C_Farkle.IsPlaying() then
                local value = msg:match(pattern)
                if value then
                    value = tonumber(value)
                    table.insert(dices, value)
                    if C_Farkle.IsPlayerTurn() then
                        table.insert(farkle.player["dices"], value)
                    else
                        table.insert(farkle.opponent["dices"], value)
                    end
                    if #dices == roll then
                        self:UnregisterEvent("CHAT_MSG_SYSTEM"); ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", chatFilter)
                        S_Timer.After((C_Farkle.IsPlayerTurn() and 1.55 or 1.55 + (select(3, GetNetStats()) / 500)), function()
                            diceRoll(roll, dices); S_Sound.Play("Interface\\AddOns\\Farkle\\Media\\Audio\\diceRoll.mp3", "Master")
                        end)
                    end
                end
            else
                self:UnregisterEvent("CHAT_MSG_SYSTEM"); ChatFrame_RemoveMessageEventFilter("CHAT_MSG_SYSTEM", chatFilter)
            end
        end

        ChatFrame_AddMessageEventFilter("CHAT_MSG_SYSTEM", chatFilter); frame:SetScript("OnEvent", chatHandler)

        S_Sound.Play("Interface\\AddOns\\Farkle\\Media\\Audio\\diceCup.mp3", "Master")
        if C_Farkle.IsPlayerTurn() then
            C_Farkle.SendAddonMessage(format("roll:%s:%s", delay, roll))
        end

        S_Timer.After(delay + 1.180, function()
            S_Sound.Play("Interface\\AddOns\\Farkle\\Media\\Audio\\diceShaking.mp3", "Master")
            if C_Farkle.IsPlayerTurn() then
                for i = 1, roll do
                    RandomRoll(1, 6)
                end
            end
        end)
    end
end