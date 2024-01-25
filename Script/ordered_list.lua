-- 维护一个ordered_list模块, 保持数据的有序性、唯一性
-- 只提供一系列方法，每一个方法的第一个参数必须是table。

local order_list = {}

-- 默认按升序进行排序
function order_list.sort(_table)
    table.sort(_table);
end

-- 二分查找，如果没有值，就返回false
function order_list.bsearch(_table, item)
    local low = 1
    local high = #_table
    local mid

    while low <= high do
        mid = math.floor((low + high) / 2)
        if _table[mid] == item then
            return mid  -- 找到元素，返回索引
        elseif _table[mid] < item then
            low = mid + 1
        else
            high = mid - 1
        end
    end

    return 0  -- 没有找到元素，返回0，因为Lua table的索引从1开始
end

-- 二分查找，然后插入
function order_list.insert(_table, item)
    local low = 1
    local high = #_table
    local mid

    while low <= high do
        mid = math.floor((low + high) / 2)
        if _table[mid] == item then
            -- 如果找到一个完全相同的元素，直接返回，因为要保持数据的唯一性
            return
        elseif _table[mid] < item then
            low = mid + 1
        else
            high = mid - 1
        end
    end

    -- 如果没有找到完全相同的元素，那么low将是正确的插入位置
    table.insert(_table, low, item)
end

function order_list.remove(_table, item)
    local index = order_list.bsearch(_table, item)
    if index > 0 then
        table.remove(_table, index)
    end
end

function order_list.print(_table)
    for i, v in ipairs(_table) do
        print(i, v)
    end
end


----------------------------- test zone -----------------------------

-- test_list = {"banana", "apple", "adc"}
-- test_list = {}

-- order_list.insert(test_list, "apple")

-- print(test_list[1])

-- order_list.sort(test_list)

-- print(test_list[1], test_list[2], test_list[3])

-- order_list.insert(test_list, "apple")
-- order_list.insert(test_list, "bac")


-- print(test_list[1], test_list[2], test_list[3], test_list[4], test_list[5])

-- print(order_list.bsearch(test_list, "apple"))

----------------------------------------------------------------------

return order_list