-- GeneraMonedas.lua
-- ServerScriptService/RebirthCooldown.lua

local Players = game:GetService("Players")

local function configurarJugador(player)
	local rebirthCooldown = player:FindFirstChild("RebirthCooldown")

	if rebirthCooldown and rebirthCooldown:IsA("NumberValue") then
		rebirthCooldown.Value = 0
	end
end

Players.PlayerAdded:Connect(configurarJugador)

for _, player in ipairs(Players:GetPlayers()) do
	configurarJugador(player)
end
