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

        local userdata = setmetatable({}, {
            __index = function(_, k)
                return rawget(tbl, k)
            end,

            __metatable = "This metatable is locked",

            __tostring = function()
                return "Signal"
            end
        })

        return userdata
    end
}

local signal = setmetatable({}, {
    __index = function(_, k)
        return rawget(signaltbl, k:lower())
    end,

    __metatable = "This metatable is locked",

    __tostring = function()
        return "Signal Library"
    end
})
