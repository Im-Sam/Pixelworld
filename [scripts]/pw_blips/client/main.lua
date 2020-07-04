PW, characterLoaded, playerData = nil, false, nil
charBlips, curBlips, showBlips, settingBlip = {}, {}, false, false
settingBlipData = {}

Citizen.CreateThread(function()
    while PW == nil do
	TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)
    Citizen.Wait(1)
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(data)
    playerData = data
    characterLoaded = true
    PW.TriggerServerCallback('pw_blips:server:getBlips', function(myBlips)
        if myBlips ~= nil then
            charBlips = myBlips
            LoadBlips()
            showBlips = true
        end
    end)
end)

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    DeleteBlips()
    characterLoaded = false
    playerData = nil
end)

function LoadBlips()
    if charBlips ~= nil and charBlips[1] ~= nil then
        for k,v in pairs(charBlips) do
            CreateBlip(k, v)
        end
    end
end

function CreateBlip(k, v)
    local blip = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
    SetBlipSprite(blip, v.sprite)
    SetBlipScale(blip, Config.Defaults.size) 
    SetBlipAsShortRange(blip, false)
    SetBlipColour(blip, v.color)
    SetBlipDisplay(blip, v.display)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(v.name)
    EndTextCommandSetBlipName(blip)
    
    curBlips[k] = blip
end

function DeleteBlips()
    if curBlips ~= nil then
        for k,v in pairs(curBlips) do
            if DoesBlipExist(v) then
                RemoveBlip(v)
            end
        end
        curBlips = {}
    end
end

function ReloadBlips()
    DeleteBlips()
    LoadBlips()
    
    TriggerServerEvent('pw_blips:server:saveBlip', charBlips)
end

RegisterNetEvent('pw_blips:client:mainMenu')
AddEventHandler('pw_blips:client:mainMenu', function()
    if not settingBlip then
        settingBlipData = {}
        local menu = {}
        --table.insert(menu, { ['label'] = , ['action'] = , ['value'] = , ['triggertype'] = , ['color'] = 'primary' })
        local maxLimit = charBlips ~= nil and charBlips[1] ~= nil and #charBlips >= Config.MaxBlips
        table.insert(menu, { ['label'] = (maxLimit and "Blip Limit Reached" or "Add New Blip"), ['action'] = 'pw_blips:client:newBlip', ['triggertype'] = 'client', ['color'] = (maxLimit and 'danger disabled' or 'primary') })
        table.insert(menu, { ['label'] = "Manage Blips", ['action'] = 'pw_blips:client:manageBlips', ['triggertype'] = 'client', ['color'] = 'primary' })
        table.insert(menu, { ['label'] = (showBlips and "Hide" or "Show") .. " All Custom Blips", ['action'] = 'pw_blips:client:toggleBlips', ['triggertype'] = 'client', ['color'] = 'primary' })

        TriggerEvent('pw_interact:generateMenu', menu, "Map Blips Menu")
    else
        exports.pw_notify:SendAlert('error', 'You can\'t access blips menu while setting a new blip. Cancel the operation or finish setting it up first.', 5000)
    end
end)

RegisterNetEvent('pw_blips:client:newBlip')
AddEventHandler('pw_blips:client:newBlip', function()
    if not settingBlip then
        if #charBlips < Config.MaxBlips then
            settingBlip = true
            settingBlipData = {}
            exports.pw_notify:PersistentAlert('start', 'setBlip', 'inform', 'Place a waypoint on your map at the desired blip location and then press <b><span style="color: #ffff00">SHIFT+X</span></b>')
                exports.pw_notify:PersistentAlert('start', 'setBlipZ', 'inform', 'You can also press <b><span style="color: #ffff00">SHIFT+SPACEBAR</span></b> to set a blip on your current location')
            exports.pw_notify:PersistentAlert('start', 'setBlipCancel', 'inform', '<b><span style="color: #ff0000">Cancel</span></b> the operation with <b><span style="color: #ffff00">SHIFT+C</span></b>')
            Citizen.CreateThread(function()
                while settingBlip do
                    Citizen.Wait(1)
                    if IsControlJustPressed(0, 73) and IsControlPressed(0, 21) then -- Shift+x
                        local waypoint = GetFirstBlipInfoId(8)

                        if DoesBlipExist(waypoint) then
                            local waypointCoords = GetBlipInfoIdCoord(waypoint)
                            SaveNewBlip(waypointCoords)
                            settingBlip = false
                            exports.pw_notify:PersistentAlert('end', 'setBlip')
                            exports.pw_notify:PersistentAlert('end', 'setBlipZ')
                            exports.pw_notify:PersistentAlert('end', 'setBlipCancel')
                        else
                            exports.pw_notify:SendAlert('error', 'Waypoint not found')
                        end
                    end

                    if IsControlJustPressed(0, 22) and IsControlPressed(0, 21) then -- Shift+space
                        local pedCoords = GetEntityCoords(PlayerPedId())
                        SaveNewBlip(pedCoords)
                        settingBlip = false
                        exports.pw_notify:PersistentAlert('end', 'setBlip')
                        exports.pw_notify:PersistentAlert('end', 'setBlipZ')
                        exports.pw_notify:PersistentAlert('end', 'setBlipCancel')
                    end

                    if IsControlJustPressed(0, 79) and IsControlPressed(0, 21) then -- Shift+c
                        settingBlip = false
                        exports.pw_notify:PersistentAlert('end', 'setBlip')
                        exports.pw_notify:PersistentAlert('end', 'setBlipZ')
                        exports.pw_notify:PersistentAlert('end', 'setBlipCancel')
                    end
                end
            end)
        else
            exports.pw_notify:SendAlert('error', 'Blip Limit reached')
        end
    end
end)

function SaveNewBlip(coords)
    local x, y, z = table.unpack(coords)
    local form = {
        { ['type'] = "text", ['label'] = "Set the name to display (<i>3-15 characters</i>)", ['name'] = 'blipName' },
        --[[ { ['type'] = "writting", ['align'] = 'left', ['value'] = "For the next fields, please refer to<br><i><span class='text-primary'>https://docs.fivem.net/game-references/blips/</span></i>)<br>Leave blank for defaults: Sprite <b>".. Config.Defaults.sprite .."</b> Color <b>" .. Config.Defaults.color .. "</b>" },
        { ['type'] = "number", ['label'] = "Set the blip sprite", ['name'] = 'blipSprite' },
        { ['type'] = "number", ['label'] = "Set the blip color", ['name'] = 'blipColor' }, ]]
        { ['type'] = "writting", ['align'] = 'center', ['value'] = "<b>Confirm name?</b>" },
        { ['type'] = "yesno", ['success'] = 'Yes', ['reject'] = 'Cancel' },
        { ['type'] = "hidden", ['name'] = 'coords', ['data'] = { ['x'] = x, ['y'] = y, ['z'] = z } }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_blips:client:chooseSprite', 'client', form, 'New Blip', {}, false, "350px", { { ['trigger'] = 'pw_blips:client:mainMenu', ['method'] = 'client' }})
end

RegisterNetEvent('pw_blips:client:chooseSprite')
AddEventHandler('pw_blips:client:chooseSprite', function(data)
    local newName = data.blipName.value
    if string.len(newName) > 2 and string.len(newName) < 16 then
        settingBlipData['coords'] = { ['x'] = data.coords.data.x, ['y'] = data.coords.data.y, ['z'] = data.coords.data.z }
        settingBlipData['name'] = newName
        TriggerEvent('pw_interact:generateBlips', { ['trigger'] = "pw_blips:client:chooseSpriteColor", ['type'] = "client" }, {{['trigger'] = 'pw_blips:client:mainMenu', ['method'] = "client"}})
    else
        exports.pw_notify:SendAlert('error', 'Blip name must be between 3 and 15 characters long', 5000)
        SaveNewBlip(vector3(data.coords.data.x, data.coords.data.y, data.coords.data.z))
    end
end)

RegisterNetEvent('pw_blips:client:chooseSpriteColor')
AddEventHandler('pw_blips:client:chooseSpriteColor', function(blipId)
    settingBlipData['sprite'] = tonumber(blipId)
    TriggerEvent('pw_interact:generateBlipColor', { ['trigger'] = "pw_blips:client:saveBlip", ['type'] = "client" }, {{['trigger'] = 'pw_blips:client:mainMenu', ['method'] = "client"}})
end)

RegisterNetEvent('pw_blips:client:saveBlip')
AddEventHandler('pw_blips:client:saveBlip', function(blipColor)
    settingBlipData['color'] = blipColor
    local blipSettings = {
        ['name'] = settingBlipData['name'], 
        ['coords'] = settingBlipData['coords'], 
        ['sprite'] = settingBlipData['sprite'], 
        ['color'] = settingBlipData['color'],
        ['display'] = Config.Defaults.display
    }
    table.insert(charBlips, blipSettings)
    settingBlipData = {}
    ReloadBlips()
    exports.pw_notify:SendAlert('success', 'Blip <b>'..blipSettings.name..'</b> saved', 4000)
    SetWaypointOff()
    TriggerEvent('pw_blips:client:mainMenu')
end)

RegisterNetEvent('pw_blips:client:manageBlips')
AddEventHandler('pw_blips:client:manageBlips', function()
    if charBlips ~= nil and charBlips[1] ~= nil then
        settingBlipData = {}
        local menu = {}
        table.insert(menu, { ['label'] = "Blips: "..#charBlips.."/"..Config.MaxBlips, ['value'] = 0, ['color'] = (#charBlips < Config.MaxBlips and 'info' or 'warning')..' disabled', ['subMenu'] = sub })
        for k,v in pairs(charBlips) do
            local sub = {}
            table.insert(sub, { ['label'] = "Rename", ['action'] = 'pw_blips:client:renameBlip', ['value'] = k, ['triggertype'] = 'client' } )
            table.insert(sub, { ['label'] = "Edit Sprite", ['action'] = 'pw_blips:client:editBlipSprite', ['value'] = k, ['triggertype'] = 'client' } )
            table.insert(sub, { ['label'] = (v.display > 0 and "Hide" or "Show"), ['action'] = 'pw_blips:client:toggleBlip', ['value'] = k, ['triggertype'] = 'client' } )
            table.insert(sub, { ['label'] = "<b><span class='text-danger'>Delete</span></b>", ['action'] = 'pw_blips:client:deleteBlip', ['value'] = k, ['triggertype'] = 'client' } )
            table.insert(menu, { ['label'] = k .. ". " .. v.name, ['value'] = k, ['color'] = (v.display > 0 and 'success' or 'danger'), ['subMenu'] = sub })
        end
        table.sort(menu, function(a,b) return a.value < b.value end)

        TriggerEvent("pw_interact:generateMenu", menu, "Manage Blips", { { ['trigger'] = 'pw_blips:client:mainMenu', ['method'] = 'client' } })
    else
        exports.pw_notify:SendAlert('error', 'No blips saved')
    end
end)

RegisterNetEvent('pw_blips:client:toggleBlip')
AddEventHandler('pw_blips:client:toggleBlip', function(blip)
    charBlips[blip].display = (charBlips[blip].display > 0 and 0 or Config.Defaults.display)
    ReloadBlips()
    TriggerEvent('pw_blips:client:manageBlips')
end)

RegisterNetEvent('pw_blips:client:toggleBlips')
AddEventHandler('pw_blips:client:toggleBlips', function()
    if charBlips ~= nil and charBlips[1] ~= nil then
        showBlips = not showBlips
        for k,v in pairs(charBlips) do
            charBlips[k].display = (showBlips and Config.Defaults.display or 0)
        end
        ReloadBlips()
        TriggerEvent('pw_blips:client:mainMenu')
    end
end)

RegisterNetEvent('pw_blips:client:renameBlip')
AddEventHandler('pw_blips:client:renameBlip', function(blip)
    local form = {
        { ['type'] = "text", ['label'] = "Set the new name for <b>" .. charBlips[blip].name .. "</b>", ['name'] = 'blipName' },
        { ['type'] = "writting", ['align'] = 'center', ['value'] = "<b>Save new name?</b>" },
        { ['type'] = "yesno", ['success'] = 'Yes', ['reject'] = 'Cancel' },
        { ['type'] = "hidden", ['name'] = 'blip', ['value'] = blip }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_blips:client:setName', 'client', form, 'Rename Blip', {}, false, "350px", { { ['trigger'] = 'pw_blips:client:manageBlips', ['trigger'] = 'client' } })
end)

RegisterNetEvent('pw_blips:client:setName')
AddEventHandler('pw_blips:client:setName', function(data)
    local newName = data.blipName.value
    local blip = tonumber(data.blip.value)
    if string.len(newName) > 2 and string.len(newName) < 16 then 
        exports.pw_notify:SendAlert('inform', 'Blip <b>' .. charBlips[blip].name .. '</b> renamed to <b>' .. newName .. '</b>' )
        charBlips[blip].name = newName
        ReloadBlips()
        TriggerEvent('pw_blips:client:manageBlips')
    else
        exports.pw_notify:SendAlert('error', 'New name must be between 3 and 15 characters long', 5000)
        TriggerEvent('pw_blips:client:renameBlip', blip)
    end
end)

RegisterNetEvent('pw_blips:client:deleteBlip')
AddEventHandler('pw_blips:client:deleteBlip', function(blip)
    local form = {
        { ['type'] = "writting", ['align'] = 'center', ['value'] = "<b>This action is irreversible.<br>Are you sure?</b>" },
        { ['type'] = "yesno", ['success'] = 'Delete', ['reject'] = 'Cancel' },
        { ['type'] = "hidden", ['name'] = 'blip', ['value'] = blip }
    }

    TriggerEvent('pw_interact:generateForm', 'pw_blips:client:delete', 'client', form, 'Delete Blip', {}, false, "350px", { { ['trigger'] = 'pw_blips:client:manageBlips', ['trigger'] = 'client' } })
end)

RegisterNetEvent('pw_blips:client:delete')
AddEventHandler('pw_blips:client:delete', function(data)
    exports.pw_notify:SendAlert('success', 'Blip <b>'..charBlips[tonumber(data.blip.value)].name ..'</b> removed')
    table.remove(charBlips, tonumber(data.blip.value))
    ReloadBlips()
    TriggerEvent('pw_blips:client:manageBlips')
end)

RegisterNetEvent('pw_blips:client:editBlipSprite')
AddEventHandler('pw_blips:client:editBlipSprite', function(blip)
    settingBlipData = {}
    settingBlipData['blipId'] = blip
    TriggerEvent('pw_interact:generateBlips', { ['trigger'] = "pw_blips:client:editSpriteColor", ['type'] = "client" }, {{['trigger'] = 'pw_blips:client:manageBlips', ['method'] = "client"}})
end)

RegisterNetEvent('pw_blips:client:editSpriteColor')
AddEventHandler('pw_blips:client:editSpriteColor', function(blipId)
    settingBlipData['sprite'] = tonumber(blipId)
    TriggerEvent('pw_interact:generateBlipColor', { ['trigger'] = "pw_blips:client:setSprite", ['type'] = "client" }, {{['trigger'] = 'pw_blips:client:manageBlips', ['method'] = "client"}})
end)

RegisterNetEvent('pw_blips:client:setSprite')
AddEventHandler('pw_blips:client:setSprite', function(blipColor)
    local blip = settingBlipData['blipId']
    local sprite = settingBlipData['sprite']
    local color = blipColor
    charBlips[blip].sprite = sprite
    charBlips[blip].color = color
    exports.pw_notify:SendAlert('success', 'Blip <b>'..charBlips[blip].name ..'</b> edited')
    ReloadBlips()
    TriggerEvent('pw_blips:client:manageBlips')
end)

function tprint (t, s)
    for k, v in pairs(t) do
        local kfmt = '["' .. tostring(k) ..'"]'
        if type(k) ~= 'string' then
            kfmt = '[' .. k .. ']'
        end
        local vfmt = '"'.. tostring(v) ..'"'
        if type(v) == 'table' then
            tprint(v, (s or '')..kfmt)
        else
            if type(v) ~= 'string' then
                vfmt = tostring(v)
            end
            print(type(t)..(s or '')..kfmt..' = '..vfmt)
        end
    end
end