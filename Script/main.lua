--[[
    Create time: 2024-01-21 21:46
    Author: bindale324
    github link: https://github.com/bindale324
]]

local o_list = require("ordered_list");
local libmodfunc = require("libmodfunc");

local uiqueue = {};  -- maintain a fixed size queue, size = 2
local in_bar = false;

local foodAutoEatRecords = {}  -- maintain an array, we just record the food ID here.

local GameMgr_GetT = xlua.get_generic_method(CS.GameMgr, "Get");

local function operate_queue(uiname)
    table.insert(uiqueue, tostring(uiname));
    if #uiqueue > 2 then
        table.remove(uiqueue, 1);
    end
end

function OnOpenUI(uiname)
    -- print("Open  ", tostring(uiname));
    operate_queue(uiname);
    if uiname == "NewMapUI" then
        if uiqueue[1] == "BarWindow" then
            in_bar = true;
        end
    end
    return false;
end

function OnCloseUI(uiname)
    -- print("Close  ", tostring(uiname), " flag status: ", tostring(in_bar));
    operate_queue(uiname);
    if uiname == "MissionWindow" then
        if in_bar then
            CS.QxFramework.Core.UIManager.Instance:Open("BarWindow");
            in_bar = false;
        end
    elseif uiname == "BarWindow" then
        in_bar = false;
    end
    return false;
end

function OnEat(personal, item)
    local autoEat_flag = item.Characteristic:ContainsKey("ItemBuff_DontAutoEat");
    if autoEat_flag then
        o_list.insert(foodAutoEatRecords, item.Name);
    else
        if o_list.bsearch(foodAutoEatRecords, item.Name) ~= 0 then
            o_list.remove(foodAutoEatRecords, item.Name);
        end
    end

    o_list.print(foodAutoEatRecords);
    return false
end

-- 无论是单次cook还是批量cook，这个函数都只会被调用一次。
function OnCook(ingredients, result)
    local size = result.Count;
    for i = 1, size do
        local item = result[i-1]; -- Food
        local autoEat_flag = o_list.bsearch(foodAutoEatRecords, item.Name) ~= 0;
        if autoEat_flag then
            item.Characteristic:Add("ItemBuff_DontAutoEat", 0);
        end
    end

    o_list.print(foodAutoEatRecords);
    return false
end

-- ModFunc(CS.PeopleEvent, "PeopleEat",
--     function (self, hero, item)
--         if item ~= nil then     -- PeopleEat has another override.
--             self:PeopleEat(hero, item);
--         else
--             self:PeopleEat(hero);
--         end
--     end);


-- -- trade bug fix
-- util.hotfix_ex(CS.TradeManager, "TradeAction", 
--     function (self, TradeSellContent, TradeBuyContent, CurrentTraderID)
--         self:TradeAction(TradeSellContent, TradeBuyContent, CurrentTraderID);
--         print("TradeAction triggered");
--         print(TradeSellContent);
--         print(TradeBuyContent);
--     end)

local function register_modify_methods()
    xlua.private_accessible(CS.BargainWindow);
    for _, obj in ipairs(libmodfunc) do
        ModFunc(obj.tModule, obj.funcName, obj.func);
    end
end

register_modify_methods();
