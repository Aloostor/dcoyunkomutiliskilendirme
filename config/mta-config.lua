local CONFIG = {}

-- Discord Bot Ayarları
CONFIG.DISCORD = {
    BOT_TOKEN = "YOUR_DISCORD_BOT_TOKEN_HERE",
    CLIENT_ID = "YOUR_DISCORD_CLIENT_ID_HERE",
    GUILD_ID = "YOUR_DISCORD_SERVER_ID_HERE",
    ADMIN_ROLE_ID = "YOUR_ADMIN_ROLE_ID_HERE",
    LOG_CHANNEL_ID = "YOUR_LOG_CHANNEL_ID_HERE"
}

-- HTTP Server Ayarları
CONFIG.HTTP = {
    PORT = 22005,
    HOST = "localhost",
    TIMEOUT = 10000
}

-- Veritabanı Ayarları
CONFIG.DATABASE = {
    TYPE = "sqlite",
    HOST = "localhost",
    PORT = 3306,
    NAME = "mta_discord_commands",
    USER = "root",
    PASSWORD = "",
    SQLITE_FILE = "discord_commands.db"
}

-- Komut Ayarları
CONFIG.COMMANDS = {
    COOLDOWN = 5, -- Saniye
    MAX_PARAMETERS = 10,
    LOG_ALL_COMMANDS = true,
    REQUIRE_ACCOUNT_LINK = false -- Discord hesabı ile oyun hesabı bağlantısı gerekli mi
}

-- Para Sistemi Ayarları
CONFIG.MONEY = {
    MAX_TRANSFER = 1000000,
    MAX_GIVE = 5000000,
    MIN_AMOUNT = 1,
    CURRENCY_SYMBOL = "$"
}

-- Hapis Sistemi Ayarları
CONFIG.JAIL = {
    DEFAULT_DURATION = 60, -- Dakika
    MAX_DURATION = 1440, -- 24 saat
    MIN_DURATION = 1,
    JAIL_POSITION = {
        x = 1544.5,
        y = -1675.7,
        z = 13.6,
        interior = 0,
        dimension = 0
    },
    SPAWN_POSITION = {
        x = 1481.0,
        y = -1771.3,
        z = 18.8,
        interior = 0,
        dimension = 0
    }
}

-- Zaman Sistemi Ayarları
CONFIG.TIME = {
    MIN_HOUR = 0,
    MAX_HOUR = 23,
    MIN_MINUTE = 0,
    MAX_MINUTE = 59,
    DEFAULT_HOUR = 12,
    DEFAULT_MINUTE = 0
}

-- Yetki Seviyeleri
CONFIG.PERMISSIONS = {
    USER = {
        commands = {"ooc", "status", "paraver"}
    },
    ADMIN = {
        commands = {"bakiyever", "bakiyeal", "hapis", "hapiscikar", "zamanayarla"}
    },
    SUPER_ADMIN = {
        commands = {"ban", "kick", "teleport", "weather", "all"}
    }
}

-- Mesaj Şablonları
CONFIG.MESSAGES = {
    SUCCESS = {
        MONEY_GIVEN = "Oyuncu %s hesabına %d%s eklendi",
        MONEY_TAKEN = "Oyuncu %s hesabından %d%s alındı",
        MONEY_TRANSFERRED = "Oyuncu %s hesabına %d%s transfer edildi",
        PLAYER_JAILED = "Oyuncu %s hapse atıldı (%d dakika)",
        PLAYER_UNJAILED = "Oyuncu %s hapisten çıkarıldı",
        TIME_SET = "Oyun saati %02d:%02d olarak ayarlandı",
        OOC_SENT = "OOC mesajı gönderildi"
    },
    ERROR = {
        PLAYER_NOT_FOUND = "Oyuncu bulunamadı",
        INSUFFICIENT_MONEY = "Yeterli paranız yok",
        INVALID_AMOUNT = "Geçersiz miktar",
        INVALID_TIME = "Geçersiz saat formatı",
        NO_PERMISSION = "Bu komutu kullanmak için yetkiniz yok",
        COMMAND_COOLDOWN = "Komut bekleme süresinde, lütfen %d saniye bekleyin",
        INVALID_PARAMETERS = "Geçersiz parametreler",
        ACCOUNT_NOT_LINKED = "Discord hesabınız oyun hesabınızla bağlı değil"
    }
}

-- Log Ayarları
CONFIG.LOGGING = {
    ENABLED = true,
    LOG_TO_FILE = true,
    LOG_TO_CONSOLE = true,
    LOG_TO_DISCORD = true,
    LOG_LEVEL = "INFO", -- DEBUG, INFO, WARN, ERROR
    MAX_LOG_SIZE = 10485760, -- 10MB
    LOG_FILE = "logs/discord_commands.log"
}

-- Güvenlik Ayarları
CONFIG.SECURITY = {
    RATE_LIMIT = {
        ENABLED = true,
        MAX_REQUESTS = 10,
        WINDOW_SECONDS = 60
    },
    IP_WHITELIST = {
        ENABLED = false,
        ALLOWED_IPS = {"127.0.0.1", "localhost"}
    },
    COMMAND_VALIDATION = true,
    SANITIZE_INPUT = true
}

-- Performans Ayarları
CONFIG.PERFORMANCE = {
    MAX_CONCURRENT_REQUESTS = 50,
    REQUEST_TIMEOUT = 10000,
    DATABASE_POOL_SIZE = 10,
    CACHE_ENABLED = true,
    CACHE_TTL = 300 -- 5 dakika
}

-- Debug Ayarları
CONFIG.DEBUG = {
    ENABLED = false,
    VERBOSE_LOGGING = false,
    MOCK_RESPONSES = false,
    TEST_MODE = false
}

return CONFIG
