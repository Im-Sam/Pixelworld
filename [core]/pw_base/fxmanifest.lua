description 'PixelWorld Base Framework'
name 'PixelWorld Base Framework'
author 'PixelWorldRP [Chris Rogers] - https://pixelworldrp.com'
version 'v1.0.0'

loadscreen_manual_shutdown 'yes'

server_scripts {
    '@pw_mysql/lib/MySQL.lua',
    'config/main.lua',
    'locale.lua',
    'locales/en.lua',
    'common/functions.lua',
    'server/functions.lua',
    'server/commands.lua',
    'server/character_selection.lua',
    'server/components.lua',
    'server/users.lua',
    'server/main.lua',
}

client_scripts {
    'config/main.lua',
    'locale.lua',
    'locales/en.lua',
    'locale.js',
    'common/functions.lua',
    'client/functions.lua',
    'client/character_creator_new.lua',
    'client/character_selection.lua',
    'client/main.lua',
}

ui_page 'nui/characterselection.html'
loadscreen 'nui/loading.html'

files {
    'locale.js',
    'nui/images/female.png',
    'nui/images/male.png',
    'nui/characterselection.html',
    'nui/css/main.css',
    'nui/css/selector.css',
    'nui/app.js',
    'nui/wrapper.js',
	'chat/chat.css',
	'nui/loading.html',
    'nui/css/style.css',
    'nui/images/logo.png',
    'nui/images/background.jpg',
    'nui/music/Loading.ogg',
}

dependencies {
    'pw_mysql'
}

fx_version 'adamant'
games { 'gta5' }