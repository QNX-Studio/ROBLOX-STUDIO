# 🎨 LOADING SCREEN LOGO SETUP GUIDE

## Lokasi File Konfigurasi
- **File Config**: `LoadingScreenConfig.luau`
- **File Client**: `LoadingScreenClient.luau`

---

## 📍 TEMPAT MEMASUKKAN GAMBAR/LOGO

### **1️⃣ LOGO KOMUNITAS (RECOMMENDED)**
**Lokasi dalam file**: `LoadingScreenConfig.luau` (baris ~169-180)

```lua
-- 🎨 TAMBAHKAN GAMBAR KOMUNITAS ANDA DI SINI:
Config.SHOW_COMMUNITY_LOGO = true        -- Enable logo komunitas
Config.COMMUNITY_LOGO_IMAGE_ID = "rbxassetid://13509614097"  -- 👈 GANTI DENGAN ID GAMBAR ANDA!
```

**Letaknya di Loading Screen**: 
- 📍 **Atas tengah** (top center)
- Di atas progress bar
- Ukuran standar: 200x200 pixels
- Bisa di-customize dengan settings:
  - `Config.LOGO_SIZE` = Ukuran logo
  - `Config.LOGO_POSITION` = Posisi
  - `Config.LOGO_ROTATION` = Rotasi
  - `Config.LOGO_CORNER_RADIUS` = Rounded corner

---

### **2️⃣ BACKGROUND IMAGE (OPTIONAL)**
**Lokasi dalam file**: `LoadingScreenConfig.luau` (baris ~182-186)

```lua
-- 🎨 GAMBAR LATAR BELAKANG (OPSIONAL):
Config.SHOW_BACKGROUND_IMAGE = false     -- Set ke TRUE untuk enable
Config.BACKGROUND_IMAGE_ID = "rbxassetid://0"  -- 👈 GANTI DENGAN ID GAMBAR!
Config.BACKGROUND_IMAGE_TRANSPARENCY = 0.3  -- Transparansi (0-1)
```

**Letaknya di Loading Screen**:
- 📍 **Di belakang** semua elemen
- Full screen background
- Bisa dibuat transparan supaya tidak menutupi

---

## 🔑 CARA MENDAPATKAN IMAGE ID ROBLOX

### **Method 1: Upload Gambar Baru di ROBLOX Studio**

1. **Buka ROBLOX Studio** → File → Publish
2. Atau di **Asset Manager** (View → Asset Manager)
3. **Klik "Upload"** → Pilih gambar Anda (PNG/JPG recommended)
4. Tunggu upload selesai
5. **Copy Image ID** dari properties atau URL
6. Format: `rbxassetid://[NOMOR]`

### **Method 2: Cari Gambar yang Sudah Ada (Testing)**

Gunakan image ID publik untuk testing:
- Roblox Logo: `rbxassetid://656832664`
- Loading Animation: `rbxassetid://5804226251`
- Badge Icon: `rbxassetid://6022668135`

---

## 🎯 CONTOH SETUP LENGKAP

### **Skenario 1: Logo Komunitas Saja (RECOMMENDED)**

```lua
-- LoadingScreenConfig.luau

Config.SHOW_COMMUNITY_LOGO = true
Config.COMMUNITY_LOGO_IMAGE_ID = "rbxassetid://12345678"  -- ID gambar Anda
Config.LOGO_SIZE = UDim2.new(0, 200, 0, 200)              -- 200x200 pixels
Config.LOGO_POSITION = UDim2.new(0.5, -100, 0.15, 0)      -- Top center
Config.LOGO_ROTATION = 0

Config.SHOW_BACKGROUND_IMAGE = false     -- Tidak pakai background
```

**Hasil**: Logo komunitas tampil di tengah atas, loading bar di bawah

---

### **Skenario 2: Logo + Background (FANCY)**

```lua
-- LoadingScreenConfig.luau

Config.SHOW_COMMUNITY_LOGO = true
Config.COMMUNITY_LOGO_IMAGE_ID = "rbxassetid://12345678"
Config.LOGO_SIZE = UDim2.new(0, 250, 0, 250)
Config.LOGO_POSITION = UDim2.new(0.5, -125, 0.1, 0)

Config.SHOW_BACKGROUND_IMAGE = true      -- Enable background
Config.BACKGROUND_IMAGE_ID = "rbxassetid://87654321"
Config.BACKGROUND_IMAGE_TRANSPARENCY = 0.4  -- Semi-transparent
```

**Hasil**: Background theme + Logo di atas + Progress bar

---

### **Skenario 3: Background Hanya (Minimalist)**

```lua
Config.SHOW_COMMUNITY_LOGO = false
Config.SHOW_BACKGROUND_IMAGE = true
Config.BACKGROUND_IMAGE_ID = "rbxassetid://87654321"
Config.BACKGROUND_IMAGE_TRANSPARENCY = 0.2
```

**Hasil**: Background design dengan progress bar overlay

---

## 🚀 LANGKAH IMPLEMENTASI

### **Step 1: Persiapkan Gambar**
- Ukuran recommended: 
  - Logo: 512x512 px (akan di-scale ke 200x200)
  - Background: 1920x1080 px atau lebih besar
- Format: PNG (transparent) atau JPG
- Ukuran file: < 2 MB recommended

### **Step 2: Upload ke ROBLOX**
1. Buka **ROBLOX Studio** 
2. **Tools** → **Asset Manager** (atau View → Asset Manager)
3. **Upload Image** → Pilih file gambar
4. Tunggu upload complete
5. **Copy Image ID** (format: `12345678` tanpa `rbxassetid://`)

### **Step 3: Update Config**
1. Buka `LoadingScreenConfig.luau`
2. Cari baris dengan `Config.COMMUNITY_LOGO_IMAGE_ID`
3. Ganti dengan: `"rbxassetid://[IMAGE_ID_ANDA]"`
4. Set `Config.SHOW_COMMUNITY_LOGO = true`
5. **Save file** (Ctrl+S)

### **Step 4: Test Loading Screen**
1. **Play** game di ROBLOX Studio
2. Lihat loading screen dengan logo baru Anda
3. Adjust size/position jika perlu:
   - `Config.LOGO_SIZE` untuk ukuran
   - `Config.LOGO_POSITION` untuk posisi

---

## 🎛️ CUSTOMIZATION OPTIONS

### **Logo Size (Ukuran Logo)**
```lua
Config.LOGO_SIZE = UDim2.new(0, 200, 0, 200)  -- 200x200 pixels
Config.LOGO_SIZE = UDim2.new(0, 250, 0, 150)  -- 250 lebar, 150 tinggi
```

### **Logo Position (Posisi Logo)**
```lua
-- Format: UDim2.new(scaleX, offsetX, scaleY, offsetY)
Config.LOGO_POSITION = UDim2.new(0.5, -100, 0.1, 0)
-- 0.5 = 50% horizontal (center), -100 = offset left
-- 0.1 = 10% vertical, 0 = no offset
```

### **Logo Rotation (Rotasi Logo)**
```lua
Config.LOGO_ROTATION = 0      -- Normal
Config.LOGO_ROTATION = 15     -- Rotasi 15 derajat
Config.LOGO_ROTATION = 45     -- Rotasi 45 derajat
```

### **Corner Radius (Sudut Rounded)**
```lua
Config.LOGO_CORNER_RADIUS = 0      -- Persegi
Config.LOGO_CORNER_RADIUS = 10     -- Sedikit rounded
Config.LOGO_CORNER_RADIUS = 20     -- Rounded penuh (circle-ish)
```

### **Background Transparency (Transparansi Background)**
```lua
Config.BACKGROUND_IMAGE_TRANSPARENCY = 0    -- Fully opaque (solid)
Config.BACKGROUND_IMAGE_TRANSPARENCY = 0.5  -- 50% transparent
Config.BACKGROUND_IMAGE_TRANSPARENCY = 1    -- Fully invisible
```

---

## ❌ TROUBLESHOOTING

### Problem: Logo tidak muncul
- ✅ Cek `Config.SHOW_COMMUNITY_LOGO = true`
- ✅ Cek Image ID format: `rbxassetid://[ANGKA]`
- ✅ Pastikan gambar sudah di-upload ke ROBLOX

### Problem: Logo terpotong/tidak terlihat
- ✅ Ubah `Config.LOGO_SIZE` lebih besar
- ✅ Ubah `Config.LOGO_POSITION` agar tidak bertabrakan dengan element lain

### Problem: Background gambar buram/pixel
- ✅ Gunakan gambar dengan resolusi lebih tinggi
- ✅ Baca dari: https://www.roblox.com/develop

### Problem: Loading screen terasa berat (lag)
- ✅ Gunakan gambar dengan file size lebih kecil (compress)
- ✅ Kurangi besarnya `Config.BACKGROUND_IMAGE_TRANSPARENCY` atau disable background

---

## 📝 CATATAN

- ✅ Recommended: **Logo PNG transparent** agar terlihat rapi
- ✅ Gunakan **warna yang kontras** dengan background
- ✅ Test di berbagai resolusi (mobile, tablet, PC)
- ✅ Ukuran file < 2MB untuk loading cepat
- ✅ Image ID tetap valid selama ada di ROBLOX account Anda

---

## 🎯 QUICK REFERENCE

| Setting | Default | Min | Max | Rekomendasi |
|---------|---------|-----|-----|-------------|
| LOGO_SIZE | 200x200 | 100x100 | 400x400 | 200-250 |
| LOGO_POSITION | Top 10% | - | - | 0.05-0.15 |
| LOGO_ROTATION | 0° | 0° | 360° | 0° atau 15° |
| CORNER_RADIUS | 0 | 0 | 50 | 0 atau 10 |
| BG_TRANSPARENCY | 0.3 | 0 | 1 | 0.2-0.4 |

---

**✨ Loading screen komunitas Anda siap dibuat! Happy customizing! 🎉**
