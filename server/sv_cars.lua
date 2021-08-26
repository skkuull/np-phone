function getCars(pCharacterId)

    -- if not pCharacterId then return false, "No Character Id" end

    -- local query = [[
    --     SELECT model, '[-277.5246887207,-889.99249267578,30.872133178711]' as 'location', `state` as 'parking_state', `garage` as
    --     'parking_garage', `plate`, `damage`, `type` as type FROM _vehicle WHERE cid = ? 
    -- ]]
    -- local pResult = Await(SQL.execute(query, pCharacterId))

    -- for _, v in pairs(pResult) do
    --     local conf = exports["np-showrooms"]:getStingleCarConfig(v.model)
    --     if conf then
    --         v.name = conf.name
    --         v.brand = conf.brand
    --     else
    --         v.name = v.model
    --         v.brand = ""
    --     end
    --     if v.damage then
    --         local dmgData = json.decode(v.damage)
    --         v.stats_body = dmgData.body
    --     end
    --     `body_damage` as 'stats_body', `engine_damage` as 'stats_engine',
    -- end
    
    return true, true
end

-- SPAGHETTI
-- local src = source
-- local user = exports["np-base"]:getModule("Player"):GetUser(src)
-- local character = user:getCurrentCharacter()
-- local player = user:getVar("hexid")

-- exports.ghmattimysql:execute("SELECT * FROM characters_cars WHERE cid = @cid",{['username'] = player, ['cid'] = character.id},
-- function(result)


--     if (result) then
--         for _, v in ipairs(result) do
--             local curGarage = "Any"
--             if v.current_garage ~= nil then
--                 curGarage = v.current_garage
--             end
--             local amountduenow = 0
--             local last_payment = lastPayment(v.last_payment)

--         if last_payment > 7 then
--             amountduenow = math.cell(v.purchase_price / 10 * (last_payment / 7))
--         end
--         t = { ["id"] = v.id, ["model"] = v.model, ["name"] = v.name, ["license_plate"] = v.license_plate, ["vehicle_state"] = v.vehicle_state, ["engine_damage"] = v.engine_damage, ["body_damage"] = v.body_damage, ["current_garage"] = curGarage, ["data"] = json, decode(v.data), ["fuel"] = v.fuel, ["payments"] = v.financed, ["last_payment"] = last_payment, ["amount_due"] = amountduenow, ["coords"] = json.decode(v.coords), }
--         vehicles[v.id] = t
--     end
-- end
-- TriggerClientEvent('garages:getVehicles', src, vehicles)
-- end)