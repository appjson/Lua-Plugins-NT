LuaApi = require "Plugins/lib/LuaApi"
Data = require "Plugins/lib/Data"
WhiteList = require "Plugins/WhiteList"

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

function ThreadHold(id)
    local holdCache = "./Plugins/Cache/PingHold.txt"
    if id == 0 then
        local f_w1, _ = io.open(holdCache, "w+")
        f_w1:write(id)
        f_w1:close()
        return 0
    else
        local f_r, _ = io.open(holdCache, "r")
        if f_r == nil then
            local f_w1, _ = io.open(holdCache, "w+")
            f_w1:write(id)
            f_w1:close()
            return 0
        end
        local data = f_r:read()
        if tonumber(data) == 0 or data == "" or data == nil then
            local f_w2, _ = io.open(holdCache, "w+")
            f_w2:write(id)
            f_w2:close()
            return 0
        else
            return tonumber(data)
        end
    end
end

function Ping(url)
    local cmd = "ping -c 5 " .. url .. " > ./Plugins/Cache/ping.txt"
    os.execute(cmd)
    return 1
end

function ReadPing()
    local content = Read("./Plugins/Cache/ping.txt")
    local msg
    if content == nil or content == "" then
        msg = "Ping 失败"
    else
        msg = content:match("(---.+)$")
    end
    return msg
end

function ReceiveFriendMsg(CurrentQQ, data)
    data = Data.FriendMsg(data)
    Content = data.Content
    if Content:find("Ping [%-%w]+%.%w+") then
        local checkWL = WhiteList.Check(data.FromUin, WhiteList.DefaultLevel)
        if checkWL ~= nil then
            LuaApi.Action:sendFriendText(data.FromUin, checkWL)
            return 1
        end
        local url = Content:match("([%-%w%.]+%.%w+)$")
        local status = ThreadHold(data.FromUserId)
        if status == 0 then
            print(data.FromUin, url)
            Ping(url)
            os.execute("sleep 6")
            local msg = ReadPing()
            ThreadHold(0)
            LuaApi.Action:sendFriendText(data.FromUin, msg)
        else
            LuaApi.Action:sendFriendText(data.FromUin, "当前已有Ping操作\n请稍后再试")
        end
    end
    if data.Content:find("^解除线程锁$") then
        LuaApi.Action:sendFriendText(data.FromUin, "Ping lock:" .. tostring(ThreadHold(0)))
        return 1
    end
    return 1
end

function ReceiveGroupMsg(CurrentQQ, data)
    data = Data.GroupMsg(data)
    if data.FromUserId == tonumber(CurrentQQ) then
        return 1
    end
    Content = data.Content
    if Content:find("Ping [%-%w]+%.%w+") then
        local checkWL = WhiteList.Check(data.FromUserId, WhiteList.DefaultLevel)
        if checkWL ~= nil then
            LuaApi.Action:sendGroupText(data.FromGroupId, checkWL)
            return 1
        end
        local status = ThreadHold(data.FromUserId)
        if status == 0 then
            local url = Content:match("([%-%w%.]+%.%w+)$")
            print(data.FromGroupId, data.FromUserId, url)
            Ping(url)
            os.execute("sleep 6")
            local msg = ReadPing()
            ThreadHold(0)
            LuaApi.Action:sendGroupText(data.FromGroupId, msg)
        else
            LuaApi.Action:sendGroupText(data.FromGroupId, "当前已有Ping操作\n请稍后再试")
        end
    end
    return 1
end
function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end
