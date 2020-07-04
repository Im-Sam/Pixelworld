function DrawAdvancedText(x,y ,w,h,sc, text, r,g,b,a,font,jus)
    SetTextFont(font)
    SetTextProportional(0)
    SetTextScale(sc, sc)
    N_0x4e096588b13ffeca(jus)
    SetTextColour(r, g, b, a)
    SetTextDropShadow(0, 0, 0, 0,255)
    SetTextEdge(1, 0, 0, 0, 255)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(x - 0.1+w, y - 0.02+h)
end

local mph = 0
local x = 0.01135
local y = 0.002

Citizen.CreateThread(function()
    while true do
        Citizen.Wait(1)
        local playerPed = GetPlayerPed(-1)
        local playerCoords = GetEntityCoords(playerPed)

        if IsPedInAnyVehicle(playerPed, false) then
            local vehicle = GetVehiclePedIsIn(playerPed)
            local speed = GetEntitySpeed(vehicle)
            mph = tostring(math.ceil(speed * 2.236936))
            DrawAdvancedText(0.130 - x, 0.77 - y, 0.005, 0.0028, 0.6, mph..' /mph', 255, 255, 255, 255, 6, 1)
        else
            if mph ~= 0 then
                mph = 0
            end
        end
    end
end)