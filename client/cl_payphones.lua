local insidePrison = false

local payphoneModels = {
  `p_phonebox_02_s`,
  `prop_phonebox_03`,
  `prop_phonebox_02`,
  `prop_phonebox_04`,
  `prop_phonebox_01c`,
  `prop_phonebox_01a`,
  `prop_phonebox_01b`,
  `p_phonebox_01b_s`,
}

Citizen.CreateThread(function()
  exports["np-interact"]:AddPeekEntryByModel(payphoneModels, {{
    event = "np-phone:startPayPhoneCall",
    id = "np-phone:startPayPhoneCall",
    icon = "phone-volume",
    label = "Make Call",
    parameters = {},
  }}, { 
    distance = { radius = 1.5 },
    isEnabled = function()
      if insidePrison then
        return false
      end
      return true
    end
   })
end)

local entityPayPhoneCoords = nil
AddEventHandler("np-phone:startPayPhoneCall", function(pArgs, pEntity)
  entityPayPhoneCoords = GetEntityCoords(pEntity)
  exports['np-ui']:openApplication('textbox', {
    callbackUrl = 'np-phone:startPayPhoneCallAction',
    key = 1,
    items = {
      {
        icon = "phone-volume",
        label = "Phone Number",
        name = "number",
      },
    },
    show = true,
  })
end)

AddEventHandler("np-polyzone:enter", function(zone, data)
    if zone == "prison" then insidePrison = true end
end)

AddEventHandler("np-polyzone:exit", function(zone)
    if zone == "prison" then insidePrison = false end
end)

RegisterUICallback("np-phone:startPayPhoneCallAction", function(data, cb)
  cb({ data = {}, meta = { ok = true, message = 'done' } })
  exports['np-ui']:closeApplication('textbox')
  local number = data.values.number
  RPC.execute("phone:callStart", data.character.number, number, 'PAYPHONE', "Unknown Number")
  Citizen.CreateThread(function()
    while entityPayPhoneCoords do
      if #(GetEntityCoords(PlayerPedId()) - entityPayPhoneCoords) > 2.0 then
        entityPayPhoneCoords = nil
        TriggerEvent("np:fiber:voice-event", 'callEnd')
      end
      Citizen.Wait(500)
    end
  end)
end)
