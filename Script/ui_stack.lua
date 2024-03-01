local uiStack = {};

uiStack.ui_stack = {"Main_UI", "ArchivementMainUI", "CommandUI"};

---Summary: This function will filter out invalid UI names and return true if the UI name is valid.
---@param uiname string: the UI name to check.
---@return boolean: true if the UI name is valid, false otherwise.
local function checkValidUI(uiname)
    if uiname == "Main_UI" or uiname == "ArchivementMainUI" or uiname == "CommandUI" then
        return false;
    elseif uiname == "WaitTime" or uiname == "SplashScript" or uiname == "PlotUI2" then
        return false;
    elseif uiname == "NewEventUI" then
        return false;
    end
    return true;
end

function uiStack:push_back(uiname)
    if (not checkValidUI(uiname)) then
        return;
    end
    if (uiname == "BargainWindow") then
        table.insert(self.ui_stack, self:find_first("DialogWindowUI"), uiname);
    else
        table.insert(self.ui_stack, uiname);
    end
end

function uiStack:remove(uiname)
    if (not checkValidUI(uiname)) then
        return;
    end
    local len = #self.ui_stack;
    for i = len, 1, -1 do
        -- print("closing: " .. self.ui_stack[i]);
        if (self.ui_stack[i] == uiname) then
            -- print(1);
            table.remove(self.ui_stack, i);
            return true;
        end
    end
    return false;
end

function uiStack:Top()
    return self.ui_stack[#self.ui_stack];
end

function uiStack:print_stack()
    print("==================")
    for k, v in ipairs(self.ui_stack) do
        print("layer " .. k .. " UI: " .. v);
    end
end

---Summary: This function will search for the last occurrence of the given UI name in the stack.
---@param uiname string: the UI name to search for.
---@return integer: the index of the last occurrence of the UI name in the stack. If the UI name is not found, it will return 0.
function uiStack:find(uiname)
    local len = #self.ui_stack;
    for i = len, 1, -1 do
        if self.ui_stack[i] == uiname then
            return i;
        end
    end
    return 0;
end

---Summary: This function will search for the first occurrence of the given UI name in the stack.
---@param uiname string: the UI name to search for.
---@return integer: the index of the first occurrence of the UI name in the stack. If the UI name is not found, it will return the index of the last element in the stack.
function uiStack:find_first(uiname)
    local len = #self.ui_stack;
    for i = 1, len do
        if self.ui_stack[i] == uiname then
            return i;
        end
    end
    return len + 1;
end

return uiStack;