LuaApi = require "Plugins/lib/LuaApi"
Data = require "Plugins/lib/Data"
local json = require("json")

function CheckGroup(id, method)
    local file_name = "./Plugins/Data/ShowUrl-Data.json"
    local f_r, _ = io.open(file_name, "r")
    if method == 1 then
        if f_r == nil then
            local users = {}
            table.insert(users, id)
            local f_w, _ = io.open(file_name, "w+")
            f_w:write(json.encode(users))
            f_w:close()
            return true
        end
        local users = json.decode(f_r:read("*all"))
        for _, user in ipairs(users) do
            if user == id then
                return false
            end
        end
        table.insert(users, id)
        local f_w, _ = io.open(file_name, "w+")
        f_w:write(json.encode(users))
        f_w:close()
        return true
    end
    if method == -1 then
        if f_r == nil then
            return true
        end
        local users = json.decode(f_r:read("*all"))
        for i, user in ipairs(users) do
            if user == id then
                table.remove(users, i)
                local f_w, _ = io.open(file_name, "w+")
                f_w:write(json.encode(users))
                f_w:close()
                return true
            end
        end
    end
    if method == 0 then
        if f_r == nil then
            return false
        end
        local users = json.decode(f_r:read("*all"))
        for _, user in ipairs(users) do
            if user == id then
                return true
            end
        end
        return false
    end
end

function ReceiveFriendMsg(CurrentQQ, data)
    return 1
end
function ReceiveGroupMsg(CurrentQQ, data)
    data = Data.GroupMsg(data)
    if data.FromUserId == tonumber(CurrentQQ) then
        return 1
    end
    if data.Content:find("^%.开始解析$") and data.FromUserId == 1948511629 then
        CheckGroup(data.FromGroupId, 1)
        LuaApi.Action:replyGroupMsg(
            data.FromGroupId,
            "已开始解析URL",
            data.MsgSeq,
            data.MsgTime,
            data.FromUserId,
            data.Content
        )
        return 1
    end
    if data.Content:find("^%.停止解析$") then
        CheckGroup(data.FromGroupId, -1)
        LuaApi.Action:replyGroupMsg(
            data.FromGroupId,
            "已停止解析URL",
            data.MsgSeq,
            data.MsgTime,
            data.FromUserId,
            data.Content
        )
        return 1
    end

    if CheckGroup(data.FromGroupId, 0) then
        -- XML
        if data.MsgType == "XmlMsg" then
            Content = json.decode(data.Content)["Content"]
            local url = string.match(Content, 'url="(https?://[%w%p]+)"')
            print("    XML URL: " .. url)
            if url ~= nil then
                -- url = url:gsub('url="', "")
                -- url = url:gsub('"', "")
                msg = "拒绝小卡片，关心电脑党\n" .. url
                LuaApi.Action:sendGroupText(data.FromGroupId, msg)
                return 1
            end
        end
        -- Pic
        if data.MsgType == "PicMsg" then
            local image = json.decode(data.Content)
            if image["Content"] ~= nil and string.find(image["Content"], "%[闪照%]") then
                image = image["Url"]
            else
                image = image["GroupPic"][1]["Url"]
            end
            image = image:match("(https?://[%w%p]+/0)")
            local fileName = "./Plugins/Cache/qr-detect.jpg"
            local cachePath = "./Plugins/Cache/qr-detect.txt"
            local wget = "wget -q -O " .. fileName .. " " .. image .. " && sleep 3"
            local cmd = "./Plugins/Utils/qr-detect " .. fileName .. " > " .. cachePath .. " && sleep 1"
            os.execute(wget)
            os.execute(cmd)
            local f_r, _ = io.open(cachePath, "r")
            if f_r ~= nil then
                local res = f_r:read("*all")
                if res ~= nil and res ~= "" then
                    res = "在图片中检测到二维码[表情74]\n[表情190]成功解析\n" .. res
                    LuaApi.Action:replyGroupMsg(
                        data.FromGroupId,
                        res,
                        data.MsgSeq,
                        data.MsgTime,
                        data.FromUserId,
                        data.Content
                    )
                end
            end
            return 1
        end
        -- Text
        if data.Content:find("github.com/[%w%-_%.]") then
            LuaApi.Action:sendGroupPic(data.FromGroupId, "./Plugins/Cache/opq-osc__OPQ.jpg")
            -- local str = data.Content:match("github.com/([%w%-_%.]+/.+)")
            -- if str ~= nil and str ~= "" then
            --     local img = "https://opengraph.githubassets.com/0/" .. str
            --     str = str:gsub("/", "__")
            --     local fileName = "./Plugins/Cache/" .. str .. ".jpg"
            --     print("match github image: " .. fileName)
            --     local wget = "wget -q -O " .. fileName .. " " .. img .. " && sleep 3"
            --     os.execute(wget)
            --     LuaApi.Action:sendGroupPic(data.FromGroupId, fileName)
            -- end
            return 1
        end
    end
    return 1
end

function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end
