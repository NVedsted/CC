os.loadAPI('api/event')
os.loadAPI('api/network')

local eventHandlers = {}
local running

function addEventHandler(pattern, func)
    if pattern == nil or type(pattern) ~= "string" then
        error("Pattern should be a string.")
    end

    if func == nil or type(func) ~= "function" then
        error("The handler must be a function.")
    end

    eventHandlers[pattern] = func
end

function removeEventHandler(pattern)
    if pattern == nil or type(pattern) ~= "string" then
        error("Pattern should be a string.")
    end

    eventHandlers[pattern] = nil
end

function stop()
    running = false
    rednet.unhost('EventsReceiver', tostring(os.getComputerID()))
    network.closeAllNetworks()
end

local function runEventLoop()
    running = true
    while running do
        local events = event.getEvents()
        for i = 1, #events do
            local name, data, sender = events[i]['name'], events[i]['data'], events[i]['senderID']
            for pattern, func in pairs(eventHandlers) do
                if string.find(name, "^" .. pattern .. "$") ~= nil then
                    func(name, data, sender)
                end
            end
        end
    end
end

function run(handler)
    local modules = { runEventLoop }
    if handler ~= nil then
        if type(handler) ~= "function" then
            error("Tick handler should be a function.")
        end
        modules[#modules + 1] = handler
    end
    network.openAllNetworks()
    rednet.host('EventsReceiver', tostring(os.getComputerID()))
    addEventHandler('DEPLOY_UPDATE', function()
        print('Update available. Starting update in 10 seconds.')
        os.sleep(10)
        stop()
        while true do
            print('Updating..')
            if os.run({}, '/deploy') then
                print('Update succeded. Rebooting.')
                os.sleep(2)
                os.reboot()
            else
                print('Update failed.. Retring in 5 seconds.')
                os.sleep(5)
            end
        end
    end)
    parallel.waitForAll(unpack(modules))
end