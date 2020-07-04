PW = nil
characterLoaded, playerData = false, nil
local showingtxt, drawingMarker, blips = false, false, {}
local minedRocks = { ['coal'] = {}, ['copper'] = {}, ['iron'] = {} }    

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
    GLOBAL_PED = PlayerPedId()
    GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
    if playerData.job.job == "miner" then
        createBlips()
    end    
end)

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    characterLoaded = false
    playerData = nil
    drawingMarker = false
    destroyBlips()
end)

RegisterNetEvent('pw:toggleDuty')
AddEventHandler('pw:toggleDuty', function(toggle)
    if characterLoaded and playerData then
        playerData.job.duty = toggle
    end
end)

RegisterNetEvent('pw:setJob')
AddEventHandler('pw:setJob', function(data)
    if characterLoaded and playerData then
        playerData.job = data
        if playerData.job.job == "miner" then
            createBlips()
        else
            destroyBlips()
        end
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


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if characterLoaded and playerData then
            if playerData.job.job == 'miner' and playerData.job.duty then
                for k,v in pairs(Config.Rocks) do
                    for m,n in pairs(v) do
                        local dist = #(GLOBAL_COORDS - vector3(n.x, n.y, n.z))   
                        if dist < 1.5 then
                            if not showingtxt then
                                showingtxt = k..m
                                DrawText(k, showingtxt, n.h, m)
                            end
                        elseif showingtxt == k..m then
                            showingtxt = false
                            TriggerEvent('pw_drawtext:hideNotification')
                        end   
                    end         
                end
            end    
            for k,v in pairs(Config.MinerPoints) do   
                if v.public or (not v.public and playerData.job.job == 'miner' and (not v.dutyNeeded or (v.dutyNeeded and playerData.job.duty))) then
                    local dist = #(GLOBAL_COORDS - vector3(v.coords.x, v.coords.y, v.coords.z)) 
                    if dist < 15.0 then
                        if not drawingMarker then
                            drawingMarker = k
                            DrawShit(v.coords.x, v.coords.y, v.coords.z, drawingMarker)
                        end

                        if dist < 1.0 then
                            if not showingtxt then
                                showingtxt = k
                                DrawText(k, showingtxt)
                            end
                        elseif showingtxt == k then
                            showingtxt = false
                            TriggerEvent('pw_drawtext:hideNotification')
                        end  
                    elseif drawingMarker == k then
                        drawingMarker = false   
                    end          
                elseif showingtxt == k then
                    showingtxt = false
                    TriggerEvent('pw_drawtext:hideNotification')
                end      
            end   
        end    
    end
end) 


function DrawShit(x, y, z, var)
    Citizen.CreateThread(function()
        while drawingMarker == var do
            Citizen.Wait(1)
            DrawMarker(Config.Marker.markerType, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.markerSize.x, Config.Marker.markerSize.y, Config.Marker.markerSize.z, Config.Marker.markerColor.r, Config.Marker.markerColor.g, Config.Marker.markerColor.b, 100, false, true, 2, false, nil, nil, false)
        end
    end)
end

function DrawText(type, var, heading, rockID)
    local title, message, icon
    if type == 'duty' then
        title = "Mining Duty"
        message = "<span style='font-size:25px'>Go <b><span class='text-"..(playerData.job.duty and "danger'>Off" or "success'>On").."</span></b> Duty</span>"
        icon = "fad fa-gem" 
    elseif type == 'garage' then
        title = "Mining Garage"
        message = "<span style='font-size:20px'><b>Access Mining Garage</span></b></span>"
        icon = "fad fa-truck-container"       
    elseif type == 'processing' then
        title = "Rock Processing"
        message ="<span style='font-size:20px'><b>Process Rock</span></b></span>"
        icon = "fad fa-gem" 
    elseif type == 'smelting' then
        title = "Smelting"
        message ="<span style='font-size:20px'><b>Use the Smelter</span></b></span>"
        icon = "fad fa-flame"         
    elseif type == 'inspection' then
        title = "Rock Inspection"
        message ="<span style='font-size:20px'><b>Get Your Mined Rocks Inspected</span></b></span>"
        icon = "fad fa-gem"     
    elseif type == 'coal' then
        title = "Coal Ore"
        message = "<span style='font-size:20px'><b>" ..(IsInTable(minedRocks.coal, rockID) and "You Already Mined The Coal From Here" or "Mine Coal").. "</span></b></span>"
        icon = "fad fa-hammer-war" 
    elseif type == 'copper' then
        title = "Copper Ore"
        message = "<span style='font-size:20px'><b>" ..(IsInTable(minedRocks.copper, rockID) and "You Already Mined The Copper From Here" or "Mine Copper").. "</span></b></span>"
        icon = "fad fa-hammer-war" 
    elseif type == 'iron' then
        title = "Iron Ore"
        message = "<span style='font-size:20px'><b>" ..(IsInTable(minedRocks.iron, rockID) and "You Already Mined The Iron From Here" or "Mine Iron").. "</span></b></span>"
        icon = "fad fa-hammer-war"     
    end      
    if title ~= nil and message ~= nil and icon ~= nil then
        TriggerEvent('pw_drawtext:showNotification', { title = title, message = message, icon = icon })
    end

    Citizen.CreateThread(function()
        while showingtxt == var do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) then
                if type == 'duty' then
                    showingtxt = false
                    TriggerEvent('pw_drawtext:hideNotification')
                    TriggerServerEvent('pw_mining:server:toggleDuty')
                elseif type == 'garage' then
                    if IsPedInAnyVehicle(GLOBAL_PED) then
                        ParkVehicle() 
                    else    
                        OpenGarage()   
                    end         
                elseif type == 'processing' then
                    showingtxt = false
                    TriggerEvent('pw_drawtext:hideNotification')
                    ProcessRock() 
                elseif type == 'smelting' then
                    showingtxt = false
                    TriggerEvent('pw_drawtext:hideNotification')
                    StartSmelting() 
                elseif type == 'inspection' then
                    showingtxt = false
                    TriggerEvent('pw_drawtext:hideNotification')
                    InspectRock()     
                elseif type == 'coal' then
                    if not IsInTable(minedRocks.coal, rockID) then
                        table.insert(minedRocks.coal, rockID) -- client side for now
                        showingtxt = false 
                        TriggerEvent('pw_drawtext:hideNotification')
                        MineRock(type, heading, Config.MineSwings.coal)
                    else
                        TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You Already Mined Here!", length = 5000})  
                    end    
                elseif type == 'copper' then
                    if not IsInTable(minedRocks.copper, rockID) then
                        table.insert(minedRocks.copper, rockID) -- client side for now 
                        showingtxt = false
                        TriggerEvent('pw_drawtext:hideNotification')
                        MineRock(type, heading, Config.MineSwings.copper)
                    else
                        TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You Already Mined Here!", length = 5000})  
                    end   
                elseif type == 'iron' then
                    if not IsInTable(minedRocks.iron, rockID) then
                        table.insert(minedRocks.iron, rockID) -- client side for now 
                        showingtxt = false
                        TriggerEvent('pw_drawtext:hideNotification')
                        MineRock(type, heading, Config.MineSwings.iron)
                    else
                        TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You Already Mined Here!", length = 5000})  
                    end  
                end     
            end
        end
    end)
end


-- Vehicle Spawner/Despawner --
function OpenGarage()
    local menu = {}
        table.insert(menu, { ['label'] = GetVehNameByModel(Config.MinerPoints.garage.minerVehicle), ['action'] = 'pw_mining:client:spawnVeh', ['value'] = { ['model'] = Config.MinerPoints.garage.minerVehicle }, ['triggertype'] = 'client', ['color'] = 'primary' })
    TriggerEvent('pw_interact:generateMenu', menu, "Miner Vehicle Garage")
end

RegisterNetEvent('pw_mining:client:spawnVeh')
AddEventHandler('pw_mining:client:spawnVeh', function(data)
    local coords = Config.MinerPoints.garage.vehicleSpawn
    local cV = GetClosestVehicle(coords.x, coords.y, coords.z, 5.0, 0, 71)
    if cV == 0 or cV == nil then
        PW.Game.SpawnOwnedVehicle(data.model, coords, coords.h, function(spawnedVeh)
            local props = PW.Game.GetVehicleProperties(spawnedVeh)
            PW.TriggerServerCallback('pw_vehicleshop:server:registerPotentialVin', function(vin)
                TriggerServerEvent('pw_keys:issueKey', "Vehicle", vin, false, true)
                TriggerEvent('pw:notification:SendAlert', {type = "success", text = 'Spawned Vehicle', length = 7000})
            end, props, spawnedVeh)
        end)
    else
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = 'There\'s a vehicle blocking the vehicle exit', length = 8000})
    end
end)

function ParkVehicle()
    if GetHashKey(Config.MinerPoints.garage.minerVehicle) == GetEntityModel(GetVehiclePedIsIn(GLOBAL_PED)) then
        local pedVeh = GetVehiclePedIsIn(GLOBAL_PED)
        local vin = PW.Vehicles.GetVinNumber(PW.Game.GetVehicleProperties(pedVeh).plate)
        TriggerServerEvent('pw_keys:revokeKeys', 'Vehicle', vin, true, nil)
        SetEntityAsMissionEntity(pedVeh, true, true)
        DeleteEntity(pedVeh)
        TriggerEvent('pw:notification:SendAlert', {type = "success", text = "Vehicle Parked", length = 5000}) 
    else
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = 'This Isn\'t a Mining Vehicle so You Cannot Return it Here!', length = 8000})
    end 
end 


-- Mine the Rocks
local impacts, pickaxe = 0, nil
function MineRock(type, heading, swings)
    TriggerEvent('pw:progressbar:progress',
    { name = 'mining', duration = (2700 * swings), label = 'Mining ' .. type, useWhileDead = false, canCancel = false, controlDisables = { disableMovement = true, disableCarMovement = false, disableMouse = false, disableCombat = true,}, },
    function(status)
    end) 
    Citizen.CreateThread(function()
        SetEntityHeading(GLOBAL_PED, heading)
        while impacts < swings do
            Citizen.Wait(1)	
            RequestAnimDict("melee@large_wpn@streamed_core")
            Citizen.Wait(100)
            TaskPlayAnim((GLOBAL_PED), 'melee@large_wpn@streamed_core', 'ground_attack_on_spot', 8.0, 8.0, -1, 80, 0, 0, 0, 0)
            TriggerEvent('pw_sound:client:PlayOnOne', 'pickaxe', 0.6)
            if impacts == 0 then
                pickaxe = CreateObject(GetHashKey("prop_tool_pickaxe"), 0, 0, 0, true, true, true) 
                local playerBone = GetPedBoneIndex(GLOBAL_PED, 57005)
                AttachEntityToEntity(pickaxe, GLOBAL_PED, playerBone, 0.08, -0.06, -0.04, 290.0, 15.0, 4.0, true, true, false, true, 1, true)
            end  
            Citizen.Wait(2500)
            ClearPedTasks(GLOBAL_PED)
            impacts = impacts + 1
            if impacts == swings then
                DetachEntity(pickaxe, 1, true)
                DeleteEntity(pickaxe)
                impacts = 0
                TriggerServerEvent('pw_mining:server:addRock', type)
                break
            end        
        end
    end)
end

-- Processing --

function ProcessRock()
    local menu = {}
    local menuItems = 0

    for i = 1, #Config.RockProcessing do
        local itemCount = PW.Game.CheckInventory(Config.RockProcessing[i].item)
        if itemCount > 0 then
            table.insert(menu, { ['label'] = Config.RockProcessing[i].label .. " <i>(You Have " .. itemCount ..")</i>", ['action'] = 'pw_mining:client:processing', ['value'] = { ['processid'] = i, ['label'] = Config.RockProcessing[i].label, ['amount'] = itemCount }, ['triggertype'] = 'client', ['color'] = "primary" })
            menuItems = (menuItems + 1)
        end    
    end

    if menuItems ~= 0 then
        TriggerEvent('pw_interact:generateMenu', menu, "Which Rock's Should Be Processed")
    else
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You Have No Items to Process!", length = 5000})
    end 
end

RegisterNetEvent('pw_mining:client:processing')
AddEventHandler('pw_mining:client:processing', function(data)
    TriggerEvent('pw:progressbar:progress',
    {
        name = 'processing_rock',
        duration = (Config.Timings.processTime * data.amount),
        label = 'Processing ' .. data.amount .. ' '.. data.label,
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = { 
            animDict = 'amb@prop_human_bum_bin@idle_a',
            anim = 'idle_a',
            flags = 0,
            task = nil,
        },
    },
    function(status)
        if not status then
            TriggerServerEvent('pw_mining:server:processRock', data)
        else
            TriggerEvent('pw:notification:SendAlert', {type = "error", text = "Cancelled", length = 5000})
        end
    end)       
end)

-- Smelting --

function StartSmelting()
    local menu = {}
    local menuItems = 0
    for i = 1, #Config.RockSmelting do
        local itemCount = PW.Game.CheckInventory(Config.RockSmelting[i].item)
        if itemCount > 0 then
            table.insert(menu, { ['label'] = Config.RockSmelting[i].label .. " <i>(You Have " .. itemCount ..")</i>", ['action'] = 'pw_mining:client:smelting', ['value'] = { ['smeltid'] = i, ['label'] = Config.RockSmelting[i].label, ['amount'] = itemCount }, ['triggertype'] = 'client', ['color'] = "primary" })
            menuItems = (menuItems + 1)
        end    
    end
    if menuItems ~= 0 then
        TriggerEvent('pw_interact:generateMenu', menu, "Which Rock's Should Be Smelted")
    else
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You Have No Smeltable Items!", length = 5000})
    end       
end

RegisterNetEvent('pw_mining:client:smelting')
AddEventHandler('pw_mining:client:smelting', function(data)
    TriggerEvent('pw:progressbar:progress',
    {
        name = 'smelting_rock',
        duration = (Config.Timings.smeltingTime * data.amount),
        label = 'Smelting ' .. data.amount .. ' '.. data.label,
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = { 
            animDict = 'amb@prop_human_bum_bin@idle_a',
            anim = 'idle_a',
            flags = 0,
            task = nil,
        },
    },
    function(status)
        if not status then
            TriggerServerEvent('pw_mining:server:smeltItem', data)
        else
            TriggerEvent('pw:notification:SendAlert', {type = "error", text = "Cancelled Smelting", length = 5000})
        end
    end)       
end)

-- Inspection (Selling) --

function InspectRock()
    local menu = {}
    local menuItems = 0
    for i = 1, #Config.RockInspection do
        local itemCount = PW.Game.CheckInventory(Config.RockInspection[i].item)
        if itemCount > 0 then
            table.insert(menu, { ['label'] = Config.RockInspection[i].label .. " <i>(You Have " .. itemCount ..")</i>", ['action'] = 'pw_mining:client:inspection', ['value'] = { ['inspectid'] = i, ['label'] = Config.RockInspection[i].label, ['amount'] = itemCount }, ['triggertype'] = 'client', ['color'] = "primary" })
            menuItems = (menuItems + 1)
        end    
    end
    if menuItems ~= 0 then
        TriggerEvent('pw_interact:generateMenu', menu, "Which Rock's Should Be Inspected For Sale")
    else
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You Have No Rocks to be Inspected for Sale!", length = 5000})
    end  
end

RegisterNetEvent('pw_mining:client:inspection')
AddEventHandler('pw_mining:client:inspection', function(data)
    TriggerEvent('pw:progressbar:progress',
    {
        name = 'inspecting_rock',
        duration = (Config.Timings.inspectTime * data.amount),
        label = 'Inspecting ' .. data.amount .. ' '.. data.label,
        useWhileDead = false,
        canCancel = true,
        controlDisables = {
            disableMovement = true,
            disableCarMovement = true,
            disableMouse = false,
            disableCombat = true,
        },
        animation = {
            animDict = "missheistdockssetup1clipboard@base",
            anim = "base",
            flags = 49,
        },
        prop = {
            model = "p_amb_clipboard_01",
            bone = 18905,
            coords = { x = 0.10, y = 0.02, z = 0.08 },
            rotation = { x = -80.0, y = 0.0, z = 0.0 },
        },
        propTwo = {
            model = "prop_pencil_01",
            bone = 58866,
            coords = { x = 0.12, y = 0.0, z = 0.001 },
            rotation = { x = -150.0, y = 0.0, z = 0.0 },
        },
    },
    function(status)
        if not status then
            TriggerServerEvent('pw_mining:server:inspectRock', data)
        else
            TriggerEvent('pw:notification:SendAlert', {type = "error", text = "Cancelled Inspection", length = 5000})
        end
    end)       
end)


function createBlips()
    Citizen.CreateThread(function()
        for k, v in pairs(Config.MinerPoints) do
            if v.blip then
                blips[k] = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
                SetBlipSprite(blips[k], v.blip_info.type)
                SetBlipDisplay(blips[k], 4)
                SetBlipScale  (blips[k], v.blip_info.scale)
                SetBlipColour (blips[k], v.blip_info.color)
                SetBlipAsShortRange(blips[k], true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(v.blip_info.name)
                EndTextCommandSetBlipName(blips[k])
            end    
        end
    end)
end

function destroyBlips()
    for k, v in pairs(blips) do
        RemoveBlip(v)
    end
end


function GetVehNameByModel(model)
    local hashVehicle = (type(model) ~= "number" and GetHashKey(model) or model)
    hashVehicle = string.gsub(GetDisplayNameFromVehicleModel(hashVehicle), "%s", "_")
    local vehicleName = GetLabelText(hashVehicle)
    if vehicleName == "NULL" or vehicleName == "CARNOTFOUND" then
        vehicleName = GetDisplayNameFromVehicleModel(hashVehicle)
    end
    return vehicleName
end


function IsInTable(tab, val)
    for index, value in ipairs(tab) do
        if value == val then
            return true
        end
    end
    return false
end
