-- ✅ Gabungan ConfighandleHand.lua + ConfighandleHand1.lua
-- Menangani positioning handle tool di tangan karakter dengan smart prioritas

local tool = script.Parent

-- Fungsi cek apakah tangan sudah memegang tool lain
local function isHandOccupied(hand)
	for _, child in ipairs(hand:GetChildren()) do
		if child:IsA("Motor6D") and (child.Name == "RightGrip" or child.Name == "RightGripCustom" or child.Name == "LeftGrip") then
			return true
		end
	end
	return false
end

-- Fungsi untuk attach handle ke tangan
local function attachHandle(hand, handle, gripName)
	if not hand or not handle then return end
	
	local weld = Instance.new("Motor6D")
	weld.Name = gripName
	weld.Part0 = hand
	weld.Part1 = handle
	-- Posisi natural - sedikit ke bawah dan sudut 30 derajat
	weld.C0 = CFrame.new(0, -0.2, 0) * CFrame.Angles(math.rad(30), 0, 0)
	weld.Parent = hand
end

tool.Equipped:Connect(function()
	local char = tool.Parent
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	-- Cari tangan kanan dan kiri
	local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
	local leftHand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")

	-- Cari handle kanan dan kiri di tool
	local handleRight = tool:FindFirstChild("HandleRight") or tool:FindFirstChild("Handle")
	local handleLeft = tool:FindFirstChild("HandleLeft")

	-- === PRIORITAS SMART POSITIONING ===
	-- Jika ada HandleRight dan HandleLeft, gunakan kedua tangan
	if handleRight and handleLeft and rightHand and leftHand then
		attachHandle(rightHand, handleRight, "RightGripCustom")
		attachHandle(leftHand, handleLeft, "LeftGrip")
	
	-- Jika hanya satu handle, pakai tangan yang kosong dengan prioritas kanan
	elseif handleRight then
		if rightHand and not isHandOccupied(rightHand) then
			attachHandle(rightHand, handleRight, "RightGripCustom")
		elseif leftHand and not isHandOccupied(leftHand) then
			attachHandle(leftHand, handleRight, "LeftGrip")
		else
			-- Fallback: paksa tangan kanan
			if rightHand then
				attachHandle(rightHand, handleRight, "RightGripCustom")
			end
		end
	
	-- Jika hanya HandleLeft
	elseif handleLeft and leftHand then
		if not isHandOccupied(leftHand) then
			attachHandle(leftHand, handleLeft, "LeftGrip")
		elseif rightHand and not isHandOccupied(rightHand) then
			attachHandle(rightHand, handleLeft, "RightGripCustom")
		else
			attachHandle(leftHand, handleLeft, "LeftGrip")
		end
	end
end)

tool.Unequipped:Connect(function()
	local char = tool.Parent
	if char then
		for _, limb in ipairs({"RightHand", "Right Arm", "LeftHand", "Left Arm"}) do
			local part = char:FindFirstChild(limb)
			if part then
				for _, v in ipairs(part:GetChildren()) do
					if v:IsA("Motor6D") and (v.Name == "RightGripCustom" or v.Name == "LeftGrip") then
						v:Destroy()
					end
				end
			end
		end
	end
end)
