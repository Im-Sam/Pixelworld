description 'PixelWorld Prison'
name 'PixelWorld: pw_prison'
author 'PixelWorldRP'
version 'v1.0.0'

server_scripts {
    '@pw_mysql/lib/MySQL.lua',
    'config/main.lua',
    'functions/common.lua',
    'server/main.lua'
}

client_scripts {
    'config/main.lua',
    'functions/common.lua',
    'client/main.lua',
}


dependencies {
    'pw_mysql',
    'pw_base'
}

fx_version 'adamant'
games {'gta5'}