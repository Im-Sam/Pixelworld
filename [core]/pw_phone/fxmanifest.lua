
client_scripts {
    "client/notifications.lua",
    "client/main.lua",
    "client/nui.lua"
}


server_scripts {
    "@pw_mysql/lib/MySQL.lua",
    "server/wrapper/simcard.lua",
    "server/main.lua"
}

dependencies {
    'pw_voip',
}

ui_page 'nui/index.html'

files {
    'nui/images/phone.png',
    'nui/images/radio.png',
    'nui/index.html',
    'nui/style.css',
    'nui/pw_phone.js',
    'nui/sound/success.ogg',
    'nui/sound/error.ogg'
}

fx_version 'adamant'
games {'gta5'}