-- functions

local function Destroy(obj)
	if obj == nil then
		return true
	end

	if typeof(obj) == "function" then
		obj()
	elseif typeof(obj) == "RBXScriptConnection" or obj.Disconnect then
		obj:Disconnect()
	elseif typeof(obj) == "Instance" or obj.Destroy() then
		obj:Destroy()
	else
		return false
	end

	return true
end

-- module

local Maid = {}

function Maid.new()
	local maid = {
		ClassName = "Maid";
		Destroyed = false;
		Objects = {};
	}

	setmetatable(maid, {
		__index = function(self, index)
			if self.Objects[index] ~= nil then
				return self.Objects[index]
			else
				return Maid[index]
			end
		end;
		-- this is cool thanks hutch
		__newindex = function(self, index, value)
			rawset(self, index, nil)
			return self:Give(value, index)
		end;
	})

	return maid
end

function Maid.Give(self, obj, ind)
	if self.Destroyed then
		return Destroy(obj)
	else
		local index = ind or #self.Objects + 1
		local old = self.Objects[index]

		if obj ~= old then
			self.Objects[index] = obj
		end

		if old then
			if not Destroy(old) then
				warn(string.format("Maid failed to destroy %q", index), old)
			end
		end

		return obj
	end
end

function Maid.Remove(self, obj)
	for index, other in pairs(self.Objects) do
		if other == obj then
			self.Objects[index] = nil
			return obj
		end
	end
end

function Maid.Clean(self)
	for index, obj in pairs(self.Objects) do
		if not Destroy(obj) then
			warn(string.format("Maid failed to destroy %q", index), obj)
		end
	end

	table.clear(self.Objects)
end

function Maid.Destroy(self)
	self.Destroyed = true
	self:Clean()
end

return Maid