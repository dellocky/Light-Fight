--[[simple linked lists used to manage active entities,
dramatically speeds up entity and projectile spawning]]
--NOTE used to be something else, Pooled manager is a poor name but a refactor would take too long right now
local PooledManager = {}
PooledManager.__index = PooledManager

function PooledManager.new()
    local self = setmetatable({}, PooledManager)

    self.head = nil
    self.tail = nil

    return self
end

function PooledManager:register(obj)
    obj._next = nil
    obj._prev = self.tail

    if self.tail then
        self.tail._next = obj
    else
        self.head = obj
    end

    self.tail = obj
    return obj
end

function PooledManager:remove(obj)
    if obj._prev then
        obj._prev._next = obj._next
    else
        self.head = obj._next
    end

    if obj._next then
        obj._next._prev = obj._prev
    else
        self.tail = obj._prev
    end

    obj._next = nil
    obj._prev = nil
    return obj
end

function PooledManager:each()
    local current = self.head
    return function()
        local node = current
        if node then
            current = node._next
            return node
        end
    end
end


return PooledManager