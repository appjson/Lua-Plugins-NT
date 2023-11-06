LuaApi = require "Plugins/lib/LuaApi"
Data = require "Plugins/lib/Data"

function ReceiveFriendMsg(CurrentQQ, data)
    return 1
end
function ReceiveGroupMsg(CurrentQQ, data)
    data = Data.GroupMsg(data)
    if data.FromUserId == tonumber(CurrentQQ) then
        return 1
    end

    if (string.find(data.Content, "^复读机 ")) then
        local keyWord = data.Content:gsub("复读机 ", "", 1)
        LuaApi.Action:sendGroupText(data.FromGroupId, keyWord)
        os.execute("sleep 3")
        LuaApi.Action:sendGroupText(data.FromGroupId, keyWord)
    end
    return 1
end
function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end
