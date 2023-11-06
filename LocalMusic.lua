LuaApi = require "Plugins/lib/LuaApi"
Data = require "Plugins/lib/Data"

function Read(url)
    local file = io.open(url, "r")
    if (file == nil) then
        return nil
    else
        file:seek("set")
        local str = file:read("*a")
        file:close()
        return str
    end
end

function ReadFile(file)
    assert(file, "file open failed")
    local fileTab = {}
    file = io.open(file)
    local line = file:read()
    while line do
        table.insert(fileTab, line)
        line = file:read()
    end
    return fileTab
end

function ReceiveFriendMsg(CurrentQQ, data)
    return 1
end
function ReceiveGroupMsg(CurrentQQ, data)
    data = Data.GroupMsg(data)
    if data.FromUserId == tonumber(CurrentQQ) then
        return 1
    end
    if data.Content:find("^%.随机播放") or data.Content:find("^%.play") then
        local dir = "../Music/"
        local file = "./Plugins/Cache/local-music.txt"
        local cmd = "ls -A -X " .. dir .. " > " .. file
        os.execute(cmd)
        local filedata = ReadFile(file)
        math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 7)))
        local choice = math.random(1, #filedata)
        local selected = dir .. filedata[choice]
        LuaApi.Action:sendGroupVoice(data.FromGroupId, selected)
    end
    if data.Content:find("^%.播放列表") then
        local dir = "../Music/"
        local file = "./Plugins/Cache/local-music.txt"
        local cmd = "ls -A -X " .. dir .. " > " .. file
        os.execute(cmd)
        local msg = Read(file)
        LuaApi.Action:sendGroupText(data.FromGroupId, msg)
    end
    if data.Content:find("^你干嘛 ?哎哟$") then
        local dir = "../Music/"
        local selected = dir .. "ngmhhy.silk"
        LuaApi.Action:sendGroupVoice(data.FromGroupId, selected)
    end
    if data.Content:find("^你好烦$") then
        local dir = "../Music/"
        local selected = dir .. "nhf.silk"
        LuaApi.Action:sendGroupVoice(data.FromGroupId, selected)
    end
    return 1
end
function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end
