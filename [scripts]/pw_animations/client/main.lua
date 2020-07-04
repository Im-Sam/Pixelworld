local playerCurrentlyAnimated = false
local playerCurrentlyHasProp = false
local playerCurrentlyHasWalkstyle = false
local surrendered = false
local firstAnim = true
local playerPropList = {}
local LastAD
PW = nil
local characterLoaded, playerData = false, nil

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
    TriggerEvent('pw_animations:KillProps')
	playerCurrentlyHasProp = false
end)

Citizen.CreateThread( function()
	while true do
        Citizen.Wait(5)
        if characterLoaded and playerData then
            if (IsControlJustPressed(0,Config.RadioKey))  then
                local player = PlayerPedId()
                if ( DoesEntityExist( player ) and not IsEntityDead( player ) ) then 

                    if IsEntityPlayingAnim(player, "random@arrests", "generic_radio_chatter", 3) then
                        ClearPedSecondaryTask(player)
                    else
                        loadAnimDict( "random@arrests" )
                        TaskPlayAnim(player, "random@arrests", "generic_radio_chatter", 2.0, 2.5, -1, 49, 0, 0, 0, 0 )
                        RemoveAnimDict("random@arrests")
                    end
                end
            elseif (IsControlJustPressed(0,Config.HandsUpKey)) then
                local player = PlayerPedId()
        
                if ( DoesEntityExist( player ) and not IsEntityDead( player ) ) then
        
                    if IsEntityPlayingAnim(player, "random@mugging3", "handsup_standing_base", 3) then
                        ClearPedSecondaryTask(player)
                    else
                        loadAnimDict( "random@mugging3" )
                        TaskPlayAnim(player, "random@mugging3", "handsup_standing_base", 2.0, 2.5, -1, 49, 0, 0, 0, 0 )
                        RemoveAnimDict("random@mugging3")
                    end
                end

            elseif (IsControlJustPressed(0,Config.HoverHolsterKey)) then
                local player = PlayerPedId()
        
                if ( DoesEntityExist( player ) and not IsEntityDead( player ) ) then
        
                    if IsEntityPlayingAnim(player, "move_m@intimidation@cop@unarmed", "idle", 3) then
                        ClearPedSecondaryTask(player)
                    else
                        loadAnimDict( "move_m@intimidation@cop@unarmed" )
                        TaskPlayAnim(player, "move_m@intimidation@cop@unarmed", "idle", 2.0, 2.5, -1, 49, 0, 0, 0, 0 )
                        RemoveAnimDict("move_m@intimidation@cop@unarmed")
                    end
                end
            end
        end
	end
end)

RegisterNetEvent('pw_animations:KillProps')
AddEventHandler('pw_animations:KillProps', function()
	for _,v in pairs(playerPropList) do
		DeleteEntity(v)
	end

	playerCurrentlyHasProp = false
end)

RegisterNetEvent('pw_animations:AttachProp')
AddEventHandler('pw_animations:AttachProp', function(prop_one, boneone, x1, y1, z1, r1, r2, r3)
	local player = PlayerPedId()
	local x,y,z = table.unpack(GetEntityCoords(player))

	if not HasModelLoaded(prop_one) then
		loadPropDict(prop_one)
	end

	prop = CreateObject(GetHashKey(prop_one), x, y, z+0.2,  true,  true, true)
	AttachEntityToEntity(prop, player, GetPedBoneIndex(player, boneone), x1, y1, z1, r1, r2, r3, true, true, false, true, 1, true)
	SetModelAsNoLongerNeeded(prop_one)
	table.insert(playerPropList, prop)
	playerCurrentlyHasProp = true
end)

RegisterNetEvent('pw_animations:Animation')
AddEventHandler('pw_animations:Animation', function(ad, anim, body)
	local player = PlayerPedId()
	if playerCurrentlyAnimated then -- Cancel Old Animation

		loadAnimDict(ad)
		TaskPlayAnim( player, ad, "exit", 8.0, 1.0, -1, body, 0, 0, 0, 0 )
		Wait(750)
		ClearPedSecondaryTask(player)
		RemoveAnimDict(LastAD)
		RemoveAnimDict(ad)
		LastAD = ad
		playerCurrentlyAnimated = false
		TriggerEvent('pw_animations:KillProps')
		return
	end

	if firstAnim then
		LastAD = ad
		firstAnim = false
	end

	loadAnimDict(ad)
	TaskPlayAnim(player, ad, anim, 4.0, 1.0, -1, body, 0, 0, 0, 0 )  --- We actually play the animation here
	RemoveAnimDict(ad)
	playerCurrentlyAnimated = true

end)

RegisterNetEvent('pw_animations:StopAnimations')
AddEventHandler('pw_animations:StopAnimations', function()

	local player = PlayerPedId()
	if vehiclecheck() then
		if IsPedUsingAnyScenario(player) then
			--ClearPedSecondaryTask(player)
			ClearPedTasks(player)
		end

		if playerCurrentlyHasWalkstyle then
			ResetPedMovementClipset(player, 0.0)
			playerCurrentlyHasWalkstyle = false
		end

		if playerCurrentlyAnimated then
			if LastAD then
				RemoveAnimDict(LastAD)
			end

			if playerCurrentlyHasProp then
				TriggerEvent('pw_animations:KillProps')
				playerCurrentlyHasProp = false
			end

			if surrendered then
				surrendered = false
			end

			--ClearPedSecondaryTask(player)
			ClearPedTasks(player)
			playerCurrentlyAnimated = false
		end
	end
end)

RegisterNetEvent('pw_animations:Scenario')
AddEventHandler('pw_animations:Scenario', function(ad)
	local player = PlayerPedId()
	TaskStartScenarioInPlace(player, ad, 0, 1)   
end)

RegisterNetEvent('pw_animations:Walking')
AddEventHandler('pw_animations:Walking', function(ad)
	local player = PlayerPedId()
	ResetPedMovementClipset(player, 0.0)
	RequestWalking(ad)
	SetPedMovementClipset(player, ad, 0.25)
	RemoveAnimSet(ad)
end)

RegisterNetEvent('pw_animations:Surrender')  -- Too many waits to make it work properly within the config
AddEventHandler('pw_animations:Surrender', function()
	local player = PlayerPedId()
	local ad = "random@arrests"
	local ad2 = "random@arrests@busted"

	if ( DoesEntityExist( player ) and not IsEntityDead( player )) then 
		loadAnimDict( ad )
		loadAnimDict( ad2 )
		if ( IsEntityPlayingAnim( player, ad2, "idle_a", 3 ) ) then 
			TaskPlayAnim( player, ad2, "exit", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
			Wait (3000)
			TaskPlayAnim( player, ad, "kneeling_arrest_get_up", 8.0, 1.0, -1, 128, 0, 0, 0, 0 )
			RemoveAnimDict("random@arrests@busted")
			RemoveAnimDict("random@arrests" )
			surrendered = false
			LastAD = ad
			playerCurrentlyAnimated = false
		else

			TaskPlayAnim( player, "random@arrests", "idle_2_hands_up", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
			Wait (4000)
			TaskPlayAnim( player, "random@arrests", "kneeling_arrest_idle", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
			Wait (500)
			TaskPlayAnim( player, "random@arrests@busted", "enter", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
			Wait (1000)
			TaskPlayAnim( player, "random@arrests@busted", "idle_a", 8.0, 1.0, -1, 9, 0, 0, 0, 0 )
			Wait(100)
			surrendered = true
			playerCurrentlyAnimated = true
			LastAD = ad2
			RemoveAnimDict("random@arrests" )
			RemoveAnimDict("random@arrests@busted")
		end     
	end

	Citizen.CreateThread(function() --disabling controls while surrendering
		while surrendered do
			Citizen.Wait(1000)
			if IsEntityPlayingAnim(GetPlayerPed(PlayerId()), "random@arrests@busted", "idle_a", 3) then
				DisableControlAction(1, 140, true)
				DisableControlAction(1, 141, true)
				DisableControlAction(1, 142, true)
				DisableControlAction(0,21,true)
			end
		end
	end)
end)

AddEventHandler('onResourceStop', function(resource)
	if resource == GetCurrentResourceName() then
		TriggerEvent('pw_animations:KillProps')
		playerCurrentlyHasProp = false
	end
end)

RegisterNetEvent('pw_animations:cancelAnim')
AddEventHandler('pw_animations:cancelAnim', function()
    local player = PlayerPedId()
    TriggerEvent('pw_animations:KillProps')
    TriggerEvent('pw_animations:StopAnimations')

    local ad = "random@arrests"
    local ad2 = "random@arrests@busted"
    loadAnimDict( ad )
    loadAnimDict( ad2 )
    
    if ( IsEntityPlayingAnim( player, ad2, "idle_a", 3 ) ) then 
        TaskPlayAnim( player, ad2, "exit", 8.0, 1.0, -1, 2, 0, 0, 0, 0 )
        Wait (3000)
        TaskPlayAnim( player, ad, "kneeling_arrest_get_up", 8.0, 1.0, -1, 128, 0, 0, 0, 0 )
        RemoveAnimDict("random@arrests@busted")
        RemoveAnimDict("random@arrests" )
        surrendered = false
        LastAD = ad
        playerCurrentlyAnimated = false
    end
end)

RegisterNetEvent('pw_animations:doAnimation')
AddEventHandler('pw_animations:doAnimation', function(args)
    if characterLoaded and playerData then
        local player = PlayerPedId()
        local argh = tostring(args)
        if argh == "surrender" then
            TriggerEvent('pw_animations:Surrender')
        elseif argh == "cancel" then
            TriggerEvent('pw_animations:cancelAnim')
        else
            for i = 1, #Config.Anims, 1 do
                local name = Config.Anims[i].name
                if argh == name then				
                    local prop_one = Config.Anims[i].data.prop
                    local boneone = Config.Anims[i].data.boneone
                    if ( DoesEntityExist( player ) and not IsEntityDead( player )) then 

                        if Config.Anims[i].data.type == 'prop' then
                            if playerCurrentlyHasProp then --- Delete Old Prop

                                TriggerEvent('pw_animations:KillProps')
                            end
                            
                            TriggerEvent('pw_animations:AttachProp', prop_one, boneone, Config.Anims[i].data.x, Config.Anims[i].data.y, Config.Anims[i].data.z, Config.Anims[i].data.xa, Config.Anims[i].data.yb, Config.Anims[i].data.zc)

                        elseif Config.Anims[i].data.type == 'brief' then

                            if name == 'brief' then
                                GiveWeaponToPed(player, 0x88C78EB7, 1, false, true)
                            else
                                GiveWeaponToPed(player, 0x01B79F17, 1, false, true)
                            end
                            return
                        elseif Config.Anims[i].data.type == 'scenario' then
                            local ad = Config.Anims[i].data.ad

                            if vehiclecheck() then
                                if IsPedActiveInScenario(player) then
                                    ClearPedTasks(player)
                                else
                                    TriggerEvent('pw_animations:Scenario', ad)
                                end 
                            end

                        elseif Config.Anims[i].data.type == 'walkstyle' then
                            local ad = Config.Anims[i].data.ad
                            if vehiclecheck() then
                                TriggerEvent('pw_animations:Walking', ad)
                                if not playerCurrentlyHasWalkstyle then
                                    playerCurrentlyHasWalkstyle = true
                                end
                            end
                        else

                            if vehiclecheck() then
                                local ad = Config.Anims[i].data.ad
                                local anim = Config.Anims[i].data.anim
                                local body = Config.Anims[i].data.body
                                
                                TriggerEvent('pw_animations:Animation', ad, anim, body) -- Load/Start animation

                                if prop_one ~= 0 then
                                    local prop_two = Config.Anims[i].data.proptwo
                                    local bonetwo = nil

                                    loadPropDict(prop_one)
                                    TriggerEvent('pw_animations:AttachProp', prop_one, boneone, Config.Anims[i].data.x, Config.Anims[i].data.y, Config.Anims[i].data.z, Config.Anims[i].data.xa, Config.Anims[i].data.yb, Config.Anims[i].data.zc)
                                    if prop_two ~= 0 then
                                        bonetwo = Config.Anims[i].data.bonetwo
                                        prop_two = Config.Anims[i].data.proptwo
                                        loadPropDict(prop_two)
                                        TriggerEvent('pw_animations:AttachProp', prop_two, bonetwo, Config.Anims[i].data.twox, Config.Anims[i].data.twoy, Config.Anims[i].data.twoz, Config.Anims[i].data.twoxa, Config.Anims[i].data.twoyb, Config.Anims[i].data.twozc)
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end)

function loadAnimDict(dict)
	RequestAnimDict(dict)
	while not HasAnimDictLoaded(dict) do
		Citizen.Wait(500)
	end
end

function loadPropDict(model)
	RequestModel(GetHashKey(model))
	while not HasModelLoaded(GetHashKey(model)) do
		Citizen.Wait(500)
	end
end

function RequestWalking(ad)
	RequestAnimSet( ad )
	while ( not HasAnimSetLoaded( ad ) ) do 
		Citizen.Wait( 500 )
	end 
end

function vehiclecheck()
	local player = PlayerPedId()
	if IsPedInAnyVehicle(player, false) then
		return false
	end
	return true
end