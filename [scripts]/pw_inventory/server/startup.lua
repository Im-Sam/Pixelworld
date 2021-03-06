InvSlots = {--[[
	['misc'] = { slots = 10, label = 'Unknown' },
	['player'] = { slots = 40, label = 'Player' },
	['drop'] = { slots = 100, label = 'Drop' },
	['container'] = { slots = 100, label = 'Container' },
	['car-int'] = { slots = 5, label = 'Glove Box' },
	['car-ext'] = { slots = 50, label = 'Trunk' },
	['prop-1'] = { slots = 50, label = 'Property Stash' },
	['prop-2'] = { slots = 65, label = 'Property Stash' },
	['prop-3'] = { slots = 80, label = 'Property Stash' },
	['prop-4'] = { slots = 100, label = 'Property Stash' },
	['biz-1'] = { slots = 100, label = 'Property Stash' },
	['biz-2'] = { slots = 125, label = 'Property Stash' },
	['biz-3'] = { slots = 150, label = 'Property Stash' },
	['biz-4'] = { slots = 200, label = 'Property Stash' },
	['pd-evidence'] = { slots = 1000, label = 'Evidence Locker' },
	['pd-trash'] = { slots = 1000, label = 'Trash Locker' },
]]}

MySQL.ready(function ()
    MySQL.Async.execute('DELETE FROM inventory_items WHERE count <= 0', {}, function() end)
end)