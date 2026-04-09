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

tool.Equipped:Connect(function()
	local char = tool.Parent
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	-- Cari tangan kanan dan kiri
	local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
	local leftHand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")

	-- Prioritas: gunakan tangan kanan dulu, kalau penuh pakai kiri
	local targetHand = nil
	local handleToUse = nil
	local gripName = ""

	if rightHand and not isHandOccupied(rightHand) then
		targetHand = rightHand
		handleToUse = tool:FindFirstChild("HandleRight") or tool:FindFirstChild("Handle")
		gripName = "RightGripCustom"
	elseif leftHand and not isHandOccupied(leftHand) then
		targetHand = leftHand
		handleToUse = tool:FindFirstChild("HandleLeft") or tool:FindFirstChild("Handle")
		gripName = "LeftGrip"
	else
		-- Fallback: paksa pakai tangan kanan (timpa tool lain)
		targetHand = rightHand
		handleToUse = tool:FindFirstChild("HandleRight") or tool:FindFirstChild("Handle")
		gripName = "RightGripCustom"
	end

	if targetHand and handleToUse then
		local weld = Instance.new("Motor6D")
		weld.Name = gripName
		weld.Part0 = targetHand
		weld.Part1 = handleToUse
		-- Posisi button natural
		weld.C0 = CFrame.new(0, -0.2, 0) * CFrame.Angles(math.rad(30), 0, 0)
		weld.Parent = targetHand
	end
end)

tool.Unequipped:Connect(function()
	local char = tool.Parent
	if char then
		for _, limb in ipairs({"RightHand","Right Arm","LeftHand","Left Arm"}) do
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