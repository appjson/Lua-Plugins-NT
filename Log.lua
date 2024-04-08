local log = require("log")
Data = require "Plugins/lib/Data"

function ReceiveFriendMsg(CurrentQQ, data)
    data = Data.FriendMsg(data)
    local str =
        string.format(
        "isAdminMsg: %s  \nisSelfMsg: %s  \nFromUin  %d  \nToUin %d\nMsgType %s MsgSeq %s\nContent %s  \nEvent %s ",
        data.AdminMsg,
        data.SelfMsg,
        data.FromUin,
        data.ToUin,
        data.MsgType,
        data.MsgSeq,
        data.Content,
        data.Event
    )
    log.notice("From FriendMsg \n%s", str)
    return 1
end

function ReceiveGroupMsg(CurrentQQ, data)
    data = Data.GroupMsg(data)
    local str =
        string.format(
        "isAdminMsg: %s  \nisSelfMsg: %s  \nGroupId: %d  \nGroupname: %s \nGroupUserQQ: %d \nGroupUsername: %s \nMsgType: %s\nseq: %d time: %d  random: %d\nContent: %s",
        data.AdminMsg,
        data.SelfMsg,
        data.FromGroupId,
        data.FromGroupName,
        data.FromUserId,
        data.FromNickName,
        data.MsgType,
        data.MsgSeq,
        data.MsgTime,
        data.MsgRandom,
        data.Content
        -- data.Image,
        -- data.Video,
        -- data.Voice
    )

    log.notice("From GroupMsg \n%s", str)
    return 1
end

function ReceiveEvents(CurrentQQ, data, extData)
    log.notice("收到事件！==>\n", data)
    log.notice("事件详情！==>\n", extData)
    return 1
end
