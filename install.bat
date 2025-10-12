@echo off
echo MTA SA Discord Komut Sistemi Kurulum
echo =====================================

echo.
echo 1. Discord Bot kurulumu basliyor...
cd discord-bot

echo Node.js modulleri yukleniyor...
call npm install

echo.
echo 2. .env dosyasi olusturuluyor...
if not exist .env (
    copy env.example .env
    echo .env dosyasi olusturuldu. Lutfen tokenlari girin.
) else (
    echo .env dosyasi zaten mevcut.
)

echo.
echo 3. Veritabani hazirlaniyor...
cd ..
if not exist database (
    mkdir database
)

echo.
echo 4. Log klasoru olusturuluyor...
if not exist logs (
    mkdir logs
)

echo.
echo Kurulum tamamlandi!
echo.
echo Sonraki adimlar:
echo 1. discord-bot/.env dosyasini duzenleyin
echo 2. Discord bot tokenini girin
echo 3. MTA sunucusuna dosyalari kopyalayin
echo 4. Discord bot'u baslatin: npm start
echo 5. MTA sunucusunu yeniden baslatin
echo.
pause
