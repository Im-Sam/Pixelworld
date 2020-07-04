PW = nil
local characterLoaded, playerData = false, nil
local crouched = false

RegisterNetEvent('pw:characterLoaded')
AddEventHandler('pw:characterLoaded', function(data)
    playerData = data
    characterLoaded = true
    TriggerEvent('pw_crouch:startThread')
end)

RegisterNetEvent('pw:characterUnLoaded')
AddEventHandler('pw:characterUnLoaded', function()
    playerLoaded = false
    characterLoaded = nil
end)

RegisterNetEvent('pw_crouch:startThread')
AddEventHandler('pw_crouch:startThread', function()
    while characterLoaded do
        Citizen.Wait(1)

        local ped = GetPlayerPed( -1 )

        if ( DoesEntityExist( ped ) and not IsEntityDead( ped ) ) then 
            DisableControlAction( 0, 36, true ) -- INPUT_DUCK  

            if ( not IsPauseMenuActive() ) then 
                if ( IsDisabledControlJustPressed( 0, 36 ) ) then 
                    RequestAnimSet( "move_ped_crouched" )

                    while ( not HasAnimSetLoaded( "move_ped_crouched" ) ) do 
                        Citizen.Wait( 100 )
                    end 

                    if ( crouched == true ) then 
                        ResetPedMovementClipset( ped, 0 )
                        crouched = false
                    elseif ( crouched == false ) then
                        SetPedMovementClipset( ped, "move_ped_crouched", 0.25 )
                        crouched = true
                    end 

                    TriggerEvent('pw_pedfeatures:client:crouching', crouched)
                end
            end 
        end
    end
end)