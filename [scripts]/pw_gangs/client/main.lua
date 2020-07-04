PW = nil
characterLoaded, playerData = false, nil
local GangPoints = {}
local nearMarker = false
local nearTxt = false

Citizen.CreateThread(function()
    while PW == nil do
        TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)
        Citizen.Wait(1)
    end
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(data)
    PW.TriggerServerCallback('pw_gangs:server:getGangPoints', function(gangpoints)
        GangPoints = gangpoints
        playerData = data
        characterLoaded = true
    end)    
end)

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    characterLoaded = false
    playerData = nil
end)

RegisterNetEvent('pw:setGang')
AddEventHandler('pw:setGang', function(data)
    if characterLoaded and playerData then
        playerData.gang = data
    end
end)

RegisterNetEvent('pw_gangs:client:refreshGangPoints')
AddEventHandler('pw_gangs:client:refreshGangPoints', function()
    PW.TriggerServerCallback('pw_gangs:server:getGangPoints', function(gangpoints)
        GangPoints = gangpoints
        nearMarker = false
    end) 
end)

local showing = false
Citizen.CreateThread(function()
    while true do
        Citizen.Wait(100)
        if characterLoaded and playerData and playerData.gang.gang then
            local ped = PlayerPedId()
            local pedCoords = GetEntityCoords(ped)
            for k,v in pairs(GangPoints) do
                for j,b in pairs(v.gang_coords) do
                    if playerData.gang.gang == v.gang_id then
                        local dist = #(pedCoords - vector3(b.coords.x, b.coords.y, b.coords.z))
                        if dist < 10 then 
                            if not nearMarker then
                                nearMarker = true
                                MarkerDraw(b.coords.x, b.coords.y, b.coords.z)
                            end    
                            if dist < 3 then
                                if not showing then
                                    showing = k..j
                                    DrawText(j, showing, k, v.gang_name)
                                end
                            elseif showing == k..j then
                                showing = false
                                TriggerEvent('pw_drawtext:hideNotification')
                                if j == "storage" then
                                    TriggerEvent('pw_inventory:client:removeSecondary', "storage")
                                end
                            end
                        elseif nearMarker then
                            nearMarker = false
                        end        
                    elseif showing == k..j then
                        showing = false
                        TriggerEvent('pw_drawtext:hideNotification')
                        if j == "storage" then
                            TriggerEvent('pw_inventory:client:removeSecondary',  "storage")
                        end
                    end
                end
            end
        end
    end
end)

function MarkerDraw(x, y, z)
    Citizen.CreateThread(function()
        while nearMarker and characterLoaded do
            Citizen.Wait(1)   
            DrawMarker(Config.Marker.markerType, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.markerSize.x, Config.Marker.markerSize.y, Config.Marker.markerSize.z, Config.Marker.markerColor.r, Config.Marker.markerColor.g, Config.Marker.markerColor.b, 100, false, true, 2, false, nil, nil, false)           
        end
    end)
end

function DrawText(type, var, gang, gangname)
    local title, message, icon
    
    if type == 'storage' then
        TriggerEvent('pw_inventory:client:secondarySetup', "storage", { type = 22, owner = gang, name = "Gang Storage - " .. gangname })
        title = "Gang Storage"
        message = "<span style='font-size:20px'><b>Access <span class='text-danger'>" .. gangname .. "</span> Storage</b></span>"
        icon = "fal fa-box-full"
    end

    if title ~= nil and message ~= nil and icon ~= nil then
        TriggerEvent('pw_drawtext:showNotification', { title = title, message = message, icon = icon })
    end

    Citizen.CreateThread(function()
        while showing == var do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) then
                if type == 'storage' then
                    
                end
            end
        end
    end)
end



RegisterNetEvent('pw_gangs:bossMenu')
AddEventHandler('pw_gangs:bossMenu', function()
    local gang = playerData.gang.gang
    local gang_name = playerData.gang.name
    local menu = {}

    table.insert(menu, { ['label'] = "Gang Member Management", ['action'] = 'pw_gangs:client:openStaff', ['triggertype'] = 'client', ['color'] = 'primary' })
    table.insert(menu, { ['label'] = "Location Management", ['action'] = 'pw_gangs:client:openCoords', ['value'] = { ['gang'] = gang, ['gang_name'] = gang_name }, ['triggertype'] = 'client', ['color'] = 'primary' })

    TriggerEvent('pw_interact:generateMenu', menu, "Hello ".. playerData.name .. ", Welcome to the " .. gang_name .. " Gang Menu")
end)

RegisterNetEvent('pw_gangs:client:openCoords')
AddEventHandler('pw_gangs:client:openCoords', function(data)
    local gang = data.gang
    local menu = {}     
        for j,b in pairs(GangPoints[gang].gang_coords) do
            table.insert(menu, { ['label'] = b.label[1], ['action'] = 'pw_gangs:client:editCoords', ['value'] = { ['type'] = j, ['typelabel'] = b.label[1], ['gang'] = data.gang, ['gang_name'] = data.gang_name }, ['triggertype'] = 'client', ['color'] = 'primary' })
        end 
    TriggerEvent('pw_interact:generateMenu', menu, "Location Editing")
end)

RegisterNetEvent('pw_gangs:client:editCoords')
AddEventHandler('pw_gangs:client:editCoords', function(data)
    local ped = PlayerPedId()
    local pedCoords = GetEntityCoords(ped) 
    local menu = {} 
    table.insert(menu, { ['label'] = 'Set to Current Location', ['action'] = 'pw_gangs:server:changeCoord', ['value'] = { ['type'] = data.type, ['newcoords'] = { ['x'] = pedCoords.x, ['y'] = pedCoords.y, ['z'] = pedCoords.z }, ['gang'] = data.gang }, ['triggertype'] = 'server', ['color'] = 'primary' })
    TriggerEvent('pw_interact:generateMenu', menu, "Edit Location of " .. data.typelabel .. " for the " .. data.gang_name)
end)


RegisterNetEvent('pw_gangs:client:bossHiretest')
AddEventHandler('pw_gangs:client:bossHiretest', function(result)
    local grades = {}
    local form = {}
    for i = 1, 4 do
        table.insert(grades, {['value'] = i, ['label'] = i})
    end

    table.insert(form, { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font size:22px;'><b>Employment Contract Details<br><span class='text-primary' style='font size:28px;'>"..'hello'.."</span></b></span>" })
    table.insert(form, { ['type'] = "dropdown", ['label'] = 'Grade', ['name'] = "grades", ['options'] = grades })
    table.insert(form, { ['type'] = "hidden", ['name'] = "data", ['data'] = result })
    
    TriggerEvent('pw_interact:generateForm', 'pw_gangs:client:bossHiretest2', 'client', form, '')
end)

RegisterNetEvent('pw_gangs:client:bossHiretest2')
AddEventHandler('pw_gangs:client:bossHiretest2', function(result)
    print(result.grades.value)
end)




RegisterNetEvent('pw_gangs:client:openStaff')
AddEventHandler('pw_gangs:client:openStaff', function()
    local gang = playerData.gang.gang
    local gangname = playerData.gang.name
    local closestPlayer, closestDistance = PW.Game.GetClosestPlayer()
        local nearbyPlayersSub = {}
        if closestPlayer ~= -1 and closestDistance <= 3.0 then
            local pName
            PW.TriggerServerCallback('pw_gangs:server:getNearbyName', function(name)
                pName = name
            end, GetPlayerServerId(closestPlayer))

            while pName == nil do
                Wait(10)
            end

            if pName then
                table.insert(nearbyPlayersSub, { ['label'] = pName, ['action'] = "", ['value'] = {target = GetPlayerServerId(closestPlayer), name = pName, gang_id = gang, gang_name = gangname}, ['triggertype'] = "client", ['color'] = "warning" })
            else
                table.insert(nearbyPlayersSub, { ['label'] = "No players nearby", ['action'] = "", ['triggertype'] = "client", ['color'] = "warning" })
            end
        else
            table.insert(nearbyPlayersSub, { ['label'] = "No players nearby", ['action'] = "", ['triggertype'] = "client", ['color'] = "warning" })
        end

    local menu = {}

    table.insert(menu, { ['label'] = "Recruit Gang Members", ['action'] = 'pw_gangs:client:bossHire', ['triggertype'] = 'client', ['color'] = 'success', ['subMenu'] = nearbyPlayersSub })
    table.insert(menu, { ['label'] = "Manage Current Members", ['action'] = 'pw_gangs:client:manageStaff', ['triggertype'] = 'client', ['color'] = 'warning' })

    TriggerEvent('pw_interact:generateMenu', menu, "Gang Member Management Menu")
end)


RegisterNetEvent('pw_gangs:client:manageStaff')
AddEventHandler('pw_gangs:client:manageStaff', function()
    local gang = playerData.gang.gang
    local menu = {}
    PW.TriggerServerCallback('pw_gangs:server:getGangMembers',  function(list)
        print(1)
        for k, v in pairs(list) do
            local staffSub = {}
            table.insert(staffSub, {['label'] = "Promote/Demote", ['action'] = "pw_gangs:client:changeGrade", ['triggertype'] = 'client', ['value'] = v })
            table.insert(staffSub, {['label'] = "<b><span class='text-danger'>Kick From Gang</span></b>", ['action'] = "pw_gangs:client:fireStaff", ['triggertype'] = 'client', ['value'] = v })

            table.insert(menu, {['label'] = v.name, ['color'] = 'primary', ['subMenu'] = staffSub })
        end

        TriggerEvent('pw_interact:generateMenu', menu, "Gang Member List")
    end, gang)    
end)

RegisterNetEvent('pw_gangs:client:changeGrade')
AddEventHandler('pw_gangs:client:changeGrade', function(result)
    local gang = playerData.gang.gang
    local grades = {}
    local form = {}
    for i = 0, 3 do
        table.insert(grades, {['value'] = i, ['label'] = i })
    end

    table.insert(form, { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font size:22px;'><b>Employee<br><span class='text-primary' style='font size:28px;'>"..result.name.."</span></b></span>" })
    table.insert(form, { ['type'] = "dropdown", ['label'] = 'Grade', ['name'] = "grades", ['options'] = grades })
    table.insert(form, { ['type'] = "hidden", ['name'] = "data", ['data'] = result })
    table.insert(form, { ['type'] = "hidden", ['name'] = "gang", ['data'] = gang })
    
    TriggerEvent('pw_interact:generateForm', 'pw_gangs:server:setNewGrade', 'server', form, 'Set Gang Member Level')
end)

RegisterNetEvent('pw_gangs:client:fireStaff')
AddEventHandler('pw_gangs:client:fireStaff', function(result)
    local form = {}
    table.insert(form, { ['type'] = "writting", ['align'] = 'left', ['value'] = "<b><span class='text-primary'>"..result.name.."</span></b>," })
    table.insert(form, { ['type'] = "writting", ['align'] = 'left', ['value'] = "This will remove the above mentioned member from the gang and they will lose access to things such as the gang storage."})
    table.insert(form, { ['type'] = "checkbox", ['label'] = 'Gang Owner,<br><i>'..playerData.name..'</i>', ['name'] = "fire", ['value'] = 'yes' })
    table.insert(form, { ['type'] = "hidden", ['name'] = "gang", ['data'] = playerData.gang.gang })
    table.insert(form, { ['type'] = "hidden", ['name'] = "data", ['data'] = result })

    TriggerEvent('pw_interact:generateForm', 'pw_gangs:server:fireStaff', 'server', form, 'Remove From Gang - '..result.name)
end)

RegisterNetEvent('pw_gangs:client:bossHire')
AddEventHandler('pw_gangs:client:bossHire', function(result)
    local grades = {}
    local form = {}
    for i = 0, 3 do
        table.insert(grades, {['value'] = i, ['label'] = i})
    end

    table.insert(form, { ['type'] = "writting", ['align'] = 'center', ['value'] = "<span style='font size:22px;'><b>Invite to " .. result.gang_name .. " Gang<br><span class='text-primary' style='font size:28px;'>".. result.name .."</span></b></span>" })
    table.insert(form, { ['type'] = "dropdown", ['label'] = 'Gang Level', ['name'] = "grades", ['options'] = grades })
    table.insert(form, { ['type'] = "hidden", ['name'] = "data", ['data'] = result })
    
    TriggerEvent('pw_interact:generateForm', 'pw_gangs:client:bossHireReview', 'client', form, 'Gang Invitation')
end)

RegisterNetEvent('pw_gangs:client:bossHireReview')
AddEventHandler('pw_gangs:client:bossHireReview', function(result)
    local formCopy = {
        { ['type'] = "writting", ['align'] = 'center', ['value'] = 'This will add <b>'.. result.data.data.name ..'</b> to ' .. result.data.data.gang_name .. ' at level '.. result.grades.value},
        { ['type'] = "writting", ['align'] = 'center', ['value'] = 'Please be aware that they will gain access to things such as the gang storage and other gang related entities.'},
    }

    local form = {}
    table.insert(form, { ['type'] = "hidden", ['name'] = "gang_id", ['value'] = result.data.data.gang_id })
    table.insert(form, { ['type'] = "hidden", ['name'] = "gang_name", ['value'] = result.data.data.gang_name })
    table.insert(form, { ['type'] = "hidden", ['name'] = "target", ['value'] = result.data.data.target })
    table.insert(form, { ['type'] = "hidden", ['name'] = "gang_level", ['value'] = tonumber(result.grades.value) })
    table.insert(form, { ['type'] = "hidden", ['name'] = "bossSrc", ['value'] = GetPlayerServerId(PlayerId()) })

    TriggerEvent('pw_interact:generateForm', 'pw_gangs:server:sendContractForm', 'server', form, 'Invite Review', {}, false, '500px')
end)

RegisterNetEvent('pw_gangs:client:sendContractForm')
AddEventHandler('pw_gangs:client:sendContractForm', function(gang, gang_name, level, boss)
    local form = {}
    table.insert(form, { ['type'] = "writting", ['align'] = 'center', ['value'] = 'You have been invited to Join the Gang: '.. gang_name .. ' at the level of '.. level})
    table.insert(form, { ['type'] = "writting", ['align'] = 'center', ['value'] = 'Please Sign Below if You Wish to Join'})
    table.insert(form, { ['type'] = "checkbox", ['label'] = '<i>'..playerData.name.."</i>", ['name'] = "contractReview", ['value'] = 'yes'})
    table.insert(form, { ['type'] = "hidden", ['name'] = "gang", ['value'] = gang })
    table.insert(form, { ['type'] = "hidden", ['name'] = "gangname", ['value'] = gang_name })
    table.insert(form, { ['type'] = "hidden", ['name'] = "level", ['value'] = level })
    table.insert(form, { ['type'] = "hidden", ['name'] = "bossSrc", ['value'] = boss })

    TriggerEvent('pw_interact:generateForm', 'pw_gangs:server:contractSigned', 'server', form, 'Gang Invitation Form', {}, false, '500px')
end)






