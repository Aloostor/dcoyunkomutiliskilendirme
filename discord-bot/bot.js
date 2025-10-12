const { Client, GatewayIntentBits, EmbedBuilder, PermissionFlagsBits } = require('discord.js');
const express = require('express');
const axios = require('axios');
const sqlite3 = require('sqlite3').verbose();
const path = require('path');
require('dotenv').config();

// Discord bot client
const client = new Client({
    intents: [
        GatewayIntentBits.Guilds,
        GatewayIntentBits.GuildMessages,
        GatewayIntentBits.MessageContent,
        GatewayIntentBits.GuildMembers
    ]
});

// Express app for MTA communication
const app = express();
app.use(express.json());

// Database setup
const db = new sqlite3.Database('./discord_commands.db');

// Initialize database tables
db.serialize(() => {
    db.run(`
        CREATE TABLE IF NOT EXISTS discord_users (
            discord_id TEXT PRIMARY KEY,
            game_account TEXT,
            last_seen DATETIME DEFAULT CURRENT_TIMESTAMP
        )
    `);
    
    db.run(`
        CREATE TABLE IF NOT EXISTS command_logs (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            discord_id TEXT,
            command TEXT,
            parameters TEXT,
            timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
            success BOOLEAN
        )
    `);
});

// Configuration
const CONFIG = {
    BOT_TOKEN: process.env.DISCORD_BOT_TOKEN,
    CLIENT_ID: process.env.DISCORD_CLIENT_ID,
    GUILD_ID: process.env.DISCORD_GUILD_ID,
    ADMIN_ROLE_ID: process.env.DISCORD_ADMIN_ROLE_ID,
    MTA_SERVER_URL: process.env.MTA_SERVER_URL || 'http://localhost:22005',
    PORT: process.env.PORT || 3000
};

// Command permissions
const COMMAND_PERMISSIONS = {
    'ooc': ['user'],
    'bakiyever': ['admin'],
    'bakiyeal': ['admin'],
    'hapis': ['admin'],
    'zamanayarla': ['admin'],
    'status': ['user'],
    'paraver': ['user'],
    'hapiscikar': ['admin']
};

// Bot ready event
client.once('ready', () => {
    console.log(`Discord bot ${client.user.tag} olarak giriş yaptı!`);
    
    // Bot presence
    client.user.setPresence({
        activities: [{ name: 'MTA SA Komutları', type: 0 }],
        status: 'online'
    });
});

// Message handler
client.on('messageCreate', async (message) => {
    // Bot mesajlarını ignore et
    if (message.author.bot) return;
    
    // Komut prefix kontrolü
    if (!message.content.startsWith('!')) return;
    
    // Komutu parse et
    const args = message.content.slice(1).trim().split(/ +/);
    const commandName = args.shift().toLowerCase();
    
    // Komut varlığını kontrol et
    if (!COMMAND_PERMISSIONS[commandName]) {
        return;
    }
    
    // Yetki kontrolü
    if (!await checkPermission(message, commandName)) {
        const embed = new EmbedBuilder()
            .setColor('#ff0000')
            .setTitle('❌ Yetki Hatası')
            .setDescription('Bu komutu kullanmak için yeterli yetkiniz yok.')
            .setTimestamp();
        
        return message.reply({ embeds: [embed] });
    }
    
    // Komutu işle
    try {
        await handleCommand(message, commandName, args);
    } catch (error) {
        console.error('Komut işleme hatası:', error);
        
        const embed = new EmbedBuilder()
            .setColor('#ff0000')
            .setTitle('❌ Hata')
            .setDescription('Komut işlenirken bir hata oluştu.')
            .setTimestamp();
        
        message.reply({ embeds: [embed] });
    }
});

// Yetki kontrol fonksiyonu
async function checkPermission(message, commandName) {
    const requiredRoles = COMMAND_PERMISSIONS[commandName];
    
    if (requiredRoles.includes('user')) {
        return true; // Herkes kullanabilir
    }
    
    if (requiredRoles.includes('admin')) {
        // Admin rolü kontrolü
        if (CONFIG.ADMIN_ROLE_ID) {
            return message.member.roles.cache.has(CONFIG.ADMIN_ROLE_ID);
        }
        
        // Alternatif: Yönetici yetkisi kontrolü
        return message.member.permissions.has(PermissionFlagsBits.Administrator);
    }
    
    return false;
}

// Komut işleme fonksiyonu
async function handleCommand(message, commandName, args) {
    const discordID = message.author.id;
    const username = message.author.username;
    
    // Kullanıcıyı veritabanına kaydet
    db.run(
        'INSERT OR REPLACE INTO discord_users (discord_id, game_account, last_seen) VALUES (?, ?, CURRENT_TIMESTAMP)',
        [discordID, username]
    );
    
    // Komut geçmişini kaydet
    db.run(
        'INSERT INTO command_logs (discord_id, command, parameters, success) VALUES (?, ?, ?, ?)',
        [discordID, commandName, args.join(' '), false]
    );
    
    // MTA sunucusuna komut gönder
    try {
        const response = await axios.post(`${CONFIG.MTA_SERVER_URL}/api/discord-command`, {
            discordID: discordID,
            command: commandName,
            parameters: args,
            username: username
        }, {
            timeout: 10000
        });
        
        // Başarılı yanıt
        if (response.data.success) {
            const embed = new EmbedBuilder()
                .setColor('#00ff00')
                .setTitle('✅ Komut Başarılı')
                .setDescription(response.data.message || 'Komut başarıyla işlendi.')
                .addFields(
                    { name: 'Komut', value: `!${commandName}`, inline: true },
                    { name: 'Kullanıcı', value: `<@${discordID}>`, inline: true },
                    { name: 'Parametreler', value: args.length > 0 ? args.join(' ') : 'Yok', inline: false }
                )
                .setTimestamp();
            
            message.reply({ embeds: [embed] });
            
            // Veritabanını güncelle
            db.run(
                'UPDATE command_logs SET success = 1 WHERE discord_id = ? AND command = ? AND timestamp = (SELECT MAX(timestamp) FROM command_logs WHERE discord_id = ?)',
                [discordID, commandName, discordID]
            );
        } else {
            // Başarısız yanıt
            const embed = new EmbedBuilder()
                .setColor('#ff0000')
                .setTitle('❌ Komut Başarısız')
                .setDescription(response.data.message || 'Komut işlenemedi.')
                .addFields(
                    { name: 'Komut', value: `!${commandName}`, inline: true },
                    { name: 'Kullanıcı', value: `<@${discordID}>`, inline: true }
                )
                .setTimestamp();
            
            message.reply({ embeds: [embed] });
        }
        
    } catch (error) {
        console.error('MTA sunucu iletişim hatası:', error.message);
        
        const embed = new EmbedBuilder()
            .setColor('#ff0000')
            .setTitle('❌ Sunucu Bağlantı Hatası')
            .setDescription('MTA sunucusu ile bağlantı kurulamadı. Lütfen daha sonra tekrar deneyin.')
            .setTimestamp();
        
        message.reply({ embeds: [embed] });
    }
}

// Komut yardım sistemi
client.on('messageCreate', async (message) => {
    if (message.content === '!help' || message.content === '!yardim') {
        const embed = new EmbedBuilder()
            .setColor('#0099ff')
            .setTitle('🎮 MTA SA Discord Komutları')
            .setDescription('Mevcut komutlar ve kullanımları:')
            .addFields(
                {
                    name: '👤 Kullanıcı Komutları',
                    value: '`!ooc [mesaj]` - OOC mesaj gönder\n`!status` - Kendi durumunu gör\n`!paraver [oyuncu] [miktar]` - Oyuncuya para ver',
                    inline: false
                },
                {
                    name: '🛡️ Admin Komutları',
                    value: '`!bakiyever [oyuncu] [miktar]` - Oyuncuya para ekle\n`!bakiyeal [oyuncu] [miktar]` - Oyuncudan para al\n`!hapis [oyuncu] [süre]` - Oyuncuyu hapse at\n`!hapiscikar [oyuncu]` - Oyuncuyu hapisten çıkar\n`!zamanayarla [saat] [dakika]` - Oyun saatini ayarla',
                    inline: false
                }
            )
            .setFooter({ text: 'Komut başına 200 TL ücret alınır' })
            .setTimestamp();
        
        message.reply({ embeds: [embed] });
    }
});

// MTA sunucusundan gelen yanıtları işle
app.post('/api/mta-response', (req, res) => {
    const { discordID, success, message } = req.body;
    
    console.log(`MTA Yanıt: ${discordID} - ${success ? 'Başarılı' : 'Başarısız'} - ${message}`);
    
    res.json({ status: 'received' });
});

// Health check endpoint
app.get('/health', (req, res) => {
    res.json({ 
        status: 'healthy', 
        uptime: process.uptime(),
        commands: Object.keys(COMMAND_PERMISSIONS)
    });
});

// Express server başlat
app.listen(CONFIG.PORT, () => {
    console.log(`HTTP server ${CONFIG.PORT} portunda çalışıyor`);
});

// Bot'u başlat
if (CONFIG.BOT_TOKEN) {
    client.login(CONFIG.BOT_TOKEN);
} else {
    console.error('DISCORD_BOT_TOKEN bulunamadı! .env dosyasını kontrol edin.');
}

// Graceful shutdown
process.on('SIGINT', () => {
    console.log('Bot kapatılıyor...');
    client.destroy();
    db.close();
    process.exit(0);
});
