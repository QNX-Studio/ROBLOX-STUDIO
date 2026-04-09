-- ClientController.lua - FULL DEBUG VERSION
-- PC: Tekan R untuk ganti warna
-- Mobile: Tap layar mana saja untuk ganti warna
-- Keduanya: Klik tool untuk toggle lampu

local Tool = script.Parent
local Remote = Tool:WaitForChild("GlowRemote", 10)
local UIS = game:GetService("UserInputService")
local Players = game:GetService("Players")
local player = Players.LocalPlayer

print("========================================")
print("CLIENT CONTROLLER LOADED")
print("Tool:", Tool.Name)
print("Remote found:", Remote ~= nil)
print("Player:", player.Name)
print("========================================")

-- Siklus warna
local colorWheel = {
	Color3.fromRGB(0, 255, 170),
	Color3.fromRGB(255, 0, 110),
	Color3.fromRGB(255, 170, 0),
	Color3.fromRGB(0, 170, 255),
	Color3.fromRGB(255, 170, 255),
	Color3.fromRGB(24, 226, 248)
}
local colorIndex = 1

-- Connection storage
local inputConn = nil
local activatedConn = nil

-- Cleanup
local function cleanup()
	if inputConn then
		inputConn:Disconnect()
		inputConn = nil
		print("🧹 Input disconnected")
	end
	if activatedConn then
		activatedConn:Disconnect()
		activatedConn = nil
		print("🧹 Activated disconnected")
	end
end

-- Ganti warna
local function changeColor()
	colorIndex = (colorIndex % #colorWheel) + 1
	local newColor = colorWheel[colorIndex]

	print("🎨 Attempting to change color...")
	print("   Index:", colorIndex)
	print("   Color:", newColor)

	-- Try FireServer
	local success, err = pcall(function()
		Remote:FireServer("setColor", newColor)
	end)

	if success then
		print("   ✅ FireServer SUCCESS")
	else
		warn("   ❌ FireServer FAILED:", err)
	end
end

-- EQUIPPED EVENT
local equippedConn = Tool.Equipped:Connect(function()
	print("========================================")
	print("⚡ TOOL EQUIPPED BY:", player.Name)
	print("========================================")

	-- Cleanup old
	cleanup()

	-- Setup input detection
	inputConn = UIS.InputBegan:Connect(function(input, gpe)
		print("📥 INPUT DETECTED:")
		print("   Type:", input.UserInputType.Name)
		print("   KeyCode:", input.KeyCode.Name)
		print("   GameProcessed:", gpe)

		if gpe then
			print("   ⏭️ Skipped (GUI processed)")
			return
		end

		-- PC: R key
		if input.UserInputType == Enum.UserInputType.Keyboard and input.KeyCode == Enum.KeyCode.R then
			print("   🎯 R KEY PRESSED!")
			changeColor()
		end

		-- Mobile: Touch anywhere
		if input.UserInputType == Enum.UserInputType.Touch then
			print("   👆 SCREEN TAPPED!")
			changeColor()
		end
	end)

	-- Toggle lights
	activatedConn = Tool.Activated:Connect(function()
		print("========================================")
		print("💡 TOOL ACTIVATED (Toggle Lights)")
		print("========================================")

		local success, err = pcall(function()
			Remote:FireServer("toggleLights")
		end)

		if success then
			print("   ✅ Toggle SUCCESS")
		else
			warn("   ❌ Toggle FAILED:", err)
		end
	end)

	print("✅ Input listeners ready!")
	print("   PC: Press R to change color")
	print("   Mobile: Tap screen to change color")
	print("   Both: Click tool to toggle lights")
end)

-- UNEQUIPPED EVENT
local unequippedConn = Tool.Unequipped:Connect(function()
	print("========================================")
	print("📤 TOOL UNEQUIPPED")
	print("========================================")
	cleanup()
end)

-- Cleanup on destroy
script.Destroying:Connect(function()
	print("🗑️ Script destroying, cleaning up...")
	cleanup()
	if equippedConn then equippedConn:Disconnect() end
	if unequippedConn then unequippedConn:Disconnect() end
end)

print("✅ ClientController ready and waiting...")