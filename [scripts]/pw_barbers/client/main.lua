PW = nil
characterLoaded, playerData = false, nil
GLOBAL_PED, GLOBAL_COORDS = nil, nil
local showing, currentLocation, blips = false, 0, {}
local inStore = false

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
end)

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    characterLoaded = false
    playerData = nil
end)

Citizen.CreateThread(function()
    while true do
        if characterLoaded then
            GLOBAL_PED = PlayerPedId()
            GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        end
        Citizen.Wait(100)
    end
end)

RegisterNetEvent('pw_barbershop:leftStore')
AddEventHandler('pw_barbershop:leftStore', function()
    inStore = false
end)

function openBarberMenu()
    if not inStore then
        PW.TriggerServerCallback('pw_barbers:checkCashAmount', function(enough)
            if enough then
                inStore = true
                TriggerEvent('pw_base:charCreator:openHairMenu')
            else
                exports.pw_notify:SendAlert('inform', 'You do not have enough cash to access the barbers menu', 5000)
            end
        end)
    end
end

Citizen.CreateThread(function()
    for k, v in pairs(Config.Locations) do
        blips[k] = AddBlipForCoord(v.x, v.y, v.z)
        SetBlipSprite(blips[k], Config.Blips.blipSprite)
        SetBlipDisplay(blips[k], 4)
        SetBlipScale  (blips[k], Config.Blips.blipScale)
        SetBlipColour (blips[k], Config.Blips.blipColor)
        SetBlipAsShortRange(blips[k], true)
        BeginTextCommandSetBlipName("STRING")
        AddTextComponentString(tostring(Config.Blips.blipName))
        EndTextCommandSetBlipName(blips[k])
    end
end)

Citizen.CreateThread(function()
    while true do  
        local letSleep = true
        if characterLoaded and GLOBAL_PED and GLOBAL_COORDS then
            for k, v in pairs(Config.Locations) do
                local distance = #(GLOBAL_COORDS - vector3(v.x, v.y, v.z))
                if distance < v.radius then
                    letSleep = false
                    currentLocation = k
                    if distance < 1.0 then
                        if not showing then
                            showing = k
                            TriggerEvent('pw_drawtext:showNotification', { title = "Barbers Shop", message = "Press [ <span class='text-danger'>E</span> ] to access<br>Cost: $<span class='text-danger'>"..Config.HairCutCost.."</span>", icon = "fad fa-cut" })
                        end

                        if IsControlJustPressed(0, 38) then
                            openBarberMenu()
                        end
                    else
                        if showing == k then
                            TriggerEvent('pw_drawtext:hideNotification')
                            showing = false
                        end
                    end
                else
                    if currentLocation == k then
                        print('meh?')
                        currentLocation = false
                        if inStore then
                            inStore = false
                            print('test?')
                            TriggerEvent('pw_interact:simulateClose')
                            --TriggerEvent('pw_base:charCreator:revertSettings');
                        end
                    end
                end
            end
        end

        if letSleep then
            Citizen.Wait(500)
        else
            Citizen.Wait(1)
        end
    end
end)