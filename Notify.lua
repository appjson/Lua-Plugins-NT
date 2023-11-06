LuaApi = require "Plugins/lib/LuaApi"
Data = require "Plugins/lib/Data"
local json = require("json")

function WriteMsg(msg)
    local msgCache = "./Plugins/Data/AutoReply.txt"
    local f_w1, _ = io.open(msgCache, "w+")
    if f_w1 ~= nil then
        f_w1:write(msg)
        f_w1:close()
        return 1
    end
end

function ReadMsg()
    local msgCache = "./Plugins/Data/AutoReply.txt"
    local f_r, _ = io.open(msgCache, "r")
    local data = nil
    if f_r ~= nil then
        data = f_r:read("*a")
        if data ~= nil then
            return data
        else
            return "nil"
        end
    else
        return "nil"
    end
end

---
-- @function: 获取table的字符串格式内容，递归
-- @tab： table
-- @ind：不用传此参数，递归用（前缀格式（空格））
-- @return: format string of the table
function dumpTab(tab, ind)
    if (tab == nil) then
        return "nil"
    end
    local str = "{"
    if (ind == nil) then
        ind = "  "
    end
    --//each of table
    for k, v in pairs(tab) do
        --//key
        if (type(k) == "string") then
            k = tostring(k) .. " = "
        else
            k = "[" .. tostring(k) .. "] = "
        end --//end if
        --//value
        local s = ""
        if (type(v) == "nil") then
            s = "nil"
        elseif (type(v) == "boolean") then
            if (v) then
                s = "true"
            else
                s = "false"
            end
        elseif (type(v) == "number") then
            s = v
        elseif (type(v) == "string") then
            s = '"' .. v .. '"'
        elseif (type(v) == "table") then
            s = dumpTab(v, ind .. "  ")
            s = string.sub(s, 1, #s - 1)
        elseif (type(v) == "function") then
            s = "function : " .. v
        elseif (type(v) == "thread") then
            s = "thread : " .. tostring(v)
        elseif (type(v) == "userdata") then
            s = "userdata : " .. tostring(v)
        else
            s = "nuknow : " .. tostring(v)
        end --//end if
        --//Contact
        str = str .. "\n" .. ind .. k .. s .. " ,"
    end --//end for
    --//return the format string
    local sss = string.sub(str, 1, #str - 1)
    if (#ind > 0) then
        ind = string.sub(ind, 1, #ind - 2)
    end
    sss = sss .. "\n" .. ind .. "}\n"
    return sss --string.sub(str,1,#str-1).."\n"..ind.."}\n";
end --//end function

function ReceiveGroupMsg(CurrentQQ, data)
    data = Data.GroupMsg(data)
    if data.FromUserId == tonumber(CurrentQQ) then
        return 1
    end

    return 1
end
function ReceiveFriendMsg(CurrentQQ, data)
    data = Data.FriendMsg(data)
    if data.FromUin == tonumber(CurrentQQ) then
        return 1
    end
    if data.FromUin ~= 1948511629 then
        return 1
    end
    if string.find(data.Content, "写公告：") then
        local msg = data.Content:gsub("写公告：", "", 1)
        local ret = WriteMsg(msg)
        if ret == 1 then
            LuaApi.Action:sendFriendText(data.FromUin, "写入成功：\n" .. msg)
        end
    end
    if string.find(data.Content, "清除公告") then
        local msg = "nil"
        local ret = WriteMsg(msg)
        if ret == 1 then
            LuaApi.Action:sendFriendText(data.FromUin, "写入成功：\n" .. msg)
        end
    end
    return 1
end
function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end
