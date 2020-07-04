PW = nil
motelRooms = {}
room = {}

function loadMotelRoom(rid)
    local self = {}
    local rTable = {}
    self.rid = rid
    self.roomLoaded = false
    self.source = 0
    MySQL.Async.fetchAll("SELECT * FROM `motel_rooms` WHERE `room_id` = @room_id", {['@room_id'] = self.rid}, function(roomSQL)
        if roomSQL[1] ~= nil then
            self.room_number = roomSQL[1].room_number
            self.motel_id = roomSQL[1].motel_id
            self.type = roomSQL[1].motel_type

            if self.motel_id ~= nil and tonumber(self.motel_id) > 0 then
                self.motelName = MySQL.Sync.fetchScalar("SELECT `name` FROM `motels` WHERE `motel_id` = @id", {['@id'] = self.motel_id})
            else
                self.motelName = "Unknown"
            end
 
            if roomSQL[1].door_meta ~= nil then
                self.doorMeta = json.decode(roomSQL[1].door_meta)
            else
                self.doorMeta = {}
            end

            if roomSQL[1].teleport_meta ~= nil then
                self.teleportMeta = json.decode(roomSQL[1].teleport_meta)
            else
                self.teleportMeta = {}
            end

            if roomSQL[1].inventories ~= nil then
                self.inventories = json.decode(roomSQL[1].inventories)
            else
                self.inventories = {
                    ['weapons'] = {},
                    ['items'] = {},
                    ['clothing'] = {},
                    ['menu'] = {},
                }
            end

            self.occupied = roomSQL[1].occupied
            self.occupier = roomSQL[1].occupier

            if roomSQL[1].charSpawn ~= nil then
                self.charSpawn = json.decode(roomSQL[1].charSpawn)
            else
                self.charSpawn = {}
            end

            if roomSQL[1].roomMeta ~= nil then
                self.roomMeta = json.decode(roomSQL[1].roomMeta)
            else
                self.roomMeta = {}
                self.roomMeta.doorLocked = true
            end

            motelRooms[self.rid] = {
                ['room_id'] = self.rid,
                ['room_number'] = self.room_number,
                ['motelName'] = self.motelName,
                ['motel_id'] = self.motel_id,
                ['motel_type'] = self.type,
                ['door_meta'] = self.doorMeta,
                ['teleport_meta'] = self.teleportMeta,
                ['charSpawn'] = self.charSpawn,
                ['inventories'] = self.inventories,
                ['occupation'] = { ['occupied'] = self.occupied, ['occupier'] = self.occupier, ['source'] = self.source },
                ['room_meta'] = self.roomMeta,
            }
        end
    end)

    repeat Wait(0) until motelRooms[self.rid] ~= nil

    self.saveRoom = function()
        MySQL.Async.execute("UPDATE `motel_rooms` SET `occupied` = @occ, `occupier` = @occp, `roomMeta` = @roommeta", {['@occ'] = self.occupied, ['@occp'] = self.occupier, ['@roommeta'] = json.encode(self.roomMeta)}, function(saved)
            
        end)
    end

    self.sendToClients = function()
        TriggerClientEvent('pw_motels:client:sendRoomInfo', -1, self.rid, motelRooms[self.rid])
    end

    self.rebuildTable = function()
        motelRooms[self.rid] = {
            ['room_id'] = self.rid,
            ['room_number'] = self.room_number,
            ['motelName'] = self.motelName,
            ['motel_id'] = self.motel_id,
            ['motel_type'] = self.type,
            ['door_meta'] = self.doorMeta,
            ['teleport_meta'] = self.teleportMeta,
            ['charSpawn'] = self.charSpawn,
            ['inventories'] = self.inventories,
            ['occupation'] = { ['occupied'] = self.occupied, ['occupier'] = self.occupier, ['source'] = self.source },
            ['room_meta'] = self.roomMeta,
        }
        self.sendToClients()
    end

    rTable.resetRoom = function()
        self.occupied = false
        self.occupier = 0
        self.source = 0
        if self.type == "Door" then
            -- Lock Motel Door in PWDoors
        else
            self.roomMeta.doorLocked = true
        end
        self.saveRoom()
        self.rebuildTable()
    end

    rTable.getMotelRoomInfo = function()
        return { ['motelName'] = self.motelName, ['room'] = self.room_number }
    end

    rTable.spawnInfo = function()
        return { ['coords'] = self.charSpawn, ['name'] = self.motelName..' Room #'..self.room_number, ['id'] = self.rid }
    end

    rTable.toggleLock = function()
        self.roomMeta.doorLocked = not self.roomMeta.doorLocked
        self.saveRoom()
        self.rebuildTable()
    end

    rTable.occupyRoom = function(src, cid)
        self.occupied = true
        self.occupier = tonumber(cid)
        self.source = tonumber(src)
        self.roomMeta.doorLocked = true
        self.saveRoom()
        self.rebuildTable()
    end

    rTable.getOccupier = function()
        if self.occupied then
            return self.occupier
        else
            return nil
        end
    end

    self.roomLoaded = true
    return rTable
end