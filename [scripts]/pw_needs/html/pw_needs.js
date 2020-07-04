window.addEventListener("message", function (event) {   
    if (event.data.action == "showBar") {
        $("#topHud").animate({"top":"0px"}, "slow")
        setTimeout(function() {
            $("#topHud").animate({"top":"-120px"}, "slow")
        }, 5000)
    } 

    else if (event.data.action == "updatePlayer") {
        if(event.data.name !== undefined && event.data.name !== null) {
            $('#playerName').html(event.data.name)
        }
        if(event.data.id !== undefined && event.data.id !== null) {
            $('#playerId').html(event.data.id)
        }
        if(event.data.cash !== undefined && event.data.cash !== null) {
            $('#playerCash').html('$ ' + event.data.cash)
        }
    }

    else if (event.data.action == "updateValues") {
        if(event.data.hunger !== undefined && event.data.hunger !== null) {
            $('#hungerBar').css({"width":event.data.hunger +"%"});
        }
        if(event.data.thirst !== undefined && event.data.thirst !== null) {
            $('#thirstBar').css({"width":event.data.thirst +"%"});
        }        
        if(event.data.stress !== undefined && event.data.stress !== null) {
            $('#stressBar').css({"width":event.data.stress +"%"});
        }
        if(event.data.drugs !== undefined && event.data.drugs !== null) {
            $('#drugBar').css({"width":event.data.drugs +"%"});
        }
        if(event.data.health !== undefined && event.data.health !== null) {
            $('#healthBar').css({"width":event.data.health +"%"});
        }
        if(event.data.stamina !== undefined && event.data.stamina !== null) {
            $('#staminaBar').css({"width":event.data.stamina +"%"});
        }
        if(event.data.armour !== undefined && event.data.armour !== null) {
            $('#armourBar').css({"width":event.data.armour +"%"});
        }
    }
});

$(document).ready(function(){
      $("#topHud").stop().animate({"margin-top":"120px"}, "slow")
      $("#topHud").stop().animate({"margin-top":"0"}, "slow")
  });
