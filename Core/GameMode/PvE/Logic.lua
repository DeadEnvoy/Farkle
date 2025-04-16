local _, farkle = ...

local C_Farkle = farkle.API
local S_Timer = farkle.API

local function isDiceSelected(selectedDices, diceIndex)
    for _, selected in ipairs(selectedDices) do
        if selected == diceIndex then
            return true
        end
    end
    return false
end

local function getStage(unit)
    if (C_Farkle.GetScore(unit) / C_Farkle.GetBoardInfo("total")) * 100 < 25 then
        return "opening"
    elseif (C_Farkle.GetScore(unit) / C_Farkle.GetBoardInfo("total")) * 100 < 75 then
        return "middlegame"
    else
        return "endgame"
    end
end

local function calculateRiskChance(opponentScore)
    local playerProgress = (C_Farkle.GetScore("player") / C_Farkle.GetBoardInfo("total")) * 100
    local opponentProgress = (opponentScore / C_Farkle.GetBoardInfo("total")) * 100
    local baseRiskChance, additionalChance = 10, 0

    if getStage("player") == "opening" then
        if playerProgress > opponentProgress and (playerProgress - opponentProgress) >= 25 then
            additionalChance = additionalChance + math.floor((playerProgress - opponentProgress) / 25) * 15
        elseif opponentProgress > playerProgress and (opponentProgress - playerProgress) >= 25 then
            additionalChance = additionalChance - math.floor((opponentProgress - playerProgress) / 25) * 15
        end
        if C_Farkle.GetOpponentInfo("rolls") == 1 then
            additionalChance = additionalChance - 15
        elseif C_Farkle.GetOpponentInfo("rolls") > 1 then
            additionalChance = additionalChance - 30
        end
    elseif getStage("player") == "middlegame" then
        additionalChance = 10
        if playerProgress > opponentProgress and (playerProgress - opponentProgress) >= 12.5 then
            additionalChance = additionalChance + math.floor((playerProgress - opponentProgress) / 12.5) * 15
        elseif opponentProgress > playerProgress and (opponentProgress - playerProgress) >= 12.5 then
            additionalChance = additionalChance - math.floor((opponentProgress - playerProgress) / 12.5) * 15
        end
        if C_Farkle.GetOpponentInfo("rolls") == 1 then
            additionalChance = additionalChance - 15
        elseif C_Farkle.GetOpponentInfo("rolls") > 1 then
            additionalChance = additionalChance - 30
        end
    elseif getStage("player") == "endgame" then
        additionalChance = 40
        if playerProgress >= 90 and opponentProgress < 75 then
            additionalChance = 90
        elseif opponentProgress >= 90 then
            additionalChance = additionalChance - 20
        elseif playerProgress > opponentProgress and (playerProgress - opponentProgress) >= 12.5 then
            additionalChance = additionalChance + math.floor((playerProgress - opponentProgress) / 12.5) * 15
        elseif opponentProgress > playerProgress and (opponentProgress - playerProgress) >= 12.5 then
            additionalChance = additionalChance - math.floor((opponentProgress - opponentProgress) / 12.5) * 15
        end
        if C_Farkle.GetOpponentInfo("rolls") == 1 and getStage("opponent") ~= "endgame" then
            additionalChance = additionalChance - 15
        elseif C_Farkle.GetOpponentInfo("rolls") > 1 and getStage("opponent") ~= "endgame" then
            additionalChance = additionalChance - 30
        end
    end

    local riskChance = baseRiskChance + additionalChance

    if riskChance <= 0 then
        riskChance = 5
    elseif riskChance > 100 then
        riskChance = 100
    end

    if math.random(100) <= riskChance then
        return true
    else
        return false
    end
end

function C_Farkle.AISelectDice(dices)
    local diceResults, selectedDices = {}, {}
    local counts, delay = {0, 0, 0, 0, 0, 0}, 0
    local remainingDices = #farkle.board["dices"]
    local aiTakeRisk = false

    for _, diceResult in pairs(dices) do
        counts[tonumber(diceResult)] = counts[tonumber(diceResult)] + 1
    end

    -- 1. Нахождение стрейта [1][2][3][4][5][6]
    if counts[1] >= 1 and counts[2] >= 1 and counts[3] >= 1 and counts[4] >= 1 and counts[5] >= 1 and counts[6] >= 1 then
        for j, value in pairs(dices) do
            if not isDiceSelected(selectedDices, j) then
                table.insert(selectedDices, j); remainingDices = remainingDices - 1
            end
        end
    else
        -- 2. Нахождение трёх пар
        local pairsFound = 0
        for _, count in ipairs(counts) do
            if count >= 2 then
                pairsFound = pairsFound + 1
            end
        end
        if pairsFound == 3 then
            for j, value in pairs(dices) do
                if counts[tonumber(value)] >= 2 and not isDiceSelected(selectedDices, j) then
                    table.insert(selectedDices, j); remainingDices = remainingDices - 1
                end
            end
        else
            -- 3. Нахождение комбинаций [1][2][3][4][5] и [2][3][4][5][6]
            if counts[1] >= 1 and counts[2] >= 1 and counts[3] >= 1 and counts[4] >= 1 and counts[5] >= 1 then
                local usedValues = {1, 2, 3, 4, 5}
                for _, value in ipairs(usedValues) do
                    local found = false
                    for j, diceValue in pairs(dices) do
                        if tonumber(diceValue) == value and not isDiceSelected(selectedDices, j) and not found then
                            table.insert(selectedDices, j); remainingDices = remainingDices - 1
                            found = true
                        end
                    end
                end
            
                -- Дополнительный поиск для [1] и [5]
                for _, value in ipairs({1, 5}) do
                    for j, diceValue in pairs(dices) do
                        if tonumber(diceValue) == value and not isDiceSelected(selectedDices, j) then
                            table.insert(selectedDices, j); remainingDices = remainingDices - 1
                        end
                    end
                end
            elseif counts[2] >= 1 and counts[3] >= 1 and counts[4] >= 1 and counts[5] >= 1 and counts[6] >= 1 then
                local usedValues = {2, 3, 4, 5, 6}
                for _, value in ipairs(usedValues) do
                    local found = false
                    for j, diceValue in pairs(dices) do
                        if tonumber(diceValue) == value and not isDiceSelected(selectedDices, j) and not found then
                            table.insert(selectedDices, j); remainingDices = remainingDices - 1
                            found = true
                        end
                    end
                end
            
                -- Дополнительный поиск только для [5]
                for _, value in ipairs({5}) do
                    for j, diceValue in pairs(dices) do
                        if tonumber(diceValue) == value and not isDiceSelected(selectedDices, j) then
                            table.insert(selectedDices, j); remainingDices = remainingDices - 1
                        end
                    end
                end
            else
                -- 4. Нахождение трёх и более одинаковых чисел
                for i = 1, 6 do
                    if counts[i] >= 3 then
                        for j, value in pairs(dices) do
                            if tonumber(value) == i and not isDiceSelected(selectedDices, j) then
                                table.insert(selectedDices, j); remainingDices = remainingDices - 1
                            end
                        end
                    end
                end
                -- Добирать [1] и/или [5]
                if remainingDices > 4 then
                    if counts[1] >= 1 and (counts[1] + counts[5]) > 3 then
                        if getStage("player") == "opening" and (counts[1] + counts[5]) == 4 and math.random(100) <= 50 then
                            for j, value in pairs(dices) do
                                if (tonumber(value) == 1 or tonumber(value) == 5) and not isDiceSelected(selectedDices, j) then
                                    table.insert(selectedDices, j); remainingDices = remainingDices - 1
                                end
                            end
                        elseif getStage("player") == "opening" and (counts[1] + counts[5]) == 3 and math.random(100) <= 25 then
                            for j, value in pairs(dices) do
                                if (tonumber(value) == 1 or tonumber(value) == 5) and not isDiceSelected(selectedDices, j) then
                                    table.insert(selectedDices, j); remainingDices = remainingDices - 1
                                end
                            end
                        else
                            if counts[1] >= 1 then
                                for j, value in pairs(dices) do
                                    if tonumber(value) == 1 and not isDiceSelected(selectedDices, j) then
                                        table.insert(selectedDices, j); remainingDices = remainingDices - 1
                                        break
                                    end
                                end
                            elseif counts[5] >= 1 then
                                for j, value in pairs(dices) do
                                    if tonumber(value) == 5 and not isDiceSelected(selectedDices, j) then
                                        table.insert(selectedDices, j); remainingDices = remainingDices - 1
                                        break
                                    end
                                end
                            end
                        end
                    elseif counts[1] >= 1 then
                        if getStage("player") == "opening" and counts[1] > 1 and math.random(100) <= 25 then
                            for j, value in pairs(dices) do
                                if tonumber(value) == 1 and not isDiceSelected(selectedDices, j) then
                                    table.insert(selectedDices, j); remainingDices = remainingDices - 1
                                end
                            end
                        else
                            for j, value in pairs(dices) do
                                if tonumber(value) == 1 and not isDiceSelected(selectedDices, j) then
                                    table.insert(selectedDices, j); remainingDices = remainingDices - 1
                                    break
                                end
                            end
                        end
                    elseif counts[5] >= 1 then
                        if getStage("player") == "opening" and counts[5] > 1 and math.random(100) <= 10 then
                            for j, value in pairs(dices) do
                                if tonumber(value) == 5 and not isDiceSelected(selectedDices, j) then
                                    table.insert(selectedDices, j); remainingDices = remainingDices - 1
                                end
                            end
                        else
                            for j, value in pairs(dices) do
                                if tonumber(value) == 5 and not isDiceSelected(selectedDices, j) then
                                    table.insert(selectedDices, j); remainingDices = remainingDices - 1
                                    break
                                end
                            end
                        end
                    end
                elseif remainingDices == 4 then
                    if counts[1] >= 1 and (counts[1] + counts[5]) >= 3 and math.random(100) <= 25 then
                        for j, value in pairs(dices) do
                            if (tonumber(value) == 1 or tonumber(value) == 5) and not isDiceSelected(selectedDices, j) then
                                table.insert(selectedDices, j); remainingDices = remainingDices - 1
                            end
                        end
                    elseif counts[1] >= 1 then
                        if counts[1] > 1 and (getStage("player") == "opening" and math.random(100) <= 90) or (getStage("player") ~= "opening" and math.random(100) <= 25) then
                            for j, value in pairs(dices) do
                                if tonumber(value) == 1 and not isDiceSelected(selectedDices, j) then
                                    table.insert(selectedDices, j); remainingDices = remainingDices - 1
                                end
                            end
                        elseif calculateRiskChance(farkle.opponent.total + farkle.opponent.round) then
                            aiTakeRisk = true
                            if counts[1] > 1 and math.random(100) <= 25 then
                                for j, value in pairs(dices) do
                                    if tonumber(value) == 1 and not isDiceSelected(selectedDices, j) then
                                        table.insert(selectedDices, j); remainingDices = remainingDices - 1
                                    end
                                end
                            else
                                for j, value in pairs(dices) do
                                    if tonumber(value) == 1 and not isDiceSelected(selectedDices, j) then
                                        table.insert(selectedDices, j); remainingDices = remainingDices - 1
                                        break
                                    end
                                end
                            end
                        else
                            for j, value in pairs(dices) do
                                if (tonumber(value) == 1 or tonumber(value) == 5) and not isDiceSelected(selectedDices, j) then
                                    table.insert(selectedDices, j); remainingDices = remainingDices - 1
                                end
                            end
                        end
                    elseif counts[5] >= 1 then
                        if counts[5] > 1 and math.random(100) <= 10 then
                            for j, value in pairs(dices) do
                                if tonumber(value) == 5 and not isDiceSelected(selectedDices, j) then
                                    table.insert(selectedDices, j); remainingDices = remainingDices - 1
                                end
                            end
                        elseif calculateRiskChance(farkle.opponent.total + farkle.opponent.round) then
                            aiTakeRisk = true
                            for j, value in pairs(dices) do
                                if tonumber(value) == 5 and not isDiceSelected(selectedDices, j) then
                                    table.insert(selectedDices, j); remainingDices = remainingDices - 1
                                    break
                                end
                            end
                        else
                            for j, value in pairs(dices) do
                                if (tonumber(value) == 1 or tonumber(value) == 5) and not isDiceSelected(selectedDices, j) then
                                    table.insert(selectedDices, j); remainingDices = remainingDices - 1
                                end
                            end
                        end
                    end
                else
                    for j, value in pairs(dices) do
                        if (tonumber(value) == 1 or tonumber(value) == 5) and not isDiceSelected(selectedDices, j) then
                            table.insert(selectedDices, j); remainingDices = remainingDices - 1
                        end
                    end
                end
            end
        end
    end

    -- [C_Farkle.GetOpponentInfo("rolls") > 0] Добавление всех отобранных костей в список, чтобы они учитывались при просчёте рисков
    for _, diceIndex in ipairs(selectedDices) do
        table.insert(diceResults, dices[diceIndex])
    end

    -- Если ИИ перебрасывает кости более 1-го раза (> 0), 
    if C_Farkle.GetOpponentInfo("rolls") > 0 and remainingDices > 3 then
        if calculateRiskChance(farkle.opponent.total + farkle.opponent.round + farkle.calculateScore(diceResults)) then
            aiTakeRisk = true
        elseif (counts[1] >= 1 or counts[5] >= 1) then
            for j, value in pairs(dices) do
                if (tonumber(value) == 1 or tonumber(value) == 5) and not isDiceSelected(selectedDices, j) then
                    table.insert(selectedDices, j); table.insert(diceResults, dices[value])
                end
            end
        end
    end

    -- [C_Farkle.GetOpponentInfo("rolls") > 0] Сброс списка результатов после просчёта рисков
    diceResults = {}

    -- Отображение (.circle:Show()) отобранных костей и добавление их в список
    for _, diceIndex in ipairs(selectedDices) do
        S_Timer.After(delay, function()
            farkle.board["dices"][diceIndex].circle:Show()
            table.insert(diceResults, dices[diceIndex])
            C_Farkle:SetScore("opponent", farkle.opponent.total, farkle.opponent.round, farkle.calculateScore(diceResults))
        end)
        delay = delay + 0.35;
    end

    S_Timer.After(delay + 1.5, function()
        for _, diceIndex in ipairs(selectedDices) do
            farkle.board["dices"][diceIndex]:Hide()
        end
        -- Если на столе не осталось ни одной кости, то перебрасывать
        if remainingDices == 0 then
            C_Farkle:SetScore("opponent", farkle.opponent.total, farkle.opponent.round + farkle.opponent.hold, 0)
            C_Farkle:SetOpponentInfo("rolls", C_Farkle.GetOpponentInfo("rolls") + 1)
            if (farkle.opponent.total + farkle.opponent.round) >= C_Farkle.GetBoardInfo("total") then
                C_Farkle:SetScore("opponent", farkle.opponent.total + farkle.opponent.round + farkle.opponent.hold, 0, 0)
                S_Timer.After(0.8, function() return C_Farkle.Defeat("lose") end)
            else
                S_Timer.After(0.8, function() C_Farkle.RollDice("math", 6) end)
            end
        elseif remainingDices > 3 and C_Farkle.GetOpponentInfo("rolls") == 0 then
            C_Farkle:SetScore("opponent", farkle.opponent.total, farkle.opponent.round + farkle.opponent.hold, 0)
            if (farkle.opponent.total + farkle.opponent.round) >= C_Farkle.GetBoardInfo("total") then
                C_Farkle:SetScore("opponent", farkle.opponent.total + farkle.opponent.round + farkle.opponent.hold, 0, 0)
                S_Timer.After(0.8, function() return C_Farkle.Defeat("lose") end)
            else
                S_Timer.After(0.8, function() C_Farkle.RollDice("math", remainingDices) end);
            end
        elseif remainingDices > 3 and C_Farkle.GetOpponentInfo("rolls") > 0 then
            C_Farkle:SetScore("opponent", farkle.opponent.total, farkle.opponent.round + farkle.opponent.hold, 0)
            if (farkle.opponent.total + farkle.opponent.round) >= C_Farkle.GetBoardInfo("total") then
                C_Farkle:SetScore("opponent", farkle.opponent.total + farkle.opponent.round + farkle.opponent.hold, 0, 0)
                S_Timer.After(0.8, function() return C_Farkle.Defeat("lose") end)
            else
                if aiTakeRisk then
                    S_Timer.After(0.8, function() C_Farkle.RollDice("math", remainingDices) end);
                else
                    C_Farkle:SetOpponentInfo("rolls", 0)
                    C_Farkle:SetScore("opponent", farkle.opponent.total + farkle.opponent.round + farkle.opponent.hold, 0, 0)
                    S_Timer.After(0.8, function()
                        C_Farkle:ClearBoard(); C_Farkle:SwitchPlayerTurn()
                    end)
                end
            end
        elseif remainingDices <= 3 then
            C_Farkle:SetScore("opponent", farkle.opponent.total, farkle.opponent.round + farkle.opponent.hold, 0)
            if (farkle.opponent.total + farkle.opponent.round) >= C_Farkle.GetBoardInfo("total") then
                C_Farkle:SetScore("opponent", farkle.opponent.total + farkle.opponent.round + farkle.opponent.hold, 0, 0)
                S_Timer.After(0.8, function() return C_Farkle.Defeat("lose") end)
            else
                if aiTakeRisk or calculateRiskChance(farkle.opponent.total + farkle.opponent.round) then
                    S_Timer.After(0.8, function() C_Farkle.RollDice("math", remainingDices) end)
                else
                    C_Farkle:SetOpponentInfo("rolls", 0)
                    C_Farkle:SetScore("opponent", farkle.opponent.total + farkle.opponent.round + farkle.opponent.hold, 0, 0)
                    S_Timer.After(0.8, function()
                        C_Farkle:ClearBoard(); C_Farkle:SwitchPlayerTurn()
                    end)
                end
            end
        end
    end)
end