local http = require("http")
local json = require("json")
LuaApi = require "Plugins/lib/LuaApi"
Data = require "Plugins/lib/Data"
WhiteList = require "Plugins/WhiteList"

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
    Content = data.Content
    ID = data.FromUserId
    if Content:find("^.+%.replace%(.+, .+%)$") then
        local checkWL = WhiteList.Check(ID, WhiteList.DefaultLevel)
        if checkWL ~= nil then
            LuaApi.Action:sendGroupText(data.FromGroupId, checkWL)
            return 1
        end
        local main = Content:gsub("%.replace%(.+, .+%)$", "", 1)
        local next = Content:gsub(main, "", 1)
        local raw = string.match(next, "%.replace%((.+), .+%)$")
        local new = string.match(next, "%.replace%(.+, (.+)%)$")
        local res = main:gsub(raw, new)
        if res ~= nil and res ~= "" then
            LuaApi.Action:sendGroupText(data.FromGroupId, res)
        end
    end

    -- if data.MsgType == "AtMsg" then
    --     local content = json.decode(data.Content)
    --     ID = tonumber(content.UserID[1])
    --     if ID == tonumber(CurrentQQ) then
    --         return 1
    --     end
    --     if content["Content"]:find("%?%?%?$") or content["Content"]:find("？？？$") then
    --         local str = "http://q1.qlogo.cn/g?b=qq&nk=" .. ID .. "&s=640"
    --         LuaApi.Action:sendGroupUrlPic(data.FromGroupId, str, "？？？")
    --     end
    --     return 1
    -- end
    return 1
end
