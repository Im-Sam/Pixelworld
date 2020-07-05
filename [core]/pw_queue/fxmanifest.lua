description 'PixelWorld Whitelist and Queueing'
name 'PixelWorld Whitelist and Queueing'
author 'PixelWorldRP'
version 'v1.0.0'

server_scripts {
    '@pw_mysql/lib/MySQL.lua',
    "server/sv_queue_config.lua",
    "connectqueue.lua",
    "shared/sh_queue.lua"
}

client_script "shared/sh_queue.lua"

dependencies {
    'pw_mysql',
}

fx_version 'adamant'
games { 'gta5' }
