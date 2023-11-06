local http = require("http")
local json = require("json")
LuaApi = require "Plugins/lib/LuaApi"
Data = require "Plugins/lib/Data"
Utils = require "Plugins/lib/Utils"

API_KEY = Utils.GetConf("YiYanApiKey")
SECRET_KEY = Utils.GetConf("YiYanSecretKey")
PATH = "./Plugins/Data/YiYan.json"
MAX = 3

function ReceiveFriendMsg(CurrentQQ, data)
    data = Data.FriendMsg(data)
    if data.FromUserId == tonumber(CurrentQQ) then
        return 1
    end
    Content = data.Content
    if not Content:find("^#一言：") then
        return 1
    end
    Count = RecordUser(data.FromUin)
    if Count > MAX and data.FromUin ~= 1948511629 then
        LuaApi.Action:sendFriendText(data.FromUin, "今日您的免费额度已用完，请充值或明日再试～")
        return 1
    end
    -- Update Access Token
    local accessToken = Utils.ReadFile(PATH)
    if accessToken == nil or accessToken == "" then
        UpdateToken()
        LuaApi.Action:sendFriendText(data.FromUin, "Token过期或无效，请稍后再试")
        return 1
    else
        accessToken = json.decode(accessToken)
        local oldTime = accessToken.time
        local nowTime = os.time()
        if oldTime == nil or nowTime - oldTime >= 30 * 24 * 60 * 60 then
            UpdateToken()
            LuaApi.Action:sendFriendText(data.FromUin, "Token过期或无效，请稍后再试")
            return 1
        end
    end
    -- request YiYan
    local content = Content:gsub("#一言：", "")
    print("-----content " .. content)
    Res = RequestYiYan(content, accessToken)
    Res = "[Prompt]\n"..content.."\n"..Res
    LuaApi.Action:sendFriendText(data.FromUin, Res)
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
    if not Content:find("^#一言：") then
        return 1
    end
    Count = RecordUser(data.FromUserId)
    if Count > MAX and data.FromUserId ~= 1948511629 then
        LuaApi.Action:sendGroupText(data.FromGroupId, "今日您的免费额度已用完，请充值或明日再试～")
        return 1
    end
    -- Update Access Token
    local accessToken = Utils.ReadFile(PATH)
    if accessToken == nil or accessToken == "" then
        UpdateToken()
        LuaApi.Action:sendGroupText(data.FromGroupId, "Token过期或无效，请稍后再试")
        return 1
    else
        accessToken = json.decode(accessToken)
        local oldTime = accessToken.time
        local nowTime = os.time()
        if oldTime == nil or nowTime - oldTime >= 30 * 24 * 60 * 60 then
            UpdateToken()
            LuaApi.Action:sendGroupText(data.FromGroupId, "Token过期或无效，请稍后再试")
            return 1
        end
    end
    -- request YiYan
    local content = Content:gsub("#一言：", "")
    print("-----content " .. content)
    Res = RequestYiYan(content, accessToken)
    Res = "[Prompt]\n"..content.."\n"..Res
    LuaApi.Action:sendGroupText(data.FromGroupId, Res)
    return 1
end

function RecordUser(id)
    File = "./Plugins/Data/YiYan-Users.json"
    id = tostring(id)
    local today = Utils.GetDateTime()
    local users = Utils.ReadFile(File)
    if users == nil or users == "" then
        local tmp = {}
        tmp[id] = 1
        tmp["date"] = today
        Utils.WriteContent(File, json.encode(tmp))
        return 1
    end
    users = json.decode(users)
    if users.date == nil or users.date ~= today then
        local tmp = {}
        tmp[id] = 1
        tmp["date"] = today
        Utils.WriteContent(File, json.encode(tmp))
        return 1
    end
    if users[id] == nil then
        users[id] = 1
        Utils.WriteContent(File, json.encode(users))
        return 1
    end
    local count = users[id] + 1
    users[id] = count
    Utils.WriteContent(File, json.encode(users))
    return count
end

function UpdateToken()
    local ret = http.request('GET',
        string.format(
            "https://aip.baidubce.com/oauth/2.0/token?grant_type=client_credentials&client_id=%s&client_secret=%s",
            API_KEY, SECRET_KEY))
    if ret == nil or ret.body == nil then
        return false
    end
    local body = json.decode(ret.body)
    body['time'] = os.time()
    Utils.WriteContent(PATH, json.encode(body))
    return true
end

function RequestYiYan(content, accessToken)
    URL = "https://aip.baidubce.com/rpc/2.0/ai_custom/v1/wenxinworkshop/chat/eb-instant?access_token=" ..
        accessToken.access_token
    local option = {
        system = "你是一个帮助用户解决各种问题的百度大语言模型，你的管理员叫小渚。接下来用户会给你提问，你需要根据问题回复答案。请直接回复答案本身即可。",
        messages = {
            {
                role = "user",
                content = content
            }
        }
    }
    local ret = http.request("POST", URL, {
        headers = {
            ["Content-Type"] = "application/json"
        },
        body = json.encode(option)
    })
    print("-----ret " .. ret.body)
    if ret ~= nil and ret.body ~= nil then
        local res = json.decode(ret.body)
        if res.result then
            print("-----result " .. res.result)
            return "[以下内容由 AI 生成]\n"..res.result
        elseif res.error_msg then
            print("-----error_msg " .. res.error_msg)
            return "[请求出现错误]\n"..res.error_msg
        end
    end
end
