Data = require "Plugins/lib/Data"
Utils = require "Plugins/lib/Utils"
LuaApi = require "Plugins/lib/LuaApi"
local json = require("json")

-- Constants
ADMIN = Utils.GetConf("AdminQQ")
DefaultType = 0
DefaultLevel = 1

function ReceiveFriendMsg(CurrentQQ, data)
    return 1
end

function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end

function ReceiveGroupMsg(CurrentQQ, data)
    data = Data.GroupMsg(data)
    if data.FromUserId == tonumber(CurrentQQ) then
        return 1
    end
    if data.FromUserId ~= ADMIN then
        return 2
    end
    Content = data.Content
    if Content:find(".add %d+") then
        local id = Content:gsub(".add ", "", 1)
        Write(id, DefaultLevel)
        LuaApi.Action:sendGroupText(data.FromGroupId, id .. ": " .. 1)
        return 1
    end
    if Content:find(".del %d+") then
        local id = Content:gsub(".del ", "", 1)
        Write(id, DefaultType)
        LuaApi.Action:sendGroupText(data.FromGroupId, id .. ": " .. 0)
        return 1
    end
    return 2
end

--

function Write(id, type)
    File = "./Plugins/Data/WhiteList.json"
    id = tostring(id)
    local users = Utils.ReadFile(File)
    if users == nil or users == "" then
        local tmp = {}
        tmp[id] = type
        Utils.WriteContent(File, json.encode(tmp))
        return 1
    end
    users = json.decode(users)
    if users[id] == nil then
        users[id] = type
        Utils.WriteContent(File, json.encode(users))
        return 1
    end
    users[id] = type
    Utils.WriteContent(File, json.encode(users))
    return 1
end

function Read(id)
    File = "./Plugins/Data/WhiteList.json"
    id = tostring(id)
    if id == tostring(ADMIN) then
        return DefaultLevel
    end
    local users = Utils.ReadFile(File)
    if users == nil or users == "" then
        return DefaultType
    end
    users = json.decode(users)
    if users[id] == nil then
        return DefaultType
    end
    return users[id]
end

function Check(id, type)
    type = type or DefaultLevel
    local cur = Read(id)
    if cur == type then
        return nil
    end
    return id .. " 不具有 Level" .. type .. " 的权限"
end

return {
    DefaultType = DefaultType,
    DefaultLevel = DefaultLevel,
    Write = Write,
    Read = Read,
    Check = Check
}
