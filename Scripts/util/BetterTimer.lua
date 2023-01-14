-- BetterTimer.lua --
-- Elpoireau 2023

BetterTimer = class( nil )


-- scrapy funcy
function BetterTimer.onCreate( self )
    self.timer = {}
end

function BetterTimer.onFixedUpdate( self )
    for i,v in ipairs(self.timer) do
        self.timer[i].tick = self.timer[i].tick + 1
        if self.timer[i].tick == v.maxTick then
            self:onTimeOver(v)
            table.remove(self.timer, i)
        end
    end 
end

-- content
function BetterTimer.createNewTimer( self , maxTick , callClass , callFunction , data )
    table.insert(self.timer, {tick = 0, maxTick = maxTick, callClass = callClass, callFunction = callFunction, data = data or nil} )
end

function BetterTimer.onTimeOver( self , timer )
    local class = timer.callClass
    local func = timer.callFunction
    if timer.data == nil then
      func(class)
    else
        func(class, timer.data)
    end
end
