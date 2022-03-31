local signal = newproxy(true)

local signaltbl = {
    new = function()
        local callbacks = {}

        local tbl
        tbl = {
            connect = function(self, func)
                local idx = #callbacks + 1
                table.insert(callbacks, func)
                
                return setmetatable({
                    disconnect = function()
                        table.remove(callbacks, idx)
                    end
                }, {
                    __index = function(self, k)
                        return rawget(self, k:lower())
                    end
                })
            end,
            
            fire = function(self, ...)
                for _, callback in next, callbacks do
                    callback(...)
                end
            end,
            
            wait = function(self)
                local done = false
                
                local connection = self:connect(function()
                    done = true
                end)
                
                repeat wait() until done
                connection:disconnect()
            end,
            
            destroy = function()
                table.clear(tbl)
            end
        }

        local userdata = newproxy(true)
        local mt = getmetatable(userdata)

        mt.__index = function(_, k)
            return rawget(tbl, k)
        end

        mt.__metatable = "This metatable is locked"

        mt.__tostring = function()
            return "Signal"
        end

        setreadonly(mt, true)

        return userdata
    end
}

local mt = getmetatable(signal)

mt.__index = function(_, k)
    return rawget(signaltbl, k:lower())
end

mt.__metatable = "This metatable is locked"
mt.__tostring = "Signal Library"
setreadonly(mt, true)

return signal
