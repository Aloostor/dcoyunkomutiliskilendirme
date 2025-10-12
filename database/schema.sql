-- MTA SA Discord Komut Sistemi Veritabanı Şeması
-- SQLite veritabanı için

-- Discord kullanıcıları tablosu
CREATE TABLE IF NOT EXISTS discord_users (
    discord_id TEXT PRIMARY KEY,
    game_account TEXT NOT NULL,
    last_seen DATETIME DEFAULT CURRENT_TIMESTAMP,
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT 1
);

-- Komut geçmişi tablosu
CREATE TABLE IF NOT EXISTS command_logs (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    discord_id TEXT NOT NULL,
    command TEXT NOT NULL,
    parameters TEXT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    success BOOLEAN NOT NULL,
    response_message TEXT,
    FOREIGN KEY (discord_id) REFERENCES discord_users(discord_id)
);

-- Oyuncu bilgileri tablosu (MTA oyuncuları için)
CREATE TABLE IF NOT EXISTS game_players (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    player_name TEXT UNIQUE NOT NULL,
    discord_id TEXT,
    last_login DATETIME,
    total_playtime INTEGER DEFAULT 0,
    money INTEGER DEFAULT 0,
    level INTEGER DEFAULT 1,
    is_banned BOOLEAN DEFAULT 0,
    ban_reason TEXT,
    FOREIGN KEY (discord_id) REFERENCES discord_users(discord_id)
);

-- Admin yetkileri tablosu
CREATE TABLE IF NOT EXISTS admin_permissions (
    discord_id TEXT PRIMARY KEY,
    can_give_money BOOLEAN DEFAULT 0,
    can_take_money BOOLEAN DEFAULT 0,
    can_jail BOOLEAN DEFAULT 0,
    can_set_time BOOLEAN DEFAULT 0,
    can_teleport BOOLEAN DEFAULT 0,
    can_ban BOOLEAN DEFAULT 0,
    granted_by TEXT,
    granted_at DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (discord_id) REFERENCES discord_users(discord_id)
);

-- Sistem ayarları tablosu
CREATE TABLE IF NOT EXISTS system_settings (
    setting_key TEXT PRIMARY KEY,
    setting_value TEXT NOT NULL,
    description TEXT,
    updated_at DATETIME DEFAULT CURRENT_TIMESTAMP
);

-- Varsayılan ayarları ekle
INSERT OR REPLACE INTO system_settings (setting_key, setting_value, description) VALUES
('command_cooldown', '5', 'Komutlar arası bekleme süresi (saniye)'),
('max_money_transfer', '1000000', 'Maksimum para transfer miktarı'),
('jail_duration_default', '60', 'Varsayılan hapis süresi (dakika)'),
('discord_channel_logs', '', 'Log mesajlarının gönderileceği Discord kanalı'),
('mta_server_url', 'http://localhost:22005', 'MTA sunucu URL'),
('bot_status', 'active', 'Bot durumu (active/inactive)');

-- İndeksler oluştur
CREATE INDEX IF NOT EXISTS idx_command_logs_discord_id ON command_logs(discord_id);
CREATE INDEX IF NOT EXISTS idx_command_logs_timestamp ON command_logs(timestamp);
CREATE INDEX IF NOT EXISTS idx_command_logs_command ON command_logs(command);
CREATE INDEX IF NOT EXISTS idx_game_players_discord_id ON game_players(discord_id);
CREATE INDEX IF NOT EXISTS idx_game_players_player_name ON game_players(player_name);
