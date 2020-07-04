window.addEventListener("message", function (event) {   
    if (event.data.action == "show") {
        $('#showNotification').css({"display":"block"});
    }
    else if(event.data.action == "hide") {
        $('#showNotification').css({"display":"none"});
    }
    else if(event.data.action == "update") {
        $('#indicator').css({"width":"" + event.data.amount + "%"});
        $('#indicator').html(event.data.amount +'%');
        if(event.data.amount > 85) {
            $('#indicator').removeClass('bg-success');
            $('#indicator').removeClass('bg-warning');
            $('#indicator').addClass('bg-danger');
        } else if(event.data.amount > 50) {
            $('#indicator').removeClass('bg-success');
            $('#indicator').removeClass('bg-danger');
            $('#indicator').addClass('bg-warning');
        } else {
            $('#indicator').removeClass('bg-danger');
            $('#indicator').removeClass('bg-warning');
            $('#indicator').addClass('bg-success');
        }
    }
});