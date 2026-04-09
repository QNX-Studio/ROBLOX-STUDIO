local tool = script.Parent
local humanoid
local animator -- Objek Animator baru
local runTrack, idleTrack
local runningConn

-- Animasi ID (ganti ikut animasi awak)
local idleAnim = Instance.new("Animation")
idleAnim.AnimationId = "rbxassetid://103728282064378" -- Ganti dengan ID Idle milik Anda

local runAnim = Instance.new("Animation")
runAnim.AnimationId = "rbxassetid://137049885702992" -- Ganti dengan ID Run milik Anda

tool.Equipped:Connect(function()
	local char = tool.Parent
	humanoid = char:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	-- Dapatkan atau tunggu objek Animator di dalam Humanoid
	animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	-- Load animasi menggunakan Animator
	idleTrack = animator:LoadAnimation(idleAnim)
	runTrack = animator:LoadAnimation(runAnim)

	-- Atur Priority (Idle harus yang paling rendah, Run bisa di Action)
	idleTrack.Priority = Enum.AnimationPriority.Idle
	runTrack.Priority = Enum.AnimationPriority.Action -- Action lebih tinggi dari Movement

	idleTrack:Play()

	-- Pantau kecepatan
	runningConn = humanoid.Running:Connect(function(speed)
		local state = humanoid:GetState()

		-- Buat tabel kondisi di mana animasi default/lain harus mengambil alih
		local isDefaultOverriding = (
			state == Enum.HumanoidStateType.Climbing or
				state == Enum.HumanoidStateType.Freefall or
				state == Enum.HumanoidStateType.Jumping or
				state == Enum.HumanoidStateType.Swimming or
				state == Enum.HumanoidStateType.Landed -- Opsional: Tambahkan Landed
		)

		if isDefaultOverriding then
			-- Jika kondisi default (seperti lompat/jatuh) aktif, hentikan animasi kustom
			if idleTrack and idleTrack.IsPlaying then idleTrack:Stop() end
			if runTrack and runTrack.IsPlaying then runTrack:Stop() end
			return
		end

		-- Idle / Run custom
		if speed > 0.1 then -- Gunakan threshold speed > 0.1 untuk lebih stabil
			-- Karakter bergerak
			if runTrack and not runTrack.IsPlaying then runTrack:Play() end
			if idleTrack and idleTrack.IsPlaying then idleTrack:Stop() end
		else
			-- Karakter diam
			if idleTrack and not idleTrack.IsPlaying then idleTrack:Play() end
			if runTrack and runTrack.IsPlaying then runTrack:Stop() end
		end
	end)
end)

tool.Unequipped:Connect(function()
	-- Hentikan animasi
	if idleTrack then idleTrack:Stop() idleTrack = nil end
	if runTrack then runTrack:Stop() runTrack = nil end

	-- Reset variabel animator
	animator = nil

	-- Putuskan connection
	if runningConn then
		runningConn:Disconnect()
		runningConn = nil
	end
end)