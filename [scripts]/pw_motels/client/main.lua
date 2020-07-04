PW = nil
characterLoaded, playerData = false, nil
GLOBAL_PED, GLOBAL_COORDS = nil, nil
motelRooms, motels, blips = {}, {}, {}
local showing, drawingText, drawingMarker = false, false, false

Citizen.CreateThread(function()
    while PW == nil do
        TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)
        Citizen.Wait(1)
    end
end)

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(5000)
        if characterLoaded then
            GLOBAL_PED = PlayerPedId()
        end
    end
end) 

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        if characterLoaded and GLOBAL_PED then
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
    end
end)

function generateBlips()
    for i = 1, #motels do
        local coords = json.decode(motels[i].location)
        blips[i] = AddBlipForCoord(coords.x, coords.y, coords.z)
        SetBlipSprite(blips[i], 475)
        SetBlipDisplay(blips[i], 4)
        SetBlipScale  (blips[i], 0.8)
        SetBlipColour (blips[i], 23)
        SetBlipAsShortRange(blips[i], true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(motels[i].name)
        EndTextCommandSetBlipName(blips[i])
    end
end

function deleteAllBlips()
    for k, v in pairs(blips) do
        RemoveBlip(v)
    end
    blips = {}
end

exports('checkRadius', function()
    local playerPed = GetPlayerPed(-1)
    local playerCoords = GetEntityCoords(playerPed)
    for k, v in pairs(motelRooms) do
        local distance = #(playerCoords - vector3(v.charSpawn.x, v.charSpawn.y, v.charSpawn.z))
        if distance <= 50.0 then
            return true
        end
    end
    return false
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(data)
    PW.TriggerServerCallback('pw_motels:server:requestRooms', function(rms)
        PW.TriggerServerCallback('pw_motels:server:requestMotels', function(mot)
            GLOBAL_PED = PlayerPedId()
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
            playerData = data
            motels = mot or {}
            motelRooms = rms or {}
            characterLoaded = true
            generateBlips()
        end)
    end)
end)

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    characterLoaded = false
    playerData = nil
    motelRooms = {}
    showing = false
    deleteAllBlips()
end)

RegisterNetEvent('pw_motels:client:sendRoomInfo')
AddEventHandler('pw_motels:client:sendRoomInfo', function(room, data)
    if motelRooms[tonumber(room)] then
        motelRooms[tonumber(room)] = data
        PW.TablePrint(motelRooms[tonumber(room)])
    end
end)

function toggleLock(k)
    TriggerServerEvent('pw_motels:server:toggleDoor', k)
    Wait(150)
    showing = false
end


RegisterNetEvent('pw_motels:client:selectClothing')
AddEventHandler('pw_motels:client:selectClothing', function(action)
    local menu = {}
        PW.TriggerServerCallback('pw_motels:server:selectOutfits', function(outfits)
            if outfits[1] ~= nil then
                for k, v in pairs(outfits) do
                    table.insert(menu, { ['label'] = v.skin_name, ['action'] = (action.action == "select" and 'pw_motels:server:changeClothing' or 'pw_motels:server:deleteClothing'), ['value'] = {action = action.action, outfit = v.outfit_id}, ['triggertype'] = 'server', ['color'] = 'info'})
                end
            else
                table.insert(menu, { ['label'] = 'No Clothing Saves', ['action'] = '', ['value'] = "select", ['triggertype'] = 'client', ['color'] = 'warning disabled'})
            end
            TriggerEvent('pw_interact:generateMenu', menu, (action.action == "select" and "Select Outfit" or "Delete Outfit").." | "..motelRooms[action.motel].motelName..' '..motelRooms[action.motel].room_number)
        end)
end)

function clothingMenu(k)
    local menu = {}
    table.insert(menu, { ['label'] = 'Change Clothing', ['action'] = 'pw_motels:client:selectClothing', ['value'] = {action = "select", motel = k}, ['triggertype'] = 'client', ['color'] = 'success'})
    table.insert(menu, { ['label'] = 'Delete Clothing', ['action'] = 'pw_motels:client:selectClothing', ['value'] = {action = "delete", motel = k}, ['triggertype'] = 'client', ['color'] = 'danger'})
    TriggerEvent('pw_interact:generateMenu', menu, "Wardrobe | "..motelRooms[k].motelName..' '..motelRooms[k].room_number)
end

function controlKeys(k, var)
    Citizen.CreateThread(function()
        while showing == var do
            if IsControlJustPressed(0, 38) then
                if showing == k..'-item' then
                    showing = false
                    drawingText = false
                    TriggerEvent('pw_drawtext:hideNotification')
                    TriggerEvent('pw_base:switchCharacter')
                elseif showing == k..'-entrance' then
                    if not motelRooms[k].room_meta.doorLocked then
                        teleportTo(k, "exit")
                    else
                        exports['pw_notify']:SendAlert('error', 'The Room is locked', 5000)
                    end
                elseif showing == k..'-exit' then
                    if not motelRooms[k].room_meta.doorLocked then
                        teleportTo(k, "entrance")
                    else
                        exports['pw_notify']:SendAlert('error', 'The Room is locked', 5000)
                    end
                elseif showing == k..'-clot' then
                    clothingMenu(k)
                end
            end

            if IsControlJustPressed(0, 23) then
                if showing == k..'-entrance' or showing == k..'-exit' then
                    showing = false
                    wdrawingText = false
                    TriggerEvent('pw_drawtext:hideNotification')
                    if motelRooms[k].occupation.occupier == playerData.cid then
                        toggleLock(k)
                    end
                end
            end
            Citizen.Wait(1)
        end
    end)
end

function teleportTo(k, access)
    local motelRoom = motelRooms[tonumber(k)]
    DoScreenFadeOut(1500)
    Citizen.Wait(1501)
    SetEntityCoords(PlayerPedId(), motelRoom.teleport_meta[access].x, motelRoom.teleport_meta[access].y, motelRoom.teleport_meta[access].z, 0.0, 0.0, 0.0, false)
    SetEntityHeading(PlayerPedId(), motelRoom.teleport_meta[access].h)    
    Citizen.Wait(1000)
    DoScreenFadeIn(1500)
    showing = false
    drawingText = false
    TriggerEvent('pw_drawtext:hideNotification')
end

--============================--
--= Marker and Door Controls =--
--============================--
-- Marker Controls
Citizen.CreateThread(function()
    while true do
        if characterLoaded and GLOBAL_PED then
            local icon = "fad fa-hotel"
            local message
            for k, v in pairs(motelRooms) do
                if v.occupation.occupier == tonumber(playerData.cid) then
                    if v.inventories ~= nil then 
                        local itemDist = #(vector3(v.inventories.items.x, v.inventories.items.y, v.inventories.items.z) - GLOBAL_COORDS)
                        if itemDist < 1.0 then
                            if not showing then
                                TriggerEvent('pw_inventory:client:secondarySetup', "motelitems", { type = 8, owner = v.occupation.occupier, name = v.motelName..' Room '..v.room_number.." Inventory" })
                                message = "Press [ <span class='text-danger'>F2</span> ] to access Inventory or press [ <span class='text-danger'>E</span> ] to change character."
                                showing = k..'-item'
                                controlKeys(k, showing)
                            end
                        elseif showing == k..'-item' then
                            TriggerEvent('pw_inventory:client:removeSecondary', "motelitems")
                            showing = false
                        else
                            local weapDist = #(vector3(v.inventories.weapons.x, v.inventories.weapons.y, v.inventories.weapons.z) - GLOBAL_COORDS)
                            if weapDist < 1.0 then
                                if not showing then
                                    TriggerEvent('pw_inventory:client:secondarySetup', "motelweapons", { type = 24, owner = v.occupation.occupier, name = v.motelName..' Room '..v.room_number.." Weapons Stash" })
                                    message = "Press [ <span class='text-danger'>F2</span> ] to access Weapons Inventory"
                                    showing = k..'-weap'
                                end
                            elseif showing == k..'-weap' then
                                TriggerEvent('pw_inventory:client:removeSecondary', "motelweapons")
                                showing = false
                            else
                                local clotDist = #(vector3(v.inventories.clothing.x, v.inventories.clothing.y, v.inventories.clothing.z) - GLOBAL_COORDS)
                                if clotDist < 1.0 then
                                    if not showing then
                                        message = "Press [ <span class='text-danger'>E</span> ] to access wardrobe."
                                        showing = k..'-clot'
                                        controlKeys(k, showing)
                                    end
                                elseif showing == k..'-clot' then
                                    showing = false
                                end
                            end
                        end
                    end

                    if showing and not drawingText then
                        drawingText = true
                        TriggerEvent('pw_drawtext:showNotification', { title = v.motelName..' Room '..v.room_number, message = message, icon = icon })
                    elseif not showing and drawingText then
                        drawingText = false
                        TriggerEvent('pw_drawtext:hideNotification')
                    end
                end
            end
        end
        Citizen.Wait(200)
    end
end)

function DrawShit(k, spot, type)
    print('drawing?', k, spot, type)
    local coords = motelRooms[k].teleport_meta[spot]

    Citizen.CreateThread(function()
        while drawingMarker and characterLoaded do
            Citizen.Wait(1)
            if type == 'owner' then
                DrawMarker(2, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 133, 219, 72, 100, false, true, 2, false, nil, nil, false)
            elseif type == 'guestUnlocked' then
                DrawMarker(2, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 229, 85, 215, 100, false, true, 2, false, nil, nil, false)
            elseif spot == 'exit' then
                DrawMarker(2, coords.x, coords.y, coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.2, 0.2, 0.2, 133, 219, 72, 100, false, true, 2, false, nil, nil, false)
            end
        end
    end)
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(200)
        local icon = "fad fa-hotel"
        if characterLoaded then
            for k, v in pairs(motelRooms) do
                if v.motel_type == "Teleport" then
                    local teleportMeta = v.teleport_meta
                    local entranceDist = #(GLOBAL_COORDS - vector3(teleportMeta.entrance.x,teleportMeta.entrance.y,teleportMeta.entrance.z))
                    local exitDist = #(GLOBAL_COORDS - vector3(teleportMeta.exit.x,teleportMeta.exit.y,teleportMeta.exit.z))
                    if entranceDist < 5.0 then
                        if not drawingMarker then
                            if v.occupation.occupier == playerData.cid then
                                drawingMarker = k .. '-entrance'
                                DrawShit(k, 'entrance', 'owner')
                            else
                                if not v.room_meta.doorLocked then
                                    drawingMarker = k .. '-entrance'
                                    DrawShit(k, 'entrance', 'guestUnlocked')
                                end
                            end
                        end
                        
                        local message2

                        if entranceDist < 1.2 then
                            message2 = (v.room_meta.doorLocked and '<span class="text-danger">Locked</span>' ..  (v.occupation.occupier == playerData.cid and ' Press [ <span class="text-danger">F</span> ] to unlock' or '') or '<span class="text-success">Unlocked</span>' .. (v.occupation.occupier == playerData.cid and ' Press [ <span class="text-danger">F</span> ] to lock' or '') .. '<br>Press [ <span class="text-danger">E</span> ] to enter room')
    
                            if not showing then
                                TriggerEvent('pw_drawtext:showNotification', { title = v.motelName..' Room '..v.room_number, message = message2, icon = icon })
                                showing = k..'-entrance'
                                controlKeys(k, showing)
                            end
                        elseif showing == k..'-entrance' then
                            TriggerEvent('pw_drawtext:hideNotification')
                            showing = false
                        end
                    elseif drawingMarker == k .. '-entrance'then
                        drawingMarker = false
                    else
                        if exitDist < 2.0 then
                            if not drawingMarker then
                                drawingMarker = k .. '-exit'
                                DrawShit(k, 'exit')
                            end

                            if exitDist < 1.2 then
                                if not showing then
                                    showing = k..'-exit'
                                    if v.room_meta.doorLocked then
                                        if v.occupation.occupier == playerData.cid then
                                            message2 = "<span class='text-danger'>Locked</span> Press [ <span class='text-danger'>F</span> ] to unlock"
                                            controlKeys(k, showing)
                                        else
                                            message2 = "Locked"
                                        end
                                    else
                                        message2 = (v.occupation.occupier == playerData.cid and  "Press [ <span class='text-danger'>E</span> ] to exit or press [ <span class='text-danger'>F</span> ] to lock" or "Press [ <span class='text-danger'>E</span> ] to exit")
                                        controlKeys(k, showing)
                                    end
                                    TriggerEvent('pw_drawtext:showNotification', { title = v.motelName..' Room '..v.room_number, message = message2, icon = icon })
                                end
                            elseif showing == k..'-exit' then
                                TriggerEvent('pw_drawtext:hideNotification')
                                showing = false
                            end
                        elseif drawingMarker == k .. '-exit' then
                            drawingMarker = false
                        end
                    end
                end
            end
        end
    end
end)

exports('getOccupier', function(room)
    return motelRooms[room].occupation.occupier
end)