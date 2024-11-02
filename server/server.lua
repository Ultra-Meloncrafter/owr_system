ESX = exports['es_extended']:getSharedObject()

local firstPlate = false
local secondPlate = false
local thirdPlate = false
local fourthPlate = false
local fifthPlate = false
local sixthPlate = false
local seventhPlate = false
local eightPlate = false
local carCount = "0"

local OldPlate = ""

RegisterServerEvent ('owr_systems:addTime')
AddEventHandler('owr_systems:addTime',function(vehPlate, lapTimerClient)
    local plate = vehPlate
    local lapTimer = lapTimerClient
    MySQL.Async.fetchAll('SELECT * FROM owr_laptime', {},
    function(result)
        local registered = false

        for i=1, #result, 1 do
            if result[i].carplate == plate then
                registered = true
            end
        end

        if not registered then 
            MySQL.Async.execute('INSERT into owr_laptime (carplate, time, fastestLap) VALUES (@plate, @lapTimer, @fastestLap)', {['@plate'] = plate, ['@lapTimer'] = lapTimer, ['@fastestLap'] = lapTimer})
        elseif registered then
            for i=1, #result, 1 do
                local lapTimerInSeconds = timeToSeconds(lapTimer)
                local comparingTimeInSeconds = timeToSeconds(result[i].fastestLap)
                print(lapTimer)
                print(comparingTime)
                if comparingTimeInSeconds > lapTimerInSeconds or comparingTimeInSeconds == 0.00 then
                    MySQL.Async.execute('UPDATE owr_laptime SET `fastestLap` = @fastestLap WHERE carplate = @plate', {['@fastestLap'] = lapTimer, ['@plate'] = plate})
                    MySQL.Async.execute('UPDATE owr_laptime SET `time` = @lapTimer WHERE carplate = @plate', {['@lapTimer'] = lapTimer, ['@plate'] = plate})
                else
                    MySQL.Async.execute('UPDATE owr_laptime SET `time` = @lapTimer WHERE carplate = @plate', {['@lapTimer'] = lapTimer, ['@plate'] = plate})
                end
            end
        end
    end)
end)

function timeToSeconds(timeStr)
    local minutes, seconds = string.match(timeStr, "(%d+).(%d+)")
    return tonumber(minutes) * 60 + tonumber(seconds)
end

ESX.RegisterServerCallback('owr_systems:carCount', function(src, cb, Count)
    cb(carCount)
    if tonumber(carCount) < 8 then
        carCount = tonumber(carCount) + 1
        carCount = tostring(carCount)
    end
end)



RegisterServerEvent('owr_systems:removePlate')
AddEventHandler('owr_systems:removePlate', function(plateText)
    local plates = {
        "OWR 1", "OWR 2", "OWR 3", "OWR 4",
        "OWR 5", "OWR 6", "OWR 7", "OWR 8"
    }
    for i, plate in ipairs(plates) do
        if string.match(plateText, plate) then
            _G["plate" .. i] = false
            break
        end
    end
    carCount = tonumber(carCount) - 1 
end)


ESX.RegisterServerCallback('owr_systems:checkPlate', function(src, cb, CurrentPlate)
    local plates = {
        firstPlate, secondPlate, thirdPlate, fourthPlate,
        fifthPlate, sixthPlate, seventhPlate, eightPlate
    }

    for i, plate in ipairs(plates) do
        if not plate then
            _G["plate" .. i] = true
            CurrentPlate = "OWR " .. i
            cb(CurrentPlate)
            return
        end
    end
end)
