function emitEvent(name, data)
    if name == nil or type(name) ~= "string" then
        error("Event name should be a string.")
    end
    local id = rednet.lookup('EventsEmit')

    if id == nil then
        return false
    end

    rednet.send(id, {
        {
            name = name,
            data = data,
            senderID = os.getComputerID()
        }
    }, 'EventsEmit')
    return true
end

function emitEventTo(id, name, data)
    if name == nil or type(name) ~= "string" then
        error("Event name should be a string.")
    end

    if name == nil or type(name) ~= "string" then
        error("Event name should be a string.")
    end
    local id = rednet.lookup('EventsEmit')

    if id == nil then
        return false
    end

    rednet.send(id, {
        {
            name = name,
            data = data,
            senderID = os.getComputerID()
        }
    }, 'EventsEmit')
    return true
end

function getEvents()
    local _, events, _ = rednet.receive('Events')
    return events
end