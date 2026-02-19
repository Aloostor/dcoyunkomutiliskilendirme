# MTA SA Discord Komut Sistemi

Bu sistem, MTA San Andreas sunucunuz ile Discord bot arasında komut ilişkilendirmesi sağlar. Oyuncular Discord üzerinden oyun komutlarını kullanabilir.

## 🎮 Mevcut Komutlar

### Kullanıcı Komutları
- `!ooc [mesaj]` - OOC mesaj gönder
- `!status` - Kendi durumunu gör
- `!paraver [oyuncu] [miktar]` - Oyuncuya para ver

### Admin Komutları
- `!bakiyever [oyuncu] [miktar]` - Oyuncuya para ekle
- `!bakiyeal [oyuncu] [miktar]` - Oyuncudan para al
- `!hapis [oyuncu] [süre]` - Oyuncuyu hapse at
- `!hapiscikar [oyuncu]` - Oyuncuyu hapisten çıkar
- `!zamanayarla [saat] [dakika]` - Oyun saatini ayarla

## 📋 Gereksinimler

### MTA SA Sunucu
- MTA SA Server 1.6+
- SQLite desteği
- HTTP modülü

### Discord Bot
- Node.js 16+
- Discord Bot Token
- Discord Server'da bot yetkileri

## 🚀 Kurulum

### 1. Discord Bot Oluşturma

1. [Discord Developer Portal](https://discord.com/developers/applications)'a gidin
2. "New Application" butonuna tıklayın
3. Bot sekmesine gidin ve "Add Bot" butonuna tıklayın
4. Bot token'ını kopyalayın
5. Bot'a gerekli yetkileri verin:
   - Send Messages
   - Use Slash Commands
   - Read Message History
   - Embed Links

### 2. Discord Bot Kurulumu

```bash
cd discord-bot
npm install
```

`.env` dosyasını oluşturun:
```env
DISCORD_BOT_TOKEN=your_bot_token_here
DISCORD_CLIENT_ID=your_client_id_here
DISCORD_GUILD_ID=your_server_id_here
DISCORD_ADMIN_ROLE_ID=your_admin_role_id_here
MTA_SERVER_URL=http://localhost:22005
PORT=3000
```

Bot'u başlatın:
```bash
npm start
```

### 3. MTA SA Kurulumu

1. `server.lua` ve `http-handler.lua` dosyalarını MTA sunucunuzun `resources` klasörüne kopyalayın
2. `meta.xml` dosyasını oluşturun:

```xml
<meta>
    <info author="Geoofy" type="script" name="Discord Commands" version="1.0" />
    <script src="server.lua" type="server" />
    <script src="http-handler.lua" type="server" />
    <file src="database/discord_commands.db" />
</meta>
```

3. Sunucuyu yeniden başlatın

### 4. Veritabanı Kurulumu

Veritabanı otomatik olarak oluşturulacaktır. Manuel kurulum için:

```bash
sqlite3 discord_commands.db < database/schema.sql
```

## ⚙️ Konfigürasyon

`config/mta-config.lua` dosyasında ayarları yapılandırın:

- Discord bot ayarları
- Komut izinleri
- Para limitleri
- Hapis koordinatları
- Mesaj şablonları

## 🔧 Kullanım

### Discord'da Komut Kullanımı

```
!ooc Merhaba herkese
!status
!paraver PlayerName 1000
!bakiyever PlayerName 5000
!hapis PlayerName 60
!zamanayarla 14 30
```

### Yetki Sistemi

- **Kullanıcı**: Temel komutlar (ooc, status, paraver)
- **Admin**: Tüm komutlar (para verme/alma, hapis, zaman ayarlama)
- **Super Admin**: Gelişmiş komutlar (ban, kick, teleport)

## 📊 Özellikler

- ✅ Discord ile MTA arasında gerçek zamanlı komut iletişimi
- ✅ Yetki sistemi (kullanıcı/admin)
- ✅ Komut geçmişi ve loglama
- ✅ SQLite veritabanı desteği
- ✅ HTTP API endpoint'leri
- ✅ Hata yönetimi ve güvenlik
- ✅ Rate limiting ve güvenlik önlemleri
- ✅ Komut cooldown sistemi

## 🔒 Güvenlik

- Rate limiting (dakikada maksimum 10 istek)
- Komut parametresi validasyonu
- Yetki kontrolü
- SQL injection koruması
- Input sanitization

## 📝 Loglama

Sistem şu bilgileri loglar:
- Tüm komut kullanımları
- Başarılı/başarısız işlemler
- Hata mesajları
- Kullanıcı aktiviteleri

## 🛠️ Geliştirme

### Yeni Komut Ekleme

1. `server.lua`'da komut handler fonksiyonu ekleyin
2. `http-handler.lua`'da komut işleme mantığını ekleyin
3. `bot.js`'de komut yetkilerini tanımlayın
4. `config/mta-config.lua`'da komut ayarlarını yapın

### Test Etme

```lua
-- MTA sunucusunda test komutu
/testdiscord status
```

## 🐛 Sorun Giderme

### Bot Bağlanamıyor
- Discord bot token'ını kontrol edin
- Bot'un sunucuda olduğundan emin olun
- İnternet bağlantısını kontrol edin

### Komutlar Çalışmıyor
- MTA sunucusu HTTP modülünü destekliyor mu?
- Port 22005 açık mı?
- Veritabanı dosyası yazılabilir mi?

### Yetki Sorunları
- Discord rol ID'lerini kontrol edin
- Bot'un gerekli yetkileri olduğundan emin olun
- Admin rolü doğru ayarlanmış mı?

## 📞 Destek

Sorunlarınız için:
- GitHub Issues açın
- Discord: aloostor

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.
---

**Not**: Bu sistem geliştirme amaçlıdır. Üretim ortamında kullanmadan önce güvenlik testlerini yapın.
