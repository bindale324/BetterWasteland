t = {1, 2, 3};

table.insert(t, 4, 5);

for k, v in pairs(t) do
    print(k, v);
end