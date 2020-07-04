PW = nil
characterLoaded, playerData = false, nil
currentTattoos = {}
currentSkin = nil
currentPreview = {}
GLOBAL_PED, GLOBAL_COORDS = nil, nil
local showing = false
local inShop = false
local blips = {}

Citizen.CreateThread(function()
    while PW == nil do
        TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)
        Citizen.Wait(1)
    end
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

RegisterNetEvent('pw:characterOutfitChanged')
AddEventHandler('pw:characterOutfitChanged', function(skin)
    currentSkin = skin
end)

function createBlippers()
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
end

function deleteBlippers()
    for k, v in pairs(blips) do 
        RemoveBlip(v)
    end
end

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(data)
    PW.TriggerServerCallback('pw_tattoos:server:requestPlayerTattoos', function(tattoos)
        playerData = data
        GLOBAL_PED = PlayerPedId()
        GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
        if tattoos then
            currentTattoos = tattoos
            for k, v in pairs(currentTattoos) do
                ApplyPedOverlay(PlayerPedId(), GetHashKey(v.collection), GetHashKey(v.hash))
            end
        end
        currentSkin = exports['pw_base']:getCurrentSkin()
        characterLoaded = true
        createBlippers()
    end)
end)

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    characterLoaded = false
    playerData = nil
    currentTattoos = {}
    deleteBlippers()
end)

Citizen.CreateThread(function()
    while true do
        local letSleep = true
        if characterLoaded and GLOBAL_COORDS then

            for k, v in pairs(Config.Locations) do
                local distance = #(GLOBAL_COORDS - vector3(v.x, v.y, v.z))
                if distance < 5.0 then
                    letSleep = false
                    if distance < 1.5 then
                        if not showing then
                            TriggerEvent('pw_drawtext:showNotification', { title = "Tattoo Shop", message = "Press [ <span class='text-danger'>E</span> ] to purchase tattoos<br>Cost: $<span class='text-danger'> Various Prices</span>", icon = "fad fa-grin-tongue-wink" })
                            showing = k
                        end
                        if IsControlJustPressed(0, 38) then
                            loadTattooMenu()
                        end
                    else
                        if showing == k then
                            TriggerEvent('pw_drawtext:hideNotification')
                            showing = false
                            if inShop then
                                TriggerEvent('pw_interact:closeMenu')
                                inShop = false
                            end
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

RegisterNetEvent('pw_interact:closeMenu')
AddEventHandler('pw_interact:closeMenu', function()
    if inShop then
        cleanPlayer()
        exports['pw_base']:setPlayerSkin(currentSkin)
        currentPreview = {}
    end
end)

RegisterNetEvent('pw_tattoos:client:purchaseTattoo')
AddEventHandler('pw_tattoos:client:purchaseTattoo', function(data)
    if currentPreview ~= nil and currentPreview['collection'] ~= nil and currentPreview['tattoo'] ~= nil then
        PW.TriggerServerCallback('pw_tattoos:server:checkCashAmount', function(valid)
            if valid then
                table.insert(currentTattoos, {['collection'] = currentPreview['collection'], ['hash'] = currentPreview['tattoo'].nameHash})
                cleanPlayer()
                TriggerServerEvent('pw_tattoos:server:purchaseTattoo', currentPreview['tattoo'].price)
                TriggerServerEvent('pw_tattoos:server:saveTattoos', currentTattoos)
                exports.pw_notify:SendAlert('success', 'You have successfully purchased this tattoo.', 5000)
                currentPreview = {}
                loadTattooMenu()
            else
                exports.pw_notify:SendAlert('error', 'Sorry you do not have enough cash for this tattoo, you need $'..currentPreview['tattoo'].price, 5000)
            end
        end, currentPreview['tattoo'].price)  
    end
end)

RegisterNetEvent('pw_tattoos:client:loadTattoo')
AddEventHandler('pw_tattoos:client:loadTattoo', function(data)
    cleanPlayer()
    for k,v in pairs(currentTattoos) do
		ApplyPedOverlay(PlayerPedId(), GetHashKey(v.collection), GetHashKey(v.hash))
    end
    
    ApplyPedOverlay(PlayerPedId(), GetHashKey(data.collection), GetHashKey(data.tattInfo.nameHash))
    currentPreview = { ['collection'] = data.collection, ['tattoo'] = data.tattInfo }

    TriggerEvent('pw_interact:enableSlider')
end)

RegisterNetEvent('pw_tattoos:client:loadTattoosCategory')
AddEventHandler('pw_tattoos:client:loadTattoosCategory', function(data)
    local menu = {}
    local changeSkinTemp = {}
    if playerData.sex then
        changeSkinTemp = {
            ['tshirt'] =    { ['one'] = 15, ['two'] = 0 },
            ['arms'] =      { ['one'] = 15 },
            ['torso'] =     {['one'] = 15, ['two'] = 0 },
            ['pants'] =     {['one'] = 14, ['two'] = 0 }
        }
    else
        changeSkinTemp = {
            ['tshirt'] =    { ['one'] = 34, ['two'] = 0 },
            ['arms'] =      { ['one'] = 15 },
            ['torso'] =     {['one'] = 15, ['two'] = 0 },
            ['pants'] =     {['one'] = 16, ['two'] = 0 }
        }
    end
    exports['pw_base']:loadUniform(changeSkinTemp)

    for k, v in pairs(Config.TattooList[data.value]) do
        table.insert(menu, { ['label'] = ((v.label or 'Style #')..k)..' $'..v.price, ['data'] = { ['tattInfo'] = v, ['collection'] = data.value, ['trigger'] = "pw_tattoos:client:loadTattoo", ['triggerType'] = "client"} })
    end
    TriggerEvent('pw_interact:generateSlider', menu, 'pw_tattoos:client:purchaseTattoo', 'client', data.name, "", {menuSwitcher = true, vehicle = true}, { { ['trigger'] = "pw_tattoos:client:loadShopMenu", ['method'] = "client"} } )
end)

RegisterNetEvent('pw_tattoos:client:loadShopMenu')
AddEventHandler('pw_tattoos:client:loadShopMenu', function()
    inShop = true
    loadTattooMenu()
end)

function loadTattooMenu()
    exports['pw_base']:setPlayerSkin(currentSkin)
    cleanPlayer()
    inShop = true
    local menu = {}
    for k, v in pairs(Config.TattooCategories) do
        table.insert(menu, {['label'] = v.name, ['color'] = 'primary', ['action'] = "pw_tattoos:client:loadTattoosCategory", ['triggertype'] = 'client', ['value'] = { value = v.value, name = v.name } })
    end
    TriggerEvent('pw_interact:generateMenu', menu, 'Tattoo Shop')
end

function cleanPlayer()
    ClearPedDecorations(PlayerPedId())
    for k,v in pairs(currentTattoos) do
		ApplyPedOverlay(PlayerPedId(), GetHashKey(v.collection), GetHashKey(v.hash))
	end
end
