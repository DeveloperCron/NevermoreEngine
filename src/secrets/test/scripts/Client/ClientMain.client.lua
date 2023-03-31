--[[
	@class ClientMain
]]
local packages = game:GetService("ReplicatedStorage"):WaitForChild("Packages")

local serviceBag = require(packages.ServiceBag).new()
serviceBag:GetService(packages.SecretsServiceClient)

-- Start game
serviceBag:Init()
serviceBag:Start()

