local f = CreateFrame("Frame")

SLASH_DEATHCOUNTER1 = "/deathcounter"
SLASH_DEATHCOUNTER2 = "/dcr"

local defaults = {
    deaths = 0,
    lastDeath = time(),
    guildAnnounce = false,
    usePopupAlert = false,
}

function f:OnEvent(event, addOnName)
    if addOnName == "Death_Counter" then
        --print("Death Counter Loaded")
        FADeathCounterDB = FADeathCounterDB or CopyTable(defaults)
        self:InitializeOptions()
    end

    if event == "PLAYER_DEAD" then
        currentTime = time()
        deathTimeString = self:CalculateTimesinceDeath(FADeathCounterDB.lastDeath, currentTime)

        self:RecordDeathTime(currentTime)
        self:CountDeath()
        self:PrintDeaths(deathTimeString)
        self:AnnounceToGuild(deathTimeString)
    end
end

f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_DEAD")
f:SetScript("OnEvent", f.OnEvent)

function f:InitializeOptions()
    self.panel = CreateFrame("Frame")
    self.panel.name = "Death Counter"

    local cb = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
    cb:SetPoint("TOPLEFT", 20, -20)
    cb.Text:SetText("Use a pop up alert")
    cb:HookScript("OnClick", function(_, btn, down)
        FADeathCounterDB.usePopupAlert = cb:GetChecked()
    end)
    cb:SetChecked(FADeathCounterDB.usePopupAlert)

    local cbGuildAnnounce = CreateFrame("CheckButton", nil, self.panel, "InterfaceOptionsCheckButtonTemplate")
    cbGuildAnnounce:SetPoint("TOPLEFT", 20, -40)
    cbGuildAnnounce.Text:SetText("Announce Deaths to Your Guild")
    cbGuildAnnounce:HookScript("OnClick", function(_, btn, down)
        FADeathCounterDB.guildAnnounce = cbGuildAnnounce:GetChecked()
    end)
    cbGuildAnnounce:SetChecked(FADeathCounterDB.guildAnnounce)

    InterfaceOptions_AddCategory(self.panel)
end

function f:CountDeath()
    FADeathCounterDB.lastDeath = time()
    FADeathCounterDB.deaths = FADeathCounterDB.deaths + 1
end

function f:PrintDeaths(deathTimeString)
    print("You have died " .. FADeathCounterDB.deaths .. " times!")
    
    if (FADeathCounterDB.deaths == 1) then
        useText = "Started Tracking "
    else
        useText = "Last death was "
    end

    messageText = useText .. deathTimeString .. "ago"
    print(messageText)

    if (FADeathCounterDB.usePopupAlert == true) then
        message("You died " .. FADeathCounterDB.deaths .. " times.\n\n" .. messageText)
    end
end

function f:RecordDeathTime(currentTime)
    FADeathCounterDB.lastDeath = currentTime
end

function f:CalculateTimesinceDeath(lastDiedTimeStamp, currentTimeStamp)
    secondsInAMinute = 60
    secondsInAnHour = secondsInAMinute * 60
    secondsInADay = secondsInAnHour * 24
    returnText = ""

    diff = currentTimeStamp - lastDiedTimeStamp

    daysAgo = math.floor(diff / secondsInADay)

    if (daysAgo >= 1) then
        returnText = daysAgo .. " days "
        diff = diff - (secondsInADay * daysAgo)
    end

    hoursAgo = math.floor(diff / secondsInAnHour)

    if (hoursAgo >= 1) then
        returnText = returnText .. hoursAgo .. " hours "
        diff = diff - (secondsInAnHour * hoursAgo)
    end

    minutesAgo = math.floor(diff / secondsInAMinute)

    if (minutesAgo >= 1) then
        returnText = returnText .. minutesAgo .. " minutes "
        diff = diff - (secondsInAMinute * minutesAgo)
    end

    returnText = returnText .. diff .. " seconds "

    return returnText
end

function f:ShouldAnnounceToGuild()
    shouldAnnounce = false

    if (FADeathCounterDB.guildAnnounce and IsInGuild()) then
        shouldAnnounce = true
    end

    return shouldAnnounce
end

function f:AnnounceToGuild(deathTimeString)
    if (f:ShouldAnnounceToGuild() == true) then
        playerName = f:GetPlayerName()
        SendChatMessage(playerName .. " just died! They died " .. FADeathCounterDB.deaths .. " times. " .. playerName .. "'s last death was " .. deathTimeString .. "ago.", "GUILD")
    else
        print("Not in a guild")
    end
end

function f:GetPlayerName()
    playerName, playerRealm = UnitName("player")

    return playerName
end

SlashCmdList.DEATHCOUNTER = function(msg)
    
    if msg == "config" then
        InterfaceOptionsFrame_OpenToCategory(f.panel)
    end

    if msg == "help" then
        print("/dcr -- Show your death count stats")
        print("/dcr help -- Show this help message")
        print("You can use /deathcounter instead of /dcr")
        print("For support, go to https://github.com/FinalAsgard/WoW-Death_Counter")
    end

    if msg == "reset confirm" then
        FADeathCounterDB = CopyTable(defaults)
        print("DB has been reset to default values")
    end

    if msg == "" or msg == nil then
        print("You have died " .. FADeathCounterDB.deaths .. " times.")
        
        if (FADeathCounterDB.deaths > 0) then
            print("Last died " .. f:CalculateTimesinceDeath(FADeathCounterDB.lastDeath, time()))
        end
    end
end

