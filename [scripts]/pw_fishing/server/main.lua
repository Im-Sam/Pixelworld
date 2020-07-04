PW = nil

TriggerEvent('pw:getSharedObject', function(obj)
     PW = obj 
end)

RegisterServerEvent('pw_base:itemUsed')
AddEventHandler('pw_base:itemUsed', function(_src, data)
     if data.item == "fishingrod" then
          TriggerClientEvent('pw_fishing:startFishing', _src)
     else
          local _char = exports.pw_base:Source(_src)
          local usedItem = false
          
          if data.item == "fishbait" then
               TriggerClientEvent('pw_fishing:setbait', _src, 1)
               usedItem = true
          elseif data.item == "advfishbait" then
               TriggerClientEvent('pw_fishing:setbait', _src, 2)
               usedItem = true
          elseif data.item == "turtle" then
               TriggerClientEvent('pw_fishing:setbait', _src, 3)
               usedItem = true
          end

          if usedItem then
               _char:Inventories():Remove().Item(data, 1)
          end
     end       
end)

function randomFish()
     local randomFish = { 'fishKelp', 'fishBass', 'FishYellow' }
     return randomFish[math.random(1, #randomFish)]
end  


-- Need to Mess with the chances
RegisterNetEvent('pw_fishing:catch') 
AddEventHandler('pw_fishing:catch', function(bait, position)
local _source = source
local amount = 1
local randomNum = math.random(1,100)
local _char = exports.pw_base:Source(_source)
local fish = randomFish()

     if bait == 1 then
		if randomNum >= 75 then
               TriggerClientEvent('fishing:setbait', _source, "none")
               amount = math.random(2, 5)
               TriggerClientEvent('pw:notification:SendAlert', _source, {type = "success", text = "You Caught " .. amount .. " Fish!", length = 5000})
               _char:Inventories():AddItem():Player().Single(fish, amount)
          else
               amount = math.random(1, 3)
               TriggerClientEvent('pw:notification:SendAlert', _source, {type = "success", text = "You Caught " .. amount .. " Fish!", length = 5000})
               _char:Inventories():AddItem():Player().Single(fish, amount)
          end

     elseif bait == 2 then

          if position.y >= 7700 or position.y <= -4000 or position.x <= -3700 or position.x >= 4300 then -- If Very Far from shore you get chance of the illegal fish
               if randomNum >= 85 then 
                    if randomNum >= 91 then
                         TriggerClientEvent('pw_fishing:setbait', _source, 0)
                         TriggerClientEvent('pw_fishing:breakrod', _source)
                         _char:Inventories():Remove().byName('fishingrod', 1)
                    else
                         TriggerClientEvent('pw_fishing:setbait', _source, 0)
                         TriggerClientEvent('pw:notification:SendAlert', _source, {type = "success", text = "You Caught a Turtle!", length = 5000})
                         _char:Inventories():AddItem():Player().Single('turtle', 1)
                    end
               else
                    if randomNum >= 75 then
                         amount = math.random(4, 6)
                         TriggerClientEvent('pw:notification:SendAlert', _source, {type = "success", text = "You Caught " .. amount .. " Fish!", length = 5000})
                         _char:Inventories():AddItem():Player().Single(fish, amount)
                    else
                         amount = math.random(2, 4)
                         TriggerClientEvent('pw:notification:SendAlert', _source, {type = "success", text = "You Caught " .. amount .. " Fish!", length = 5000})
                         _char:Inventories():AddItem():Player().Single(fish, amount)
                    end
               end
          else
               if randomNum >= 75 then
                    TriggerClientEvent('fishing:setbait', _source, "none")
                    amount = math.random(5, 7)
                    TriggerClientEvent('pw:notification:SendAlert', _source, {type = "success", text = "You Caught " .. amount .. " Fish!", length = 5000})
                    _char:Inventories():AddItem():Player().Single(fish, amount)
               else
                    amount = math.random(2, 4)
                    TriggerClientEvent('pw:notification:SendAlert', _source, {type = "success", text = "You Caught " .. amount .. " Fish!", length = 5000})
                    _char:Inventories():AddItem():Player().Single(fish, amount)
               end
          end           

     elseif bait == 3 then
          if position.y >= 7700 or position.y <= -4000 or position.x <= -3700 or position.x >= 4300 then -- If Very Far from shore you get chance of the illegal fish
               if randomNum >= 82 then
                    
                    if randomNum >= 91 then
                         TriggerClientEvent('pw_fishing:setbait', _source, 0)
                         TriggerClientEvent('pw_fishing:breakrod', _source)
                         _char:Inventories():Remove().byName('fishingrod', 1)
                    else
                         TriggerClientEvent('pw:notification:SendAlert', _source, {type = "success", text = "You Caught a Shark!", length = 5000})
                         --TriggerClientEvent('fishing:spawnPed', _source)
                         _char:Inventories():AddItem():Player().Single('shark', 1)
                         TriggerClientEvent('pw_fishing:setbait', _source, 0)
                    end	
               else
                    amount = math.random(6, 9)
                    TriggerClientEvent('pw:notification:SendAlert', _source, {type = "success", text = "You Caught " .. amount .. " Fish!", length = 5000})
                    _char:Inventories():AddItem():Player().Single(fish, amount)
               end
          end

     elseif bait == 0 then
		TriggerClientEvent('pw:notification:SendAlert', _source, {type = "warning", text = "You Are Fishing Without Bait. You Probably Won't Catch Anything!", length = 5000})	
          if randomNum >= 95 then
               TriggerClientEvent('pw:notification:SendAlert', _source, {type = "success", text = "You're Lucky! You Caught a Fish With No Bait!", length = 5000})
               _char:Inventories():AddItem():Player().Single(fish, 1)  
          end  
     end  
end)

RegisterServerEvent('pw_fishing:server:sellFish')
AddEventHandler('pw_fishing:server:sellFish', function(data)
     local _src = source 
     local _char = exports.pw_base:Source(_src)
     local indexid = data.saleid
     local fish_item = Config.FishSales[indexid].item
     local fish_label = Config.FishSales[indexid].label
     local min_price = Config.FishSales[indexid].price_min
     local max_price = Config.FishSales[indexid].price_max

     local final_price = math.random(min_price, max_price)
     local fishAmount = _char:Inventories().getItemCount(fish_item)
     if fishAmount ~= 0 then -- should never even be 0 anyway (it is checked on the client)
          Citizen.Wait(100)
          _char:Inventories():Remove().byName(fish_item, fishAmount)
          Citizen.Wait(1000)
          local cash = (final_price * fishAmount)
          local _balance = _char:Cash().Add(cash)
          TriggerClientEvent('pw:notification:SendAlert', _src, {type = "success", text = "You Have Sold " .. fishAmount .. " " .. fish_label ..  " for $" .. cash .. "!", length = 7000})
     else
          TriggerClientEvent('pw:notification:SendAlert', _src, {type = "error", text = "You Have None to Sell!", length = 5000})     
     end       
end)