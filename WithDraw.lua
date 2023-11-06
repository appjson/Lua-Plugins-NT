LuaApi = require "Plugins/lib/LuaApi"
Data = require "Plugins/lib/Data"

function Exec(data)
    if data.Content:find("#WITHDRAW=%d+") then
        Content = data.Content
        Content = Content:match("#WITHDRAW=%d+")
        Content = Content:gsub("#WITHDRAW=", "")
        SEC = 0
        SEC = tonumber(Content)
        print(
            "======> Withdraw time SEC: " ..
                SEC .. " Content: " .. Content .. " MsgSeq: " .. data.MsgSeq .. " Random: " .. data.MsgRandom
        )
        if (SEC < 60) then
            EXEC_CMD = "sleep " .. SEC
            os.execute(EXEC_CMD)
            LuaApi.Action:revokeGroupMsg(data.FromGroupId, data.MsgSeq, data.MsgRandom)
            return 1
        else
            return 2
        end
    end
end

function ReceiveFriendMsg(CurrentQQ, data)
    return 1
end
function ReceiveGroupMsg(CurrentQQ, data)
    data = Data.GroupMsg(data)
    if data.FromUserId == tonumber(CurrentQQ) then
        if data.Content:find("#WITHDRAW=%d+") then
            Exec(data)
        end
    end
    if data.Content:find("#WITHDRAW=%d+") then
        Exec(data)
    end
    return 1
end
function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end
