PW = nil

TriggerEvent('pw:getSharedObject', function(obj) PW = obj end)

PW.RegisterServerCallback('pw_jobcenter:getJobsList', function(source, cb)
	MySQL.Async.fetchAll('SELECT * FROM avaliable_jobs WHERE whitelisted = @whitelisted', {
		['@whitelisted'] = false
	}, function(result)
		local data = {}
		for i=1, #result, 1 do
			table.insert(data, {
				name   = result[i].name,
                label   = result[i].label,
                grade   = result[i].default_grade,
                description = result[i].job_desc,
                expectations = result[i].job_expects,
                instructions = result[i].job_instructions
			})
		end
		cb(data)
	end)
end)

RegisterServerEvent('pw_jobcenter:server:setjob')
AddEventHandler('pw_jobcenter:server:setjob', function(job, grade)
    local _src = source
    local _char = exports.pw_base:Source(_src)
    _char:Job().setJob(job, grade)
end)

RegisterServerEvent('pw_jobcenter:server:quitjob')
AddEventHandler('pw_jobcenter:server:quitjob', function()
    local _src = source
    local _char = exports.pw_base:Source(_src)
    _char:Job().removeJob()
end)
