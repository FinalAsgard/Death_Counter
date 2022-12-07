local f = CreateFrame("Frame")

SLASH_DEATHCOUNTER1 = "/deathcounter"
SLASH_DEATHCOUNTER2 = "/dcr"

local defaults = {
    deaths = 0,
    lastDeath = time(),
    guildAnnounce = false,
}

function f:OnEvent(event, addOnName)
    if addOnName == "Death_Counter" then
        print("Death Counter Loaded")
        FADeathCounterDB = FADeathCounterDB or CopyTable(defaults)
        --self:InitializeOptions()
    end

    if event == "PLAYER_DEAD" then
        currentTime = time()
        deathTimeString = self:CalculateTimesinceDeath(FADeathCounterDB.lastDeath, currentTime)
        self:RecordDeathTime(currentTime)
        self:CountDeath()
        self:PrintDeaths(deathTimeString)
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
    cb.Text:SetText("Announce Death to Guild")
    cb:HookScript("OnClick", function(_, btn, down)
        FADeathCounterDB.guildAnnounce = cb:GetChecked()
    end)
    cb:SetChecked(FADeathCounterDB.guildAnnounce)

    InterfaceOptions_AddCategory(self.panel)
end

function f:CountDeath()
    FADeathCounterDB.lastDeath = time()
    FADeathCounterDB.deaths = FADeathCounterDB.deaths + 1
end

function f:PrintDeaths(deathTimeString)
    print("You have died " .. FADeathCounterDB.deaths .. " times!")
    
    if (FADeathCounterDB.deaths > 0) then
        useText = "Last death was "
    else
        useText = "Started Tracking "
    end

    print(useText .. deathTimeString .. "ago")
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

SlashCmdList.DEATHCOUNTER = function(msg)
    --[[ Coming soon...
    if msg == "config" then
        InterfaceOptionsFrame_OpenToCategory(f.panel)
    end
    --]]

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

