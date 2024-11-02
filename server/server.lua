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
    if string.match(plateText, "OWR 1") then
        firstPlate = false
        print("Plate match 1")
    elseif string.match(plateText, "OWR 2") then
        secondPlate = false
        print("Plate match 2")
    elseif string.match(plateText, "OWR 3") then
        thirdPlate = false
        print("Plate match 3")
    elseif string.match(plateText, "OWR 4") then
        fourthPlate = false
        print("Plate match 4")
    elseif string.match(plateText, "OWR 5") then
        fifthPlate = false
        print("Plate match 5")
    elseif string.match(plateText, "OWR 6") then
        sixthPlate = false
        print("Plate match 6")
    elseif string.match(plateText, "OWR 7") then
        seventhPlate = false
        print("Plate match 7")
    elseif string.match(plateText, "OWR 8") then
        eightPlate = false
        print("Plate match 8")
    end
    carCount = tonumber(carCount) - 1 
end)

ESX.RegisterServerCallback('owr_systems:checkPlate', function (src, cb, CurrentPlate)
    if not firstPlate then
        firstPlate = true
        CurrentPlate = "OWR 1"
        cb(CurrentPlate)
    elseif not secondPlate then
        secondPlate = true
        CurrentPlate = "OWR 2"
        cb(CurrentPlate)
    elseif not thirdPlate then
        thirdPlate = true
        CurrentPlate = "OWR 3"
        cb(CurrentPlate)
    elseif not fourthPlate then
        fourthPlate = true
        CurrentPlate = "OWR 4"
        cb(CurrentPlate)
    elseif not fifthPlate then
        fifthPlate = true
        CurrentPlate = "OWR 5"
        cb(CurrentPlate)
    elseif not sixthPlate then
        sixthPlate = true
        CurrentPlate = "OWR 6"
        cb(CurrentPlate)
    elseif not seventhPlate then
        seventhPlate = true
        CurrentPlate = "OWR 7"
        cb(CurrentPlate)
    elseif not eightPlate then
        eightPlate = false
        CurrentPlate = "OWR 8"
        cb(CurrentPlate)
    end    
end)