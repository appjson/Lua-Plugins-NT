-- // 引入所有包
local log = require("log")
Api = require("coreApi")
local json = require("json")
local http = require("http")
local mysql = require("mysql")
Utils = require("Plugins/lib/Utils")

-- // 引入polyfill
Data = require "Plugins/lib/Data"

-- // 读取配置
QQ = Data.CurrentQQ

-- // 全局定义
Action = {}
FRIEND = 1
GROUP = 2
PRIVATE = 3

------ Text 文本消息 ------

---发送文本消息
---@param to number 发送对象
---@param type number 对象类型
---@param text string 文本内容
---@param fromGroup number | nil 来源群号
---@param at table | nil at成员列表
---@return function
function Action:_sendText(to, type, text, fromGroup, at)
    local payload = {CgiCmd = "MessageSvc.PbSendMsg", CgiRequest = {ToUin = to, ToType = type, Content = text}}
    if type == 3 then
        payload.CgiRequest.GroupCode = fromGroup
    end
    return Api.Api_MagicCgiCmd(QQ, payload)
end

---发送好友文本消息
---@param user number 好友QQ
---@param text string 文本内容
---@return function
function Action:sendFriendText(user, text)
    return self:_sendText(user, 1, text, nil)
end

---发送群文本消息
---@param group number 群号
---@param text string 文本内容
---@param at table | nil at成员列表
---@return function
function Action:sendGroupText(group, text, at)
    return self:_sendText(group, 2, text, nil, at)
end

function Action:sendPrivateText(user, group, text)
    return self:_sendText(user, 3, text, group, nil)
end

------ /Text 文本消息 ------

------ File 文件传输 ------
---上传资源文件
---@param fileSrc string 文件路径
---@param type number 上传类型：1好友图片2群组图片26好友语音29群组语音
function Action:_upload(fileSrc, type)
    local payload = {
        CgiCmd = "PicUp.DataUp",
        CgiRequest = {
            CommandId = type,
            FilePath = fileSrc
        }
    }
    return Api.Api_MagicCgiCmd(QQ, payload)
end
function Action:_uploadBase64(filePath, type)
    local content = Utils.ReadFile(filePath)
    local base64 = PkgCodec.EncodeBase64(content)
    local payload = {
        CgiCmd = "PicUp.DataUp", --lua 内置30秒脚本执行超时 尽量不要执行耗时操作
        CgiRequest = {
            CommandId = type, --上传群图片 1好友图片2群组图片26好友语音29群组语音
            Base64Buf = base64 --通过Base64Buf 发送资源
        }
    }
    return Api.Api_MagicCgiCmd(QQ, payload)
end

------ Pic 图片消息 ------

function Action:_sendPic(to, type, filePath)
    local uploadRet = self:_upload(filePath, type)
    local str =
        string.format(
        "FileToken:%s\nMD5:%s\n图片大小:%d\n",
        uploadRet.ResponseData.FileToken,
        uploadRet.ResponseData.FileMd5, --userdata 类型
        uploadRet.ResponseData.FileSize
    )
    log.info("PicUp.DataUp \n%s", str)
    local payload = {
        CgiCmd = "MessageSvc.PbSendMsg",
        CgiRequest = {
            ToUin = to,
            ToType = type,
            Images = {
                {
                    FileToken = uploadRet.ResponseData.FileToken,
                    FileMd5 = uploadRet.ResponseData.FileMd5,
                    FileSize = uploadRet.ResponseData.FileSize,
                    Height = 720,
                    Width = 1280
                }
            }
        }
    }
    return Api.Api_MagicCgiCmd(QQ, payload)
end

function Action:sendFriendPic(to, filePath)
    return self:_sendPic(to, FRIEND, filePath)
end

function Action:sendGroupPic(to, filePath)
    return self:_sendPic(to, GROUP, filePath)
end

------ Voice 语音消息 ------
function Action:_sendVoice(to, type, filePath)
    local fileType
    if type == FRIEND then
        fileType = 26
    else
        fileType = 29
    end
    local uploadRet = self:_uploadBase64(filePath, fileType)
    local str =
        string.format(
        "FileToken:%s\nMD5:%s\n音频大小:%d\n",
        uploadRet.ResponseData.FileToken,
        uploadRet.ResponseData.FileMd5, --userdata 类型
        uploadRet.ResponseData.FileSize
    )
    log.info("PicUp.DataUp \n%s", str)
    local payload = {
        CgiCmd = "MessageSvc.PbSendMsg",
        CgiRequest = {
            ToUin = to,
            ToType = type,
            Voice = {
                FileToken = uploadRet.ResponseData.FileToken,
                FileMd5 = uploadRet.ResponseData.FileMd5,
                FileSize = uploadRet.ResponseData.FileSize
            }
        }
    }
    return Api.Api_MagicCgiCmd(QQ, payload)
end

function Action:sendFriendVoice(to, filePath)
    return self:_sendVoice(to, FRIEND, filePath)
end

function Action:sendGroupVoice(to, filePath)
    return self:_sendVoice(to, GROUP, filePath)
end

function Action:revokeGroupMsg(group, seq, random)
    local payload = {
        CgiCmd = "GroupRevokeMsg",
        CgiRequest = {
            Uin = group,
            MsgSeq = seq,
            MsgRandom = random
        }
    }
    return Api.Api_MagicCgiCmd(QQ, payload)
end

function Action:shutup(group, id, second)
    local payload = {
        CgiCmd = "SsoGroup.Op",
        CgiRequest = {
            OpCode = 4691,
            Uin = group,
            Uid = id,
            BanTime = second
        }
    }
    return Api.Api_MagicCgiCmd(QQ, payload)
end

local function urlencode(str)
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

return {
    Action = Action,
    urlencode = urlencode
}
