local isLoggedIn = false
local dropsNear = {}
local dropList = {}
bagId = nil

function openDrop()
    if bagId ~= nil then
        PWInv.Inventory.Load:Secondary(bagId)
    end
end

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

AddEventHandler('pw:characterLoaded', function()
    TriggerServerEvent('pw_inventory:server:GetActiveDrops')
    isLoggedIn = true
end)

RegisterNetEvent('pw_inventory:client:RecieveActiveDrops')
AddEventHandler('pw_inventory:client:RecieveActiveDrops', function(drops)
    for k, v in pairs(drops) do
        dropList[k] = v
    end
end)

RegisterNetEvent('pw_inventory:client:RemoveBag')
AddEventHandler('pw_inventory:client:RemoveBag', function(owner)
    for i = 1, #dropList do
        if dropList[i].owner == owner.owner then
            dropList[i] = nil
        end
    end
    for i = 1, #dropsNear do
        if dropsNear[i].owner == owner.owner then
            dropsNear[i] = nil
        end
    end
    bagId = nil
end)

RegisterNetEvent('pw_inventory:client:CleanDropItems')
AddEventHandler('pw_inventory:client:CleanDropItems', function()
    dropList = {}
end)

RegisterNetEvent('pw_inventory:client:DropCreateForAll')
AddEventHandler('pw_inventory:client:DropCreateForAll', function(id, drop)
    table.insert(dropList, drop)
end)

RegisterNetEvent('mythic_base:client:Logout')
AddEventHandler('mythic_base:client:Logout', function()
    isLoggedIn = false
end)

Citizen.CreateThread(function()
    while true do
        if isLoggedIn then
            local pedCoord = GetEntityCoords(PlayerPedId())
            if #dropList > 0 then
                local plyCoords = GetEntityCoords(PlayerPedId())
                for k, v in pairs(dropList) do
                    local dist = #(vector3(v.position.x, v.position.y, v.position.z) - plyCoords)
                    if dist < 20.0 then
                        dropsNear[k] = v
                        if dist < 1.0 then
                            bagId = v
                        else
                            bagId = nil
                        end
                    else
                        dropsNear[k] = nil
                    end
                end
            else
                dropsNear = {}
            end
        end
        Citizen.Wait(1000)
    end
end)

Citizen.CreateThread(function()
    while true do
        if isLoggedIn then
            for k, v in pairs(dropsNear) do
                DrawMarker(27, v.position.x, v.position.y, v.position.z - 0.99, 0, 0, 0, 0, 0, 0, 0.5, 0.5, 1.0, 139, 16, 20, 250, false, false, 2, true, false, false, false)
                DrawMarker(20, v.position.x, v.position.y, v.position.z - 0.50, 0, 0, 0, 0, 0, 0, 0.15, 0.15, 0.15, 255, 255, 255, 250, false, false, 2, false, false, false, false)
            end
        end
        Citizen.Wait(5)
    end
end)