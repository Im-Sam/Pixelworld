phoneNumber = nil

function notificationNui(sub, show)
    SendNUIMessage({
        status = "notifications",
        sub = sub,
        show = show
    })
end

RegisterNetEvent('pw_phone:client:triggerNotification')
AddEventHandler('pw_phone:client:triggerNotification', function(alert, status, by, tweet)
    notificationNui(alert, status)
end)

RegisterNetEvent('pw_phone:client:notifications:newTextMessage')
AddEventHandler('pw_phone:client:notifications:newTextMessage', function()
    notificationNui("textMessages", true)
end)

RegisterNetEvent('pw_phone:client:tweet')
AddEventHandler('pw_phone:client:tweet', function(alert, status, by, tweet)
    if status == "reply" then
        status = "replied"
    else
        status = "tweeted"
    end
    SendNUIMessage({
        status = "newTweet",
        stat = status,
        by = by,
        tweet = tweet
    })
end)