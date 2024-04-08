Utils = require "Plugins/lib/Utils"

Data = {}

MsgType = {
    [82] = "TextMsg"
}

-- 读取配置常量
Data.CurrentQQ = Utils.GetConf().CurrentQQ
Data.AdminQQ = Utils.GetConf().AdminQQ
Data.Port = Utils.GetConf().Port
Data.Host = Utils.GetConf().Host

-- 目的是重新解包data，从而适配旧的插件

function Data.FriendMsg(data)
    local old = {
        AdminMsg = data.MsgHead.FromUid == Data.AdminQQ,
        SelfMsg = data.MsgHead.FromUid == Data.CurrentQQ,
        FromUin = data.MsgHead.FromUin,
        FromUid = data.MsgHead.FromUid,
        ToUin = data.MsgHead.ToUin,
        ToUid = data.MsgHead.ToUid,
        MsgType = MsgType[data.MsgHead.MsgType],
        MsgCode = data.MsgHead.MsgType,
        Content = data.MsgBody.Content,
        MsgSeq = data.MsgHead.MsgSeq,
        MsgTime = data.MsgHead.MsgTime,
        MsgRandom = data.MsgHead.MsgRandom,
        Event = data.EventName
    }
    return old
end

function Data.GroupMsg(data)
    local old = {
        AdminMsg = data.MsgHead.SenderUin == Data.AdminQQ,
        SelfMsg = data.MsgHead.SenderUin == Data.CurrentQQ,
        FromGroupId = data.MsgHead.FromUin,
        FromGroupName = data.MsgHead.GroupInfo.GroupName,
        FromUserId = data.MsgHead.SenderUin,
        FromUserUid = data.MsgHead.SenderUid,
        FromNickName = data.MsgHead.SenderNick,
        MsgType = MsgType[data.MsgHead.MsgType],
        MsgCode = data.MsgHead.MsgType,
        Content = data.MsgBody.Content,
        AtUsers = data.MsgBody.AtUinLists,
        MsgSeq = data.MsgHead.MsgSeq,
        MsgTime = data.MsgHead.MsgTime,
        MsgRandom = data.MsgHead.MsgRandom,
        Event = data.EventName,
        Image = data.MsgBody.Image,
        Video = data.MsgBody.Video,
        Voice = data.MsgBody.Voice
    }
    return old
end

return Data
