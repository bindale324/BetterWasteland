--[[
    this script stores the mod functions to be overrided.
    Create time: 2024-02-08 18:02
    Author: bindale324
    github link: https://github.com/bindale324
]]

libmodfunc = {};    -- global variable, will be returned for this Lua module.

local trade_objs = require("override_trade");
local UI_objs = require("override_UI");

--[[
    ======================== REGISTER ========================
]]

for i,v in ipairs(trade_objs) do
    table.insert(libmodfunc, v);
end

for i,v in ipairs(UI_objs) do
    table.insert(libmodfunc, v);
end


---------------------------------------------------------------

return libmodfunc;