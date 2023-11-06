LuaApi = require "Plugins/lib/LuaApi"
Data = require "Plugins/lib/Data"

function ReceiveGroupMsg(CurrentQQ, data)
    data = Data.GroupMsg(data)
    if data.FromUserId == tonumber(CurrentQQ) then
        return 1
    end
    -- if data.FromUserId == 1948511629 then
    --     if data.Content:find("^给大家来%d+秒禁言套餐$") == 1 then
    --         local key = data.Content:gsub("给大家来", "")
    --         key = key:gsub("秒禁言套餐", "")
    --         local t = tonumber(key)
    --         Api.Api_CallFunc(
    --             CurrentQQ,
    --             "OidbSvc.0x89a_0",
    --             {
    --                 GroupID = data.FromGroupId,
    --                 Switch = 1
    --             }
    --         )
    --         os.execute("sleep " .. t)
    --         Api.Api_CallFunc(
    --             CurrentQQ,
    --             "OidbSvc.0x89a_0",
    --             {
    --                 GroupID = data.FromGroupId,
    --                 Switch = 0
    --             }
    --         )
    --         return 1
    --     end
    --     if data.MsgType == "AtMsg" then
    --         if string.find(data.Content, "解除禁言") then
    --             local content = json.decode(data.Content)
    --             ID = tonumber(content.UserID[1])
    --             Shutup(CurrentQQ, data.FromGroupId, ID, 0)
    --         elseif string.find(data.Content, "禁言") then
    --             local content = json.decode(data.Content)
    --             ID = tonumber(content.UserID[1])
    --             Shutup(CurrentQQ, data.FromGroupId, ID, 60)
    --         end
    --     end
    -- end
    if data.Content:find("给我来份禁言套餐$") or data.Content:find("给我来一个禁言套餐$") then
        math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 7)))
        local t = math.random(1, 60)
        print("禁言：" .. t .. " 分钟")
        LuaApi.Action:shutup(data.FromGroupId, data.FromUserUid, t * 60)
        return 1
    end
    if data.Content:find("^给我来%d+分钟禁言套餐$") == 1 then
        local key = data.Content:gsub("给我来", "")
        key = key:gsub("分钟禁言套餐", "")
        local t = tonumber(key)
        if t <= 4320 then
            LuaApi.Action:shutup(data.FromGroupId, data.FromUserUid, t * 60)
        else
            local msg = string.format("想被禁言%d天怎么不直接退群呢？😅", t / 60 / 24)
            LuaApi.Action:sendGroupText(data.FromGroupId, msg)
        end
        return 1
    end
    if data.Content:find("^给我来%d+小时禁言套餐$") == 1 then
        local key = data.Content:gsub("给我来", "")
        key = key:gsub("小时禁言套餐", "")
        local t = tonumber(key)
        if t <= 72 then
            LuaApi.Action:shutup(data.FromGroupId, data.FromUserUid, t * 60 * 60)
        else
            local msg = string.format("想被禁言%d天怎么不直接退群呢？😅", t / 24)
            LuaApi.Action:sendGroupText(data.FromGroupId, msg)
        end
        return 1
    end
end
function ReceiveFriendMsg(CurrentQQ, data)
    return 1
end
function ReceiveEvents(CurrentQQ, data, extData)
    return 1
end
