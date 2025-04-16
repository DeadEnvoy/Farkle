local addonName, farkle = ...

local L = farkle.L
local C_Farkle = farkle.API

farkle.players = {}

local function GetTextureString(texturePath, width, height, cropX, cropY, left, right, top, bottom)
    local textureString = string.format("|T%s:%d:%d:%d:%d:256:256:%d:%d:%d:%d|t",
        texturePath, width, height, cropX, cropY,
        left * 256, right * 256, top * 256, bottom * 256)
    return textureString
end

EventRegistry:RegisterFrameEventAndCallback("PLAYER_TARGET_CHANGED", function(ownerID, ...)
    if UnitExists("target") and (UnitIsPlayer("target") and UnitName("target") ~= UnitName("player")) then
        local name, realm = GetUnitName("target", true) or GetUnitName("target", true), GetNormalizedRealmName()
        if not C_Farkle.UnitCanPlay(format("%s-%s", name, realm)) then
            C_Farkle.SendAddonMessage(format("checkup:%s", name, realm))
        end
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

        if not C_Farkle.UnitCanPlay(format("%s-%s", contextData.name, contextData.server or GetNormalizedRealmName())) then
            C_Farkle.SendAddonMessage(format("checkup:%s-%s", contextData.name, contextData.server or GetNormalizedRealmName()))
        end

        if not CheckInteractDistance(contextData.unit, 3) then
            return
        end

        if farkle.status["offer"].isSent or StaticPopup_Visible("FARKLE_PLAY_OFFER") then
            submenu:SetTooltip(function(tooltip, elementDescription)
                GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
                GameTooltip_AddErrorLine(tooltip, farkle.status["offer"].isSent and L["OFFER_ALREADY_SENT"] or L["CANNOT_SEND_OFFER"]);
            end)
            return
        elseif C_Farkle.HasOpponent() then
            submenu:SetTooltip(function(tooltip, elementDescription)
                GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
                GameTooltip_AddErrorLine(tooltip, L["IN_GAME"]);
            end)
            return
        end

        if not UnitAffectingCombat("player") and not UnitAffectingCombat(contextData.unit) then
            if C_Farkle.UnitCanPlay(format("%s-%s", contextData.name, contextData.server or GetNormalizedRealmName())) then
                submenu:SetEnabled(true)
            else
                submenu:SetTooltip(function(tooltip, elementDescription)
                    GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
                    GameTooltip_AddErrorLine(tooltip, L["NO_ADDON"]);
                end)
                return
            end
        elseif UnitAffectingCombat("player") or UnitAffectingCombat(contextData.unit) then
            submenu:SetTooltip(function(tooltip, elementDescription)
                GameTooltip_SetTitle(tooltip, MenuUtil.GetElementText(elementDescription));
                GameTooltip_AddErrorLine(tooltip, UnitAffectingCombat("player") and L["PLAYER_IN_COMBAT"] or L["UNIT_IN_COMBAT"]);
            end)
            return
        end

        submenu:CreateTitle(L["GAME_DURATION"])

        local safetyMode = false

        CreateButtonWithIcon(
            submenu,
            format("2000 %s", L["POINTS"]),
            L["DURATION_1"],
            format("%s: %d-%s", L["AVERAGE_DURATION"], 1, format(MINUTES_ABBR, 2)),
            function()
                C_Farkle.SendAddonMessage(format(
                    "offer:%s-%s:%s:%s", contextData.name, contextData.server or GetNormalizedRealmName(), 2000,
                    (UnitInParty(contextData.unit) and GetNumGroupMembers() == 2) and tostring(safetyMode) or "false"));
                farkle.status["offer"].isSent = format("%s-%s", contextData.name, contextData.server or GetNormalizedRealmName());
                DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. L["OFFER_SENT"], 1.000, 1.000, 0.000);
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
                C_Farkle.SendAddonMessage(format(
                    "offer:%s-%s:%s:%s", contextData.name, contextData.server or GetNormalizedRealmName(), 4000,
                    (UnitInParty(contextData.unit) and GetNumGroupMembers() == 2) and tostring(safetyMode) or "false"));
                farkle.status["offer"].isSent = format("%s-%s", contextData.name, contextData.server or GetNormalizedRealmName());
                DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. L["OFFER_SENT"], 1.000, 1.000, 0.000);
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
                C_Farkle.SendAddonMessage(format(
                    "offer:%s-%s:%s:%s", contextData.name, contextData.server or GetNormalizedRealmName(), 8000,
                    (UnitInParty(contextData.unit) and GetNumGroupMembers() == 2) and tostring(safetyMode) or "false"));
                farkle.status["offer"].isSent = format("%s-%s", contextData.name, contextData.server or GetNormalizedRealmName());
                DEFAULT_CHAT_FRAME:AddMessage(CHAT_DICE_ICON .. " " .. L["OFFER_SENT"], 1.000, 1.000, 0.000);
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