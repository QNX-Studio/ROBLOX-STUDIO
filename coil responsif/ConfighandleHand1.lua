local tool = script.Parent

tool.Equipped:Connect(function()
	local char = tool.Parent
	local humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	-- ====== Handle Kanan (manual) ======
	local handleRight = tool:FindFirstChild("HandleRight")
	if handleRight then
		local rightHand = char:FindFirstChild("RightHand") or char:FindFirstChild("Right Arm")
		if rightHand then
			local weldR = Instance.new("Motor6D")
			weldR.Name = "RightGripCustom"
			weldR.Part0 = rightHand
			weldR.Part1 = handleRight
			-- Posisi stick kanan natural
			weldR.C0 = CFrame.new(0, -0.2, 0) * CFrame.Angles(30, 0, 0)
			weldR.Parent = rightHand
		end
	end

	-- ====== Handle Kiri ======
	local handleLeft = tool:FindFirstChild("HandleLeft")
	if handleLeft then
		local leftHand = char:FindFirstChild("LeftHand") or char:FindFirstChild("Left Arm")
		if leftHand then
			local weldL = Instance.new("Motor6D")
			weldL.Name = "LeftGrip"
			weldL.Part0 = leftHand
			weldL.Part1 = handleLeft
			-- Posisi stick kiri natural
			weldL.C0 = CFrame.new(0, -0.2, 0) * CFrame.Angles(30, 0, 0)

			weldL.Parent = leftHand
		end
	end
end)

tool.Unequipped:Connect(function()
	local char = tool.Parent
	if char then
		for _, limb in ipairs({"RightHand","Right Arm","LeftHand","Left Arm"}) do
			local part = char:FindFirstChild(limb)
			if part then
				for _,v in ipairs(part:GetChildren()) do
					if v:IsA("Motor6D") and (v.Name == "RightGripCustom" or v.Name == "LeftGrip") then
						v:Destroy()
					end
				end
			end
		end
	end
end)
