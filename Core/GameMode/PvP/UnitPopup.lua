local addonName, farkle = ...

local L = farkle.L

farkle.players = { }

local function GetTextureString(texturePath, width, height, cropX, cropY, left, right, top, bottom)
    local textureString = string.format("|T%s:%d:%d:%d:%d:256:256:%d:%d:%d:%d|t",
        texturePath, width, height, cropX, cropY,
        left * 256, right * 256, top * 256, bottom * 256)
    return textureString
end

EventRegistry:RegisterFrameEventAndCallback("PLAYER_TARGET_CHANGED", function(ownerID, ...)
    if UnitExists("target") and UnitIsPlayer("target") and not C_Farkle.UnitCanPlay("target") then
        C_Farkle.SendAddonMessage("checkup")
    end
end)

local function findButton(rootDescription)
    local duelFound, petFound = nil, nil
    for index, element in rootDescription:EnumerateElementDescriptions() do
        local text = MenuUtil.GetElementText(element)
        if text and text == PET_BATTLE_PVP_DUEL then
            petFound = index
        elseif text and text == DUEL then
            duelFound = index
        end
    end
    if petFound then
        return petFound
    elseif duelFound then
        return duelFound
    end
end

local function CreateButtonWithIcon(parent, buttonText, tooltipTitle, tooltipText, func, iconTexture, textColor)
    local button = parent:CreateButton(buttonText, func)
    button:SetTooltip(function(tooltip, elementDescription)
        GameTooltip_SetTitle(tooltip, tooltipTitle);
        GameTooltip_AddNormalLine(tooltip, tooltipText);
    end)
    button:AddInitializer(function(button, description, menu)
        local rightTexture = button:AttachTexture()
        rightTexture:SetSize(18, 18)
        rightTexture:SetPoint("RIGHT")
        rightTexture:SetAtlas(iconTexture)

        local leftText = button.fontString
        leftText:SetPoint("RIGHT", rightTexture, "LEFT", -5, 0)
        leftText:SetTextColor(textColor:GetRGB())

        local pad = 20
        local width = pad + leftText:GetUnboundedStringWidth() + rightTexture:GetWidth()
        local height = 20
        return width, height
    end)
    return button
end

local function createButtons(rootDescription, contextData)
    if findButton(rootDescription) then
        ---@diagnostic disable-next-line: missing-parameter
        local index, submenu = findButton(rootDescription), MenuUtil.CreateButton(L["OFFER_MENU"])
        submenu:SetEnabled(false); rootDescription:Insert(submenu, index + 1)
        submenu:CreateTitle(L["GAME_DURATION"])

        if not UnitAffectingCombat(contextData.unit) and not UnitAffectingCombat(contextData.unit) then
            if C_Farkle.UnitCanPlay(contextData.unit) and not C_Farkle.HasOpponent() then
                submenu:SetEnabled(true)
            elseif C_Farkle.UnitCanPlay(contextData.unit) and C_Farkle.HasOpponent() then
                submenu:SetEnabled(false)
                submenu:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
                    GameTooltip_AddErrorLine(tooltip, L["IN_GAME"]);
                end)
            elseif UnitIsSameServer(contextData.unit) and not C_Farkle.UnitCanPlay(contextData.unit) then
                submenu:SetEnabled(false)
                submenu:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
                    GameTooltip_AddErrorLine(tooltip, L["NO_ADDON"]);
                end)
            else
                submenu:SetEnabled(false)
                submenu:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
                    GameTooltip_AddErrorLine(tooltip, L["NO_ADDON"]);
                end)
            end
        else
            submenu:SetEnabled(false)
            if UnitAffectingCombat("player") then
                submenu:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
                    GameTooltip_AddErrorLine(tooltip, L["PLAYER_IN_COMBAT"]);
                end)
            elseif UnitAffectingCombat(contextData.unit) then
                submenu:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
                    GameTooltip_AddErrorLine(tooltip, L["UNIT_IN_COMBAT"]);
                end)
            end
        end

        local safetyMode = false

        CreateButtonWithIcon(
            submenu,
            format("2000 %s", L["POINTS"]),
            L["DURATION_1"],
            format("%s: %d-%s", L["AVERAGE_DURATION"], 1, format(MINUTES_ABBR, 2)),
            function()
                if not safetyMode then
                    C_Farkle.SendAddonMessage("offer:2000:false");
                else
                    if UnitInParty(contextData.unit) then
                        C_Farkle.SendAddonMessage("offer:2000:true")
                    else
                        C_Farkle.SendAddonMessage("offer:2000:false")
                    end
                end
                DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. L["OFFER_SENT"], 1.000, 1.000, 0.000)
                return MenuResponse.CloseAll
            end,
            "challenges-medal-small-bronze",
            CreateColor(0.8, 0.5, 0.2)
        )

        CreateButtonWithIcon(
            submenu,
            format("4000 %s", L["POINTS"]),
            L["DURATION_2"],
            format("%s: %d-%s", L["AVERAGE_DURATION"], 3, format(MINUTES_ABBR, 4)),
            function()
                if not safetyMode then
                    C_Farkle.SendAddonMessage("offer:4000:false");
                else
                    if UnitInParty(contextData.unit) then
                        C_Farkle.SendAddonMessage("offer:4000:true")
                    else
                        C_Farkle.SendAddonMessage("offer:4000:false")
                    end
                end
                DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. L["OFFER_SENT"], 1.000, 1.000, 0.000)
                return MenuResponse.CloseAll
            end,
            "challenges-medal-small-silver",
            CreateColor(0.8, 0.8, 0.8)
        )

        CreateButtonWithIcon(
            submenu,
            format("8000 %s", L["POINTS"]),
            L["DURATION_3"],
            format("%s: %d-%s", L["AVERAGE_DURATION"], 7, format(MINUTES_ABBR, 8)),
            function()
                if not safetyMode then
                    C_Farkle.SendAddonMessage("offer:8000:false")
                else
                    if UnitInParty(contextData.unit) then
                        C_Farkle.SendAddonMessage("offer:8000:true")
                    else
                        C_Farkle.SendAddonMessage("offer:8000:false")
                    end
                end
                DEFAULT_CHAT_FRAME:AddMessage(DICE_ICON .. " " .. L["OFFER_SENT"], 1.000, 1.000, 0.000)
                return MenuResponse.CloseAll
            end,
            "challenges-medal-small-gold",
            CreateColor(1, 0.816, 0)
        )

        submenu:CreateDivider()
        local function setSelected(index)
            safetyMode = not safetyMode
            return MenuResponse.Refresh
        end
        local function isSelected(index)
            return safetyMode
        end
        if UnitInParty(contextData.unit) and GetNumGroupMembers() == 2 then
           local safeModeButton = submenu:CreateRadio(L["SAFE_MODE"], isSelected, setSelected, index)
            safeModeButton:SetEnabled(true); safeModeButton:SetTooltip(function(tooltip, elementDescription)
                GameTooltip_SetTitle(tooltip, L["SAFE_MODE"]);
                GameTooltip_AddNormalLine(tooltip, format(L["SAFE_MODE_TOOLTIP"],
                "|cff19ff19" .. GetTextureString("interface/common/commonicons", 12, 12, 0, 1, 0.00048828125, 0.12548828125, 0.5048828125, 0.7548828125),
                "|cff19ff19" .. GetTextureString("interface/common/commonicons", 12, 12, 0, 1, 0.00048828125, 0.12548828125, 0.5048828125, 0.7548828125)))
            end)
        elseif UnitInParty(contextData.unit) and GetNumGroupMembers() ~= 2 then
            local safeModeButton = submenu:CreateRadio(L["SAFE_MODE"], isSelected, setSelected, index)
            safeModeButton:SetEnabled(false); safeModeButton:SetTooltip(function(tooltip, elementDescription)
                GameTooltip_SetTitle(tooltip, L["SAFE_MODE"]);
                GameTooltip_AddNormalLine(tooltip, format(L["SAFE_MODE_TOOLTIP"],
                "|cff19ff19" .. GetTextureString("interface/common/commonicons", 12, 12, 0, 1, 0.00048828125, 0.12548828125, 0.5048828125, 0.7548828125),
                "|cffff2020" .. GetTextureString("interface/common/commonicons", 12, 12, 0, 0, 0.25244140625, 0.37744140625, 0.0009765625, 0.2509765625)))
            end)
        elseif not UnitInParty(contextData.unit) then
            local safeModeButton = submenu:CreateRadio(L["SAFE_MODE"], isSelected, setSelected, index)
            safeModeButton:SetEnabled(false); safeModeButton:SetTooltip(function(tooltip, elementDescription)
                GameTooltip_SetTitle(tooltip, L["SAFE_MODE"]);
                GameTooltip_AddNormalLine(tooltip, format(L["SAFE_MODE_TOOLTIP"],
                "|cffff2020" .. GetTextureString("interface/common/commonicons", 12, 12, 0, 0, 0.25244140625, 0.37744140625, 0.0009765625, 0.2509765625),
                "|cffff2020" .. GetTextureString("interface/common/commonicons", 12, 12, 0, 0, 0.25244140625, 0.37744140625, 0.0009765625, 0.2509765625)))
            end)
        end
    end
end

Menu.ModifyMenu("MENU_UNIT_PLAYER", function(owner, rootDescription, contextData)
    createButtons(rootDescription, contextData)
end)

Menu.ModifyMenu("MENU_UNIT_PARTY", function(owner, rootDescription, contextData)
    createButtons(rootDescription, contextData)
end)