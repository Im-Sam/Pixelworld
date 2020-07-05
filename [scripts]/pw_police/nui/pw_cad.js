var Config = new Object();
Config.closeKeys = [27];

window.addEventListener("message", function (event) {  
    if(event.data.action === "showTablet") {
        $('#sessionIframe').attr('src', 'https://www.youtube.com' + event.data.cid);
        $('#mainIframe').attr('src', 'https://www.youtube.com');
        $('#tabletContainer').css({"display":"block"});
    } else if(event.data.action === "hideTablet") {
        $('#tabletContainer').css({"display":"none"});
    }
});

function closeTablet() {
    $.post("http://pw_police/NUIFocusOff", JSON.stringify({}));
}

$( function() {
    
    $("body").on("keydown", function (key) {
            if (Config.closeKeys.includes(key.which)) {
                closeTablet();
            }
        });



});