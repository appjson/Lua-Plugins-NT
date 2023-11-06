local http = require("http")
local json = require("json")
LuaApi = require "Plugins/lib/LuaApi"
Data = require "Plugins/lib/Data"

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

    if Content:find("检测 [%-%w]+%.%w+") then
        local key = Content:gsub("检测 ", "", 1)
        local ret = http.request("GET", "https://api.oick.cn/t/api.php?url=" .. key)
        if ret ~= nil and ret ~= "" then
            local msg = ""
            local ret1 = http.request("GET", "https://api.oick.cn/icp/api.php?url=" .. key)
            if ret1 ~= nil and ret1 ~= "" then
                local res1 = json.decode(ret1.body)
                if tonumber(res1["code"]) == 200 then
                    msg =
                        msg ..
                        string.format(
                            "网站名称：%s\n网站主体：%s\n网站主体性质：%s\n网站备案证号：%s\n",
                            res1["网站名称"],
                            res1["主办单位名称"],
                            res1["主办单位性质"],
                            res1["网站备案/许可证号"]
                        )
                end
            end
            local res = json.decode(ret.body)
            msg = msg .. string.format("URL: %s\n状态：%s\n信息：%s", res["url"], res["type"], res["msg"])
            LuaApi.Action:sendGroupText(data.FromGroupId, msg)
        end
    end

    if Content:find("^%.bing$") then
        LuaApi.Action:sendGroupUrlPic(data.FromGroupId, "https://stevenos.com/api/bing/")
        return 1
    end

    if data.MsgType == "AtMsg" then
        local content = json.decode(data.Content)
        ID = tonumber(content.UserID[1])
        if ID == tonumber(CurrentQQ) then
            return 1
        end
        if content["Content"]:find("%?%?%?$") or content["Content"]:find("？？？$") then
            local str = "http://q1.qlogo.cn/g?b=qq&nk=" .. ID .. "&s=640"
            LuaApi.Action:sendGroupUrlPic(data.FromGroupId, str, "？？？")
        end
        return 1
    end
    return 1
end
