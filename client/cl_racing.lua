local function getAlias(alias, character)
  if alias ~= nil then return alias end
  return character.first_name .. " " .. character.last_name
end

RegisterUICallback("np-ui:racingGetAllRaces", function(data, cb)
  local res = exports["mkr-racing"]:getAllRaces()
  local completed = RPC.execute("mkr_racing:getFinishedRaces")
  res.completed = completed
  cb({ data = res, meta = { ok = true, message = 'done' } })
end)

RegisterUICallback("np-ui:racingPreviewRace", function(data, cb)
  exports["mkr-racing"]:previewRace(data.id)
  cb({ data = {}, meta = { ok = true, message = 'done' } })
end)

RegisterUICallback("np-ui:racingLocateRace", function(data, cb)
  exports["mkr-racing"]:locateRace(data.id, data.race.reverse)
  cb({ data = {}, meta = { ok = true, message = 'done' } })
end)

RegisterUICallback("np-ui:racingCreateRace", function(data, cb)
  data.options.characterId = data.character.id
  data.options.alias = getAlias(data.options.alias, data.character)
  local err = exports["mkr-racing"]:createPendingRace(data.id, data.options)
  if err ~= nil then
    cb({ data = res, meta = { ok = false, message = err } })
    return
  end
  cb({ data = res, meta = { ok = true, message = 'done' } })
end)

RegisterUICallback("np-ui:racingDeleteRace", function(data, cb)
  local success = false
  local message = "Failed to delete race"
  if data.id then
    success = RPC.execute('mkr_racing:deleteRace', data.id)
    if success then message = "" end
  end
  cb({ data = res, meta = { ok = success, message = message } })
end)

RegisterUICallback("np-ui:racingJoinRace", function(data, cb)
  local canJoinOrErr = exports["np-racing"]:canJoinOrStartRace()
  if canJoinOrErr ~= true then
    cb({ data = {}, meta = { ok = false, message = canJoinOrErr } })
    return
  end
  local err = exports["mkr-racing"]:joinRace(data.race.eventId, getAlias(data.alias, data.character), data.character.id)
  if err ~= nil then
    cb({ data = res, meta = { ok = false, message = err } })
    return
  end
  Wait(500)
  cb({ data = {}, meta = { ok = true, message = 'done' } })
end)

RegisterUICallback("np-ui:racingStartRace", function(data, cb)
  local canJoinOrErr = exports["np-racing"]:canJoinOrStartRace()
  if canJoinOrErr ~= true then
    cb({ data = {}, meta = { ok = false, message = canJoinOrErr } })
    return
  end
  local err = exports["mkr-racing"]:startRace(data.race.countdown)
  if err ~= nil then
    cb({ data = res, meta = { ok = false, message = err } })
    return
  end
  cb({ data = {}, meta = { ok = true, message = 'done' } })
end)

RegisterUICallback("np-ui:racingLeaveRace", function(data, cb)
  exports["mkr-racing"]:leaveRace()
  Wait(500)
  cb({ data = {}, meta = { ok = true, message = 'done' } })
end)

RegisterUICallback("np-ui:racingEndRace", function(data, cb)
  exports["mkr-racing"]:endRace()
  Wait(500)
  cb({ data = {}, meta = { ok = true, message = 'done' } })
end)

RegisterUICallback("np-ui:racingCreateMap", function(data, cb)
  local canCreate, errorMessage = RPC.execute("np-racing:canCreateNewRace", data)
  if not canCreate then
    cb({ data = {}, meta = { ok = false, message = errorMessage } })
    return
  end
  local ped = PlayerPedId()
  local veh = GetVehiclePedIsIn(PlayerPedId(), false)
  if veh ~= 0 and GetPedInVehicleSeat(veh, -1) == ped then
    TriggerEvent("mkr_racing:cmd:racecreate", data)
    cb({ data = {}, meta = { ok = true, message = 'done' } })
    exports["np-ui"]:closeApplication("phone")
  else
    cb({ data = {}, meta = { ok = false, message = 'You are not driving a vehicle' } })
  end
end)

RegisterUICallback("np-ui:racingFinishMap", function(data, cb)
  TriggerEvent("mkr_racing:cmd:racecreatedone")
  cb({ data = {}, meta = { ok = true, message = 'done' } })
end)

RegisterUICallback("np-ui:racingCancelMap", function(data, cb)
  TriggerEvent("mkr_racing:cmd:racecreatecancel")
  cb({ data = {}, meta = { ok = true, message = 'done' } })
end)

RegisterUICallback("np-ui:racingBestLapTimes", function(data, cb)
  local bestLapTimes = RPC.execute("mkr_racing:bestLapTimes", data.id, 10)
  local bestLapTimesForAlias = RPC.execute("mkr_racing:bestLapTimesForAlias", data.id, exports["isPed"]:isPed("cid"), data.alias, 1)
  local bestLapTimeForAlias = bestLapTimesForAlias ~= nil and bestLapTimesForAlias[1] or nil
  cb({ data = { bestLapTimes = bestLapTimes, bestLapTimeForAlias = bestLapTimeForAlias }, meta = { ok = true, message = 'done' } })
end)

AddEventHandler("mkr_racing:api:startingRace", function(startTime)
  TriggerEvent('DoLongHudText', "Starting in " .. tostring(startTime / 1000) .. " seconds")
end)

AddEventHandler("mkr_racing:api:updatedState", function(state)
  local data = {action = "racing-update"}
  if state.finishedRaces then data.completed = state.finishedRaces end
  if state.races then data.maps = state.races end
  if state.pendingRaces then data.pending = state.pendingRaces end
  if state.activeRaces then data.active = state.activeRaces end
  exports["np-ui"]:sendAppEvent("phone", data)
end)

function TriggerPhoneNotification(title, body)
  SendUIMessage({
    source = "np-nui",
    app = "phone",
    data = {
      action = "notification",
      target_app = "racing",
      title = title,
      body = body,
      show_even_if_app_active = true
    }
  })
end

AddEventHandler("mkr_racing:api:addedPendingRace", function(race)
  if not race.sendNotification then return end
  local hasRaceUsbAndAlias = exports["np-racing"]:getHasRaceUsbAndAlias()
  if not hasRaceUsbAndAlias.has_usb_racing or not hasRaceUsbAndAlias.racingAlias then return end
  exports["np-ui"]:sendAppEvent("phone", {
    action = "racing-new-event",
    title = "From the PM",
    text = "Pending race available...",
  })
end)

AddEventHandler("mkr_racing:api:playerJoinedYourRace", function(characterId, name)
  TriggerPhoneNotification("Race Join", name .. " joined your race")
end)

AddEventHandler("mkr_racing:api:playerLeftYourRace", function(characterId, name)
  TriggerPhoneNotification("Race Leave", name .. " left your race")
end)
