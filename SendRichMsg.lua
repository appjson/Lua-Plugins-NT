LuaApi = require "Plugins/lib/LuaApi"
Data = require "Plugins/lib/Data"

function ReceiveFriendMsg(CurrentQQ, data)
    data = Data.FriendMsg(data)
    return 1
end
function ReceiveGroupMsg(CurrentQQ, data)
    data = Data.GroupMsg(data)
    if data.FromUserId == tonumber(CurrentQQ) then
        return 1
    end
    if data.FromUserId == 1948511629 then
        if data.Content:find("Send_json:") then
            local json = data.Content:gsub("Send_json:", "", 1)
            Ret = LuaApi.Action:sendGroupJson(data.FromGroupId, json)
            print(Ret)
        elseif data.Content:find("Send_xml:") then
            local xml = data.Content:gsub("Send_xml:", "", 1)
            LuaApi.Action:sendGroupXml(data.FromGroupId, xml)
        end
    end
    return 1
end
function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end
