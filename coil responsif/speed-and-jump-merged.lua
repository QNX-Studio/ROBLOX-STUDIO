-- ✅ Gabungan config-speed.lua + speed-and-jump.lua
-- Mengelola speed boost dan jump power dengan integrasi setting-coil-scs.lua
-- setting-coil-scs.lua akan menggunakan WalkSpeed untuk perhitungan responsivitas

local tool = script.Parent
local RunService = game:GetService("RunService")

-- ⚙️ CONFIG: Tipe Tool
-- Ubah sesuai kebutuhan: "coil" atau "boost"
local TOOL_TYPE = "coil"  -- "coil" (speed persistent) atau "boost" (simple add)

-- ⚙️ CONFIG: COIL MODE (untuk Spring/Coil tools)
local COIL_SETTINGS = {
	NORMAL_SPEED = 16,
	COIL_SPEED = 36,      -- Kecepatan tinggi (akan bekerja dengan setting-coil-scs)
	NORMAL_JUMP = 50,
	COIL_JUMP = 110       -- Lompat tinggi
}

-- ⚙️ CONFIG: BOOST MODE (untuk GlowStick dan tools biasa)
local BOOST_SETTINGS = {
	SPEED_BOOST = 15      -- Tambahan kecepatan
}

local connections = {}
local originalSpeed = nil
local originalJump = nil

-- Fungsi auto-detect tipe tool berdasarkan nama
local function detectToolType()
	local toolName = tool.Name:lower()
	if toolName:find("coil") or toolName:find("spring") then
		return "coil"
	end
	return "boost"
end

-- Gunakan deteksi otomatis jika diperlukan
if TOOL_TYPE == "auto" then
	TOOL_TYPE = detectToolType()
end

-- ============ COIL MODE ============
-- Maintain speed/jump terus-menerus via Heartbeat
-- Ini bekerja bersama setting-coil-scs yang juga menggunakan Heartbeat
local function equipCoil()
	local character = tool.Parent
	local humanoid = character:WaitForChild("Humanoid")
	
	if not humanoid then return end

	originalSpeed = humanoid.WalkSpeed
	originalJump = humanoid.JumpPower

	-- Heartbeat loop: Maintain COIL_SPEED agar setting-coil-scs bisa kalkulasi responsivitas dengan benar
	connections.coilSpeed = RunService.Heartbeat:Connect(function()
		if humanoid and humanoid.Parent then
			-- Jika belum diset ke COIL_SPEED, set sekarang
			if humanoid.WalkSpeed ~= COIL_SETTINGS.COIL_SPEED then
				humanoid.WalkSpeed = COIL_SETTINGS.COIL_SPEED
			end
			if humanoid.JumpPower ~= COIL_SETTINGS.COIL_JUMP then
				humanoid.JumpPower = COIL_SETTINGS.COIL_JUMP
			end
		end
	end)
end

local function unequipCoil()
	local character = tool.Parent
	local humanoid = character:FindFirstChild("Humanoid")

	-- Disconnect Heartbeat
	if connections.coilSpeed then
		connections.coilSpeed:Disconnect()
		connections.coilSpeed = nil
	end

	-- Kembalikan ke normal
	if humanoid then
		humanoid.WalkSpeed = COIL_SETTINGS.NORMAL_SPEED
		humanoid.JumpPower = COIL_SETTINGS.NORMAL_JUMP
	end
end

-- ============ BOOST MODE ============
-- Simple sekali: tambah speed saat equipped, kurangi saat unequipped
local function equipBoost()
	local character = tool.Parent
	local humanoid = character:FindFirstChildOfClass("Humanoid")
	
	if not humanoid then return end

	originalSpeed = humanoid.WalkSpeed
	originalJump = humanoid.JumpPower
	
	-- Tambah boost ke speed yang sudah ada
	humanoid.WalkSpeed = originalSpeed + BOOST_SETTINGS.SPEED_BOOST
end

local function unequipBoost()
	local character = tool.Parent
	local humanoid = character:FindFirstChild("Humanoid")

	-- Kembalikan ke speed awal
	if humanoid and originalSpeed then
		humanoid.WalkSpeed = originalSpeed
	end
end

-- ============ MAIN LOGIC ============
tool.Equipped:Connect(function()
	if TOOL_TYPE == "coil" then
		equipCoil()
	else
		equipBoost()
	end
end)

tool.Unequipped:Connect(function()
	if TOOL_TYPE == "coil" then
		unequipCoil()
	else
		unequipBoost()
	end
end)

-- Cleanup saat tool dihapus
tool.AncestryChanged:Connect(function(child, parent)
	if parent == nil then
		if connections.coilSpeed then
			connections.coilSpeed:Disconnect()
		end
	end
end)
