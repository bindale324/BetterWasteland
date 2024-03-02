--[[
    this script stores the mod functions to be overrided.
    Create time: 2024-02-08 18:02
    Author: bindale324
    github link: https://github.com/bindale324
]]

libmodfunc = {};    -- global variable, will be returned for this Lua module.

--------------------------------------------------------------

-- We will define a class to store the necessary info
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

---------------------------------------------------------------

local function Override_PeopleEat(self, hero, item)
    if item ~= nil then
        self:PeopleEat(hero, item);
    else
        self:PeopleEat(hero);
    end
end

local PeopleEat_obj = ModFuncOverride:new(CS.PeopleEvent, "PeopleEat", Override_PeopleEat);

--- Summary: The function override for `TradeAction`, this is just a test override.
---@param TradeSellContent Dictionay<int, int>
---@param TradeBuyContent Dictionay<int, int>
---@param CurrentTraderID integer
local function Override_TradeAction(self, TradeSellContent, TradeBuyContent, CurrentTraderID)
    for k, v in pairs(TradeSellContent) do
        print("The item ID: " .. tostring(k));
        print("The item count: " .. tostring(v));
        print("=====");
    end
    self:TradeAction(TradeSellContent, TradeBuyContent, CurrentTraderID);
end

local TradeAction_obj = ModFuncOverride:new(CS.TradeManager, "TradeAction", Override_TradeAction);

-- local trade_warning_flag = true;
-- local function Override_Trade(self, TradeSellContent, TradeBuyContent, CurrentTraderID)
--     --[[
--         TradeSellContent: Dict[int, int],
--         TradeSellContent: Dict[int, int],
--         CurrentTraderID: int,
--     ]]
--     -- selling items:
--     local count = 0;
--     for k, v in pairs(TradeSellContent) do
--         count = count + 1;
--     end
--     print(tostring(count));
--     if count == 0 and trade_warning_flag then
--         CS.QxFramework.Core.UIManager.Instance:Open("DialogWindowUI", 0, "", CS.DialogWindowUI.DialogWindowUIArg("警告", "您还没有选择任何支付物品，\n白嫖可能降低某位成员的口才哦", nil, "确定"));
--         trade_warning_flag = false;
--     else
--         self:Trade(TradeSellContent, TradeBuyContent, CurrentTraderID);
--         trade_warning_flag = true;
--     end
-- end

-- local Trade_obj = ModFuncOverride:new(CS.BargainWindow, "Trade", Override_Trade);


--- Summary: The function override for `DiscardGoods`, we will change the iteration logic to avoid trading the legendary items.
---@param ID integer
---@param Amount integer
---@return any
local function Override_DiscardGoods(self, ID, Amount)
    if (self:GoodsIsObject(ID)) then
        for i = 0, self.AllItems.items.Count - 1 do
            if (ID == self.AllItems.items[i].ID) then
                self.AllItems.items[i].GoodsCout = self.AllItems.items[i].GoodsCout - Amount;
            end
        end
    elseif (self:GoodsIsParts(ID)) then
        local flag = true;
        while (Amount > 0 and flag) do
            flag = false;
            for i = 0, 2, 1 do
                local j = 0;
                while (j <= self.AllItems.sparesparts.Count - 1) do
                    if (self.AllItems.sparesparts[j].ID == ID + i * 100) then
                        if (Amount > 0) then
                            if (self.AllItems.sparesparts[j].GoodsCout > Amount) then
                                -- 如果够的话就直接减去。
                                self.AllItems.sparesparts[j].GoodsCout = self.AllItems.sparesparts[j].GoodsCout - Amount;
                                Amount = 0;
                                self:RefreshPackages();
                                return 0;
                            else
                                -- 如果不够的话，默认把当前的都减掉
                                Amount = Amount - self.AllItems.sparesparts[j].GoodsCout;
                                self.AllItems.sparesparts[j].GoodsCout = 0;
                                self.AllItems.sparesparts:RemoveAt(j);
                                flag = true;
                            end
                        end
                    end
                    j = j + 1;
                end
            end
        end
    elseif (self:GoodsIsEquip(ID)) then
        local flag2 = true;
        while (Amount > 0 and flag2) do
            flag2 = false;
            for k = 0, 2, 1 do
                local l = 0;
                while (l <= self.AllItems.sparesequips.Count - 1) do
                    if (self.AllItems.sparesequips[l].ID == ID + k * 100) then
                        -- sparesequips是装备格子，按照仓库的显示顺序来的
                        -- 刀片【专家】 刀片【传奇】虽然占两个格子，但是ID都是一样的
                        -- 在这里，我们加一个判断品质的就可以。
                        if (Amount > 0) then
                            if (self.AllItems.sparesequips[l].GoodsCout > Amount) then
                                -- 如果够的话就直接减去。
                                self.AllItems.sparesequips[l].GoodsCout = self.AllItems.sparesequips[l].GoodsCout - Amount;
                                Amount = 0;
                                self:RefreshPackages();
                                return 0;
                            else
                                -- 如果不够的话，默认把当前的都减掉
                                Amount = Amount - self.AllItems.sparesequips[l].GoodsCout;
                                self.AllItems.sparesequips[l].GoodsCout = 0;
                                self.AllItems.sparesequips:RemoveAt(l);
                                flag2 = true;
                            end
                        end
                    end
                    l = l + 1;
                end
            end
        end
    elseif (self:GoodsIsSource(ID)) then
        for i = 0, self.AllItems.sources.Count - 1 do
            if (ID == self.AllItems.sources[i].ID) then
                self.AllItems.sources[i].GoodsCout = self.AllItems.sources[i].GoodsCout - Amount;
            end
        end
    elseif (self:GoodsIsFood(ID)) then
        for i = 0, self.AllItems.foods.Count - 1 do
            if (ID == self.AllItems.foods[i].ID) then
                self.AllItems.foods[i].GoodsCout = self.AllItems.foods[i].GoodsCout - Amount;
            end
        end
    end
    self:RefreshPackages();
    return 0;
end

local DiscardGoods_obj = ModFuncOverride:new(CS.ItemManager, "DiscardGoods", Override_DiscardGoods);

local GetComponentT = xlua.get_generic_method(CS.UnityEngine.Component, "GetComponent");
local function Override_OpenChooseAmountPanel(self, IsSell, ID, TotalCount)
    print("Success override!!");
    local UIBase_GetT = xlua.get_generic_method(CS.BargainWindow, "Get");
    
    local IsSell2 = IsSell;
    local ID2 = ID;
    local TotalCount2 = TotalCount;

    UIBase_GetT(CS.UnityEngine.UI.Button)(self, "Plus").onClick:RemoveAllListeners();
    UIBase_GetT(CS.UnityEngine.UI.Button)(self, "Plus").onClick:AddListener(function()
        self:ChangeCount(1);
    end);

    UIBase_GetT(CS.UnityEngine.UI.Button)(self, "PlusMuch").onClick:RemoveAllListeners();
    UIBase_GetT(CS.UnityEngine.UI.Button)(self, "PlusMuch").onClick:AddListener(function()
        self:ChangeCount(10);
    end);

    UIBase_GetT(CS.UnityEngine.UI.Button)(self, "Minus").onClick:RemoveAllListeners();
    UIBase_GetT(CS.UnityEngine.UI.Button)(self, "Minus").onClick:AddListener(function()
        self:ChangeCount(-1);
    end);

    UIBase_GetT(CS.UnityEngine.UI.Button)(self, "MinusMuch").onClick:RemoveAllListeners();
    UIBase_GetT(CS.UnityEngine.UI.Button)(self, "MinusMuch").onClick:AddListener(function()
        self:ChangeCount(-10);
    end);

    self._totalCount = TotalCount2;

    local _gos = self._gos;
    local choose_amount_game_object = _gos:get_Item("ChooseAmountPanel");   -- GameObject

    choose_amount_game_object:SetActive(true);  -- make the panel visible

    self.slider.value = 0;

    ------------------ inject input field ------------------

    local InputField = CS.UnityEngine.UI.InputField;
    local UnityGameObject = CS.UnityEngine.GameObject;
    local AddComponentT = xlua.get_generic_method(CS.UnityEngine.GameObject, "AddComponent");   -- return type T
    
    -- 1. create InputAmount GameObject <- ChooseAmountPanel
    local InputAnoumt = UnityGameObject("InputAmount");  -- instantiate a new GameObject
    InputAnoumt.transform:SetParent(choose_amount_game_object.transform:Find("Panel"));  -- set parent to the panel

    -- add RectTransform component to the InputAmount GameObject
    local rectTransform = AddComponentT(CS.UnityEngine.RectTransform)(InputAnoumt);
    rectTransform.anchorMin = CS.UnityEngine.Vector2(0, 0);
    rectTransform.anchorMax = CS.UnityEngine.Vector2(1, 1);
    rectTransform.pivot = CS.UnityEngine.Vector2(0.5, 0.5);

    rectTransform.offsetMin = CS.UnityEngine.Vector2(420, 325);  -- Left, Bottom
    rectTransform.offsetMax = CS.UnityEngine.Vector2(-420, -105);  -- -Right, -Top

    rectTransform.localScale = CS.UnityEngine.Vector3(1, 1, 1);

    local position = rectTransform.localPosition;
    position.z = 0;
    rectTransform.localPosition = position;

    -- 2. create placeholder text GameObject <- InputAmount
    local placeholder = UnityGameObject("place_holder");  -- instantiate a new GameObject
    placeholder.transform:SetParent(choose_amount_game_object.transform:Find("Panel/InputAmount"));  -- set parent to the InputAmount GameObject

    -- 2.1 create rectTransform component <- placeholder
    local rectTransform2 = AddComponentT(CS.UnityEngine.RectTransform)(placeholder);
    rectTransform2.anchorMin = CS.UnityEngine.Vector2(0, 0);
    rectTransform2.anchorMax = CS.UnityEngine.Vector2(1, 1);
    rectTransform2.pivot = CS.UnityEngine.Vector2(0.5, 0.5);

    rectTransform2.offsetMin = CS.UnityEngine.Vector2(-5, -15);  -- Left, Bottom
    rectTransform2.offsetMax = CS.UnityEngine.Vector2(5, 15);  -- -Right, -Top

    rectTransform2.localScale = CS.UnityEngine.Vector3(1, 1, 1);

    local position2 = rectTransform2.localPosition;
    position2.z = 0;
    rectTransform2.localPosition = position2;

    -- 2.2 create Text component <- placeholder
    local place_holder_text = AddComponentT(CS.UnityEngine.UI.Text)(placeholder);

    place_holder_text.text = "请输入数字";
    place_holder_text.font = CS.UnityEngine.Font.CreateDynamicFontFromOSFont("Arial", 28);
    place_holder_text.fontSize = 28;
    place_holder_text.supportRichText = false;
    place_holder_text.alignment = CS.UnityEngine.TextAnchor.MiddleCenter;
    place_holder_text.color = CS.UnityEngine.Color.black;

    -- 3. create user_text text GameObject <- InputAmount
    local user_text = UnityGameObject("user_text");  -- instantiate a new GameObject
    user_text.transform:SetParent(choose_amount_game_object.transform:Find("Panel/InputAmount"));  -- set parent to the InputAmount GameObject

    -- 3.1 create rectTransform component <- user_text
    local rectTransform3 = AddComponentT(CS.UnityEngine.RectTransform)(user_text);
    rectTransform3.anchorMin = CS.UnityEngine.Vector2(0, 0);
    rectTransform3.anchorMax = CS.UnityEngine.Vector2(1, 1);
    rectTransform3.pivot = CS.UnityEngine.Vector2(0.5, 0.5);

    rectTransform3.offsetMin = CS.UnityEngine.Vector2(-5, -15);  -- Left, Bottom
    rectTransform3.offsetMax = CS.UnityEngine.Vector2(5, 15);  -- -Right, -Top

    rectTransform3.localScale = CS.UnityEngine.Vector3(1, 1, 1);

    local position3 = rectTransform3.localPosition;
    position3.z = 0;
    rectTransform3.localPosition = position3;

    -- 3.2 create Text component <- user_text
    local user_text_text = AddComponentT(CS.UnityEngine.UI.Text)(user_text);

    user_text_text.text = "";
    user_text_text.font = CS.UnityEngine.Font.CreateDynamicFontFromOSFont("Arial", 32);
    user_text_text.fontSize = 32;

    user_text_text.supportRichText = false;
    user_text_text.alignment = CS.UnityEngine.TextAnchor.MiddleCenter;
    user_text_text.color = CS.UnityEngine.Color.black;

    -- 4. Image component <- ChooseAmountPanel
    local image = AddComponentT(CS.UnityEngine.UI.Image)(InputAnoumt);
    image.color = CS.UnityEngine.Color.white;

    local input_field = AddComponentT(InputField)(InputAnoumt);
    input_field.textComponent = user_text_text;
    input_field.contentType = InputField.ContentType.IntegerNumber;

    input_field.placeholder = place_holder_text;

    ------------------ finish injecting input field ------------------

    local transform = choose_amount_game_object.transform:Find("Panel/Confirm");
    GetComponentT(CS.UnityEngine.UI.Button)(transform).onClick:RemoveAllListeners();
    GetComponentT(CS.UnityEngine.UI.Button)(transform).onClick:AddListener(function()
        if IsSell2 then
            self:UpdateTrade(self.TradeSellContent, ID2, CS.UnityEngine.Mathf.RoundToInt(self.slider.value * TotalCount2));
        else
            self:UpdateTrade(self.TradeBuyContent, ID2, CS.UnityEngine.Mathf.RoundToInt(self.slider.value * TotalCount2));
        end
        self:SetChooseList(IsSell2);
        InputAnoumt.transform:SetParent(nil);   -- remove the InputAmount GameObject
        choose_amount_game_object:SetActive(false);
    end);

    local transform2 = choose_amount_game_object.transform:Find("Panel/Cancle");
    GetComponentT(CS.UnityEngine.UI.Button)(transform2).onClick:RemoveAllListeners();
    GetComponentT(CS.UnityEngine.UI.Button)(transform2).onClick:AddListener(function()
        InputAnoumt.transform:SetParent(nil);   -- remove the InputAmount GameObject
        choose_amount_game_object:SetActive(false);
    end);

end

local OpenChooseAmountPanel_obj = ModFuncOverride:new(CS.BargainWindow, "OpenChooseAmountPanel", Override_OpenChooseAmountPanel);

local function Override_BargainWindow_Update(self)
    local _gos = self._gos;
    local choose_amount_game_object = _gos:get_Item("ChooseAmountPanel");   -- GameObject
    local text_obj = choose_amount_game_object.transform:Find("Panel/InputAmount/user_text");
    if text_obj ~= nil then
        local user_input = GetComponentT(CS.UnityEngine.UI.Text)(text_obj).text;    -- string
        if user_input ~= "" then
            local input_num = tonumber(user_input);
            if input_num ~= nil and input_num > 0 then
                if input_num <= self._totalCount then
                    self.slider.value = input_num / self._totalCount;
                else
                    self.slider.value = 1;
                end
            end
        end
    end

    self:Update();
end

local BargainWindow_Update_obj = ModFuncOverride:new(CS.BargainWindow, "Update", Override_BargainWindow_Update);

--------------------------------------------------------------

--[[
    ======================== REGISTER ========================
]]

table.insert(libmodfunc, PeopleEat_obj);
table.insert(libmodfunc, TradeAction_obj);
-- table.insert(libmodfunc, Trade_obj);
table.insert(libmodfunc, DiscardGoods_obj);
table.insert(libmodfunc, OpenChooseAmountPanel_obj);
table.insert(libmodfunc, BargainWindow_Update_obj);

---------------------------------------------------------------

return libmodfunc;