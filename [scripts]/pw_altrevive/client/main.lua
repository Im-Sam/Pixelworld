PW = nil
characterLoaded, playerData = false, nil
local showing, showingMarker = false, false
local blip

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
    if playerData.job.job ~= 'ems' and playerData.job.job ~= 'police' and playerData.job.job ~= 'doctor' and playerData.job.job ~= 'prisonguard' then
        createBlip()
    else
        deleteBlip()
    end
end)

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    characterLoaded = false
    playerData = nil
    deleteBlip()
end)

RegisterNetEvent('pw:setJob')
AddEventHandler('pw:setJob', function(data)
    if characterLoaded and playerData then
        playerData.job = data
        if playerData.job.job ~= 'ems' and playerData.job.job ~= 'police' and playerData.job.job ~= 'doctor' and playerData.job.job ~= 'prisonguard' then
            createBlip()
        else
            deleteBlip()
        end
    end    
end)


function MarkerDraw()
    Citizen.CreateThread(function()
        while showingMarker and characterLoaded do
            Citizen.Wait(1)
            DrawMarker(Config.Location.markerType, Config.Location.coords.x, Config.Location.coords.y, Config.Location.coords.z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Location.markerSize.x, Config.Location.markerSize.y, Config.Location.markerSize.z, Config.Location.markerColor.r, Config.Location.markerColor.g, Config.Location.markerColor.b, 100, false, true, 2, true, nil, nil, false)
        end
    end)
end

function DrawText()
    TriggerEvent('pw_drawtext:showNotification', { title = "Alternative Medical Treatment", message = "<span style='font-size:20px'>Press <b><span class='text-danger'>E</span></b> For Medical Attention</span>", icon = "fad fa-prescription-bottle-alt" })
    
    Citizen.CreateThread(function()
        while showing and characterLoaded do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) then
                OpenReviveDecideMenu()
            end
        end
    end)
end

function createBlip()
    if characterLoaded and playerData then
        if playerData.job.job ~= 'ems' and playerData.job.job ~= 'police' and playerData.job.job ~= 'doctor' and playerData.job.job ~= 'prisonguard' then
            blip = AddBlipForCoord(Config.Location.coords.x, Config.Location.coords.y, Config.Location.coords.z)
            SetBlipSprite(blip, 51)
            SetBlipDisplay(blip, 4)
            SetBlipScale  (blip, 0.7)
            SetBlipColour (blip, 7)
            SetBlipAsShortRange(blip, true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString("Doctor")
            EndTextCommandSetBlipName(blip)
        end
    end
end

function deleteBlip()
    if blip ~= nil then
        RemoveBlip(blip)
    end
end

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if characterLoaded and playerData then
            local player = PlayerPedId()
            local playerCoords = GetEntityCoords(player)

            local dist = #(playerCoords - vector3(Config.Location.coords.x, Config.Location.coords.y, Config.Location.coords.z))
            if playerData.job.job ~= 'ems' and playerData.job.job ~= 'police' and playerData.job.job ~= 'doctor' and playerData.job.job ~= 'prisonguard' then
                if dist < Config.Location.markerDistance then
                    if not showingMarker then
                        showingMarker = true
                        MarkerDraw()
                    end
                    if dist < Config.Location.drawDistance then
                        if not showing then
                            showing = true
                            DrawText()
                        end
                    elseif showing then
                        showing = false
                        TriggerEvent('pw_drawtext:hideNotification')
                    end
                elseif showingMarker then
                    showingMarker = false
                end  
            end    
        end
    end
end)


function OpenReviveDecideMenu()  
    local menu = { 
        { ['label'] = 'Yes, Please Treat Me!', ['action'] = 'pw_altrevive:client:startrevive', ['value'] = { }, ['triggertype'] = 'client', ['color'] = 'success' },
        { ['label'] = 'No, I don\'t want to be Treated', ['action'] = 'pw:notification:SendAlert', ['value'] = {type = "error", text = 'You don\'t Want Treatment? Get Out of Here!', length = 5000}, ['triggertype'] = 'client', ['color'] = 'danger' },
    }
    TriggerEvent('pw_interact:generateMenu', menu, "<strong>Do You Require Medical Attention?</strong>")   
end

RegisterNetEvent('pw_altrevive:client:startrevive')
AddEventHandler('pw_altrevive:client:startrevive', function()
    local player = PlayerPedId()
    if IsPedFatallyInjured(player) or exports['pw_skeleton']:IsInjuredOrBleeding() then
        ClearPedTasks(player)
        TaskStartScenarioInPlace(player, "WORLD_HUMAN_SUNBATHE_BACK", 0, true)
        TriggerEvent('pw:notification:SendAlert', {type = "info", text = 'Beginning Medical Procedures', length = 5000}) 
        TriggerEvent('pw:progressbar:progress',
        {
            name = 'alt_revival_progress',
            duration = (Config.RevivingTime * 1000),
            label = 'Performing Medical Procedures',
            useWhileDead = true,
            canCancel = true,
            controlDisables = {
                disableMovement = true,
                disableCarMovement = false,
                disableMouse = false,
                disableCombat = true,
            },
        },
        function(status)
            if not status then
                local chance = math.random(1, 100)
                if chance > Config.ReviveChance then
                    TriggerServerEvent('pw_altrevive:server:payment')

                    TriggerEvent('pw_ems:revive') -- the actual revive
                    TriggerEvent('pw:notification:SendAlert', {type = "success", text = 'You Were Healed Successfully, It Cost $'.. Config.ReviveCost .. '', length = 7500})
                    ClearPedTasks(player)
                else    
                    TriggerEvent('pw:notification:SendAlert', {type = "error", text = 'The Healing Was Not Successful. You Could Try Again!', length = 10000})
                    ClearPedTasks(player)
                end    
            else
                TriggerEvent('pw:notification:SendAlert', {type = "error", text = 'Healing Cancelled!', length = 5000})  
                ClearPedTasks(player) 
            end    
        end)
    else
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = 'It Does Not Seem Like You Need Medical Attention', length = 8000}) 
    end       
end)