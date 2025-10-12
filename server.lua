local db = dbConnect("sqlite", "discord_commands.db")


dbExec(db, [[
    CREATE TABLE IF NOT EXISTS discord_users (
        discord_id TEXT PRIMARY KEY,
        game_account TEXT,
        last_seen DATETIME DEFAULT CURRENT_TIMESTAMP
    )
]])

dbExec(db, [[
    CREATE TABLE IF NOT EXISTS command_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        discord_id TEXT,
        command TEXT,
        parameters TEXT,
        timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
        success BOOLEAN
    )
]])


local discordWebhook = ""

-- Komut handler fonksiyonu
function handleDiscordCommand(discordID, command, params)
    local success = false
    local response = ""
    
    -- Komut geçmişini loglama
    local query = dbPrepare(db, "INSERT INTO command_logs (discord_id, command, parameters, success) VALUES (?, ?, ?, ?)")
    dbExecute(query, discordID, command, params, false)
    
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
    
    -- Başarı durumunu güncelle
    local updateQuery = dbPrepare(db, "UPDATE command_logs SET success = ? WHERE discord_id = ? AND command = ? AND timestamp = (SELECT MAX(timestamp) FROM command_logs WHERE discord_id = ?)")
    dbExecute(updateQuery, success, discordID, command, discordID)
    
    return success, response
end

-- OOC komut handler
function handleOOCCommand(discordID, params)
    local player = getPlayerByDiscordID(discordID)
    if not player then
        return false
    end
    
    local message = table.concat(params, " ")
    if #message < 1 then
        return false
    end
    
    -- OOC mesajını oyuna gönder
    outputChatBox("(( " .. getPlayerName(player) .. ": " .. message .. " ))", root, 255, 255, 255, true)
    return true
end

-- Bakiye ver komut handler
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
    
    -- Para verme işlemi (bu kısmı kendi ekonomi sisteminize göre uyarlayın)
    local currentMoney = getPlayerMoney(targetPlayer)
    setPlayerMoney(targetPlayer, currentMoney + amount)
    
    local response = "Oyuncu " .. getPlayerName(targetPlayer) .. " hesabına " .. amount .. "$ eklendi"
    outputChatBox("Admin " .. getPlayerName(player) .. " size " .. amount .. "$ verdi", targetPlayer, 0, 255, 0)
    
    return true, response
end

-- Bakiye al komut handler
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

-- Hapis komut handler
function handleHapisCommand(discordID, params)
    local player = getPlayerByDiscordID(discordID)
    if not player then
        return false, "Oyuncu bulunamadı"
    end
    
    if #params < 1 then
        return false, "Kullanım: !hapis [oyuncu] [süre (dakika)]"
    end
    
    local targetPlayer = getPlayerFromName(params[1])
    local duration = tonumber(params[2]) or 60 -- Varsayılan 60 dakika
    
    if not targetPlayer then
        return false, "Hedef oyuncu bulunamadı"
    end
    
    -- Hapis koordinatları (Los Santos Police Department)
    local jailX, jailY, jailZ = 1544.5, -1675.7, 13.6
    
    setElementPosition(targetPlayer, jailX, jailY, jailZ)
    setElementInterior(targetPlayer, 0)
    setElementDimension(targetPlayer, 0)
    
    local response = "Oyuncu " .. getPlayerName(targetPlayer) .. " hapse atıldı (" .. duration .. " dakika)"
    outputChatBox("Admin " .. getPlayerName(player) .. " tarafından hapse atıldınız", targetPlayer, 255, 0, 0)
    
    return true, response
end

-- Zaman ayarla komut handler
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

-- Status komut handler
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

-- Para ver komut handler
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
    
    -- Para transferi
    setPlayerMoney(player, currentMoney - amount)
    setPlayerMoney(targetPlayer, getPlayerMoney(targetPlayer) + amount)
    
    local response = "Oyuncu " .. getPlayerName(targetPlayer) .. " hesabına " .. amount .. "$ transfer edildi"
    outputChatBox("Oyuncu " .. getPlayerName(player) .. " size " .. amount .. "$ verdi", targetPlayer, 0, 255, 0)
    
    return true, response
end

-- Hapis çıkar komut handler
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
    
    -- Hapisten çıkarma (spawn noktası)
    local spawnX, spawnY, spawnZ = 1481.0, -1771.3, 18.8
    
    setElementPosition(targetPlayer, spawnX, spawnY, spawnZ)
    setElementInterior(targetPlayer, 0)
    setElementDimension(targetPlayer, 0)
    
    local response = "Oyuncu " .. getPlayerName(targetPlayer) .. " hapisten çıkarıldı"
    outputChatBox("Admin " .. getPlayerName(player) .. " tarafından hapisten çıkarıldınız", targetPlayer, 0, 255, 0)
    
    return true, response
end

-- Discord ID'den oyuncu bulma fonksiyonu
function getPlayerByDiscordID(discordID)
    -- Bu fonksiyonu kendi sisteminize göre uyarlayın
    -- Genellikle bir veritabanından Discord ID ile oyuncu hesabı eşleştirmesi yapılır
    
    local query = dbQuery(db, "SELECT game_account FROM discord_users WHERE discord_id = ?", discordID)
    local result = dbPoll(query, -1)
    
    if result and #result > 0 then
        return getPlayerFromName(result[1].game_account)
    end
    
    return nil
end

-- HTTP request handler (Discord bot'tan gelen komutlar için)
addEvent("onDiscordCommand", true)
addEventHandler("onDiscordCommand", root, function(discordID, command, params)
    local success, response = handleDiscordCommand(discordID, command, params)
    
    -- Discord bot'a yanıt gönder
    triggerEvent("onDiscordResponse", root, discordID, success, response)
end)

-- Test komutu (sadece geliştirme için)
addCommandHandler("testdiscord", function(player, cmd, ...)
    local params = {...}
    local command = params[1] or "status"
    local discordID = "test_user_" .. getPlayerName(player)
    
    local success, response = handleDiscordCommand(discordID, command, {})
    outputChatBox("Test sonucu: " .. (success and "Başarılı" or "Başarısız") .. " - " .. response, player)
end)

outputDebugString("Discord Komut Sistemi yüklendi")
