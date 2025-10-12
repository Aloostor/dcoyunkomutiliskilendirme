-- MTA HTTP Handler - Discord Bot ile iletişim
-- Bu dosya MTA sunucusunda çalışır

local httpPort = 22005 -- Discord bot'un bağlanacağı port

-- HTTP sunucusu oluştur
local httpServer = createHTTPServer(httpPort, function(req, res)
    -- CORS headers
    res.setHeader("Access-Control-Allow-Origin", "*")
    res.setHeader("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
    res.setHeader("Access-Control-Allow-Headers", "Content-Type")
    
    if req.method == "OPTIONS" then
        res.writeHead(200)
        res.write("")
        res.finish()
        return
    end
    
    -- Discord komut endpoint
    if req.path == "/api/discord-command" and req.method == "POST" then
        local body = req.body
        if body then
            local data = fromJSON(body)
            if data then
                local discordID = data.discordID
                local command = data.command
                local parameters = data.parameters or {}
                local username = data.username
                
                outputDebugString("Discord komut alındı: " .. command .. " - " .. username)
                
                -- Komutu işle
                local success, response = handleDiscordCommand(discordID, command, parameters)
                
                -- JSON yanıt gönder
                local responseData = {
                    success = success,
                    message = response,
                    command = command,
                    timestamp = getRealTime().timestamp
                }
                
                res.writeHead(200, {["Content-Type"] = "application/json"})
                res.write(toJSON(responseData))
                res.finish()
                return
            end
        end
        
        -- Hata yanıtı
        res.writeHead(400, {["Content-Type"] = "application/json"})
        res.write(toJSON({success = false, message = "Geçersiz istek"}))
        res.finish()
        return
    end
    
    -- Health check endpoint
    if req.path == "/health" and req.method == "GET" then
        local healthData = {
            status = "healthy",
            server = getServerName(),
            players = getPlayerCount(),
            maxPlayers = getMaxPlayers(),
            uptime = getTickCount()
        }
        
        res.writeHead(200, {["Content-Type"] = "application/json"})
        res.write(toJSON(healthData))
        res.finish()
        return
    end
    
    -- 404 yanıtı
    res.writeHead(404, {["Content-Type"] = "application/json"})
    res.write(toJSON({error = "Endpoint bulunamadı"}))
    res.finish()
end)

-- HTTP sunucusunu başlat
if httpServer then
    outputDebugString("HTTP Server başlatıldı - Port: " .. httpPort)
else
    outputDebugString("HTTP Server başlatılamadı!")
end

-- Discord komut işleme fonksiyonu (server.lua'dan import edilecek)
function handleDiscordCommand(discordID, command, params)
    -- Bu fonksiyon server.lua dosyasında tanımlanmış
    -- Eğer bu dosya ayrı çalışıyorsa, komut işleme mantığını buraya ekleyin
    
    local success = false
    local response = ""
    
    if command == "ooc" then
        success = handleOOCCommand(discordID, params)
        response = success and "OOC mesajı gönderildi" or "OOC komutu başarısız"
        
    elseif command == "bakiyever" then
        success, response = handleBakiyeVerCommand(discordID, params)
        
    elseif command == "bakiyeal" then
        success, response = handleBakiyeAlCommand(discordID, params)
        
    elseif command == "hapis" then
        success, response = handleHapisCommand(discordID, params)
        
    elseif command == "zamanayarla" then
        success, response = handleZamanAyarlaCommand(discordID, params)
        
    elseif command == "status" then
        success, response = handleStatusCommand(discordID, params)
        
    elseif command == "paraver" then
        success, response = handleParaVerCommand(discordID, params)
        
    elseif command == "hapiscikar" then
        success, response = handleHapisCikarCommand(discordID, params)
        
    else
        response = "Bilinmeyen komut: " .. command
    end
    
    return success, response
end

-- Komut handler fonksiyonları (server.lua'dan kopyalanmış)
function getPlayerByDiscordID(discordID)
    -- Bu fonksiyonu kendi sisteminize göre uyarlayın
    local players = getElementsByType("player")
    for _, player in ipairs(players) do
        local playerName = getPlayerName(player)
        -- Discord ID ile oyuncu eşleştirmesi yapın
        -- Bu kısmı kendi veritabanı sisteminize göre uyarlayın
        if string.find(playerName, "discord_" .. discordID) then
            return player
        end
    end
    return nil
end

function handleOOCCommand(discordID, params)
    local player = getPlayerByDiscordID(discordID)
    if not player then
        return false
    end
    
    local message = table.concat(params, " ")
    if #message < 1 then
        return false
    end
    
    outputChatBox("(( " .. getPlayerName(player) .. ": " .. message .. " ))", root, 255, 255, 255, true)
    return true
end

function handleBakiyeVerCommand(discordID, params)
    local player = getPlayerByDiscordID(discordID)
    if not player then
        return false, "Oyuncu bulunamadı"
    end
    
    if #params < 2 then
        return false, "Kullanım: !bakiyever [oyuncu] [miktar]"
    end
    
    local targetPlayer = getPlayerFromName(params[1])
    local amount = tonumber(params[2])
    
    if not targetPlayer then
        return false, "Hedef oyuncu bulunamadı"
    end
    
    if not amount or amount <= 0 then
        return false, "Geçersiz miktar"
    end
    
    local currentMoney = getPlayerMoney(targetPlayer)
    setPlayerMoney(targetPlayer, currentMoney + amount)
    
    local response = "Oyuncu " .. getPlayerName(targetPlayer) .. " hesabına " .. amount .. "$ eklendi"
    outputChatBox("Admin " .. getPlayerName(player) .. " size " .. amount .. "$ verdi", targetPlayer, 0, 255, 0)
    
    return true, response
end

function handleBakiyeAlCommand(discordID, params)
    local player = getPlayerByDiscordID(discordID)
    if not player then
        return false, "Oyuncu bulunamadı"
    end
    
    if #params < 2 then
        return false, "Kullanım: !bakiyeal [oyuncu] [miktar]"
    end
    
    local targetPlayer = getPlayerFromName(params[1])
    local amount = tonumber(params[2])
    
    if not targetPlayer then
        return false, "Hedef oyuncu bulunamadı"
    end
    
    if not amount or amount <= 0 then
        return false, "Geçersiz miktar"
    end
    
    local currentMoney = getPlayerMoney(targetPlayer)
    if currentMoney < amount then
        return false, "Oyuncunun yeterli parası yok"
    end
    
    setPlayerMoney(targetPlayer, currentMoney - amount)
    
    local response = "Oyuncu " .. getPlayerName(targetPlayer) .. " hesabından " .. amount .. "$ alındı"
    outputChatBox("Admin " .. getPlayerName(player) .. " hesabınızdan " .. amount .. "$ aldı", targetPlayer, 255, 0, 0)
    
    return true, response
end

function handleHapisCommand(discordID, params)
    local player = getPlayerByDiscordID(discordID)
    if not player then
        return false, "Oyuncu bulunamadı"
    end
    
    if #params < 1 then
        return false, "Kullanım: !hapis [oyuncu] [süre (dakika)]"
    end
    
    local targetPlayer = getPlayerFromName(params[1])
    local duration = tonumber(params[2]) or 60
    
    if not targetPlayer then
        return false, "Hedef oyuncu bulunamadı"
    end
    
    local jailX, jailY, jailZ = 1544.5, -1675.7, 13.6
    setElementPosition(targetPlayer, jailX, jailY, jailZ)
    setElementInterior(targetPlayer, 0)
    setElementDimension(targetPlayer, 0)
    
    local response = "Oyuncu " .. getPlayerName(targetPlayer) .. " hapse atıldı (" .. duration .. " dakika)"
    outputChatBox("Admin " .. getPlayerName(player) .. " tarafından hapse atıldınız", targetPlayer, 255, 0, 0)
    
    return true, response
end

function handleZamanAyarlaCommand(discordID, params)
    local player = getPlayerByDiscordID(discordID)
    if not player then
        return false, "Oyuncu bulunamadı"
    end
    
    if #params < 2 then
        return false, "Kullanım: !zamanayarla [saat] [dakika]"
    end
    
    local hour = tonumber(params[1])
    local minute = tonumber(params[2])
    
    if not hour or not minute or hour < 0 or hour > 23 or minute < 0 or minute > 59 then
        return false, "Geçersiz saat formatı (0-23:0-59)"
    end
    
    setTime(hour, minute)
    
    local response = "Oyun saati " .. string.format("%02d:%02d", hour, minute) .. " olarak ayarlandı"
    outputChatBox("Admin " .. getPlayerName(player) .. " oyun saatini değiştirdi", root, 255, 255, 0)
    
    return true, response
end

function handleStatusCommand(discordID, params)
    local player = getPlayerByDiscordID(discordID)
    if not player then
        return false, "Oyuncu bulunamadı"
    end
    
    local playerName = getPlayerName(player)
    local playerMoney = getPlayerMoney(player)
    local playerHealth = getElementHealth(player)
    local playerArmor = getPedArmor(player)
    local playerX, playerY, playerZ = getElementPosition(player)
    
    local response = string.format(
        "Oyuncu: %s\nPara: $%d\nSağlık: %.0f\nZırh: %.0f\nKonum: %.1f, %.1f, %.1f",
        playerName, playerMoney, playerHealth, playerArmor, playerX, playerY, playerZ
    )
    
    return true, response
end

function handleParaVerCommand(discordID, params)
    local player = getPlayerByDiscordID(discordID)
    if not player then
        return false, "Oyuncu bulunamadı"
    end
    
    if #params < 2 then
        return false, "Kullanım: !paraver [oyuncu] [miktar]"
    end
    
    local targetPlayer = getPlayerFromName(params[1])
    local amount = tonumber(params[2])
    
    if not targetPlayer then
        return false, "Hedef oyuncu bulunamadı"
    end
    
    if not amount or amount <= 0 then
        return false, "Geçersiz miktar"
    end
    
    local currentMoney = getPlayerMoney(player)
    if currentMoney < amount then
        return false, "Yeterli paranız yok"
    end
    
    setPlayerMoney(player, currentMoney - amount)
    setPlayerMoney(targetPlayer, getPlayerMoney(targetPlayer) + amount)
    
    local response = "Oyuncu " .. getPlayerName(targetPlayer) .. " hesabına " .. amount .. "$ transfer edildi"
    outputChatBox("Oyuncu " .. getPlayerName(player) .. " size " .. amount .. "$ verdi", targetPlayer, 0, 255, 0)
    
    return true, response
end

function handleHapisCikarCommand(discordID, params)
    local player = getPlayerByDiscordID(discordID)
    if not player then
        return false, "Oyuncu bulunamadı"
    end
    
    if #params < 1 then
        return false, "Kullanım: !hapiscikar [oyuncu]"
    end
    
    local targetPlayer = getPlayerFromName(params[1])
    
    if not targetPlayer then
        return false, "Hedef oyuncu bulunamadı"
    end
    
    local spawnX, spawnY, spawnZ = 1481.0, -1771.3, 18.8
    setElementPosition(targetPlayer, spawnX, spawnY, spawnZ)
    setElementInterior(targetPlayer, 0)
    setElementDimension(targetPlayer, 0)
    
    local response = "Oyuncu " .. getPlayerName(targetPlayer) .. " hapisten çıkarıldı"
    outputChatBox("Admin " .. getPlayerName(player) .. " tarafından hapisten çıkarıldınız", targetPlayer, 0, 255, 0)
    
    return true, response
end
