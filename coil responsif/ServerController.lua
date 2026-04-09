-- ServerController.lua
-- Glowstick: attach ke tangan, default putih, warna + trail (termasuk hitam)

local Tool = script.Parent
local Remote = Tool:WaitForChild("GlowRemote")

local lastChar
local DEFAULT_COLOR = Color3.fromRGB(24, 24, 255)

-- ===== Utilities =====
local function ensureTrail(stick)
	if not stick then return end
	local base = stick:FindFirstChild("Base") or Instance.new("Attachment", stick)
	base.Name = "Base"
	local tip  = stick:FindFirstChild("Tip")  or Instance.new("Attachment", stick)
	tip.Name = "Tip"

	local halfZ = (stick.Size and stick.Size.Z or 0.7)/2
	base.Position = Vector3.new(0,0,-halfZ)
	tip.Position  = Vector3.new(0,0, halfZ)

	local tr = stick:FindFirstChildOfClass("Trail")
	if not tr then
		tr = Instance.new("Trail")
		tr.Name = "GlowTrail"
		tr.Attachment0, tr.Attachment1 = base, tip
		tr.MinLength = 0
		tr.Lifetime = 0.35
		tr.LightEmission = 1
		tr.Transparency = NumberSequence.new{
			NumberSequenceKeypoint.new(0,0),
			NumberSequenceKeypoint.new(1,0.85)
		}
		tr.Parent = stick
	end
	tr.Color = ColorSequence.new(DEFAULT_COLOR)
	tr.Enabled = true
	return tr
end

local function setStickLightsEnabled(stick, on)
	if not stick then return end
	for _, d in ipairs(stick:GetChildren()) do
		if d:IsA("Light") then d.Enabled = on end
	end
	local tr = stick:FindFirstChildOfClass("Trail")
	if tr then tr.Enabled = on end
end

local function destroyJointsInCharacter(char)
	if not char then return end
	for _, j in ipairs(char:GetDescendants()) do
		if j:IsA("Motor6D") and (j.Name == "RightGlowstickJoint" or j.Name == "LeftGlowstickJoint") then
			j:Destroy()
		end
	end
end

local function restoreSticksToTool()
	for _, name in ipairs({"RightStick","LeftStick"}) do
		local stick = Tool:FindFirstChild(name)
		if not stick and lastChar then stick = lastChar:FindFirstChild(name) end
		if stick then
			stick.Anchored = true
			stick.CanCollide = false
			stick.Parent = Tool
			setStickLightsEnabled(stick, false)
		end
	end
end

local function getHands(char)
	local isR15 = char:FindFirstChild("UpperTorso") ~= nil
	local rightHand = isR15 and (char:FindFirstChild("RightHand")) or (char:FindFirstChild("Right Arm"))
	local leftHand  = isR15 and (char:FindFirstChild("LeftHand"))  or (char:FindFirstChild("Left Arm"))
	return rightHand, leftHand, isR15
end

local function attachStick(stick, hand, isRight, isR15)
	if not (stick and hand) then return end
	stick.Massless = true
	stick.CanCollide = false
	stick.Anchored = false
	ensureTrail(stick)

	for _, j in ipairs(hand:GetChildren()) do
		if j:IsA("Motor6D") and (j.Name == "RightGlowstickJoint" or j.Name == "LeftGlowstickJoint") then
			j:Destroy()
		end
	end

	local joint = Instance.new("Motor6D")
	joint.Part0 = hand
	joint.Part1 = stick
	joint.Name = isRight and "RightGlowstickJoint" or "LeftGlowstickJoint"
	local yaw = isRight and math.rad(90) or math.rad(-90)
	if isR15 then
		joint.C0 = CFrame.new(0, -0.28, -0.20) * CFrame.Angles(0, yaw, 0)
	else
		joint.C0 = CFrame.new(0, -1.00, -0.20) * CFrame.Angles(0, yaw, 0)
	end
	joint.Parent = hand
end

-- ===== EQUIP / UNEQUIP =====
Tool.Equipped:Connect(function()
	local char = Tool.Parent
	if not char then return end
	lastChar = char

	restoreSticksToTool()

	local rightStick = Tool:FindFirstChild("RightStick")
	local leftStick  = Tool:FindFirstChild("LeftStick")
	if not (rightStick and leftStick) then return end

	local rightHand, leftHand, isR15 = getHands(char)
	if not (rightHand and leftHand) then return end

	attachStick(rightStick, rightHand, true, isR15)
	attachStick(leftStick, leftHand, false, isR15)

	setStickLightsEnabled(rightStick, true)
	setStickLightsEnabled(leftStick,  true)

	local hum = char:FindFirstChildOfClass("Humanoid")
	if hum then
		hum.Died:Once(function()
			destroyJointsInCharacter(char)
			restoreSticksToTool()
			lastChar = nil
		end)
	end
end)

Tool.Unequipped:Connect(function()
	destroyJointsInCharacter(lastChar)
	restoreSticksToTool()
	lastChar = nil
end)

-- ===== REMOTE EVENTS =====
Remote.OnServerEvent:Connect(function(player, action, payload)
	local rightStick = Tool:FindFirstChild("RightStick")
	local leftStick  = Tool:FindFirstChild("LeftStick")
	if not (rightStick and leftStick) then return end

	if action == "setColor" and typeof(payload) == "Color3" then
		for _, stick in ipairs({rightStick, leftStick}) do
			stick.Color = payload
			for _, d in ipairs(stick:GetChildren()) do
				if d:IsA("Light") then
					d.Color = payload
				end
			end
			local tr = stick:FindFirstChildOfClass("Trail")
			if tr then
				tr.Enabled = true
				tr.Color = ColorSequence.new(payload) -- semua warna termasuk hitam
			end
		end

	elseif action == "toggleLights" then
		local sample = rightStick:FindFirstChildOfClass("PointLight")
		local nextOn = sample and (not sample.Enabled) or true
		setStickLightsEnabled(rightStick, nextOn)
		setStickLightsEnabled(leftStick,  nextOn)
	end
end)

-- default putih saat spawn
Tool.AncestryChanged:Connect(function(_, parent)
	if parent == workspace or parent == nil then
		for _, stick in ipairs({Tool:FindFirstChild("RightStick"), Tool:FindFirstChild("LeftStick")}) do
			if stick then
				stick.Color = DEFAULT_COLOR
				for _, d in ipairs(stick:GetChildren()) do
					if d:IsA("Light") then
						d.Color = DEFAULT_COLOR
					end
				end
				local tr = stick:FindFirstChildOfClass("Trail")
				if tr then
					tr.Color = ColorSequence.new(DEFAULT_COLOR)
					tr.Enabled = true
				end
			end
		end
	end
end)
