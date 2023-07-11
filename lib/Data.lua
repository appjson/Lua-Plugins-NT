Data = {}

function Data.FriendMsg(data)
    local old = {
        FromUin = data.MsgHead.FromUin,
        ToUin = data.MsgHead.ToUin,
        MsgType = data.MsgHead.MsgType,
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
        FromGroupId = data.MsgHead.FromUin,
        FromGroupName = data.MsgHead.GroupInfo.GroupName,
        FromUserId = data.MsgHead.SenderUin,
        FromNickName = data.MsgHead.SenderNick,
        MsgType = data.MsgHead.MsgType,
        Content = data.MsgBody.Content,
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
