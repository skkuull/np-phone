-- GIFT FROM NoPain, https://r1c.pw

ActiveCalls = {}

function initiatePhoneCall(pSourceId, pCallNumber, pTargetNumber) --Add variable call fromPhoneType this should come from the ui 1 = burner , 0 = phone
if not isNumberAbleToEstablishCall(pCallNumber) or not isNumberAbleToEstablishCall(pTargetNumber) then
    TriggerClientEvent("phone:call:inactive", pSourceId, pTargetNumber)
    return false
end

-- GIFT FROM NoPain, https://r1c.pw

--workaround to determine callfromPhoneType until UI properly sends the data
local callfromPhoneType
local user = exports["np-base"]:getModule("Player"):GetUser(pSourceId)
if user:getCurrentCharacter() then 
    if pCallNumber == tostring(user:getCurrentCharacter().phone_number) then
        callfromPhoneType = 0 
    else
        callfromPhoneType = 1 
    end
end

-- GIFT FROM NoPain, https://r1c.pw

local found, targeId, calltoPhonetype = getServerIdByPhoneNumber(pTargetNumber)
if found then
    local call = {}
    -- call state [ completed = 0, establishing = 1, active = 2 ]
    call.state = 1
    --call participants
    call.caller = { id = pSourceId, number = pCallNumber }
    call.target = { id = targetId, number = pTargetNumber }
    --promises for handling connection and disconnection
    call.establish = promise:new()
    call.completed = promise:new()
    local callId = registerCallData(call)
    --callfromPhoneType describes the tpye of phone bein used to call 1 = buner , 0 =phone
    --callfromPhoneType describes the tpye of phone being call 1 = buner , 0 =phone
    if callfromPhoneType == 0 then
        if callfromPhoneType == 1 then
            TriggerClientEvent("burner:call:receive", call.target.id, call.caller.number, callId)
            TriggerClientEvent("burner:call:dialing", call.caller.id, call.target.number, callId)
        else
            TriggerClientEvent("burner:call:receive", call.target.id, call.caller.number, callId)
            TriggerClientEvent("burner:call:dialing", call.caller.id, call.target.number, callId)
        end
    elseif callfromPhoneType == 1 then
        if callfromPhoneType == 1 then
            TriggerClientEvent("burner:call:receive", call.target.id, call.caller.number, callId)
            TriggerClientEvent("burner:call:dialing", call.caller.id, call.target.number, callId)
        else
            TriggerClientEvent("burner:call:receive", call.target.id, call.caller.number, callId)
            TriggerClientEvent("burner:call:dialing", call.caller.id, call.target.number, callId)
        end
    end

    call.target.soundId = triggerAudio(call.target.id, 1, 3.0, 'ringing', 0.5, 'playLooped')
    call.caller.soundId = triggerAudio(call.caller.id, 1, 0.2, 'dialing', 0.5, 'playLooped')
    -- Time before automatically ending if no one answers or hangups
    local timeout = PromiseTimeout(30, 1000)
    -- Race between the Promises and then we proceed to establish or complete the call depending of the winner
    promise.first({ timeout, call.establish, call.completed }):next(function (establish)
        exports["np-infinity"]:CancelActiveAreaEvent(call.target.soundId)
        exports["np-infinity"]:CancelActiveAreaEvent(call.caller.soundId)
        if establish then
            establishPhoneCall(callId,callfromPhoneType,calltoPhonetype)
        else
            completePhoneCall(callId,callfromPhoneType,calltoPhonetype)
        end
    end)
else
    wait(2000)
    if callfromPhoneType == 0 then
        TriggerClientEvent("phone:call:inactive", pSourceId, pTargetNumber)
    elseif callfromPhoneType == 1 then
        TriggerClientEvent("burner:call:inactive", pSourceId, pTargetNumber)
    end
end
    return false, targetId
end

function establishPhoneCall(callId,callfromPhoneType,calltoPhonetype)
    local call = ActiveCalls[callId]

    if call then
        -- set the call state to active
        call.state = 2
        --Notify the participants
        if callfromPhoneType == 0 then
            if calltoPhonetype == 1 then
                TriggerClientEvent("burner:call:in-progress", call.target.id, call.caller.number, callId)
                TriggerClientEvent("phone:call:in-progress", call.caller.id, call.target.number, callId)
            else
                TriggerClientEvent("phone:call:in-progress", call.target.id, call.caller.number, callId)
                TriggerClientEvent("phone:call:in-progress", call.caller.id, call.target.number, callId)
            end
        elseif callfromPhoneType == 1 then
            if calltoPhonetype == 1 then 
                TriggerClientEvent("burner:call:in-progress", call.target.id, call.caller.number, callId)
                TriggerClientEvent("burner:call:in-progress", call.caller.id, call.target.number, callId)
            else
                TriggerClientEvent("phone:call:in-progress", call.target.id, call.caller.number, callId)
                TriggerClientEvent("burner:call:in-progress", call.caller.id, call.target.number, callId)
            end
        end
        -- start the mumble call
        TriggerEvent('np:voice:phone:call:start', call.caller.id, call.target.number, callId)
        --Once the promise is resolved we proceed to end the call 
        call.completed:next(function()
            completePhoneCall(callId, callfromPhoneType,calltoPhonetype)
        end)
    end
end

-- GIFT FROM NoPain, https://r1c.pw

function completePhoneCall(callId, callfromPhoneType,calltoPhonetype)
    local call = ActiveCalls[callId]

    if call then 
        --set the call state to completed
        call.state = 0
        --notify the completion to the participants
        if callfromPhoneType == 0 then
            if calltoPhonetype == 1 then
                TriggerClientEvent("burner:call:inactive", call.target.id, call.caller.number, callId)
                TriggerClientEvent("phone:call:inactive", call.caller.id, call.target.number, callId)
            else
                TriggerClientEvent("phone:call:inactive", call.target.id, call.caller.number, callId)
                TriggerClientEvent("phone:call:inactive", call.caller.id, call.target.number, callId)
            end
        elseif callfromPhoneType == 1 then
            if calltoPhonetype == 1 then
                TriggerClientEvent("burner:call:inactive", call.target.id, call.caller.number, callId)
                TriggerClientEvent("burner:call:inactive", call.caller.id, call.target.number, callId)
            else
                TriggerClientEvent("phone:call:inactive", call.target.id, call.caller.number, callId)
                TriggerClientEvent("burner:call:inactive", call.caller.id, call.target.number, callId)
            end
        end
        --stop the mumble call 
        TriggerEvent('np:voice:phone:call:end', call.caller.id, call.target.id, callId)
        -- we clear the call data 
        clearCallData(callId)
    end
end

function acceptPhoneCall(pCallId)
    local call = ActiveCalls[pCallId]
    if call and call.state == 1 then
        call.establish:resolve(true)
    elseif call and call.state == 0 then
        return false, 'Caller Hung up'
    elseif not call then
        return false, 'Invalid Call ID'
    end
    return true, 'Call Established'
end

function endPhoneCall(pCallId)
    local call = ActiveCalls[pCallId]
    if call and call.state == 0 then
        call.completed:resolve(false)
    elseif not call then
        return false, 'Invalid Call ID'
    end

    return true, 'Call Completed'
end

-- GIFT FROM NoPain, https://r1c.pw

function registerCallData(callData)
    local callId = #ActiveCalls +1
    ActiveCalls[callId] = callData 
    return callId
end

function clearCallData(pCallId)
    Citizen.SetTimeout(30 * 1000, function ()
        ActiveCalls[callId] = nil
    end)
end



function triggerAudio(pPlayerId, pType, pRadius, ...)
    local playerCoords = GetEntityCoords(GetPlayerPed(pPlayerId))

    local Area = {
        type = pType, -- [ 1 = coords, 2 = player, 3 = entity ]
        target = playerCoords, -- [ vector3 or net handle]
        radius = pRadius
    }

    local Event = {
        server = false, -- set to false if we don't want to trigger server events
        inEvent = 'InteractSound_CL:PlayOnOne',
        outEvent = 'InteractSound_CL:StopLooped'
    }

    return exports["np-infinity"]: TriggerActiveAreaEvent(Event, Area, ...)
end

-- GIFT FROM NoPain, https://r1c.pw