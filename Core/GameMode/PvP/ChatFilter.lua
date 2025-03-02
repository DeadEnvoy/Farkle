local _, farkle = ...

local L = farkle.L

local function OnEvent(self, event, msg, sender, ...)
    local target = msg:match(L.CHAT_MESSAGE_PATTERN) or msg:match(L.CHAT_MESSAGE_PATTERN_RU)
    if target then
        local senderName, senderRealm = strsplit("-", sender)
        if senderRealm == GetNormalizedRealmName() then
            sender = senderName
        end
        local targetName, targetRealm = strsplit("-", target)
        if targetRealm == GetNormalizedRealmName() then
            target = targetName
        end
        for i = 1, NUM_CHAT_WINDOWS do
            local chatFrame = _G["ChatFrame" .. i]
            if chatFrame and chatFrame:IsEventRegistered("CHAT_MSG_SYSTEM") then
                if GetLocale() == "ruRU" then
                    chatFrame:AddMessage(format(farkle.L.CHAT_MESSAGE_FORMAT_RU, sender, target), 1.000, 1.000, 0.000, 1)
                else
                    chatFrame:AddMessage(format(farkle.L.CHAT_MESSAGE_FORMAT, sender, target), 1.000, 1.000, 0.000, 1)
                end
            end
        end
    end
    return false
end

local function FilterEmoteMessages(self, event, msg, sender, ...)
    if msg:match(farkle.L.CHAT_MESSAGE_PATTERN) or msg:match(farkle.L.CHAT_MESSAGE_PATTERN_RU) then
        return true
    end
    return false
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("CHAT_MSG_EMOTE")
frame:SetScript("OnEvent", OnEvent)

ChatFrame_AddMessageEventFilter("CHAT_MSG_EMOTE", FilterEmoteMessages)