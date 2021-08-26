RPC = {}

RPC.register("phone:checkCryptoAmount", function(pSource, pCryptoId, pAmount)

    local user = exports["np-base"]:getModule('Players'):GetUser(pSource);
    local character = user:getCurrentCharacter()
    local pCharacterId = character.id
    local success, message = getCrypto(pCharacterId)
    if not success then
        return false, message
    end

    local found = nil
    for _, v in pairs(message) do
        if v.id == pCryptoId then
            found = v
        end
    end
    if found == nil then
        return false, "Wallet not found"
    end
    if found.amount < pAmount then
        return false, "Not enough " .. found.name .. "! (" .. tostring(pAmount) .. ")"
    end
    return found, ''
end)

RPC.register("phone:getArticles", function(pSource, pArticleTypeId)
    return getArticles(pArticleTypeId)
end)

RPC.register("phone:getMusicCharts", function(pSource, pArticleTypeId)
    return getMusicCharts(pArticleTypeId)
end)

RPC.register("phone:getArticleContent", function(pSource, pArticleTypeId)
    return getArticleContent(pArticleId)
end)

RPC.register("phone:createArticle", function(pSource, pCharacterId, pArticleBody, pArticleTitle, pArticleTypeId, pArticleImages)
    return createArticle(pCharacterId, pArticleTitle, pArticleTypeId, pArticleImages)
end)

RPC.register("phone:editArticle", function(pSource, pArticleId, pArticleBody, pArticleTitle, pArticleImages)
    return editArticle(pArticleId, pArticleBody, pArticleTitle, pArticleImages)
end)

RPC.register("phone:updateArticleState", function(pSource, pArticleId, pPublishState)
    return editArticle(pArticleId, pPublishState)
end)

RPC.register("phone:deleteArticle", function(pSource, pArticleId, pCharacterId)
    return deleteArticle(pArticleId, pCharacterId)
end)

RPC.register("phone:articleUnlock", function(pSource, pData)
    return articleUnlock(pData)
end)
