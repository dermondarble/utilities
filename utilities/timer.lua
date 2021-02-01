--[[

Timer:BindToStep(id, priority, callback)
Timer:UnbindFromStep(id)
Timer:BindToHeartbeat(id, priority, callback)
Timer:UnbindFromHeartbeat(id)
Timer:BindToRenderStep(id, priority, callback)
Timer:UnbindFromRenderStep(id)

Timer:Wait(t)
Timer:Delay(t, callback)
Timer:Schedule(t, callback)

]]

-- services

local RunService = game:GetService("RunService")

-- functions

local function Bind(i, p, c)
	return {
		ID = i;
		Priority = p;
		Callback = c;
	}
end

-- timer

local Timer = {
	_StepBinds = {};
	_HeartbeatBinds = {};
}

-- step
function Timer.BindToStep(self, id, priority, callback)
	table.insert(self._StepBinds, Bind(id, priority, callback))

	table.sort(self._StepBinds, function(a, b)
		return a.Priority < b.Priority
	end)
end

function Timer.UnbindFromStep(self, id)
	for i, bind in pairs(self._StepBinds) do
		if bind.ID == id then
			table.remove(self._StepBinds, i)
			return
		end
	end
end

-- heartbeat
function Timer.BindToHeartbeat(self, id, priority, callback)
	table.insert(self._HeartbeatBinds, Bind(id, priority, callback))

	table.sort(self._HeartbeatBinds, function (a, b)
		return a.Priority < b.Priority
	end)
end

function Timer.UnbindFromHeartbeat(self, id)
	for i, bind in pairs(self._HeartbeatBinds) do
		if bind.ID == id then
			table.remove(self._HeartbeatBinds, i)
			return
		end
	end
end

-- renderstep
function Timer.BindToRenderStep(_, id, priority, callback)
	return RunService:BindToRenderStep(id, priority, callback)
end

function Timer.UnbindFromRenderStep(_, id)
	return RunService:UnbindFromRenderStep(id)
end

-- waiting
function Timer.Wait(_, t)
	local elapsed
	local start = os.clock()
	repeat
		RunService.Stepped:Wait()
		elapsed = os.clock() - start
	until elapsed >= t
	return elapsed
end

function Timer.Delay(self, t, callback)
	-- wait t and call the callback, blocking
	self:Wait(t)
	callback()
end

function Timer.Schedule(self, t, callback)
	-- wait t and call the callback, no blocking
	-- TODO: make sure error throws work here
	coroutine.resume(coroutine.create(function()
		self:Delay(t, callback)
	end))
end

-- events

RunService.Stepped:Connect(function(_, deltaTime)
	for _, bind in pairs(Timer._StepBinds) do
		bind.Callback(deltaTime)
	end
end)

RunService.Heartbeat:Connect(function(deltaTime)
	for _, bind in pairs(Timer._HeartbeatBinds) do
		bind.Callback(deltaTime)
	end
end)

return Timer