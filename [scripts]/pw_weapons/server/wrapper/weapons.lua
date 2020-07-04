weaponTypes = {}
ammoTypes = {}
registeredWeapons = {}

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

function loadWeapon(serial)
    local self = {}
    self.serial = serial
    local processed = false    
    MySQL.Async.fetchAll("SELECT * FROM `registered_weapons` WHERE `weapon_serial` = @serial", {['@serial'] = self.serial}, function(qry)
        self.query = qry
        processed = true
    end)

    repeat Wait(0) until processed == true

    if self.query[1] ~= nil then
        self.components = json.decode(self.query[1].weapon_components)
        self.information = json.decode(self.query[1].weapon_information)
    end

    local rTable = {}

    rTable.saveWeapon = function(time)
        local processed = false
        local success
        MySQL.Async.execute("UPDATE `registered_weapons` SET `weapon_information` = @info, `weapon_components` = @comp WHERE `weapon_serial` = @ser",
        {
        ['@info'] = json.encode(self.information),
        ['@comp'] = json.encode(self.components),
        ['@ser'] = self.serial}, function(saved)
            if saved > 0 then
                success = true
            else
                success = false
            end
            processed = true
        end)
        
        repeat Wait(0) until success == true

        if time ~= nil and time > 0 then
            SetTimeout(time, function() rTable.saveWeapon(60000) end)
        end

        return success
    end

    SetTimeout(60000, function() rTable.saveWeapon(60000) end)

    rTable.getSerial = function()
        return self.serial
    end

    rTable.getHash = function()
        return self.information.weaponHash 
    end

    rTable.getName = function()
        return self.information.weaponName
    end

    rTable.getLabel = function()
        return self.information.weaponLabel
    end

    rTable.getAmmo = function()
        return self.information.ammo
    end

    rTable.getRegisteredKeeper = function()
        local registeredKeeper = { ['name'] = self.information.owner, ['cid'] = self.information.cid, ['uid'] = self.information.uid }
        return registeredKeeper
    end

    rTable.getRegistryDate = function()
        local registryDate = { ['date'] = self.information.registryDate, ['time'] = self.information.registryTime }
        return registryDate
    end

    rTable.getEvidenceLogged = function()
        return self.information.evidence
    end

    rTable.numberOfComponents = function()
        return self.information.numberOfComponents
    end

    rTable.getComponents = function()
        return self.components
    end

    rTable.getAllInformation = function()
        return self.information
    end

    rTable.returnSQL = function()
        return self.query
    end

    rTable.returnRequirements = function()
        return self.information.mysql
    end

    -- Update Functions

    rTable.SetAmmoCount = function(num)
        if type(num) == "number" then
            self.information.ammo = num
            rTable.saveWeapon()
        end
    end

    rTable.AddAmmo = function(num)
        if type(num) == "number" then
            self.information.ammo = self.information.ammo + num
            rTable.saveWeapon()
        end
    end

    return rTable
end

function registerWeapon(weapon, serial, char, crafted)
    if weapon == nil then
        return
    end
    if serial == nil then
        return
    end
    local time = os.date("%H:%M:%S")
    local date = os.date("%Y-%m-%d")
    local weaponConfig = retreiveWeapon(weapon.name)
    local processed = false
    
    MySQL.Async.fetchAll("SELECT * FROM `items_database` WHERE `item_name` = @weapon", {['@weapon'] = weapon.name}, function(retreiveSQL)
        retrieveSQLInfo = retreiveSQL
        processed = true
    end)

    repeat Wait(0) until processed == true

    local self = {}
    self.serialnumber = serial
    self.components = {}
    for k, v in pairs(weaponConfig.components) do
        self.components[v.hash] = v 
    end
    self.information = {}
    self.information.weaponLabel = weaponConfig.label
    self.information.weaponName = weaponConfig.name
    self.information.numberOfComponents = #weaponConfig.components
    self.information.weaponHash = GetHashKey(weaponConfig.name)
    self.information.ammo = weapon.qty
    self.information.cid = char:Character().getCID()
    if crafted then
        self.information.owner = "Unregistered Owner"
    else
        self.information.owner = char:Character().getName()
    end
    self.information.uid = char:User().getUID()
    self.information.registryDate = date
    self.information.registryTime = time
    self.information.metaRecorded = { ['fired'] = false, ['evidenced'] = false}

    if retrieveSQLInfo[1] ~= nil then
        self.information.mysql = json.decode(retrieveSQLInfo[1].item_reqmeta)
    end

    self.information.evidence = {}

    if crafted then
        table.insert(self.information.evidence, {['date'] = date, ['time'] = time, ['note'] = "Firearm Crafted Illegally - Unregistered"})
    else
        table.insert(self.information.evidence, {['date'] = date, ['time'] = time, ['note'] = "Firearm Registered To "..char:Character().getCID().." ("..char:Character().getName()..")"})
    end
    
    MySQL.Async.insert("INSERT INTO `registered_weapons` (`weapon_serial`, `weapon_name`, `weapon_information`, `weapon_components`) VALUES (@serial, @name, @info, @comp)", {
        ['@serial'] = self.serialnumber,
        ['@name'] = weapon.name,
        ['@info'] = json.encode(self.information),
        ['@comp'] = json.encode(self.components)
    }, function(success)
        registeredWeapons[self.serialnumber] = loadWeapon(self.serialnumber)
    end)
end