os.loadAPI('api/framework')
os.loadAPI('api/event')

framework.addEventHandler('.*', function(name, data, sender)
    print("Received event '" .. name .. "' from #" .. tostring(sender) .. " with data:")
    if type(data) == 'table' then
        for key, value in pairs(data) do
            print(key .. " - " .. value)
        end
    else
        print(data)
    end
end)

framework.run(function()
    while true do
        local name = io.read()
        if event.emitEvent(name, nil) then
            print("Emitted event '" .. name .. "'")
        else
            print("Emit failed.")
        end
    end
end)