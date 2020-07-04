PW = nil
characterLoaded, playerData = false, nil
local shopMenuOpen = false
local showing = nil
local blips = {}

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
    processBlips()
end)

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    characterLoaded = false
    playerData = nil
    removeBlips()
end)

function openClothesShop(k)
    PW.TriggerServerCallback('pw_clothing:server:checkMoney', function(cash)
        if cash >= Config.requiredCash then
            shopMenuOpen = k
            TriggerEvent('pw_base:charCreator:frontMenuShop')
        else
            exports['pw_notify']:SendAlert('warning', 'You do not have enough cash on you.', 5000)
        end
    end)
end

function processBlips()
    for k, v in pairs(Config.ShopLocations) do
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
end

function removeBlips()
    for k, v in pairs(blips) do
        RemoveBlip(v)
    end
    blips = {}
end

function menuClosed()
    shopMenuOpen = false
end

exports('menuClosed', function()
    menuClosed()
end)

RegisterNetEvent('pw_clothing:client:processPayment')
AddEventHandler('pw_clothing:client:processPayment', function()
    TriggerServerEvent('pw_clothing:client:processPayment')
end)


Citizen.CreateThread(function()
    while true do
        local letSleep = true
        if characterLoaded and playerData then
            local playerCoords = GetEntityCoords(PlayerPedId())
            
            for k, v in pairs(Config.ShopLocations) do
                local distance = #(playerCoords - vector3(v.x, v.y, v.z))
                if distance <= v.radius then
                    letSleep = false
                    if distance < 5.0 then
                        if showing ~= k then
                            showing = k
                            TriggerEvent('pw_drawtext:showNotification', { title = "Clothing Store", message = "Press [ <span class='text-danger'>E</span> ] to open clothes shop,<br>Cost: $<span class='text-danger'>"..Config.requiredCash.."</span>", icon = "fad fa-tshirt" })
                        end

                        if IsControlJustPressed(0, 38) then
                            openClothesShop(k)
                        end
                    else
                        if showing == k then
                            TriggerEvent('pw_drawtext:hideNotification')
                            showing = nil
                        end
                    end
                else
                    
                    if shopMenuOpen == k then
                        PW.TriggerServerCallback('pw_base:server:loadCharacterSkin', function(skin)
                            if skin ~= nil then
                                menuClosed()
                                TriggerEvent('pw_interact:closeMenu')
                                exports['pw_base']:setPlayerSpawn(skin)
                            end
                        end)
                    end
                end
            end

        end

        if letSleep then
            Citizen.Wait(1000)
        else
            Citizen.Wait(1)
        end
    end
end)