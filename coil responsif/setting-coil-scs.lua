local RunService = game:GetService("RunService")

local character = script.Parent
local humanoid = character:WaitForChild("Humanoid")
local root = character:WaitForChild("HumanoidRootPart")

-- ⚙️ Setting Feel
local groundControl = 0.95   -- makin besar makin responsif
local stopFriction = 0.15    -- makin besar makin nempel
local airControl = 0.75     -- kontrol saat di udara

RunService.Heartbeat:Connect(function()

	local moveDir = humanoid.MoveDirection
	local velocity = root.AssemblyLinearVelocity

	-- Kalau di tanah
	if humanoid.FloorMaterial ~= Enum.Material.Air then

		if moveDir.Magnitude > 0 then
			-- Arahkan velocity langsung sesuai WASD (biar belok instan)
			local targetVelocity = moveDir.Unit * humanoid.WalkSpeed
			root.AssemblyLinearVelocity = Vector3.new(
				targetVelocity.X * groundControl,
				velocity.Y,
				targetVelocity.Z * groundControl
			)
		else
			-- Stop langsung kalau lepas tombol
			root.AssemblyLinearVelocity = Vector3.new(
				velocity.X * (1 - stopFriction),
				velocity.Y,
				velocity.Z * (1 - stopFriction)
			)
		end

	else
		-- Air control kecil
		if moveDir.Magnitude > 0 then
			root.AssemblyLinearVelocity += moveDir.Unit * airControl
		end
	end

end)
