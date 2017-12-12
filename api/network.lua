local openSides = {}

function openAllNetworks()
    local peripherals = peripheral.getNames()
    for i = 1, #peripherals do
        if peripheral.getType(peripherals[i]) == "modem" then
            openSides[#openSides + 1] = peripherals[i]
            rednet.open(peripherals[i])
        end
    end
end

function closeAllNetworks()
    for i = 1, #openSides do
        rednet.close(openSides[i])
    end
    openSides = {}
end

function getNetworkSides()
    return openSides
end