local started = false
local frameWorkVersion, primaryDevelopers = "4.0"
local allowScriptStart = false
local allowwhiteListLoad = false
local recentDisconnects = {}
local PWBaseprocessed = false
RegisterServerEvent('pw:playerTeleported')
exports('ServerStartupSequence', function()
    started = true
end)

exports('checkScriptStart', function()
    return allowScriptStart
end)

exports('allowWhitelist', function()
    return allowwhiteListLoad
end)

MySQL.ready(function ()
    MySQL.Async.fetchAll("SELECT * FROM `users`", {}, function(usrs)
        for k, v in pairs(usrs) do
            Users[tonumber(v.unique_id)] = User(tonumber(v.unique_id))
        end
        PWBaseprocessed = true
        print('Loaded '..#usrs..' Users')
    end)
end)

AddEventHandler('onResourceStart', function(resource)
    if resource == "pw_base" then
        print('')
        print(' ^1[PixelWorld Framework] ^3- Initialising Framework...^7')
        print('')
        print(' ^1[PixelWorld Framework] ^3- Step 1/4 - Loading Users^7')
        print(' ^1[PixelWorld Framework] ^3- Step 2/4 - Loading Characters^7')
        print('')     
        local scripters, mappers, vehicles
        for k, v in pairs(Config.Developers['Scripters']) do
            if k == 1 then
                scripters = v
            else
                scripters = scripters..", "..v
            end
        end

        for k, v in pairs(Config.Developers['Vehicles']) do
            if k == 1 then
                vehicles = v
            else
                vehicles = vehicles..", "..v
            end
        end

        for k, v in pairs(Config.Developers['Mappers']) do
            if k == 1 then
                mappers = v
            else
                mappers = mappers..", "..v
            end
        end
        repeat Wait(0) until started == true
        print('\n ^1██████╗ ^2██╗^3██╗  ██╗^4███████╗^5██╗     ^6██╗    ██╗^7 ██████╗ ^8██████╗ ^9██╗     ^1██████╗ ^7')
        print(' ^1██╔══██╗^2██║^3╚██╗██╔╝^4██╔════╝^5██║     ^6██║    ██║^7██╔═══██╗^8██╔══██╗^9██║     ^1██╔══██╗^7')
        print(' ^1██████╔╝^2██║^3 ╚███╔╝ ^4█████╗  ^5██║     ^6██║ █╗ ██║^7██║   ██║^8██████╔╝^9██║     ^1██║  ██║^7')
        print(' ^1██╔═══╝ ^2██║^3 ██╔██╗ ^4██╔══╝  ^5██║     ^6██║███╗██║^7██║   ██║^8██╔══██╗^9██║     ^1██║  ██║^7')
        print(' ^1██║     ^2██║^3██╔╝ ██╗^4███████╗^5███████╗^6╚███╔███╔╝^7╚██████╔╝^8██║  ██║^9███████╗^1██████╔╝^7')
        print(' ^1╚═╝     ^2╚═╝^3╚═╝  ╚═╝^4╚══════╝^5╚══════╝^6 ╚══╝╚══╝ ^7 ╚═════╝ ^8╚═╝  ╚═╝^9╚══════╝^1╚═════╝ ^7')
        print('')
        print(' ^1[PixelWorld Framework] ^3- Step 3/4 - Loading Whitelist^7')
        allowwhiteListLoad = true
        repeat Wait(0) until exports['pw_queue']:GetQueueExports().IsWhitelistLoaded() == true
        print(' ^1[PixelWorld Framework] ^3- Step 4/4 - Loading Components^7')
        repeat Wait(0) until PWBaseprocessed == true
        print(' ^1[PixelWorld Framework] ^3- Accepting New Connections^7')
        print(' ^1[PixelWorld Framework] ^3- Initialised...^7')
        print(' ^1[PixelWorld Framework] ^3- Framework Version: ^5'..frameWorkVersion..'^7')
        print(' ^1[PixelWorld Framework] ^3- Scripting Development Team: ^4'..scripters..'^7')
        print(' ^1[PixelWorld Framework] ^3- Vehicle Development Team: ^4'..vehicles..'^7')
        print(' ^1[PixelWorld Framework] ^3- Mapping Development Team: ^4'..mappers..'^7')
        allowScriptStart = true
        print('')                                                                                                                                                                              
    end
end)

PW.RegisterServerCallback('pw_base:getVinNumber', function(source, cb, plate)
    local vehicles = exports.pw_vehicleshop:getVehicles()
    local found = false
    for k, v in pairs(vehicles) do
        if v.getCurrentPlate() == plate then
            cb(k)
        end
    end
end)

AddEventHandler("playerConnecting", function(name, setKickReason, deferrals)
    deferrals.defer()
    local _src = source
    local steam = GetPlayerIdentifiers(_src)[1]
    local license = GetPlayerIdentifiers(_src)[2]
    Wait(0)
    print(steam, license)
    MySQL.Async.fetchAll("SELECT * FROM `banned_users` WHERE `steam` = @steam OR `license` = @lic", {['@steam'] = steam, ['@lic'] = license}, function(banned)
        if banned[1] ~= nil then
            deferrals.done("Sorry you have been banned from playing on the PixelWorld Roleplay Servers, your Ban ID is: "..banned[1].ban_id)
        else
            deferrals.done()
        end
    end)    
end)

AddEventHandler('playerDropped', function(reason)
    local _src = source
    if Players[_src] then
        if Users[Players[_src]].loadedChar ~= nil and Users[Players[_src]].loadedChar ~= 0 then
            table.insert(recentDisconnects, {['source'] = _src, ['name'] = Users[Players[_src]]:Character().getName(), ['reason'] = reason})
            print(' ^1[PixelWorld] ^7 - ^4'..Users[Players[_src]]:Character().getName()..' has disconnected.')
            Wait(1000)
            Users[Players[_src]].unloadCharacter()
            Players[_src] = nil
        end
    end
end)

RegisterServerEvent('pw_base:giveWeapon')
AddEventHandler('pw_base:giveWeapon', function(name, ammo)
    local _src = source
    exports['pw_base']:Source(_src):Inventories():AddItem():Player().Weapon(name, ammo)
end)

function getStaff(job, workplace)
    local staff = {}
    for k, v in pairs(Users) do
        for b, c in pairs(Users[k].avaCharacters()) do
            if (not workplace and Users[k]:Offline(tonumber(c.cid)):Job().getJob().job == job) or (workplace and (Users[k]:Offline(tonumber(c.cid)):Job().getJob().job == job and Users[k]:Offline(tonumber(c.cid)):Job().getJob().workplace == workplace)) then
                table.insert(staff, {['cid'] = Users[k]:Offline(tonumber(c.cid)):Character().getCID(), ['name'] = Users[k]:Offline(tonumber(c.cid)):Character().getName(), ['job'] = Users[k]:Offline(tonumber(c.cid)):Job().getJob(), ['source'] = Users[k]:Offline(tonumber(c.cid)):Character().getSource()})
            end
        end
    end
    return staff
end

function getGangMembers(gangnumber)
    local members = {}
    for k, v in pairs(Users) do
        for b, c in pairs(Users[k].avaCharacters()) do
            if Users[k]:Offline(tonumber(c.cid)):Gang().getGang().gang == tonumber(gangnumber) then
                table.insert(members, {['cid'] = Users[k]:Offline(tonumber(c.cid)):Character().getCID(), ['name'] = Users[k]:Offline(tonumber(c.cid)):Character().getName(), ['gang'] = Users[k]:Offline(tonumber(c.cid)):Gang().getGang(), ['source'] = Users[k]:Offline(tonumber(c.cid)):Character().getSource()})
            end
        end
    end
    return members
end

exports('getStaff', function(job, workplace)
    return getStaff(job, workplace)
end)

exports('getGangMembers', function(gangnumber)
    return getGangMembers(gangnumber)
end)

RegisterServerEvent('pw_base:server:startNetworkSession')
AddEventHandler('pw_base:server:startNetworkSession', function()
    local _src = source
    local steamIdentifer = GetPlayerIdentifiers(_src)[1]  or nil
    local fivemIdentifier = GetPlayerIdentifiers(_src)[2] or nil
    local loaded = false
    local failed = false
    MySQL.Async.fetchAll("SELECT * FROM `users` WHERE `steam` = @steam OR `license` = @lic", {['@steam'] = steamIdentifer, ['@lic'] = fivemIdentifier }, function(uid)
        if uid[1] ~= nil then
            Players[_src] = tonumber(uid[1].unique_id)
            loaded = true
        else
            -- Register The User
            local function generateIdent(genId)
                local processed = false
                local res
                MySQL.Async.fetchScalar("SELECT `unique_id` FROM `users` WHERE `unique_id` = @uid", {['@uid'] = genId}, function(id)
                    res = id
                    processed = true
                end)
                repeat Wait(0) until processed == true
                return res
            end

            local randomIdent
            repeat
                math.randomseed(os.time())
                randomIdent = math.random(111111111,999999999)
                local check = generateIdent(randomIdent)
            until check == nil

            MySQL.Async.insert("INSERT INTO `users` (`unique_id`, `license`, `steam`, `prio`, `whitelisted`) VALUES (@uid, @lic, @st, @prio, @wl)", {['@uid'] = randomIdent, ['@lic'] = fivemIdentifier, ['@st'] = steamIdentifer, ['@prio'] = 0, ['@wl'] = false}, function(inserted)
                if inserted > 0 then
                    Users[tonumber(randomIdent)] = User(tonumber(randomIdent))
                    Players[tonumber(randomIdent)] = tonumber(randomIdent)
                    loaded = true
                else
                    failed = true
                end
            end)
        end
    end)
    repeat Wait(0) until loaded == true or failed == true

    if failed then
        DropPlayer(_src, "There was an error loading your user account, please reconnect to PixelWorld to try and resolve this.")
    else
        TriggerClientEvent('pw_base:client:processCharacters', _src, Users[Players[_src]].retreiveCharacters())
    end
end)

exports('checkSource', function(src)
    local _src = tonumber(src)
    if Players[_src] then
        return true
    else
        return false
    end
end)

exports('Source', function(src)
    local _src = tonumber(src)
    if Players[_src] then
        if (Users[Players[_src]]) then
            return Users[Players[_src]]
        else
            return nil
        end
    else
        return nil
    end
end)

PW.RegisterServerCallback('pw_base:getAllOnlineForMenu', function(source, cb)
    local onlinePlayers = {}
    for k, v in pairs(Players) do
        if Users[v].loadedChar ~= nil and Users[v].loadedChar ~= 0 then
            table.insert(onlinePlayers, {['name'] = Users[v]:Character().getName(), ['source'] = Users[v]:Character().getSource()})
        end
    end
    Wait(50)
    cb(onlinePlayers, recentDisconnects)
end)

function getUserAccount(cid)
    for k, v in pairs(Users) do
        for kk, vv in pairs(Users[k].avaCharacters()) do
            if vv.cid == cid then
                return Users[k]:Offline(vv.cid)
            end
        end
    end
    return false
end

RegisterServerEvent('pw_base:switchCharacter')
AddEventHandler('pw_base:switchCharacter', function()
    local _src = source
    if Players[_src] and Users[Players[_src]] then
        Users[Players[_src]]:unloadCharacter()
    end
    TriggerClientEvent('pw:characterUnLoaded', _src)
    TriggerEvent('pw_base:server:refreshCharacters', _src)
end)

exports('Offline', function(cid)
    return getUserAccount(cid)
end)

exports('User', function(id)
    local _id = tonumber(id)
    if(Users[_id])then
        return Users[_id]
    else
        return nil
    end
end)

RegisterServerEvent('pw_base:toggleAdminDuty')
AddEventHandler('pw_base:toggleAdminDuty', function()
    local _src = source
    if Players[_src] and Users[Players[_src]] then
        Users[Players[_src]]:Job().toggleDuty()
    end
end)

function updatePlayTime()
    for k, v in pairs(Players) do
        Users[v]:Character().updatePlaytime()
    end
    SetTimeout(60000, function() updatePlayTime() end)
end
SetTimeout(60000, function() updatePlayTime() end)