local http = require("http")
local json = require("json")
LuaApi = require "Plugins/lib/LuaApi"
Data = require "Plugins/lib/Data"

function string.split(input, delimiter)
    input = tostring(input)
    delimiter = tostring(delimiter)
    if (delimiter == "") then
        return false
    end
    local pos, arr = 0, {}
    -- for each divider found
    for st, sp in function()
        return string.find(input, delimiter, pos, true)
    end do
        table.insert(arr, string.sub(input, pos, st - 1))
        pos = sp + 1
    end
    table.insert(arr, string.sub(input, pos))
    return arr
end

function GetKeyValue(Rowkey)
    if (string.find(Rowkey, "=") ~= nil) then
        local tb = string.split(Rowkey, "=")
        if tb[1] == nil or tb[2] == nil then
            return nil
        elseif tb[1] == "" or tb[2] == "" then
            return nil
        else
            return tb
        end
    else
        return nil
    end
end

function Read(url)
    local file = io.open(url, "r")
    if (file == nil) then
        return nil
    else
        file:seek("set")
        local str = file:read("*a")
        file:close()
        return str
    end
end

function Write(url, msg)
    local file = io.open(url, "w+")
    file:write(msg)
    file:close()
    return "ok"
end

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
    if Content:find("^alias%s.+=.+$") then
        Rowkey = Content:gsub("alias%s+", "", 1)
        if (string.find(Rowkey, "[Aa][Tt][Aa][Ll][Ll]") ~= nil) then
            Rowkey = Rowkey:gsub("[Aa][Tt][Aa][Ll][Ll]", "")
        end
        if (string.find(Rowkey, "[Aa][Tt][Uu][Ss][Ee][Rr]") ~= nil) then
            Rowkey = Rowkey:gsub("[Aa][Tt][Uu][Ss][Ee][Rr]", "")
        end
        local tb = GetKeyValue(Rowkey)
        local key = tb[1]
        local value = tb[2]
        print("Alias:---------Key:" .. key .. "---------Value:" .. value)
        if #key > 16 or #value > 256 then
            LuaApi.Action:sendGroupText(data.FromGroupId, "Error: too long.")
            return 2
        end
        local file = "./Plugins/Data/Alias.json"
        local content = Read(file)
        local insert = {}
        if content ~= nil and content ~= "" then
            local jsonContent = json.decode(content)
            local oldValue = jsonContent[key]
            if oldValue ~= value then
                jsonContent[key] = value
                local insertJson = json.encode(jsonContent)
                local ret = Write(file, insertJson)
                if ret == "ok" then
                    LuaApi.Action:sendGroupText(data.FromGroupId, "Done.")
                end
            else
                insert[key] = value
                jsonContent.insert(insert)
                local insertJson = json.encode(jsonContent)
                local ret = Write(file, insertJson)
                if ret == "ok" then
                    LuaApi.Action:sendGroupText(data.FromGroupId, "Done.")
                end
            end
        else
            insert[key] = value
            local insertJson = json.encode(insert)
            local ret = Write(file, insertJson)
            if ret == "ok" then
                LuaApi.Action:sendGroupText(data.FromGroupId, "Done.")
            end
        end
    elseif Content:find("^unalias%s.+$") then
        local key = Content:gsub("unalias%s+", "", 1)
        local file = "./Plugins/Data/Alias.json"
        local content = Read(file)
        local insert = {}
        if content ~= nil and content ~= "" then
            local jsonContent = json.decode(content)
            local oldValue = jsonContent[key]
            if oldValue == nil or oldValue == "" then
                return 1
            else
                jsonContent[key] = ""
                local insertJson = json.encode(jsonContent)
                local ret = Write(file, insertJson)
                if ret == "ok" then
                    LuaApi.Action:sendGroupText(data.FromGroupId, "已删除" .. key)
                end
            end
        end
    elseif Content:find("^alias%s+-l") then
        local file = "./Plugins/Data/Alias.json"
        local content = Read(file)
        if content ~= nil and content ~= "" then
            local jsonContent = json.decode(content)
            local msg = ""
            for key, value in pairs(jsonContent) do
                msg = msg .. key .. "=" .. value .. "\n"
            end
            print(msg)
            msg = msg .. "#WITHDRAW=30"
            LuaApi.Action:sendGroupText(data.FromGroupId, msg)
            return 1
        else
            local msg = "No alias"
            LuaApi.Action:sendGroupText(data.FromGroupId, msg)
            return 1
        end
    elseif Content:find("^alias%s+-rm") then
        -- 新模板字符串
        local file = "./Plugins/Data/Alias.json"
        local content = Read(file)
        if content ~= nil and content ~= "" then
            local ret = Write(file, "")
            if ret == "ok" then
                LuaApi.Action:sendGroupText(data.FromGroupId, "已清空")
            end
            return 1
        end
    elseif Content:find("^一键%S+[%.。]$") then
        local word = Content:gsub("一键", "", 1)
        local word = word:gsub("[%.。]", "")
        if #word > 12 then
            return 2
        end
        local msg =
            string.format(
            "%s嘿嘿嘿%s🤤🤤🤤嘿嘿我的%s🤤🤤🤤嘿嘿嘿……嘿嘿嘿🤤🤤🤤%s好可爱嘿嘿嘿🤤🤤🤤%s我好喜欢🤤🤤🤤%s好乖啊嘿嘿嘿😋",
            word,
            word,
            word,
            word,
            word,
            word
        )
        LuaApi.Action:replyGroupMsg(data.FromGroupId, msg, data.MsgSeq, data.MsgTime, data.FromUserId, "模板：" .. word)
        return 1
    else
        local file = "./Plugins/Data/Alias.json"
        local content = Read(file)
        if content ~= nil and content ~= "" then
            local jsonContent = json.decode(content)
            local msg = jsonContent[Content]
            if msg ~= nil and msg ~= "" then
                LuaApi.Action:sendGroupText(data.FromGroupId, msg)
            end
        end
    end
    return 1
end
