---
-- @module RxInstanceUtils
-- @author Quenty

local require = require(game:GetService("ReplicatedStorage"):WaitForChild("Nevermore"))

local Observable = require("Observable")
local Maid = require("Maid")
local Brio = require("Brio")

local RxInstanceUtils = {}

function RxInstanceUtils.observeProperty(instance, property)
	assert(typeof(instance) == "Instance")
	assert(type(property) == "string")

	return Observable.new(function(fire, fail, complete)
		local maid = Maid.new()

		maid:GiveTask(instance:GetPropertyChangedSignal(property):Connect(function()
			fire(instance[property])
		end))
		fire(instance[property])

		return maid
	end)
end

function RxInstanceUtils.observeValidPropertyBrio(instance, property, predicate)
	assert(typeof(instance) == "Instance")
	assert(type(property) == "string")
	assert(type(predicate) == "function" or predicate == nil)

	return Observable.new(function(fire, fail, complete)
		local maid = Maid.new()

		local function handlePropertyChanged()
			maid._property = nil

			local propertyValue = instance[property]
			if not predicate or predicate(propertyValue) then
				local brio = Brio.new(instance[property])
				maid._property = brio
				fire(brio)
			end
		end

		maid:GiveTask(instance:GetPropertyChangedSignal(property):Connect(handlePropertyChanged))
		handlePropertyChanged()

		return maid
	end)
end

function RxInstanceUtils.observeLastNamedChildBrio(parent, className, name)
	assert(typeof(parent) == "Instance")
	assert(type(className) == "string")
	assert(type(name) == "string")

	return Observable.new(function(fire, fail, complete)
		local topMaid = Maid.new()

		local function handleChild(child)
			if not child:IsA(className) then
				return
			end

			local maid = Maid.new()

			local function handleNameChanged()
				if child.Name == name then
					local brio = Brio.new(child)
					maid._brio = brio
					topMaid._lastBrio = brio

					fire(brio)
				else
					maid._brio = nil
				end
			end

			maid:GiveTask(child:GetPropertyChangedSignal("Name"):Connect(handleNameChanged))
			handleNameChanged()

			topMaid[child] = maid
		end

		topMaid:GiveTask(parent.ChildAdded:Connect(handleChild))
		topMaid:GiveTask(parent.ChildRemoved:Connect(function(child)
			topMaid[child] = nil
		end))

		for _, child in pairs(parent:GetChildren()) do
			handleChild(child)
		end

		return topMaid
	end)
end


-- FIres once, and then completes
function RxInstanceUtils.observeParentChangeFrom(child, parent)
	assert(child)
	assert(parent)
	assert(child.Parent == parent)

	return Observable.new(function(fire, fail, complete)
		if child.Parent ~= parent then
			fire()
			complete()
			return
		end

		local maid = Maid.new()

		maid:GiveTask(child:GetPropertyChangedSignal("Parent"):Connect(function()
			if child.Parent ~= parent then
				fire()
				complete()
			end
		end))

		return maid
	end)
end

function RxInstanceUtils.observeChildrenBrio(parent, predicate)
	assert(typeof(parent) == "Instance")
	assert(type(predicate) == "function" or predicate == nil)

	return Observable.new(function(fire, fail, complete)
		local maid = Maid.new()

		local function handleChild(child)
			if not predicate or predicate(child) then
				local value = Brio.new(child)
				maid[child] = value
				fire(value)
			end
		end

		maid:GiveTask(parent.ChildAdded:Connect(handleChild))
		maid:GiveTask(parent.ChildRemoved:Connect(function(child)
			maid[child] = nil
		end))

		for _, child in pairs(parent:GetChildren()) do
			handleChild(child)
		end

		return maid
	end)
end

return RxInstanceUtils