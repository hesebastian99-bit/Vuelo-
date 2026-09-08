local function supermanPose()
	if not character then
		return
	end

	local torso = character:FindFirstChild("UpperTorso")
		or character:FindFirstChild("Torso")

	if not torso then
		return
	end

	local rightShoulder = torso:FindFirstChild("RightShoulder")
	local leftShoulder = torso:FindFirstChild("LeftShoulder")

	-- Brazo derecho extendido hacia adelante
	if rightShoulder then
		rightShoulder.Transform =
			CFrame.Angles(
				math.rad(-95),
				math.rad(5),
				math.rad(8)
			)
	end

	-- Brazo izquierdo también levantado,
	-- ligeramente separado para dar apariencia de Superman
	if leftShoulder then
		leftShoulder.Transform =
			CFrame.Angles(
				math.rad(-80),
				math.rad(-5),
				math.rad(-12)
			)
	end

	-- Inclinar ligeramente el cuerpo hacia adelante
	local rootJoint = torso:FindFirstChild("Waist")

	if rootJoint then
		rootJoint.Transform =
			CFrame.Angles(
				math.rad(-12),
				0,
				0
			)
	end
end
