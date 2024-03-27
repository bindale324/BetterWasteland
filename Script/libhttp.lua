libhttp = {};

local launcher = CS.QxFramework.Core.Launcher;

function test_coro()
    return util.cs_generator(function ()
        for i = 1, 10 do
            coroutine.yield(CS.UnityEngine.WaitForSeconds(1));
            print("runtime i=", i);
        end
    end)
end

function libhttp.Get(url)
    print("test");
    -- local tmp_func = util.cs_generator(function ()
    --     print("success!!!");

    --     coroutine.yield(CS.UnityEngine.WaitForSeconds(3));

    --     print("waited for 3 seconds.");
    -- end);

    -- convert to IEnumerator
    -- co = CS.XLua.Cast.Any(CS.System.Collections.IEnumerator)(tmp_func);
    launcher.Instance:StartCoroutine(test_coro());
    print("11111");
end

function libhttp.Post(url, data)

end

return libhttp;