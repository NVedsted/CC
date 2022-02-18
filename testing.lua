local monitor = peripheral.wrap('right')

local monitorWidth, monitorHeight = monitor.getSize()

local windowHeader = window.create(monitor, 1, 1, monitorWidth, 1, true)
local windowContent = window.create(monitor, 1, 2, monitorWidth, monitorHeight - 1, true)

windowContent.write('Memes\n')