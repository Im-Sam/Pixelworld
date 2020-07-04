Config = {}


Config.MaxValues = { ['hunger'] = 1000000, ['thirst'] = 1000000, ['drugs'] = 1000000, ['stress'] = 1000000 }
Config.ReductionValues = { ['hunger'] = 2850, ['thirst'] = 1750, ['drugs'] = 5000, ['stress'] = 2500 }

-- Update Times
Config.ServerUpdateTime = 60 -- In Seconds
Config.ClientUpdateTime = 10 -- In Seconds

Config.Blips = {
    ['type'] = 197,
    ['scale'] = 1.0,
    ['color'] = 27
}

Config.ExcerciseLocations = {
    [1]  = { ['x'] = -1208.64, ['y'] = -1574.12, ['z'] = 4.61, ['h'] = 306.45 }
}

Config.ExcercisePoints = {
    [1] = { ['x'] = -1231.2, ['y'] = -1550.97, ['z'] = 4.55, ['h'] = 274.83, ['label'] = "Yoga", ['icon'] = "fad fa-running", ['msg'] = "Press [<span class='text-success'> E </span>] to do Yoga", ['action'] = "yoga", ['reductionAmount'] = 15000, ['radius'] = 5.0 },
    [2] = { ['x'] = -1219.56, ['y'] = -1544.02, ['z'] = 4.71, ['h'] = 117.84, ['label'] = "Yoga", ['icon'] = "fad fa-running", ['msg'] = "Press [<span class='text-success'> E </span>] to do Yoga", ['action'] = "yoga", ['reductionAmount'] = 15000, ['radius'] = 5.0 },
    [3] = { ['x'] = -1213.13, ['y'] = -1551.52, ['z'] = 4.37, ['h'] = 221.44, ['label'] = "Push-ups", ['icon'] = "fad fa-dumbbell", ['msg'] = "Press [<span class='text-success'> E </span>] to do Push-ups", ['action'] = "pushup", ['reductionAmount'] = 18500, ['radius'] = 5.0 }, -- pushups
    [4] = { ['x'] = -1185.84, ['y'] = -1593.63, ['z'] = 4.56, ['h'] = 261.31, ['label'] = "Sit-ups", ['icon'] = "fad fa-dumbbell", ['msg'] = "Press [<span class='text-success'> E </span>] to do Sit-ups", ['action'] = "situp", ['reductionAmount'] = 17000, ['radius'] = 5.0 }, -- situps
    [5] = { ['x'] = -1204.76, ['y'] = -1564.25, ['z'] = 4.61, ['h'] = 34.7, ['label'] = "Pull-ups", ['icon'] = "fad fa-dumbbell", ['msg'] = "Press [<span class='text-success'> E </span>] to do Pull-ups", ['action'] = "pullup", ['reductionAmount'] = 17000, ['radius'] = 1.0 },
    [6] = { ['x'] = -1199.86, ['y'] = -1571.26, ['z'] = 4.61, ['h'] = 33.74, ['label'] = "Pull-ups", ['icon'] = "fad fa-dumbbell", ['msg'] = "Press [<span class='text-success'> E </span>] to do Pull-ups", ['action'] = "pullup", ['reductionAmount'] = 17000, ['radius'] = 1.0 },
    [7] = { ['x'] = -1202.83, ['y'] = -1565.28, ['z'] = 4.61, ['h'] = 37.78, ['label'] = "Weights", ['icon'] = "fad fa-dumbbell", ['msg'] = "Press [<span class='text-success'> E </span>] to do Weights", ['action'] = "arms", ['reductionAmount'] = 25000, ['radius'] = 1.0 },
    [8] = { ['x'] = -1210.59, ['y'] = -1561.31, ['z'] = 4.61, ['h'] = 259.58, ['label'] = "Weights", ['icon'] = "fad fa-dumbbell", ['msg'] = "Press [<span class='text-success'> E </span>] to do Weights", ['action'] = "arms", ['reductionAmount'] = 25000, ['radius'] = 1.0 },
    [9] = { ['x'] = -1198.96, ['y'] = -1574.59, ['z'] = 4.61, ['h'] = 38.78, ['label'] = "Weights", ['icon'] = "fad fa-dumbbell", ['msg'] = "Press [<span class='text-success'> E </span>] to do Weights", ['action'] = "arms", ['reductionAmount'] = 25000, ['radius'] = 1.0 },
    [10] = { ['x'] = -1196.78, ['y'] = -1573.22, ['z'] = 4.61, ['h'] = 37.66, ['label'] = "Weights", ['icon'] = "fad fa-dumbbell", ['msg'] = "Press [<span class='text-success'> E </span>] to do Weights", ['action'] = "arms", ['reductionAmount'] = 25000, ['radius'] = 1.0 }
}

