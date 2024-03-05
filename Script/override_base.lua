ModFuncOverride = {tModule = nil, funcName = "", func = nil};

function ModFuncOverride:new(t_module, func_name, func)
    local obj = {};
    setmetatable(obj, self);
    self.__index = self;
    obj.tModule = t_module;
    obj.funcName = func_name;
    obj.func = func;
    return obj;
end

return ModFuncOverride;