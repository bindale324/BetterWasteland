--[[
    Create time: 2024-01-21 21:46
    Author: bindale324
    github link: https://github.com/bindale324
]]

local o_list = require("ordered_list");
local libmodfunc = require("libmodfunc");
local libids = require("libids");
local uiStack = require("ui_stack");

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

local TopLayerUI = "";
local Input = CS.UnityEngine.Input;
local KeyCode = CS.UnityEngine.KeyCode;
local layer_0_ui = false;

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

-- local function invoke_mission_return()
--     local mission_window = FindObjectOfType_T(CS.MissionWindow)();
--     if (mission_window) then
--         local _gos = mission_window._gos;
    
--         if (_gos:ContainsKey("Locating")) then
--             local locating = _gos:get_Item("Locating");
--             local _return = _gos:get_Item("Return");
--             local flag = _gos:get_Item("flag");
--             local pivot = _gos:get_Item("Pivot");
--             local panel = _gos:get_Item("Panel");
--             locating:SetActive(false);
--             _return:SetActive(false);
--             flag:SetActive(false);
--             pivot:SetActive(true);
--             panel:SetActive(true);
--         end
--         TopLayerUI = "MissionWindow";
--     end
-- end

local close_bar_count = 0;
local battle_scene = false;

-- if there is any UI logic should avoid closing, goto `checkValidUI()` in ui_stack.lua

local function Keybind_Escape()
    if (Input.GetKeyDown(KeyCode.Escape)) then
        -- print("I was triggered.");
        TopLayerUI = uiStack:Top();
        -- print("current top: " .. TopLayerUI);
        if (TopLayerUI ~= "Main_UI" and TopLayerUI ~= "ArchivementMainUI" and TopLayerUI ~= "CommandUI") then
            if (TopLayerUI == "NewMapUI" and in_bar) then
                return;
            end

            if (TopLayerUI == "UnderAttackUI" or TopLayerUI == "FallBackUI" or TopLayerUI == "BattleWindow") then
                print("you cannot close this UI.");
                if (TopLayerUI == "BattleWindow") then
                    battle_scene = false;
                else
                    battle_scene = true;
                end
                return;
            end

            if (TopLayerUI == "DialogWindowUI") then
                if battle_scene then
                    print("you cannot close this UI during battling");
                    return;
                end
            end

            -- if (TopLayerUI == "BargainWindow") then
            --     print("you cannot close this UI during bargaining");
            --     return;
            -- end

            if (close_bar_count ~= 0) then
                close_bar_count = close_bar_count - 1;
                return;
            end
            UIManager:Close(TopLayerUI);
        else
            print("you cannot close this UI.");
        end
    end
end


function Update()
    if init_game_flag then
        init_game_flag = false;
        DeactiveRedPoint();
    end
    Keybind_Escape();
end

function OnOpenUI(uiname)
    -- print("Open  ", tostring(uiname));
    operate_queue(uiname);

    uiStack:push_back(uiname);
    -- uiStack:print_stack();
    if (uiname == "DialogWindowUI") then
        if (uiStack:find("BarWindow") ~= 0 or uiStack:find("MissionWindow") ~= 0) then
            close_bar_count = 1;
        end
    end

    if uiname == "NewMapUI" then
        if uiqueue[1] == "BarWindow" then
            in_bar = true;
        end
    else
        DeactiveRedPoint();
    end
    return false;
end

function OnCloseUI(uiname)
    -- print("Close  ", tostring(uiname));
    operate_queue(uiname);
    uiStack:remove(uiname);
    -- uiStack:print_stack();


    DeactiveRedPoint();

    if uiname == "MissionWindow" then
        if in_bar then
            UIManager:Open("BarWindow");
            in_bar = false;
        end
        layer_0_ui = false;
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
    elseif uiname == "BattleWindow" then
        battle_scene = false;
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

function OnDrinkWater(personal)
    local Item_manager = CS.ItemManager;
end

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
