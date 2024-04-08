local json = require("json")
Utils = {}

-- -- 定义一个常量
-- Utils.constant = "这是一个常量"

function Utils.Sleep(n)
    local t0 = os.clock()
    while os.clock() - t0 <= n do
    end
end

function Utils.GetConf(key)
    local raw = Utils.ReadFile("./Plugins/conf.json")
    local conf = json.decode(raw)
    if key ~= nil then
        return conf[key]
    end
    return conf
end

--时间戳->字符串 格式化时间 到秒
function Utils.FormatUnixTime2Date(t)
    return string.format(
        "%s年%s月%s日%s时%s分%s秒",
        os.date("%Y", t),
        os.date("%m", t),
        os.date("%d", t),
        os.date("%H", t),
        os.date("%M", t),
        os.date("%S", t)
    )
end

--时间戳->字符串 格式化时间 到日期
function Utils.FormatUnixTime2Day(t)
    return string.format("%s年%s月%s日", os.date("%Y", t), os.date("%m", t), os.date("%d", t))
end

function Utils.GetDateTime()
    return os.date("%Y%m%d", os.time())
end

-- 格式化日期（自定义）
function Utils.GetWeekTime()
    local _WEEK = {"星期日", "星期一", "星期二", "星期三", "星期四", "星期五", "星期六"}
    local d = os.time()
    local w = os.date("%w", d)
    local t = os.date("%Y-%m-%d %X | ", d)
    t = t .. _WEEK[w + 1]
    return t
end

--字符串分割
function Utils.split(input, delimiter)
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

--读取文件
function Utils.ReadFile(filePath)
    local f, err = io.open(filePath, "rb")
    if err ~= nil then
        return nil
    end
    if f ~= nil then
        local content = f:read("*all")
        f:close()
        return content
    end
end

--Url解码
function Utils.UrlDecode(s)
    s =
        string.gsub(
        s,
        "%%(%x%x)",
        function(h)
            return string.char(tonumber(h, 16))
        end
    )
    return s
end
function Utils.UrlEncode(str)
    return string.gsub(
        string.gsub(
            str,
            "([^%w%.%- ])",
            function(c)
                return string.format("%%%02X", string.byte(c))
            end
        ),
        " ",
        "%%20"
    )
end

--随机整数
function Utils.GenRandInt(x, y)
    math.randomseed(tonumber(tostring(os.time()):reverse():sub(1, 6)))
    local num = math.random(x, y)
    return num
end

function Random(n, m)
    math.randomseed(os.clock() * math.random(1000000, 90000000) + math.random(1000000, 90000000))
    return math.random(n, m)
end

--随机字符串
function Utils.RandomLetter(len)
    local rt = ""
    for i = 1, len, 1 do
        rt = rt .. string.char(Random(97, 122))
    end
    return rt
end

--获取星期几
function Utils.GetWday()
    local wday = os.date("%w", os.time())
    local weekTab = {
        ["0"] = "日",
        ["1"] = "一",
        ["2"] = "二",
        ["3"] = "三",
        ["4"] = "四",
        ["5"] = "五",
        ["6"] = "六"
    }
    return weekTab[wday]
end

--写文件二进制
function Utils.WriteFile(path, stream)
    local file = io.open(path, "wb")
    if file then
        if file:write(stream) == nil then
            return false
        end
        io.close(file)
        return true
    else
        return false
    end
end

--写文件内容
function Utils.WriteContent(path, content)
    local file = io.open(path, "w+")
    if file then
        if file:write(content) == nil then
            return false
        end
        io.close(file)
        return true
    else
        return false
    end
end

---
-- @function: 获取table的字符串格式内容，递归
-- @tab： table
-- @ind：不用传此参数，递归用（前缀格式（空格））
-- @return: format string of the table
function Utils.dumpTable(tab, ind)
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
            s = tostring(v)
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

return Utils
