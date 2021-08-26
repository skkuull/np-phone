local isDialing, dialCounter, isRinging, ringingCounter = false, 0, false, 0

-- This is what you should call on the receiving end ;)
RegisterNetEvent("burner:call:receive")
AddEventHandler("burner:call:receive", function(pNumber, pCallId)
  SendUIMessage({
    source = "np-nui",
      app = "burner",
      data = {
        action = "call-receiving",
        number = pNumber,
        callId = pCallId
    }
  })
  isRinging = true
end)

-- call this event when call begins
RegisterNetEvent("burner:call:in-progress")
AddEventHandler("burner:call:in-progress", function(pNumber, pCallId)
  SendUIMessage({
    source = "np-nui",
    app = "burner",
    data = {
      action = "call-in-progress",
      number = pNumber,
      callId = pCallId
    }
  })
  isDialing, isRinging = false, false
end)

-- call this event when call is outgoing
RegisterNetEvent("burner:call:dialing")
AddEventHandler("burner:call:dialing", function(pNumber, pCallId)
  
  SendUIMessage({
    source = "np-nui",
    app = "burner",
    data = {
      action = "call-dialing",
      number = pNumber,
      callId = pCallId
    }
  })
  isDialing = true
end)

-- call this when there is no active calling state (not dialing, receiving, in call - after hang up)
RegisterNetEvent("burner:call:inactive")
AddEventHandler("burner:call:inactive", function(pNumber)
  
  SendUIMessage({
    source = "np-nui",
    app = "burner",
    data = {
      action = "call-inactive",
      number = pNumber
    }
  })
  print("Inactive")
  isDialing, isRinging = false, false
end)

-- dial from phone
RegisterUICallback("np-ui:burnerCallStart", function(data, cb)
  local caller_number, target_number = data.source_number, data.number
  RPC.execute("burner:callStart", caller_number, target_number)
  cb({ data = {}, meta = { ok = true, message = '' } })
end)