local ModFuncOverride = require("override_base");


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

trade_objs = {TradeAction_obj, DiscardGoods_obj, PeopleEat_obj};
return trade_objs;