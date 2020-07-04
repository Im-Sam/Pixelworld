PW = nil
local characterLoaded = false
local showCoords = false
local playerData = nil

Citizen.CreateThread(function()
	while PW == nil do
		TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)
		Citizen.Wait(1)
    end
end)

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function(data)
	SendNUIMessage({
		action = "hideCoords",
	})
	showCoords = false
	characterLoaded = false
    playerData = data
end)

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(data)
    playerData = data
    characterLoaded = true
end)

function DrawTxt(text, x, y)
	SetTextFont(0)
	SetTextProportional(1)
	SetTextScale(0.0, 0.4)
	SetTextDropshadow(1, 0, 0, 0, 255)
	SetTextEdge(1, 0, 0, 0, 255)
	SetTextDropShadow()
	SetTextOutline()
	SetTextEntry("STRING")
	AddTextComponentString(text)
	DrawText(x, y)
end

RegisterNUICallback("closeWindow", function(data, cb)
    SendNUIMessage({
		action = "closemenu",
	})
	SetNuiFocus(false, false)
    cb("ok")
end)

RegisterNUICallback("saveCoords", function(data, cb)
	if data ~= nil then
		if playerData.permission == 'Owner' or playerData.permission == 'Developer' or playerData.permission == 'Admin' then
			TriggerServerEvent('pw_coords:saveCoords', data)
		end
	end
    cb("ok")
end)

RegisterNUICallback("copiedClipboard", function(data, cb)
	if playerData.permission == 'Owner' or playerData.permission == 'Developer' or playerData.permission == 'Admin' then
		exports['pw_notify']:SendAlert('inform', 'The Requested Coords have been copied to your clipboard', 5000)
	end
    cb("ok")
end)

function openSaverMenu(x, y, z, h)
	if playerData.permission == 'Owner' or playerData.permission == 'Developer' or playerData.permission == 'Admin' then
		local xpos, ypos, zpos, hpos = x, y, z, h
		local tmpTable = { ['x'] = x, ['y'] = y, ['z'] = z, ['h'] = h}
		SendNUIMessage({
			action = "openmenu",
			x = xpos,
			y = ypos,
			z = zpos,
			h = hpos,
			json = json.encode(tmpTable)
		})
		SetNuiFocus(true, true)
	end
end

Citizen.CreateThread(function()
	local previousX = 0
    while true do
		Citizen.Wait(1)
		if characterLoaded then
			if playerData ~= nil then
				if playerData.permission == 'Owner' or playerData.permission == 'Developer' or playerData.permission == 'Admin' then
					if showCoords then
						local x, y, z = table.unpack(GetEntityCoords(GetPlayerPed(-1), true))
						if previousX ~= x then
							previousX = x
							roundx = tonumber(string.format("%.2f", x))
							roundy = tonumber(string.format("%.2f", y))
							roundz = tonumber(string.format("%.2f", z))				
							heading = GetEntityHeading(GetPlayerPed(-1))
							roundh = tonumber(string.format("%.2f", heading))
							local tmpTable = { ['x'] = roundx, ['y'] = roundy, ['z'] = roundz, ['h'] = roundh}
							SendNUIMessage({
								action = "updateCoords",
								x = roundx,
								y = roundy,
								z = roundz,
								h = roundh,
								json = json.encode(tmpTable)
							})
						end

						if IsControlJustPressed(0, 56) then
							openSaverMenu(roundx, roundy, roundz, roundh)
						end
					end

					if IsControlJustPressed(0, 168) then
						showCoords = not showCoords
						if showCoords then
							SendNUIMessage({
								action = "showCoords",
							})
						else
							SendNUIMessage({
								action = "hideCoords",
							})
						end
					end
				end
			end
		end
    end
end)
