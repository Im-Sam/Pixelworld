PW = nil

TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)

PW.RegisterServerCallback('pw_fuel:server:getVehicleFuel', function(source, cb, plate)
    local _src = source
    local _vehicle = exports['pw_vehicleshop']:loadVehicleByPlate(plate)
    if _vehicle ~= nil then
        cb(_vehicle:getFuelLevel())
    else
        cb(0)
    end
end)

RegisterServerEvent('pw_fuel:server:setVehicleFuel')
AddEventHandler('pw_fuel:server:setVehicleFuel', function(plate, level)
    local _vehicle = exports['pw_vehicleshop']:loadVehicleByPlate(plate)
    _vehicle.setFuelLevel(level)
end)

RegisterServerEvent('pw_fuel:server:updateFuelLevel')
AddEventHandler('pw_fuel:server:updateFuelLevel', function(plate, det)
    local _vehicle = exports['pw_vehicleshop']:loadVehicleByPlate(plate)
    _vehicle.setFuelLevel(det)
end)

RegisterServerEvent('pw_fuel:server:payforFuel')
AddEventHandler('pw_fuel:server:payforFuel', function(cost)
    local _src = source
    local _char = exports['pw_base']:Source(_src)
    if _char:Cash().getCash() >= cost then
        _char:Cash().Remove(cost)
    end
end)