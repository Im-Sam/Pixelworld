window.addEventListener("message", function (event) {    
    if(event.data.status == "showhud") {
        $(".fixed-bottom").css({"display":"block"});    
    } else if (event.data.status == "hidehud") {
        $(".fixed-bottom").css({"display":"none"});
    } else if (event.data.status == "minimap") {
        $(".bottom-stuff").css({"left":"300px"});
    } else if (event.data.status == "nominimap") {
        $(".bottom-stuff").css({"left":"20px"});
    } else if (event.data.status == "updateClock") {
        $('#timeBlock').html(event.data.time);
    } else if (event.data.status == "updateStreet") {
        $('#streetBlock').html(event.data.street);
        $('#direction').html(event.data.direction);
    } else if (event.data.status == "showVehicle") {
        setTimeout(function() {
            $("#vehicleInfo").css({"display":"flex"});
        }, 500)
    } else if (event.data.status == "hideVehicle") {
        $("#vehicleInfo").css({"display":"none"});
    } else if (event.data.status == "updateVehicle") {
        
        if (event.data.fuel >= 80) {
            $("#vehicleFuel").removeClass('text-white').removeClass('text-warning').removeClass('text-danger').addClass('text-success');
        } else if (event.data.fuel >= 20 && event.data.fuel <= 79) {
            $("#vehicleFuel").removeClass('text-white').removeClass('text-danger').removeClass('text-success').addClass('text-warning');
        } else if (event.data.fuel < 20) {
            $("#vehicleFuel").removeClass('text-white').removeClass('text-warning').removeClass('text-success').addClass('text-danger');
        }

        if (event.data.lights) {
            var lightStatus = event.data.lights
            if (lightStatus == 0) {
                lighthtml = '<i class="fad fa-lightbulb-slash"></i>';
            }
            else if (lightStatus == 1) {
                lighthtml = '<i class="fad fa-lightbulb"></i>';
            }
            else if (lightStatus == 2) {
                lighthtml = '<i class="fad fa-lightbulb-on"></i>';
            }
        } else {
            lighthtml = '<i class="fad fa-lightbulb-slash"></i>';
        }
        $("#vehLights").html(lighthtml)

        if (event.data.engineStatus) {
            $("#engineState").addClass('text-success').removeClass('text-danger').removeClass('text-light');
        } else {
            $("#engineState").addClass('text-danger').removeClass('text-success').removeClass('text-light');
        }

        if (event.data.seatbelt) {
            $("#seatBelt").removeClass('text-danger').addClass('text-success').html('BUCKLED');
        } else {
            $("#seatBelt").addClass('text-danger').removeClass('text-success').html('UNBUCKLED');
        }

        $("#vehicleSpeed").html(event.data.speed);

        if(event.data.showfuel !== undefined) {
            if(event.data.showfuel == 3) {
                if(event.data.fuel !== undefined) {
                    $("#vehicleFuel").html(event.data.fuel+'%');
                    $('#fuelIcon').html('<i class="fad fa-charging-station fa-fw"></i>');
                    $('#fuelIcon').css({"display":"flex-inline"});
                    $('#vehicleFuel').css({"display":"flex-inline"});
                }
            } else if(event.data.showfuel == 2) {
                if(event.data.fuel !== undefined) {
                    $("#vehicleFuel").html(event.data.fuel+'%');
                    $('#fuelIcon').html('<i class="fad fa-gas-pump fa-fw"></i>');
                    $('#fuelIcon').css({"display":"flex-inline"});
                    $('#vehicleFuel').css({"display":"flex-inline"});
                }
            } else {
                $('#fuelIcon').css({"display":"none"});
                $('#vehicleFuel').css({"display":"none"});
                $('#fuelIcon').html('');
                $("#vehicleFuel").html('');
            }
        }
    }
    
});