$( function() {
    $('.carousel').carousel({
        interval: 15000
      })
    // Dynamic Stuff
    $(document).on('click','[data-act=selectCharacter]',function(){
      var cid = $(this).attr("data-character");
        $.post('http://pw_base/selectCharacter', JSON.stringify({ 
            cid: cid,
        }));
    });

    $(document).on('click','[data-act=selectnewCharacter]',function(){
          $.post('http://pw_base/newCharacter', JSON.stringify({}));
    });

    $(document).on('click','[data-action=spawnCharacter]',function(){
        var sid = $(this).attr("data-spawnid");
        $.post('http://pw_base/spawnCharacter', JSON.stringify({ 
            sid: sid,
        }));
    });

    $(document).on('click','[data-act=deleteCharacter]',function(){
        var character_id = $(this).attr("data-character");
        var slot = $(this).attr("data-slot");
        var character_name = $(this).attr("data-name");
        
        $("#confirmDeletion").attr('data-cid', character_id)
        $("#confirmDeletion").attr('data-slot', slot)
        $("#delCharName").html(character_name);
        $("#delCitizenID").html(character_id);
        $("#characterSelector").css({"display":"none"});
        $("#characterDeleter").css({"display":"block"});
      });

    $(document).on('click','[data-act=createCharacter]',function(){
        $("#lastNameText").val('');
        $("#dobText").val('');
        $("#genderSelect").val('');
        $("#bioText").val('');
        $('#charHeight').val('');
        $('#welcomeMessage').css({"display":"none"});
        $('#welcomeMessage2').css({"display":"none"});
        var slot = $(this).attr("data-slot");
        $("#createCharBtn").attr("data-slot", slot);
        $("#characterSelector").css({"display":"none"});
        $("#characterCreator").css({"display":"block"});
    });

    $(document).on('click','[data-act=confirmDeletion]',function(){
        var cid = $(this).attr("data-cid");
        var slot = $(this).attr("data-slot");
        $.post('http://pw_base/deleteCharacter', JSON.stringify({ 
            cid: cid,
            slot: slot
        }));
    });
    
    $("#cancelCharBtn, #cancelDeletion, #spawnBack").click(function () {
        $('#welcomeMessage').css({"display":"block"});
        $('#welcomeMessage2').css({"display":"block"});
        $("#characterDeleter").css({"display":"none"});
        $("#characterCreator").css({"display":"none"});
        $("#spawnLoader").css({"display":"none"});
        $("#delCharName").html('');
        $("#spawnLoc").html('');
        $("#delCitizenID").html('');
        $.post('http://pw_base/refreshCharacter', JSON.stringify({ })); 
    });

    $("#quitGame").click(function () {
        PixelWorld.CloseUI();
        $.post('http://pw_base/exitGame', JSON.stringify({ })); 
    });
    
    $(document).on('click','#createCharBtn',function(){
        var slot = $(this).attr("data-slot");
        var firstname = $("#firstNameText").val();
        var lastname = $("#lastNameText").val();
        var dob = $("#dobText").val();
        var gender = $("#genderSelect").val();
        var bio = $("#bioText").val();
        var height = $('#charHeight').val();
        error = false

        if(slot == undefined || slot == 0 || slot == '') {
            // Error Slot
            $('#charCreatorError').css({"display":"block"});
            $("#charCreatorError").html('There has been an error selecting the correct Character Slot');
            error = true
        } 
        
        if(firstname == undefined || firstname == '') {
            $("#firstNameText").addClass('is-invalid');
            if(error != true) {
                error = true
                $('#charCreatorError').css({"display":"block"});
                $("#charCreatorError").html('You need to specify a first name.');
                $('#collapseOne').collapse({ show: true })
            }
        } else {
            $("#firstNameText").removeClass('is-invalid');
            $("#firstNameText").addClass('is-valid');
        }
        
        if(lastname == undefined || lastname == '') {
            $("#lastNameText").addClass('is-invalid');
            if(error != true) {
                error = true
                $('#charCreatorError').css({"display":"block"});
                $("#charCreatorError").html('You need to specify a last name');
                $('#collapseOne').collapse({ show: true })
            }
        } else {
            $("#lastNameText").removeClass('is-invalid');
            $("#lastNameText").addClass('is-valid');
        }
        
        if(dob == undefined || dob == '') {
            $("#dobText").addClass('is-invalid');
            if(error != true) {
                error = true
                $('#charCreatorError').css({"display":"block"});
                $("#charCreatorError").html('You need to specify a date of birth');
                $('#collapseTwo').collapse({ show: true })
            }
        } else {
            $("#dobText").removeClass('is-invalid');
            $("#dobText").addClass('is-valid');
        }

        if(height == undefined || height == '' || height > 220 || height < 130) {
            $("#charHeight").addClass('is-invalid');
            if(error != true) {
                $('#charCreatorError').css({"display":"block"});
                $("#charCreatorError").html('You need to specify a height which is above 130cm and below 220cm');
                $('#collapseTwo').collapse({ show: true })
            }
        } else {
            $("#charHeight").removeClass('is-invalid');
            $("#charHeight").addClass('is-valid');
        }
        
        if(gender == undefined || gender == '') {
            $("#genderSelect").addClass('is-invalid');
            if(error != true) {
                error = true
                $('#charCreatorError').css({"display":"block"});
                $("#charCreatorError").html('You need to select a character gender');
                $('#collapseTwo').collapse({ show: true })
            }
        } else {
            $("#genderSelect").removeClass('is-invalid');
            $("#genderSelect").addClass('is-valid');
        }
        
        if(bio == undefined || bio == '') {
            $("#bioText").addClass('is-invalid');
            if(error != true) {
                error = true
                $('#charCreatorError').css({"display":"block"});
                $("#charCreatorError").html('You must state a character biography/backstory');
                $('#collapseThree').collapse({ show: true })
            }
        } else {
            var lengthofBio = $("#bioText").val().replace(/ /g,'').length;
            if (lengthofBio < 50) {
                $("#bioText").addClass('is-invalid');
                if(error != true) {
                    error = true
                    $('#charCreatorError').css({"display":"block"});
                    $("#charCreatorError").html('Your biography/backstory must be more than 50 characters.');
                    $('#collapseThree').collapse({ show: true })
                }
            } else {
                $("#bioText").removeClass('is-invalid');
                $("#bioText").addClass('is-valid');
            }
        }       
        if(error === false) {
            $('#charCreatorError').css({"display":"none"});
            $("#charCreatorError").html('');
            $("#bioText").removeClass('is-invalid').removeClass('is-valid');;
            $("#genderSelect").removeClass('is-invalid').removeClass('is-valid');
            $("#charHeight").removeClass('is-invalid').removeClass('is-valid');
            $("#dobText").removeClass('is-invalid').removeClass('is-valid');
            $("#lastNameText").removeClass('is-invalid').removeClass('is-valid');
            $("#firstNameText").removeClass('is-invalid').removeClass('is-valid');
            $('#collapseOne').collapse({ toggle: true })
                $.post('http://pw_base/createCharacter', JSON.stringify({
                    slot: slot,
                    firstname: firstname,
                    lastname: lastname,
                    dob: dob,
                    gender: gender,
                    bio: bio, 
                    height: height
                 })); 
        }
    });

});

(() => {
    PixelWorld = {};

    PixelWorld.VehicleLoaderStart = function() {
        $("#quitButton").css({"display":"none"});
        $("#characterSelector").css({"display":"none"});
        $("#vehicleLoader").css({"display":"block"});
    };

    PixelWorld.VehicleLoaderEnd = function() {
        $("#vehicleLoader").css({"display":"none"});
        $("#quitButton").css({"display":"block"});
        $("#characterSelector").css({"display":"block"});
    };

    PixelWorld.CurrentVehicle = function(name) {
        $("#vehicleName").html(name);
    };

    PixelWorld.BlankUI = function() {
        $("#characterDeleter").css({"display":"none"});
        $("#delCharName").html('');
        $("#delCitizenID").html('');
        $("#messageBox").removeClass( "alert-danger" );
        $("#messageBox").addClass( "alert-dark" );
        $("#messageBox").html('Please be sure to keep up to date with the latest information by joining our discord server, and our forums/website.');
        $("#firstNameText").val('');
        $("#spawnLoc").html('');
        $("#spawnLoader").css({"display":"none"});
        $("#lastNameText").val('');
        $("#dobText").val('');
        $("#genderSelect").val('');
        $("#bioText").val('');
        $('#charHeight').val('');
        $("#characterLoader").css({"display":"block"});
        $("#characterSelector").css({"display":"none"});
        $("#characterCreator").css({"display":"none"});
        $("#showUI").css({"display":"block"});
    };

    PixelWorld.ShowUI = function(data) {
            for(i = 0; i < 10; i++) {
                $('[data-charid=' + (i+1) + ']').html('');
                $('[data-charbtn=' + (i+1) + ']').html('Slot '+ (i+1) +' Available');
                $('[data-charid=' + (i+1) + ']').html('<div class="card text-center mx-auto" style="max-width:800px; min-height:250px;"><div class="card-header">Slot ' + (i+1) + ' Avaliable</div><div class="card-body text-left"><div class="container-fluid"><div class="row"><div class="col-12 p-2 text-center"><i class="fad fa-user-plus fa-4x text-info"></i><br><button class="btn btn-success mt-3" data-act="createCharacter" style="min-width:400px;" data-slot="' + (i+1) + '">Create Character</button></div></div></div></div></div>');
            }

            $('#welcomeMessage').css({"display":"block"});
            $('#welcomeMessage2').css({"display":"block"});
            $("#characterDeleter").css({"display":"none"});
            $("#delCharName").html('');
            $("#delCitizenID").html('');
            $("#spawnLoc").html('');
            $("#spawnLoader").css({"display":"none"});
            $("#messageBox").removeClass( "alert-danger" );
            $("#messageBox").addClass( "alert-dark" );
            $("#messageBox").html('Please be sure to keep up to date with the latest information by joining our discord server, and our forums/website.');
            $("#firstNameText").val('');
            $("#lastNameText").val('');
            $("#dobText").val('');
            $("#genderSelect").val('');
            $("#bioText").val('');

            $("#characterLoader").css({"display":"none"});
            $("#characterSelector").css({"display":"block"});
            $("#characterCreator").css({"display":"none"});
            $("#showUI").css({"display":"block"});
            $("body").css("background-image", "none");
            
            if(data.characters !== null) {
                $.each(data.characters, function (index, char) {
                        if (char.cid !== 0) {
                            if(char.sex == 1) {
                                char.gender_human = "Male"
                            } else {
                                char.gender_human = "Female"
                            }
                            if (char.newCharacter == 1) {
                                spawn = "Character";
                            } else {
                                spawn = "Character"
                            }

                            if(char.photo == undefined) {
                                if(char.sex == 1) {
                                    char.photo = 'images/male.png'
                                } else {
                                    char.photo = 'images/female.png'
                                }
                            }
                            $('[data-charid=' + char.slot + ']').html('');
                            $('[data-charbtn=' + char.slot + ']').html(char.firstname + ' ' + char.lastname);
                            $('[data-charid=' + char.slot + ']').html('<div class="card text-center mx-auto" style="max-width:700px; min-height:300px;"><div class="card-header">' + char.firstname + ' ' + char.lastname + '</div><div class="card-body text-left"><div class="container-fluid"><div class="row"><div class="col-6 text-center my-auto"><img src="' + char.photo + '" class="img-fluid img-thumbnail" style="max-height:150px;"></div><div class="col-6"><p class="card-text"><small>Date of Birth: <strong>' + char.dateofbirth + '</strong><br>Bank Balance: <strong>$' + char.bank + '</strong><br>Cash Balance: <strong>$' + char.cash + '</strong><br>Email: <strong>' + char.email + '</strong><br>Twitter: <strong>' + char.twitter + '</strong></small></p></div></div><div class="row mt-2"><div class="col-12 text-center"><a href="#" class="btn btn-success btn-sm btn-block m-1" data-act="select' + spawn + '" data-character="' + char.cid + '">Select Character</a> <a href="#" class="btn btn-danger btn-block btn-sm m-1" data-act="deleteCharacter" data-character="' + char.cid + '" data-name="' + char.firstname + ' ' + char.lastname + '" data-slot="' + char.slot + '">Delete</a></div></div></div></div></div>');
                        }
                });
            }
    };

    PixelWorld.BlankSlot = function(data) {
        if (data.slot !== null) {
            $('[data-charbtn=' + data.slot + ']').html('Slot ' + data.slot + ' Available');
            $('[data-charid=' + data.slot + ']').html('');
            $('[data-charid=' + data.slot + ']').html('<div class="card text-center mx-auto" style="max-width:700px; min-height:300px;"><div class="card-header">Slot ' + data.slot + ' Avaliable</div><div class="card-body text-left"><div class="container-fluid"><div class="row"><div class="col-12 p-2 text-center"><i class="fad fa-user-plus fa-4x text-info"></i><br><button class="btn btn-success mt-3" data-act="createCharacter" style="min-width:400px;" data-slot="1">Create Character</button></div></div></div></div></div>');
        }
    };

    PixelWorld.SelectSpawn = function(data) {
        $('#spawnLocationsFiller').html('');
        $.each(data.spawns, function (index, spawn) {
            $('#spawnLocationsFiller').append("<button class='btn m-1 btn-dark' style='min-width:250px; max-width:250px;' data-action='spawnCharacter' data-spawnid='" + (index + 1) +"'  style='min-width:200px;'>" + spawn.name + "</button>");
        });
        $("#characterSelector").css({"display":"none"});
        $('#welcomeMessage').css({"display":"none"});
        $('#welcomeMessage2').css({"display":"none"});
        $("#spawnLoader").css({"display":"block"});
    };


    PixelWorld.CloseUI = function() {
        $("#showUI").fadeOut(1000);
        setTimeout(function() {
            $("#spawnLoader").css({"display":"none"});
            $("#characterDeleter").css({"display":"none"});
            $("#spawnLoc").html('');
            $("#delCharName").html('');
            $("#delCitizenID").html('');
            $("#firstNameText").val('');
            $("#lastNameText").val('');
            $("#dobText").val('');
            $("#genderSelect").val('');
            $("#bioText").val('');
        }, 1001);
    };

    PixelWorld.CloseBackground = function(){
        //$('#backgroundImage').fadeOut(1000);
    };

    window.onload = function(e) {
        window.addEventListener('message', function(event) {
            switch(event.data.action) {
                case 'closebackground':
                    PixelWorld.CloseBackground();
                    break;
                case 'startvehicles':
                    PixelWorld.VehicleLoaderStart();
                    break;
                case 'endvehicles':
                    PixelWorld.VehicleLoaderEnd();
                    break;
                case 'updatevehicle':
                    PixelWorld.CurrentVehicle(event.data.vehiclename)
                    break;
                case 'selectSpawn':
                    PixelWorld.SelectSpawn(event.data);
                    break;
                case 'showlogintime':
                    $("#lastLoginTime").html(event.data.time);
                    break;
                case 'blankui':
                    PixelWorld.BlankUI();
                    break;
                case 'openui':
                    PixelWorld.ShowUI(event.data);
                    break;
                case 'blanker':
                        PixelWorld.BlankSlot(event.data);
                    break;
                case 'senderror':
                    PixelWorld.ShowError(event.data.message);
                    break;
                case 'closeui':
                    PixelWorld.CloseUI();
                    break;
            }
        })
    }

})();