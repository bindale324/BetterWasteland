local ModFuncOverride = require("override_base");

local GetComponentT = xlua.get_generic_method(CS.UnityEngine.Component, "GetComponent");
local function Override_OpenChooseAmountPanel(self, IsSell, ID, TotalCount)
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

local function Override_BargainWindow_Display(self, args)
    -- self:OnDisplay(args);
    local int = CS.System.Int32;
    self.CurrentTraderID = tonumber(args);
    local Dict_int_int = CS.System.Collections.Generic.Dictionary(CS.System.Int32, CS.System.Int32);
    self.TradeSellContent = Dict_int_int();
	self.TradeBuyContent = Dict_int_int();

    local first_time = true;

    self:CollectObject();
    self:SetChooseList(true);
    self:SetChooseList(false);
    
    local _gos = self._gos;
    local choose_amount_game_object = _gos:get_Item("ChooseAmountPanel");   -- GameObject
    choose_amount_game_object:SetActive(false);  -- make the panel invisible

    local image_trans = _gos:get_Item("Texts").transform:Find("Image");

    local Load = xlua.get_generic_method(CS.QxFramework.Core.ResourceManager, "Load");
    local GetT = xlua.get_generic_method(CS.GameMgr, "Get");
    local image_id = GetT(CS.IPeopleManager)():GetPeopleByID(self.CurrentTraderID).ImageId;
    GetComponentT(CS.UnityEngine.UI.Image)(image_trans).sprite = Load(CS.UnityEngine.Sprite)(
        CS.QxFramework.Core.ResourceManager.Instance, "Pic/Hero/" .. image_id
    );

    local btn_trans = _gos:get_Item("Buttons").transform:Find("ButtonCancle");
    GetComponentT(CS.UnityEngine.UI.Button)(btn_trans).onClick:RemoveAllListeners();
    GetComponentT(CS.UnityEngine.UI.Button)(btn_trans).onClick:AddListener(function()
        self:Close();
    end);

    local btn_trans2 = _gos:get_Item("Buttons").transform:Find("ButtonBuy");
    GetComponentT(CS.UnityEngine.UI.Button)(btn_trans2).onClick:RemoveAllListeners();
    GetComponentT(CS.UnityEngine.UI.Button)(btn_trans2).onClick:AddListener(function()
        if first_time then
            first_time = false;
            local cnt = 0;
            for k, v in pairs(self.TradeSellContent) do
                cnt = cnt + 1;
            end
            if cnt == 0 then
                CS.QxFramework.Core.UIManager.Instance:Open(
                    "DialogWindowUI", 0, "", CS.DialogWindowUI.DialogWindowUIArg(
                        "警告", "你没有选择任何商品，这可能会导致您的随机成员口才 -1 哦！", nil, "确定", function() end
                    )
                )
            end
        else
            self:Trade(self.TradeSellContent, self.TradeBuyContent, self.CurrentTraderID);
        end
    end);
end

local BargainWindow_Display_obj = ModFuncOverride:new(CS.BargainWindow, "OnDisplay", Override_BargainWindow_Display);

local function Override_PurchasePanel_Display(self, args)
    self:OnDisplay(args);
    local _gos = self._gos;

    -- Inject input field for choosing amount
    local InputField = CS.UnityEngine.UI.InputField;
    local UnityGameObject = CS.UnityEngine.GameObject;
    local AddComponentT = xlua.get_generic_method(CS.UnityEngine.GameObject, "AddComponent");   -- return type T
    
    -- 1. create InputAmount GameObject <- ChooseAmountPanel
    local InputAnoumt = UnityGameObject("InputAmount");  -- instantiate a new GameObject
    InputAnoumt.transform:SetParent(self.gameObject.transform:Find("Panel"));  -- set parent to the panel

    -- add RectTransform component to the InputAmount GameObject
    
    local rectTransform = AddComponentT(CS.UnityEngine.RectTransform)(InputAnoumt);
    rectTransform.anchorMin = CS.UnityEngine.Vector2(0, 0);
    rectTransform.anchorMax = CS.UnityEngine.Vector2(1, 1);
    rectTransform.pivot = CS.UnityEngine.Vector2(0.5, 0.5);

    rectTransform.offsetMin = CS.UnityEngine.Vector2(400, 380);  -- Left, Bottom
    rectTransform.offsetMax = CS.UnityEngine.Vector2(-400, -170);  -- -Right, -Top

    rectTransform.localScale = CS.UnityEngine.Vector3(1, 1, 1);

    local position = rectTransform.localPosition;
    position.z = 0;
    rectTransform.localPosition = position;

    -- 2. create placeholder text GameObject <- InputAmount
    local placeholder = UnityGameObject("place_holder");  -- instantiate a new GameObject
    placeholder.transform:SetParent(self.gameObject.transform:Find("Panel/InputAmount"));  -- set parent to the InputAmount GameObject

    -- 2.1 create rectTransform component <- placeholder
    local rectTransform2 = AddComponentT(CS.UnityEngine.RectTransform)(placeholder);
    rectTransform2.anchorMin = CS.UnityEngine.Vector2(0, 0);
    rectTransform2.anchorMax = CS.UnityEngine.Vector2(1, 1);
    rectTransform2.pivot = CS.UnityEngine.Vector2(0.5, 0.5);

    rectTransform2.offsetMin = CS.UnityEngine.Vector2(0, 0);  -- Left, Bottom
    rectTransform2.offsetMax = CS.UnityEngine.Vector2(0, 0);  -- -Right, -Top

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
    user_text.transform:SetParent(self.gameObject.transform:Find("Panel/InputAmount"));  -- set parent to the InputAmount GameObject

    -- 3.1 create rectTransform component <- user_text
    local rectTransform3 = AddComponentT(CS.UnityEngine.RectTransform)(user_text);
    rectTransform3.anchorMin = CS.UnityEngine.Vector2(0, 0);
    rectTransform3.anchorMax = CS.UnityEngine.Vector2(1, 1);
    rectTransform3.pivot = CS.UnityEngine.Vector2(0.5, 0.5);

    rectTransform3.offsetMin = CS.UnityEngine.Vector2(0, 0);  -- Left, Bottom
    rectTransform3.offsetMax = CS.UnityEngine.Vector2(0, 0);  -- -Right, -Top

    rectTransform3.localScale = CS.UnityEngine.Vector3(1, 1, 1);

    local position3 = rectTransform3.localPosition;
    position3.z = 0;
    rectTransform3.localPosition = position3;

    -- 3.2 create Text component <- user_text
    local user_text_text = AddComponentT(CS.UnityEngine.UI.Text)(user_text);

    user_text_text.text = "";    -- set default text
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

    ---------- finish injecting input field ----------
    local UIBase_GetT = xlua.get_generic_method(CS.PurchasePanel, "Get");

    UIBase_GetT(CS.UnityEngine.UI.Button)(self, "Confrim").onClick:RemoveAllListeners();
    UIBase_GetT(CS.UnityEngine.UI.Button)(self, "Confrim").onClick:AddListener(function()
        InputAnoumt.transform:SetParent(nil);   -- remove the InputAmount GameObject
        self:Confrim(0);
    end);

    
    UIBase_GetT(CS.UnityEngine.UI.Button)(self, "Cancle").onClick:RemoveAllListeners();
    UIBase_GetT(CS.UnityEngine.UI.Button)(self, "Cancle").onClick:AddListener(function()
        InputAnoumt.transform:SetParent(nil);   -- remove the InputAmount GameObject
        self:Cancel();
    end);

    UIBase_GetT(CS.UnityEngine.UI.Button)(self, "Bargin").onClick:RemoveAllListeners();
    UIBase_GetT(CS.UnityEngine.UI.Button)(self, "Bargin").onClick:AddListener(function()
        InputAnoumt.transform:SetParent(nil);   -- remove the InputAmount GameObject
        local str_tmp = "";
        self:Confrim(self:GetFinalSuccess(str_tmp));
    end);
end

local PurchasePanel_Display_obj = ModFuncOverride:new(CS.PurchasePanel, "OnDisplay", Override_PurchasePanel_Display);

local function Override_PurchasePanel_UpdatePanel(self)
    local text_obj = self.gameObject.transform:Find("Panel/InputAmount/user_text");

    if text_obj ~= nil then
        local user_input = GetComponentT(CS.UnityEngine.UI.Text)(text_obj).text;    -- string
        if user_input ~= "" then
            local input_num = tonumber(user_input);
            if input_num ~= nil and input_num > 0 then
                if input_num <= self.maxCount then
                    self.slider.value = input_num / self.maxCount;
                else
                    self.slider.value = 1;
                end
            end
        end
    end

    self:UpdatePannel();
end

local PurchasePanel_UpdatePanel_obj = ModFuncOverride:new(CS.PurchasePanel, "UpdatePannel", Override_PurchasePanel_UpdatePanel);


local mount_count = 0;
local function Override_OnOpenFilterPanel(self, isOpen)
    local UnityGameObject = CS.UnityEngine.GameObject;
    local GetT = xlua.get_generic_method(CS.NewMapUI, "Get");
    local AddComponentT = xlua.get_generic_method(CS.UnityEngine.GameObject, "AddComponent");   -- return type T
    local GetComponentT = xlua.get_generic_method(CS.UnityEngine.GameObject, "GetComponent");   -- return type T

    local filter_panel = GetT(CS.UnityEngine.Transform)(self, "FilterPanel");   -- Transform
    local CurrentSelection_trans = filter_panel:Find("FilterLeft/CurrentSelection");   -- Transform

    -- we add a input field and a placeholder text to the CurrentSelection GameObject
    -- for only once.
    local input_field = nil;
    if isOpen and mount_count == 0 then
        mount_count = 1;
        -- we will judge if the input field already exists
        -- because once we reload the game, the input field will still exist.
        local ipt_fld_handler = GetComponentT(CS.UnityEngine.UI.InputField)(CurrentSelection_trans.gameObject);

        if ipt_fld_handler == nil then
            local placeholder = UnityGameObject("place_holder_");  -- instantiate a new GameObject
            placeholder.transform:SetParent(CurrentSelection_trans);  -- set parent to the CurrentSelection GameObject
    
            -- 2.1 create rectTransform component <- placeholder
            local rectTransform2 = AddComponentT(CS.UnityEngine.RectTransform)(placeholder);
            rectTransform2.anchorMin = CS.UnityEngine.Vector2(0, 0);
            rectTransform2.anchorMax = CS.UnityEngine.Vector2(1, 1);
            rectTransform2.pivot = CS.UnityEngine.Vector2(0.5, 0.5);
        
            rectTransform2.offsetMin = CS.UnityEngine.Vector2(50, -30);  -- Left, Bottom
            rectTransform2.offsetMax = CS.UnityEngine.Vector2(-50, 30);  -- -Right, -Top
        
            rectTransform2.localScale = CS.UnityEngine.Vector3(1, 1, 1);
        
            local position2 = rectTransform2.localPosition;
            position2.z = 0;
            rectTransform2.localPosition = position2;
        
            -- 2.2 create Text component <- placeholder
            local place_holder_text = AddComponentT(CS.UnityEngine.UI.Text)(placeholder);
            
            place_holder_text.text = "请输入";
            place_holder_text.font = CS.UnityEngine.Font.CreateDynamicFontFromOSFont("Arial", 24);
            place_holder_text.fontSize = 24;
            place_holder_text.supportRichText = false;
            place_holder_text.alignment = CS.UnityEngine.TextAnchor.MiddleCenter;
            place_holder_text.color = CS.UnityEngine.Color.white;
        
            -- if mount_count == 0 then
            input_field = AddComponentT(CS.UnityEngine.UI.InputField)(CurrentSelection_trans.gameObject);
            local user_input = GetT(CS.UnityEngine.UI.Text)(self, "CurrentSelectionLable");
            user_input.supportRichText = false;
            user_input.horizontalOverflow = CS.UnityEngine.HorizontalWrapMode.Wrap;
            user_input.resizeTextForBestFit = false;
    
    
            input_field.textComponent = user_input;
            -- input_field.contentType = InputField.ContentType.Alphanumeric;
            
            input_field.placeholder = place_holder_text;
        else
            input_field = ipt_fld_handler;
        end
    
        -- end
    end
    
    GetT(CS.UnityEngine.Transform)(self, "FilterPanel").gameObject:SetActive(isOpen);
    local FindObjectOfType_T = xlua.get_generic_method(CS.UnityEngine.Object, "FindObjectOfType");
    if isOpen then
        FindObjectOfType_T(CS.MapCameraController)(CS.UnityEngine.Object).disableZoom = true;
        GetT(CS.UnityEngine.UI.Text)(self, "CurrentSelectionLable").text = "";
        local list_String = CS.System.Collections.Generic.List(CS.System.String);
        local list = list_String();

        GetT(CS.UnityEngine.UI.Button)(self, "SearchButton").onClick:RemoveAllListeners();
        GetT(CS.UnityEngine.UI.Button)(self, "SearchButton").onClick:AddListener(function ()
            self:SearchCity();
        end);

        GetT(CS.UnityEngine.Transform)(self, "SearchResultHint").gameObject:SetActive(true);
        GetT(CS.UnityEngine.UI.Text)(self, "SearchResultHint").text = "开始查找吧！";

        local iter_list = CS.App.Common.Data.Instance.TableAgent:CollectKey1("Shop");
        for i = 0, iter_list.Count - 1 do
            list:Add(CS.App.Common.Data.Instance.TableAgent:GetString("Shop", iter_list[i], "CName"));
        end

        local BuildMultipleItem = xlua.get_generic_method(CS.QxFramework.Core.UIBase, "BuildMultipleItem");
        BuildMultipleItem(CS.System.String)(self, GetT(CS.UnityEngine.Transform)(self, "SecletGoodsContent"), list, function (child, name)
            local T = child.transform:GetChild(0);
            GetComponentT(CS.UnityEngine.UI.Text)(T.gameObject).text = name;
            GetComponentT(CS.UnityEngine.UI.Button)(child).onClick:RemoveAllListeners();
            GetComponentT(CS.UnityEngine.UI.Button)(child).onClick:AddListener(function()
                input_field.text = name;
            end);
        end);

        local collection = list_String();
        BuildMultipleItem(CS.System.String)(self, GetT(CS.UnityEngine.Transform)(self, "SearchResultContent"), collection, function ()
        end);
    else
        FindObjectOfType_T(CS.MapCameraController)(CS.UnityEngine.Object).disableZoom = false;
    end
    
    -- cleaning logic
    -- if not isOpen then
    --     -- remove the input field
    --     print("Cleaning..");
    --     local filter_panel = GetT(CS.UnityEngine.Transform)(self, "FilterPanel");   -- Transform
    --     local CurrentSelection_trans = filter_panel:Find("FilterLeft/CurrentSelection");   -- Transform
    --     local input_field = GetComponentT(CS.UnityEngine.UI.InputField)(CurrentSelection_trans.gameObject);
    --     if input_field ~= nil then
    --         CS.UnityEngine.Object.Destroy(input_field);
    --         input_field = nil;
    --     end

    --     -- remove the placeholder text
    --     local placeholder = CurrentSelection_trans:Find("place_holder_");   -- Transform
    --     if placeholder ~= nil then
    --         CS.UnityEngine.Object.Destroy(placeholder.gameObject);
    --         placeholder = nil;
    --     end

    --     local CIC = CurrentSelection_trans:Find("CurrentSelection Input Caret");
    --     if CIC ~= nil then
    --         CS.UnityEngine.Object.Destroy(CIC.gameObject);
    --         CIC = nil;
    --     end
    -- end
end

local NewMapUI_OnOpenFilterPanel_obj = ModFuncOverride:new(CS.NewMapUI, "OnOpenFilterPanel", Override_OnOpenFilterPanel);

UI_objs = {OpenChooseAmountPanel_obj, BargainWindow_Update_obj, BargainWindow_Display_obj,
           PurchasePanel_Display_obj, PurchasePanel_UpdatePanel_obj,
           NewMapUI_OnOpenFilterPanel_obj};

return UI_objs;