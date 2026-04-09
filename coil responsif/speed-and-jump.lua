local tool = script.Parent

local NORMAL_SPEED = 16
local COIL_SPEED = 36

local NORMAL_JUMP = 50
local COIL_JUMP = 110

local connections = {}

tool.Equipped:Connect(function()
	local character = tool.Parent
	local humanoid = character:WaitForChild("Humanoid")

	-- Paksa speed terus selama coil dipakai
	connections.speed = game:GetService("RunService").Heartbeat:Connect(function()
		if humanoid and humanoid.Parent then
			humanoid.WalkSpeed = COIL_SPEED
			humanoid.JumpPower = COIL_JUMP
		end
	end)
end)

tool.Unequipped:Connect(function()
	local character = tool.Parent
	local humanoid = character:FindFirstChild("Humanoid")

	if connections.speed then
		connections.speed:Disconnect()
		connections.speed = nil
	end

	if humanoid then
		humanoid.WalkSpeed = NORMAL_SPEED
		humanoid.JumpPower = NORMAL_JUMP
	end
end)


