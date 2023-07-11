-- menu 菜单
local log = require("log")
local json = require("json")
local http = require("http")
local lib = require "Plugins/lib/Lualib"
Data = require "Plugins/lib/Data"
Utils = require "Plugins/lib/Utils"

local menu =
  [[{
  "app": "com.tencent.miniapp",
  "desc": "",
  "view": "notification",
  "ver": "1.0.0.1",
  "prompt": "CyberBot菜单",
  "meta": {
    "notification": {
      "appInfo": {
        "appName": "CyberBot菜单",
        "appType": 4,
        "ext": "",
        "img": "img/pyqbot.png",
        "img_s": "",
        "appid": 1108249016,
        "iconUrl": "img/pyqbot.png"
      },
      "button": [
        { "action": "", "name": "⚠️ [括号]内为命令示例" },
        { "action": "", "name": "⚠️ (括号)为需要替换的内容" },
        { "action": "", "name": "[.menu] 菜单" },
        { "action": "", "name": "[赞我|拍我] 给你点赞50个" },
        { "action": "", "name": "[签到|签到规则] 获得积分" },
        { "action": "", "name": "[早安|晚安] 每日问候打卡" },
        { "action": "", "name": "[.开始解析] 解析分享卡片的URL" },
        { "action": "", "name": "[彩虹屁|一言] 一句话" },
        { "action": "", "name": "[语音：(一段文字)] 文字转语音" },
        { "action": "", "name": "[?(选项1)还是(选项2)] 帮你做选择" },
        { "action": "", "name": "[alias (a)=(b)] 自定义回复" },
        { "action": "", "name": "[复读机 (XXX)] 复读XXX" },
        { "action": "", "name": "[检测 (qq.com)] 检测网站" },
        { "action": "", "name": "[.bing] 必应每日图片" },
        { "action": "", "name": "[.time] 获得格式化时间" },
        { "action": "", "name": "[.随机播放] 播放我的曲库" },
        { "action": "", "name": "[疫情信息] 获取最新疫情信息" },
        { "action": "", "name": "[给我来份禁言套餐] 让你闭嘴" },
        { "action": "", "name": "[红外云图|真彩色云图|可见光云图]" },
        { "action": "", "name": "[水汽图|台风路径|雷达图]" },
        { "action": "", "name": "[.help] 更多帮助信息" }
      ],
      "emphasis_keyword": ""
    }
  }
}]]

local welcome = [[
大家好~我是CyberBot~
发送 .menu 获取使用帮助菜单
本bot还不完善，如果有需求欢迎提出哦~
注：本bot不会处理金钱有关消息，放心使用~
]]

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

function ReceiveFriendMsg(CurrentQQ, data)
  data = Data.FriendMsg(data)
  if data.Content:find("^%.menu$") then
    local msg_obj = json.decode(menu)
    local msg_tb = {}
    local msg = ""
    for k, v in ipairs(msg_obj["meta"]["notification"]["button"]) do
      table.insert(msg_tb, v["name"])
    end
    for k, v in ipairs(msg_tb) do
      msg = msg .. v .. "\n"
    end
    lib.Action:sendFriendText(data.FromUin, msg)
    return 1
  end

  if data.Content:find("^机器人状态$") then
    local ret = http.request("GET", "http://" .. Data.Host .. "/v1/clusterinfo")
    if ret ~= nil and ret ~= "" then
      local res = json.decode(ret.body)
      local msg =
        string.format(
        "QQ：%s\nQQ等级：%s\n总收发消息：%d/%d\n总收发数据：%s/%s\n在线时长：%s\n\n核心：%s %s\n运行时间：%s\n内存占用：%s\nGo版本：%s-%s\nGo程：%d\n机器人版本：%s\n#WITHDRAW=20",
        res["ResponseData"]["QQUsers"][1]["QQ"],
        res["ResponseData"]["QQUsers"][1]["LevelInfo"],
        res["ResponseData"]["QQUsers"][1]["ReceiveCount"],
        res["ResponseData"]["QQUsers"][1]["SendCount"],
        res["ResponseData"]["QQUsers"][1]["TotalRecv"],
        res["ResponseData"]["QQUsers"][1]["TotalSend"],
        res["ResponseData"]["QQUsers"][1]["OnlieTime"],
        res["ResponseData"]["CpuNum"],
        res["ResponseData"]["Platform"],
        res["ResponseData"]["ServerRuntime"],
        res["ResponseData"]["Sys"],
        res["ResponseData"]["GoVersion"],
        res["ResponseData"]["GoArch"],
        res["ResponseData"]["GoroutineNum"],
        res["ResponseData"]["Version"]
      )
      lib.Action:sendFriendText(data.FromUin, msg)
    end
    return 1
  end

  if data.Content:find("^%.插件列表$") and data.FromUin == Data.AdminQQ then
    local dir = "./Plugins"
    local file = "./Plugins/Cache/filelist.txt"
    local cmd = "ls -A -X " .. dir .. " > " .. file
    os.execute(cmd)
    local filedata = Read(file)
    local msg = "当前使用的Lua插件⬇️\n"
    if filedata ~= nil then
      local i = 1
      for s in string.gmatch(filedata, "%w+%.lua%c") do
        msg = msg .. i .. " - " .. s
        i = i + 1
      end
      lib.Action:sendFriendText(data.FromUin, msg)
      return 1
    end
  end

  if data.Content:find("^%.停用插件列表$") and data.FromUin == Data.AdminQQ then
    local dir = "./Plugins"
    local file = "./Plugins/Cache/filelist-disabled.txt"
    local cmd = "ls -A -X " .. dir .. " > " .. file
    os.execute(cmd)
    local filedata = Read(file)
    local msg = "当前停用的Lua插件⬇️\n"
    if filedata ~= nil then
      local i = 1
      for s in string.gmatch(filedata, "%w+%.lua%.disabled%c") do
        msg = msg .. i .. " - " .. s
        i = i + 1
      end
      lib.Action:sendFriendText(data.FromUin, msg)
      return 1
    end
  end

  if data.Content:find("^%.启用插件") and data.FromUin == Data.AdminQQ then
    local files = data.Content:gsub("^%.启用插件", "")
    if files == "Menu.lua" then
      return 1
    end
    local dir = "./Plugins/"
    local cmd = "mv " .. dir .. files .. ".disabled" .. " " .. dir .. files
    os.execute(cmd)
    local msg = "已启用插件：" .. files
    lib.Action:sendFriendText(data.FromUin, msg)
    return 1
  end

  if data.Content:find("^%.停用插件") and data.FromUin == Data.AdminQQ then
    local files = data.Content:gsub("^%.停用插件", "")
    local dir = "./Plugins/"
    local cmd = "mv " .. dir .. files .. " " .. dir .. files .. ".disabled"
    os.execute(cmd)
    local msg = "已停用插件：" .. files
    lib.Action:sendFriendText(data.FromUin, msg)
    return 1
  end
  return 1
end
function ReceiveGroupMsg(CurrentQQ, data)
  data = Data.GroupMsg(data)
  if data.FromUserId == tonumber(CurrentQQ) then
    return 1
  end
  if data.Content:find("^%.menu$") then
    local msg_obj = json.decode(menu)
    local msg_tb = {}
    local msg = ""
    for k, v in ipairs(msg_obj["meta"]["notification"]["button"]) do
      table.insert(msg_tb, v["name"])
    end
    for k, v in ipairs(msg_tb) do
      msg = msg .. v .. "\n"
    end
    lib.Action:sendGroupText(data.FromGroupId, msg, {})
    return 1
  end

  if data.Content:find("^给大家打个招呼$") and data.FromUserId == Data.AdminQQ then
    lib.Action:sendGroupText(data.FromGroupId, welcome, {})
    return 1
  end

  if data.Content:find("^%.插件列表$") and data.FromUserId == Data.AdminQQ then
    local dir = "./Plugins"
    local file = "./Plugins/Cache/filelist.txt"
    local cmd = "ls -A -X " .. dir .. " > " .. file
    os.execute(cmd)
    local filedata = Read(file)
    local msg = "当前使用的Lua插件⬇️\n"
    if filedata ~= nil then
      local i = 1
      for s in string.gmatch(filedata, "%w+%.lua%c") do
        msg = msg .. i .. " - " .. s
        i = i + 1
      end
      lib.Action:sendGroupText(data.FromGroupId, msg, {})
      return 1
    end
  end

  if data.Content:find("^%.停用插件列表$") and data.FromUserId == Data.AdminQQ then
    local dir = "./Plugins"
    local file = "./Plugins/Cache/filelist-disabled.txt"
    local cmd = "ls -A -X " .. dir .. " > " .. file
    os.execute(cmd)
    local filedata = Read(file)
    local msg = "当前停用的Lua插件⬇️\n"
    if filedata ~= nil then
      local i = 1
      for s in string.gmatch(filedata, "%w+%.lua%.disabled%c") do
        msg = msg .. i .. " - " .. s
        i = i + 1
      end
      lib.Action:sendGroupText(data.FromGroupId, msg, {})
      return 1
    end
  end

  if data.Content:find("^%.启用插件") and data.FromUserId == Data.AdminQQ then
    local files = data.Content:gsub("^%.启用插件", "")
    if files == "Menu.lua" then
      return 1
    end
    local dir = "./Plugins/"
    local cmd = "mv " .. dir .. files .. ".disabled" .. " " .. dir .. files
    os.execute(cmd)
    lib.Action:sendGroupText(data.FromGroupId, "已启用：" .. files, {})
    return 1
  end

  if data.Content:find("^%.停用插件") and data.FromUserId == Data.AdminQQ then
    local files = data.Content:gsub("^%.停用插件", "")
    local dir = "./Plugins/"
    local cmd = "mv " .. dir .. files .. " " .. dir .. files .. ".disabled"
    os.execute(cmd)
    lib.Action:sendGroupText(data.FromGroupId, "已停用：" .. files .. ".disabled", {})
    return 1
  end

  if data.Content:find("^%.time$") then
    local t = Utils.GetDateTime()
    lib.Action:sendGroupText(data.FromGroupId, t, {})
    return 1
  end

  if data.Content:find("^机器人状态$") then
    local ret = http.request("GET", "http://" .. Data.Host .. "/v1/clusterinfo")
    if ret ~= nil and ret ~= "" then
      local res = json.decode(ret.body)
      local msg =
        string.format(
        "QQ：%s\nQQ等级：%s\n总收发消息：%d/%d\n总收发数据：%s/%s\n在线时长：%s\n\n核心：%s %s\n运行时间：%s\n内存占用：%s\nGo版本：%s-%s\nGo程：%d\n机器人版本：%s\n#WITHDRAW=20",
        res["ResponseData"]["QQUsers"][1]["QQ"],
        res["ResponseData"]["QQUsers"][1]["LevelInfo"],
        res["ResponseData"]["QQUsers"][1]["ReceiveCount"],
        res["ResponseData"]["QQUsers"][1]["SendCount"],
        res["ResponseData"]["QQUsers"][1]["TotalRecv"],
        res["ResponseData"]["QQUsers"][1]["TotalSend"],
        res["ResponseData"]["QQUsers"][1]["OnlieTime"],
        res["ResponseData"]["CpuNum"],
        res["ResponseData"]["Platform"],
        res["ResponseData"]["ServerRuntime"],
        res["ResponseData"]["Sys"],
        res["ResponseData"]["GoVersion"],
        res["ResponseData"]["GoArch"],
        res["ResponseData"]["GoroutineNum"],
        res["ResponseData"]["Version"]
      )
      lib.Action:sendGroupText(data.FromGroupId, msg, {})
    end
    return 1
  end
  return 1
end
function ReceiveEvents(CurrentQQ, data, extData)
  return 1
end
