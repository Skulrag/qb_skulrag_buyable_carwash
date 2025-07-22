-- Resource Metadata
fx_version 'cerulean'
games { 'gta5' }
lua54 'on'

author 'Skulrag <skulragpro@gmail.com>'
description 'Skulrag\'s buyables carwash'
version '1.0.0'

shared_script {
    'config.lua',
    '@ox_lib/init.lua',
    '@qbx_core/modules/lib.lua',
	'@qb-core/shared/locale.lua',
	'locales/fr.lua' -- Change this to your prefered language
}

-- What to run
client_scripts {
	'client/main.lua'
}

server_scripts {
	'@oxmysql/lib/MySQL.lua',
	'server/main.lua'
}
