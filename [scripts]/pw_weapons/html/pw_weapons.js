var currentHash = 0
var currentSerial = 0

window.addEventListener("message", function (event) {    
    if(event.data.status == "showhud") {
        currentHash = event.data.weapon.hash
        currentSerial = event.data.weapon.serial
        $(".main-container").css({"display":"block"})
        $("#weaponImage").html(`<img src="images/${event.data.weapon.name}.png" class="img-fluid">`);
        $("#weaponName").html(`<strong>${event.data.weapon.label}</strong>`);
        if(event.data.weapon.hash == 883325847) { 
            currentPercentage = (event.data.weapon.ammo / event.data.max * 100)
            $("#currentAmmo").html(Math.floor(currentPercentage) +'%');
            $('#ammoName').html('Capacity');
            $('#serialCol').css({"display":"none"})
        } else {
            $("#currentAmmo").html(event.data.weapon.ammo + '/' + event.data.max + ' max');
            $("#serialNumber").html(event.data.weapon.serial);
            $('#ammoName').html('Ammo');
            $('#serialCol').css({"display":"block"})
        }
    } else if (event.data.status == "updateAmmo") {
        $("#currentAmmo").html(event.data.ammo + '/' + event.data.max + ' max');
        if(currentHash == 883325847) { 
            currentPercentage = (event.data.ammo / event.data.max * 100)
            $("#currentAmmo").html(Math.floor(currentPercentage) +'%');
            $('#ammoName').html('Capacity');
        } else {
            $("#currentAmmo").html(event.data.ammo + '/' + event.data.max + ' max');
            $('#ammoName').html('Ammo');
        }
    } else if (event.data.status == "hidehud") {
        $(".main-container").css({"display":"none"})
        currentHash = 0
    } else if (event.data.status == "updatehud") {
        updateStats(event.data.stats)
    }

});

function updateStats(data) {
    if(data.name !== undefined) {
        $("#characterName").html(data.name);
    }
    if(data.cash !== undefined) {
        $("#characterCash").html(data.cash);
    }
    if(data.source !== undefined) {
        $("#characterSource").html(' / PayPal #<font class="text-dark">'+data.source+'</font>');
    }
    if(data.time !== undefined) {
        $("#time").html(data.time);
    }
    if (data.hunger !== undefined) {
        $("#hunger").css({"width":"" + data.hunger + "%"}).attr("aria-valuenow", data.hunger);
        $("#hunger").html('<small>Hunger is at '+Math.floor(data.hunger)+'%</small>');
    }
    if (data.thirst !== undefined) {
        $("#thirst").css({"width":"" + data.thirst + "%"}).attr("aria-valuenow", data.thirst);
        $("#thirst").html('<small>Thirst is at '+Math.floor(data.thirst)+'%</small>');
    }
    if (data.stamina !== undefined) {
        $("#stamina").css({"width":"" + data.stamina + "%"}).attr("aria-valuenow", data.stamina);
        $("#stamina").html('<small>Stamina is at '+Math.floor(data.stamina)+'%</small>');
    }
    if (data.stress !== undefined) {
        $("#stressRow").css({"display":"flex"});
        $("#stress").css({"width":"" + data.stress + "%"}).attr("aria-valuenow", data.stress);
        $("#stress").html('<small>Stress is at '+Math.floor(data.stress)+'%</small>');
    }
    if (data.drugs !== undefined) {
        if(data.drugs > 0) {
            $("#drugsRow").css({"display":"flex"});
            $("#drugs").css({"width":"" + data.drugs + "%"}).attr("aria-valuenow", data.drugs);
            $("#drugs").html('<small>Drugs is at '+Math.floor(data.drugs)+'%</small>');
        } else {
            $("#drugsRow").css({"display":"none"});
        }
    }
    if (data.health !== undefined) {
        if(data.health < 0) {
            data.health = 0
        }
        $("#health").css({"width":"" + data.health + "%"}).attr("aria-valuenow", data.health);
        $("#health").html('<small>Health is at '+Math.floor(data.health)+'%</small>');
    }
    if (data.armour !== undefined) {
        if(data.armour > 0) {
            $("#armourRow").css({"display":"flex"});
            $("#armour").css({"width":"" + data.armour + "%"}).attr("aria-valuenow", data.armour);
            $("#armour").html('<small>Armor is at '+Math.floor(data.armour)+'%</small>');
        } else {
            $("#armourRow").css({"display":"none"});
        }
    }

}