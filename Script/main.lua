--[[
    Create time: 2024-01-21 21:46
    Author: bindale324
    github link: https://github.com/bindale324
]]

local o_list = require("ordered_list");
local libmodfunc = require("libmodfunc");
local libids = require("libids");

local uiqueue = {};  -- maintain a fixed size queue, size = 2
local in_bar = false;

local foodAutoEatRecords = {}  -- maintain an array, we just record the food ID here.

local GameMgr_GetT = xlua.get_generic_method(CS.GameMgr, "Get");
local FindObjectOfType_T = xlua.get_generic_method(CS.UnityEngine.Object, "FindObjectOfType");

local UIManager = CS.QxFramework.Core.UIManager.Instance;

pocketMoney = 0;    -- global variable, the money of player.
local traveller_event = false;
local traveller2trade_event = false;

local init_game_flag = true;

local function operate_queue(uiname)
    table.insert(uiqueue, tostring(uiname));
    if #uiqueue > 2 then
        table.remove(uiqueue, 1);
    end
end

local function DeactiveRedPoint()
    local main_ui = FindObjectOfType_T(CS.MainUI)();
    local _gos = main_ui._gos;

    local people_num = PeopleManager:Getpeople().NowPeople.Count;
    for i = 0, people_num - 1 do
        local hero_var = _gos:get_Item("Hero (" .. tostring(i) .. ")");
        local red_point = hero_var.transform:Find("Hero_1/RedPoint_1").gameObject;
        red_point:SetActive(false);
    end
end

function Update()
    if init_game_flag then
        print(1);
        init_game_flag = false;
        for i = 0, 2 do
            DeactiveRedPoint();
        end
    end
end

function OnOpenUI(uiname)
    -- print("Open  ", tostring(uiname));
    operate_queue(uiname);
    
    if uiname == "NewMapUI" then
        if uiqueue[1] == "BarWindow" then
            in_bar = true;
        end
        -- elseif uiname == "CommandUI" then
        --     DeactiveRedPoint();
    else
        DeactiveRedPoint();
    end
    return false;
end

function OnCloseUI(uiname)
    -- print("Close  ", tostring(uiname));
    operate_queue(uiname);
    DeactiveRedPoint();

    if uiname == "MissionWindow" then
        if in_bar then
            UIManager:Open("BarWindow");
            in_bar = false;
        end
    elseif uiname == "BarWindow" then
        in_bar = false;
    elseif uiname == "NewEventUI" then
        if (traveller_event and traveller2trade_event) then
            traveller_event = false;
            traveller2trade_event = false;
            
            local money_good = GameMgr_GetT(CS.IItemManager)():GetGoods(libids.item_ids["money"]);
            local money_changed = money_good.GoodsCout;
            
            if money_changed == pocketMoney then
                print("we will go back to the upper layer");
                EventManager:TryEvent(libids.event_ids["traveller"]);
            end
        end
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

-- function OnDrinkWater(personal)
--     local main_ui = FindObjectOfType_T(CS.MainUI)();
--     main_ui:ActiveRedPoint();
-- end

function OnInit()
    xlua.private_accessible(CS.MainUI);
    
end

function OnEvent(templateID, force, param_list)
    if templateID == libids.event_ids["traveller"] then
        -- 【旅行者】事件
        traveller_event = true;
    elseif templateID == libids.event_ids["travellerTrade"] then
        if traveller_event then
            traveller2trade_event = true;
            local money_good = GameMgr_GetT(CS.IItemManager)():GetGoods(libids.item_ids["money"]);
            pocketMoney = money_good.GoodsCout;
        else
            traveller_event = false;
            traveller2trade_event = false;
        end
    else
        traveller_event = false;
    end
end

--[[
    ======================== REGISTER Lib Module Functions ========================
]]

local function register_modify_methods()
    xlua.private_accessible(CS.MainUI);
    for _, obj in ipairs(libmodfunc) do
        ModFunc(obj.tModule, obj.funcName, obj.func);
    end
end

register_modify_methods();
