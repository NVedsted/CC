local tArgs = {...}

local base_url = 'http://192.168.1.10:8080/'

local skipBuild = false
local root = '/'

if tArgs[1] == 'clean' then
    skipBuild = true
elseif tArgs[1] ~= nil then
    root = tArgs[1]
end

if fs.exists(root .. '.deploymanifest') then
    local file = fs.open(root .. '.deploymanifest', 'r')
    local line = file.readLine()

    while line ~= nil do
        fs.delete(line)
        line = file.readLine()
    end
    file.close()
    fs.delete(root .. '.deploymanifest')
end

if not skipBuild then
    local manifest = fs.open(root .. '.deploymanifest', 'w')

    for w in string.gmatch(http.get(base_url).readAll(), '[^\n]+') do
        local request =  http.get(base_url .. w)
        manifest.writeLine(w)
        local content = request.readAll()
        local file = fs.open(root .. w, 'w')
        file.write(content)
        file.close()
        request.close()
    end

    manifest.close()
end