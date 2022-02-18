os.loadAPI('api/framework')

local myID = os.getComputerID()

local eventQueue = {}

local function delegate(events, notifiedListeners, notifiedEmitters)
    local emitters = { rednet.lookup('EventsEmitter') }
    print("Delegating to " .. tostring(#emitters - 1) .. " emitters.")
    for i = 1, #emitters do
        local id = emitters[i]
        if id ~= myID then
            if notifiedEmitters[id] == nil then
                notifiedEmitters[id] = true
                print("Delegating to emitter #" .. tostring(id) .. "...")
                rednet.send(id, {
                    events = events,
                    notifiedListeners = notifiedListeners,
                    notifiedEmitters = notifiedEmitters
                }, 'EventsEmitter')
                local _, message, _ = rednet.receive('EventsEmitted')
                local newlyNotifiedListeners, newlyNotifiedEmitters = message['notifiedListeners'], message['notifiedEmitters']
                print('Delegator notified ' .. tostring(#newlyNotifiedListeners - #notifiedListeners) .. ' unqiue listeners.')
                for i = 1, #newlyNotifiedListeners do
                    notifiedListeners[newlyNotifiedListeners[i]] = true
                end
                print('Delegator notified ' .. tostring(#newlyNotifiedEmitters - #notifiedEmitters) .. ' unqiue emitters.')
                for i = 1, #newlyNotifiedEmitters do
                    notifiedEmitters[newlyNotifiedEmitters[i]] = true
                end
            else
                print('Skipping #' .. tostring(id))
            end
        end
    end
end

local function emitToListeners(events, notified)
    local listeners = { rednet.lookup('EventsReceiver') }
    print("Emitting to " .. tostring(#listeners) .. " listeners")

    for i = 1, #listeners do
        local id = listeners[i]
        if notified[id] == nil then
            notified[id] = true
            print('Sending events to #' .. tostring(id))
            rednet.send(id, events, 'Events')
        else
            print('Skipping #' .. tostring(id))
        end
    end
end

local function emitToListener(id, events)
    local listeners = { rednet.lookup('EventsReceiver') }
    print("Searching for listener " .. tostring(id) .. " in " .. tostring(#listeners) .. " listeners")

    for i = 1, #listeners do
        local currentId = listeners[i]
        if currentId == id then
            print('Sending events single-target to #' .. tostring(id))
            rednet.send(id, events, 'Events')
            return true
        end
    end
    return false
end

function queuePopulator()
    while true do
        local sender, events, _ = rednet.receive('EventsEmit')

        for i = 1, #events do
            eventQueue[#eventQueue + 1] = events[i]
        end
        print("Adding " .. tostring(#events) .. " events from #" .. tostring(sender) .. ' to the queue. (Size: ' .. tostring(#eventQueue) .. ')')
    end
end

function handleQueue()
    while true do
        os.sleep(1)
        if #eventQueue > 0 then
            print('Sending ' .. tostring(#eventQueue) .. " events.")
            local events = { unpack(eventQueue) }
            eventQueue = {}
            local notified = {}
            emitToListeners(events, notified)
            delegate(events, notified, { [myID] = true }, myID)
            print('Done')
            print()
        end
    end
end

function handleDelegator()
    while true do
        local sender, message, _ = rednet.receive('EventsEmitter')
        local events, notifiedListeners, notifiedEmitters = message['events'], message['notifiedListeners'], message['notifiedEmitters']
        print("Delegating " .. tostring(#events) .. " for #" .. tostring(sender))
        emitToListeners(events, notifiedListeners)
        notifiedEmitters[myID] = true
        delegate(events, notifiedListeners, notifiedEmitters)
        rednet.send(sender, {
            notifiedListeners = notifiedListeners,
            notifiedEmitters = notifiedEmitters
        }, 'EventsEmitted')
        print('Done')
        print()
    end
end

framework.run(function()
    rednet.host('EventsEmit', tostring(myID))
    rednet.host('EventsEmitter', tostring(myID))

    print('Eventrouter ready to serve!')
    parallel.waitForAny(queuePopulator, handleQueue, handleDelegator)
end)