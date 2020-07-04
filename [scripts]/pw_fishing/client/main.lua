PW, characterLoaded, playerData = nil, false, nil
local showing, drawingMarker = false, false
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
    GLOBAL_PED = PlayerPedId()
    GLOBAL_COORDS = GetEntityCoords(GLOBAL_PED)
    createBlips()
end)

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    destroyBlips()
    characterLoaded = false
    playerData = nil
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

local fishing, waiting, bait = false, false, 0


function IsFacingWater(playerLocation, playerHeading) 
    local axis = nil
    local facingWater = false
    if playerHeading >= 135 and playerHeading <= 225 then
        axis = '-y'
    elseif playerHeading >= 0 and playerHeading <= 45 then
        axis = '+y'
    elseif playerHeading >= 315 and playerHeading <= 360 then
        axis = '+y'    
    elseif playerHeading >= 45 and playerHeading <= 135 then
        axis = '-x' 
    else
        axis = 'x'   
    end    
    if axis == '-y' then
        facingWater = GetWaterHeight(playerLocation.x, playerLocation.y - 2.5, playerLocation.z)
    elseif axis == '-x' then
        facingWater = GetWaterHeight(playerLocation.x - 2.5, playerLocation.y, playerLocation.z)
    elseif axis == 'y' then
        facingWater = GetWaterHeight(playerLocation.x, playerLocation.y + 2.5, playerLocation.z)
    elseif axis == 'x' then
        facingWater = GetWaterHeight(playerLocation.x + 2.5, playerLocation.y, playerLocation.z)        
    end
	return facingWater
end


RegisterNetEvent('pw_fishing:startFishing')
AddEventHandler('pw_fishing:startFishing', function()
    local playerHeading = GetEntityHeading(GLOBAL_PED)

	if IsPedInAnyVehicle(GLOBAL_PED) then
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = "Cannot Start Fishing, Get Out of the Vehicle.", length = 5000})
        
    elseif IsPedSwimming(GLOBAL_PED) or IsPedFatallyInjured(GLOBAL_PED) then -- Checks
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = "Cannot Start Fishing", length = 5000})

    else

        if IsFacingWater(GLOBAL_COORDS, playerHeading) ~= false then
            TriggerEvent('pw:notification:SendAlert', {type = "inform", text = "Starting Fishing", length = 2500})
			TaskStartScenarioInPlace(GLOBAL_PED, "WORLD_HUMAN_STAND_FISHING", 0, true) 
            fishing = true
            StartFishingCancelChecks()
            StartFishingCatchChecks()
            StartFishingCatchChecks2()

            TriggerEvent('pw_drawtext:showNotification', {title = "<span style='font-size:30px;'><center>Started Fishing</center></span>", message = "<span style='font-size:20px;'>Get ready to press <strong>E</strong> when you feel a bite. Press <strong>X</strong> to stop fishing", icon = "fas fa-fish"})
            Citizen.Wait(15000)
            TriggerEvent('pw_drawtext:hideNotification')

		else
			TriggerEvent('pw:notification:SendAlert', {type = "error", text = "Cannot Start Fishing, Not Facing Water", length = 5000})
        end
        
	end
end)


RegisterNetEvent('pw_fishing:setbait')
AddEventHandler('pw_fishing:setbait', function(baitType)
    bait = baitType
    if baitType ~= 0 then
        local baitlabel = 'Regular Fish Bait'
        if baitType == 1 then
            baitlabel = 'Regular Fish Bait'
        elseif baitType == 2 then
            baitlabel = 'Advanced Fish Bait'  
        elseif baitType == 2 then
            baitlabel = 'Turtle Meat' 
        end         
        TriggerEvent('pw:notification:SendAlert', {type = "success", text = "Attached " .. baitlabel .. " to Fishing Rod!", length = 5000})
    end    
end)


RegisterNetEvent('pw_fishing:breakrod') -- Break Fishing Rod and Stop Fishing
AddEventHandler('pw_fishing:breakrod', function()
	fishing = false
    ClearPedTasks(GLOBAL_PED)
    TriggerEvent('pw:notification:SendAlert', {type = "error", text = "Fishing Rod Broke, the Fish was too Heavy", length = 5000})
end)
--


function StartFishingCancelChecks()
    Citizen.CreateThread(function()
        while fishing do
            Citizen.Wait(1)
            sleeping = false
            local playerHeading = GetEntityHeading(GLOBAL_PED)
            if IsFacingWater(GLOBAL_COORDS, playerHeading) == false or IsPedSwimming(GLOBAL_PED) or IsPedFatallyInjured(GLOBAL_PED) or IsPedInAnyVehicle(GLOBAL_PED) or IsControlJustPressed(0, 73) then -- For When to Stop Fishing
                fishing = false
                TriggerEvent('pw:notification:SendAlert', {type = "inform", text = "Stopped Fishing", length = 5000})
                ClearPedTasks(GLOBAL_PED)
                TriggerEvent('pw_drawtext:hideNotification')
            end       
        end
    end)
end

function StartFishingCatchChecks()
    Citizen.CreateThread(function()
        while fishing do 
            Citizen.Wait(1)
            if IsControlJustPressed(0, 86) then -- Checks if E is pressed for pulling the fish in
                input = 1
            end               
            if waiting and input ~= 0 then
                waiting = false
                if input == 1 then
                    TriggerServerEvent('pw_fishing:catch', bait, GLOBAL_COORDS)
                else
                    TriggerEvent('pw:notification:SendAlert', {type = "error", text = "Unlucky! The Fish Escaped.", length = 5000})
                end
            end     
        end
    end)
end    

function StartFishingCatchChecks2()
    Citizen.CreateThread(function()
        while true do
            Citizen.Wait(100)
            if fishing then
                local randomwait = math.random(30000, 90000)
                Citizen.Wait(randomwait)
                waiting = true
                TriggerEvent('pw:notification:SendAlert', {type = "warning", text = "You Feel a Fish Pulling on the Rod. Press <strong>E</strong> to Pull in.", length = 5000})
                input = 0 
            else
                Citizen.Wait(1000)
                break
            end       
        end
    end)
end   


function DrawShit(x, y, z, var)
    Citizen.CreateThread(function()
        while drawingMarker == var do
            Citizen.Wait(1)
            DrawMarker(Config.Marker.markerType, x, y, z, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, Config.Marker.markerSize.x, Config.Marker.markerSize.y, Config.Marker.markerSize.z, Config.Marker.markerColor.r, Config.Marker.markerColor.g, Config.Marker.markerColor.b, 100, false, true, 2, false, nil, nil, false)
        end
    end)
end

function DrawText(type, var)
    local title, message, icon
    
    if type == 'fishSales' then
        title = "Fish Sales"
        message = "<span style='font-size:20px'><b><span class='text-primary'>Sell Fish</span></b></span>"
        icon = "fas fa-fish"

    end

    if title ~= nil and message ~= nil and icon ~= nil then
        TriggerEvent('pw_drawtext:showNotification', { title = title, message = message, icon = icon })
    end

    Citizen.CreateThread(function()
        while showing == var do
            Citizen.Wait(1)
            if IsControlJustPressed(0, 38) then
                if type == 'fishSales' then
                    OpenFishSaleMenu()
                --elseif type == 'illegalFishSales' then
                    --print("OPEN ILLEGAL FISH SALES")
                end
            end
        end
    end)
end


Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1000)
        if characterLoaded and playerData then

            for k,v in pairs(Config.Points) do
                local dist = #(GLOBAL_COORDS - vector3(v.coords.x, v.coords.y, v.coords.z))
                if dist < 15.0 then
                    if not drawingMarker then
                        drawingMarker = k
                        DrawShit(v.coords.x, v.coords.y, v.coords.z, drawingMarker)
                    end

                    if dist < v.drawDistance then
                        if not showing then
                            showing = k
                            DrawText(showing, k)
                        end
                    elseif showing == k then
                        showing = false
                        TriggerEvent('pw_drawtext:hideNotification')
                    end
                elseif drawingMarker == k then
                    drawingMarker = false   
                end      
            end
        end    
    end
end)

function OpenFishSaleMenu()
    local menu = {}

    for i = 1, #Config.FishType do
        table.insert(menu, { ['label'] = Config.FishType[i].label, ['action'] = 'pw_fishing:sellFish', ['value'] = { ['name'] = Config.FishType[i].name, ['label'] = Config.FishType[i].label }, ['triggertype'] = 'server', ['color'] = 'primary' })
    end

    TriggerEvent('pw_interact:generateMenu', menu, "Fish Sales")
end

-- (Selling) --

function OpenFishSaleMenu()
    local menu = {}
    local menuItems = 0
    for i = 1, #Config.FishSales do
        local itemCount = PW.Game.CheckInventory(Config.FishSales[i].item)
        if itemCount > 0 then
            table.insert(menu, { ['label'] = Config.FishSales[i].label .. " <i>(You Have " .. itemCount ..")</i>", ['action'] = 'pw_fishing:client:sellingFish', ['value'] = { ['saleid'] = i, ['label'] = Config.FishSales[i].label, ['amount'] = itemCount }, ['triggertype'] = 'client', ['color'] = "primary" })
            menuItems = (menuItems + 1)
        end    
    end
    if menuItems ~= 0 then
        TriggerEvent('pw_interact:generateMenu', menu, "Sell Fish")
    else
        TriggerEvent('pw:notification:SendAlert', {type = "error", text = "You Don't have Any Fish that we Buy!", length = 5000})
    end  
end

RegisterNetEvent('pw_fishing:client:sellingFish')
AddEventHandler('pw_fishing:client:sellingFish', function(data)
    TriggerEvent('pw:progressbar:progress',
    {
        name = 'inspecting_rock',
        duration = (3000 * data.amount),
        label = 'Selling ' .. data.amount .. ' '.. data.label,
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
            TriggerServerEvent('pw_fishing:server:sellFish', data)
        else
            TriggerEvent('pw:notification:SendAlert', {type = "error", text = "Cancelled Selling Fish", length = 5000})
        end
    end)       
end)



function createBlips()
    Citizen.CreateThread(function()
        for k, v in pairs(Config.Points) do
            blips[k] = AddBlipForCoord(v.coords.x, v.coords.y, v.coords.z)
            SetBlipSprite(blips[k], Config.Blips.type)
            SetBlipDisplay(blips[k], 4)
            SetBlipScale  (blips[k], Config.Blips.scale)
            SetBlipColour (blips[k], Config.Blips.color)
            SetBlipAsShortRange(blips[k], true)
            BeginTextCommandSetBlipName("STRING")
            AddTextComponentString(Config.Blips.name)
            EndTextCommandSetBlipName(blips[k])
        end
    end)
end

function destroyBlips()
    for k, v in pairs(blips) do
        RemoveBlip(v)
    end
end