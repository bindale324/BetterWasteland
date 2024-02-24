local uiStack = {};

uiStack.ui_stack = {"Main_UI", "ArchivementMainUI", "CommandUI"};

local function checkValidUI(uiname)
    if uiname == "Main_UI" or uiname == "ArchivementMainUI" or uiname == "CommandUI" then
        return false;
    end
    if uiname == "WaitTime" or uiname == "SplashScript" or uiname == "PlotUI2" then
        return false;
    end
    return true;
end

function uiStack:push_back(uiname)
    if (not checkValidUI(uiname)) then
        return;
    end
    table.insert(self.ui_stack, uiname);
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

function uiStack:find(uiname)
    local len = #self.ui_stack;
    for i = len, 1, -1 do
        if self.ui_stack[i] == uiname then
            return i;
        end
    end
    return 0;
end

return uiStack;