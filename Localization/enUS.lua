local addonName, farkle = ...

farkle.L = {}; local L = farkle.L

local function replaceDiceIcons(text)
    return text:gsub("%[(%d+%+?)%]", function(number)
        return "|TInterface/AddOns/Farkle/Media/Icons/dice_" .. number .. ":16:16:0:-4:50:50:0:50:0:50|t"
    end)
end

L["GAME_NAME"] = "Farkle"
L["POINTS"] = "points"
L["GAME_DURATION"] = "Game Duration"
L["DURATION_LABEL"] = "Alright then, let's play! Tell me, how long can you keep up?"
L["DURATION_1"] = "A quick warm-up."
L["DURATION_2"] = "A fair challenge."
L["DURATION_3"] = "All or nothing!"
L["AVERAGE_DURATION"] = "Average duration"
L["SAFE_MODE"] = "Safe Mode"
L["SAFE_MODE_TOOLTIP"] = [[
Changes the dice roll result calculation method to the in-game /roll system.

Mode requirements:
%s You must be in the same group as your opponent.|r
%s There must be no other players in the group.|r

Recommended for playing with strangers and/or for high-stakes games.
]]

-- Offer and responses
L["OFFER_MENU"] = "Play Dice"
L["OFFER_SENT"] = "The offer has been sent."
L["OFFER_LABEL"] = "%s wants to play dice with you."
L["OFFER_SUBTEXT"] = "Goal: %s, Safe Mode: %s."
L["OFFER_DECLINED"] = "%s declined the offer to play."
L["OFFER_PLAYING"] = "%s is currently playing."
L["ON"] = "On"
L["OFF"] = "Off"

-- Innkeeper (NPC)
L["DICE_OPTION"] = "I would like to play dice."

-- Errors
L["NO_ADDON"] = "The player does not have dice."
L["NO_PARTY"] = "The player cannot receive the request because they are not in your group."
L["IN_GAME"] = "You cannot send an offer because you are already in the game."
L["QUIT"] = "%s left the game."
L["PLAYER_IN_COMBAT"] = "You cannot send an offer while you are in combat!"
L["UNIT_IN_COMBAT"] = "You cannot send an offer while the player is in combat!"
L["COMBAT_STARTED"] = "The game has ended (combat started)."
L["OPPONNENT_ATTACKED"] = "The game has ended (the opponent was attacked)."
L["INSTANCE"] = "The game has ended (you entered an instance)."
L["DIED"] = "The game has ended (you died)."
L["MODIFIED_CODE"] = "The game has been canceled (modified code detected)."
L["GROUP_CHANGED"] = "The game has been canceled (the group composition has changed)."

-- Game states
L["READY"] = "Ready"
L["FIRST"] = "You go first!"
L["FIRST_OPPONENT"] = "%s goes first!"
L["TIME_OVER"] = "Time's up!"
L["BUST"] = "Bust!"
L["TOTAL_LABEL"] = "Total"
L["ROUND_LABEL"] = "Round"
L["HOLD_LABEL"] = "Selected"
L["YOUR_TURN"] = "Your turn."
L["OPPONENT_TURN"] = "Opponent's turn."

-- Actions
L["PASS"] = "Pass"
L["HOLD"] = "Hold"
L["GIVE_UP"] = "Give up"
L["GIVE_UP_OFFER"] = "Are you sure you want to give up?"
L["EXIT_GAME_OFFER"] = "Are you sure you want to exit?"

-- Endgame messages
L["YOU_WON"] = "You won!"
L["YOU_LOSE"] = "You lose."
L["YOU_GAVE_UP"] = "You gave up."
L["OPPONENT_GAVE_UP"] = "%s gave up."
L["OPPONENT_OFFLINE"] = "Connection with the opponent has been lost."

-- Chat Messages
L["CHAT_MESSAGE_TEXT"] = "has defeated %s in a game of dice."
L["CHAT_MESSAGE_FORMAT"] = "%s has defeated %s in a game of dice"
L["CHAT_MESSAGE_PATTERN"] = "^has defeated (%S+) in a game of dice%.$"

L["CHAT_MESSAGE_TEXT_RU"] = "обыгрывает %s в кости."
L["CHAT_MESSAGE_FORMAT_RU"] = "%s обыгрывает %s в кости."
L["CHAT_MESSAGE_PATTERN_RU"] = "^обыгрывает (%S+) в кости%.$"

-- Tutorial
L["RULES"] = "Rules"
L["TUTORIAL_BASIC_LABEL"] = "Dice: Basic rules"
L["TUTORIAL_BASIC"] = [[
If you're interested in gambling, you can find a game of dice in any respectable tavern.

|cffE6CC99Course of the game|r
You start the game by rolling all six dice. You then mark the scoring dice you want to set aside, after which you can roll the remaining dice again. You can keep rolling as long as you have at least one die in the game - however, if you don't roll a single scoring die, you forfeit all the points you collected that round and your opponent takes his turn.

The art of dice is to end the round and thus score your points before you run the risk of not scoring any more.

The first person to score the set number of points wins. You can see all the information about the game in the bottom left corner.

|cffCDCDCDTotal /|r |cffffd1004000|r — Goal.
|cffffd1001850|r — Scored points.

|cffCDCDCDRound|r
|cffffd100500|r — Current collected, but unscored points.

|cffCDCDCDSelected|r
|cffffd100100|r — Selected points.
]]

L["TUTORIAL_COMBINATIONS_LABEL"] = "Dice: Point combinations"
L["TUTORIAL_COMBINATIONS"] = replaceDiceIcons([[
Below are all dice combinations and ther points values.
|cffE6CC99
[1] - One (100 points);
[5] - Five (50 points);
[1][2][3][4][5] - Small Straight (500 points);
[2][3][4][5][6] - Large Straight (750 points);
[2][2][4][4][6][6] - Three Pairs (750 points);
[1][2][3][4][5][6] - Straight (1500 points);

[1][1][1] - Three Ones (1000 points);
[2][2][2] - Three Twos (200 points);
[3][3][3] - Three Threes (300 points);
[4][4][4] - Three Fours (400 points);
[5][5][5] - Three Fives (500 points);
[6][6][6] - Three Sixes (600 points);
|r
Each additional die after 3 doubles the value:|cffE6CC99
[2][2][2][2+] - 400 points;
[2][2][2][2+][2+] - 800 points;
[2][2][2][2+][2+][2+] - 1600 points.
]])

L["NEXT_PAGE"] = "Next page"
L["PREVIOUS_PAGE"] = "Previous page"