--[[
    LOADING SCREEN CONFIGURATION - ORBITAL CAMERA
    Lokasi: ReplicatedFirst > LoadingScreen > LoadingScreenConfig
    Tipe: ModuleScript
    
    Config untuk orbital camera system (tidak pakai CamPoint lagi!)
--]]

local Config = {}

-- ========================================
-- ?? PLAYER CONTROL SETTINGS
-- ========================================
Config.DISABLE_PLAYER_MOVEMENT = true    -- Matikan WASD movement
Config.FREEZE_CHARACTER = true           -- Freeze character position
Config.DISABLE_JUMPING = true            -- Matikan jump
Config.ANCHOR_CHARACTER = true           -- Lock character in place (uses BodyPosition, not Anchor)

-- ? WALKING ANIMATION BEHAVIOR:
-- Sistem ini menggunakan BodyPosition & BodyGyro (BUKAN Anchor):
-- - Player TIDAK bisa gerak kemana-mana (terkunci di tempat)
-- - Tapi ANIMASI tetap bisa jalan (idle, walking, dll)
-- - Character terlihat "hidup" dengan animasi idle/walking
-- - Lebih natural daripada statue diam total!
-- - Saat loading selesai, BodyPosition dihapus dan player bisa gerak normal

-- ========================================
-- ?? TIMING SETTINGS
-- ========================================
Config.MIN_LOADING_TIME = 60            -- Minimum waktu loading (detik)
Config.MESSAGE_CHANGE_INTERVAL = 2      -- Interval ganti loading message (detik)

-- ========================================
-- ?? ORBITAL CAMERA SETTINGS
-- ========================================

-- Orbit animation
Config.ORBIT_SPEED = 12                  -- Kecepatan orbit (derajat/detik) - semakin besar = semakin cepat
Config.ORBIT_DISTANCE = 25               -- Jarak kamera dari player (studs) - JAUH!
Config.ORBIT_HEIGHT_START = 15           -- Tinggi awal orbit (studs) - TINGGI BANGET!
Config.ORBIT_HEIGHT_END = 20             -- Tinggi akhir orbit (studs) - MAKIN TINGGI!
Config.ORBIT_HEIGHT_ANIMATION = true     -- Animasi perubahan tinggi saat orbit
Config.ORBIT_HEIGHT_DURATION = 20        -- Durasi animasi tinggi (detik)

-- ========================================
-- ?? INTRO ANIMATION (Depan ? Mundur Jauh & Naik Tinggi)
-- ========================================
Config.INTRO_ENABLED = true
Config.INTRO_DISTANCE_START = 7          -- Jarak awal dari player (depan)
Config.INTRO_DISTANCE_END = 20           -- Jarak akhir (MUNDUR JAUH!)
Config.INTRO_HEIGHT_START = 1.5          -- Tinggi awal (depan player)
Config.INTRO_HEIGHT_END = 15             -- Tinggi akhir (NAIK TINGGI BANGET!)
Config.INTRO_DURATION = 4                -- Durasi intro (detik)
Config.INTRO_EASE_STYLE = Enum.EasingStyle.Quad
Config.INTRO_EASE_DIRECTION = Enum.EasingDirection.Out

-- ========================================
-- ?? OUTRO ANIMATION (Dari Jauh ? Jalan Mendekati Player)
-- ========================================
Config.OUTRO_ENABLED = true
Config.OUTRO_DISTANCE_START = 20         -- Jarak awal (JAUH!)
Config.OUTRO_DISTANCE_END = 5            -- Jarak akhir (dekat player)
Config.OUTRO_HEIGHT_START = 15           -- Tinggi awal (dari atas)
Config.OUTRO_HEIGHT_END = 0              -- Tinggi akhir (eye level)
Config.OUTRO_DURATION = 3.5              -- Durasi outro (detik)
Config.OUTRO_EASE_STYLE = Enum.EasingStyle.Quad
Config.OUTRO_EASE_DIRECTION = Enum.EasingDirection.InOut

-- ========================================
-- ?? PROGRESS BAR SETTINGS
-- ========================================
Config.SHOW_PROGRESS_BAR = true
Config.SHOW_PERCENTAGE = true

-- ========================================
-- ?? FADE SETTINGS
-- ========================================
Config.START_WITH_BLACK = true           -- Mulai dengan layar hitam
Config.FADE_IN_DURATION = 1.0            -- Durasi fade in (detik)

-- ========================================
-- ? BLUR SETTINGS
-- ========================================
Config.BLUR_SIZE = 10                    -- Blur intensity (0-56)
Config.TRANSPARENT_BACKGROUND = true     -- Background transparan (hanya blur)

-- ========================================
-- ? SKIP BUTTON SETTINGS
-- ========================================
Config.SKIP_BUTTON_ENABLED = true        -- Enable skip button
Config.SKIP_BUTTON_THRESHOLD = 0.10      -- Progress threshold untuk show skip button (10%)

-- ========================================
-- ?? COMMUNITY LOGO/IMAGE SETTINGS
-- ========================================
-- 🖼️ TAMBAHKAN GAMBAR KOMUNITAS ANDA DI SINI:
Config.SHOW_COMMUNITY_LOGO = true        -- Enable logo komunitas
Config.COMMUNITY_LOGO_IMAGE_ID = "rbxassetid://13509614097"  -- 👈 GANTI DENGAN ID GAMBAR ANDA!
-- Cara mendapatkan Image ID:
-- 1. Upload gambar ke ROBLOX Studio
-- 2. Copy ID dari Address bar atau properties
-- 3. Format: "rbxassetid://[NOMOR]"

Config.LOGO_SIZE = UDim2.new(0, 200, 0, 200)  -- Ukuran logo (panjang x tinggi)
Config.LOGO_POSITION = UDim2.new(0.5, -100, 0.1, 0)  -- Posisi logo (horizontal center, top 10%)
Config.LOGO_Y_OFFSET = 30               -- Offset vertikal dari top (pixels)
Config.LOGO_ROTATION = 0                -- Rotasi logo (derajat)
Config.LOGO_CORNER_RADIUS = 0           -- Rounded corner (0 = persegi)

-- ========================================
-- ?? SPINNER SETTINGS
-- ========================================
Config.SPINNER_ENABLED = true            -- Enable spinner icon di progress bar

-- ========================================
-- ?? LOADING MESSAGES
-- ========================================
Config.LOADING_MESSAGES = {
	"Initializing Game...",
	"Loading Assets...",
	"Building World...",
	"Preparing Environment...",
	"Loading Characters...",
	"Setting Up Physics...",
	"Optimizing Graphics...",
	"Loading Audio...",
	"Finalizing Setup...",
	"Almost Ready...",
	"Get Ready!",
}

-- ========================================
-- ?? PROGRESS STAGES
-- ========================================
Config.PROGRESS_STAGES = {
	{name = "Initializing...", target = 0.15, percent = 0.15},
	{name = "Loading Assets...", target = 0.35, percent = 0.20},
	{name = "Building World...", target = 0.60, percent = 0.25},
	{name = "Preparing Game...", target = 0.85, percent = 0.25},
	{name = "Almost Ready...", target = 0.95, percent = 0.15},
}

-- ========================================
-- ?? BANNER/BACKGROUND IMAGE SETTINGS (OPTIONAL)
-- ========================================
-- 🖼️ GAMBAR LATAR BELAKANG (OPSIONAL):
Config.SHOW_BACKGROUND_IMAGE = false     -- Enable background image
Config.BACKGROUND_IMAGE_ID = "rbxassetid://0"  -- 👈 GANTI DENGAN ID GAMBAR BACKGROUND!
Config.BACKGROUND_IMAGE_TRANSPARENCY = 0.3  -- Transparansi (0 = fully opaque, 1 = invisible)

-- ========================================
-- ?? DEBUG SETTINGS
-- ========================================
Config.DEBUG_MODE = true                 -- Print debug messages
Config.VERBOSE_LOGS = true               -- Print verbose logs

-- =====================

return Config