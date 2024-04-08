LuaApi = require "Plugins/lib/LuaApi"
Data = require "Plugins/lib/Data"
WhiteList = require "Plugins/WhiteList"

function ReceiveFriendMsg(CurrentQQ, data)
    return 1
end
function ReceiveGroupMsg(CurrentQQ, data)
    data = Data.GroupMsg(data)
    if data.FromUserId == tonumber(CurrentQQ) then
        return 1
    end
    if data.Content:find("%.send ") then
        local checkWL = WhiteList.Check(data.FromUserId, WhiteList.DefaultLevel)
        if checkWL ~= nil then
            return 1
        end
        local content = data.Content:gsub("%.send ", "")
        LuaApi.Action:sendGroupText(data.FromGroupId, content)
        os.execute("sleep 3")
        LuaApi.Action:sendGroupText(data.FromGroupId, content)
    end
    return 1
end
function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end
