--- Control appearance of model being placed
-- @classmod ModelAppearance

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local qMath = require("qMath")

local ModelAppearance = {}
ModelAppearance.ClassName = "ModelAppearance"
ModelAppearance.__index = ModelAppearance

function ModelAppearance.new(model)
	local self = setmetatable({}, ModelAppearance)

	self._parts = {}
	self._interactions = {}
	self._seats = {}

	for _, part in pairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			self._parts[part] = {
				Transparency = part.Transparency;
				Color = part.Color;
				Material = part.Material;
				CanCollide = part.CanCollide;
			}

			if part:IsA("Seat") or part:IsA("VehicleSeat") then
				self._seats[part] = part
			end
		elseif part:IsA("ClickDetector") or part:IsA("BodyMover") then
			table.insert(self._interactions, part)
		end
	end


	return self
end

function ModelAppearance:DisableInteractions()
	for _, item in pairs(self._interactions) do
		item:Destroy()
	end
	self._interactions = {}
	for seat, _ in pairs(self._seats) do
		seat.Disabled = true
	end

	self:SetCanCollide(false)
end

function ModelAppearance:SetCanCollide(canCollide)
	assert(type(canCollide) == "boolean")

	if self._canCollide == canCollide then
		return
	end

	self._canCollide = canCollide
	for part, properties in pairs(self._parts) do
		part.CanCollide = properties.CanCollide and canCollide

	end
end

function ModelAppearance:SetTransparency(transparency)
	if self._transparency == transparency then
		return
	end

	self._transparency = transparency
	for part, properties in pairs(self._parts) do
		part.Transparency = qMath.MapNumber(transparency, 0, 1, properties.Transparency, 1)
	end
end

function ModelAppearance:ResetTransparency()
	if not self._transparency then
		return
	end

	self._transparency = nil
	for part, properties in pairs(self._parts) do
		part.Transparency = properties.Transparency
	end
end

function ModelAppearance:SetColor(color)
	assert(typeof(color) == "Color3")

	if self._color == color then
		return
	end

	self._color = color
	for part, _ in pairs(self._parts) do
		part.Color = color
	end
end

function ModelAppearance:ResetColor()
	if not self._color then
		return
	end

	self._color = nil
	for part, properties in pairs(self._parts) do
		part.Color = properties.Color
	end
end

function ModelAppearance:ResetMaterial()
	if not self._material then
		return
	end

	self._material = nil
	for part, properties in pairs(self._parts) do
		part.Material = properties.Material
	end
end

function ModelAppearance:SetMaterial(material)
	if self._material == material then
		return
	end

	self._material = material
	for part, _ in pairs(self._parts) do
		part.Material = material
	end
end

return ModelAppearance