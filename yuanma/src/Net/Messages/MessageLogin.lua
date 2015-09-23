--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessageLogin.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/23
-- descrip:   登录相关【请求消息格式】
--===================================================
-- 请求登录账户

LoginCGMessage = {}

function LoginCGMessage:sendMessageLoginAccount10000(args)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 10000                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.verify_key = args.verify_key                    -- 验证码(根据设备ID加密生成)
    msg.body.deviceToken = args.deviceToken                  -- 推送平台标识码(用于推送消息,不需要推送的置空)
    msg.body.theDeviceInfo = args.theDeviceInfo              -- 设备信息
    msg.body.theAppInfo = args.theAppInfo                    -- 应用程序信息
    -------------------------------------
    send(msg)
end

-- 请求服务器列表
function LoginCGMessage:sendMessageServerList10002(args)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 10002                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    -------------------------------------
    send(msg)
end

-- 母包登录请求
function LoginCGMessage:sendMessageLoginAccount10004(args)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 10004                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}

    msg.body.openId = args.openId                            -- 母包accid
    msg.body.token = args.token                              -- 母包sdk登陆返回token
    msg.body.verify_key = args.verify_key                    -- 验证码(根据设备ID加密生成)
    msg.body.deviceToken = args.deviceToken                  -- 推送平台标识码(用于推送消息,不需要推送的置空)
    msg.body.theDeviceInfo = args.theDeviceInfo              -- 设备信息
    msg.body.theAppInfo = args.theAppInfo                    -- 应用程序信息     
    -------------------------------------
    send(msg)
end

-- 登录游戏
function LoginCGMessage:sendMessageLoginGame20000(args)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20000                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.serialCode = LoginManager:getInstance()._strSerialCode    -- 序列码
    msg.body.verifySerial = mmo.HelpFunc:gXorCoding(LoginManager:getInstance()._strSerialCode)  -- 序列码验证
    msg.body.extData = LoginManager:getInstance()._strExtData                   -- 扩展字段
    -------------------------------------
    send(msg)
end

-- 请求角色随机名字
function LoginCGMessage:sendMessageRandomName20002(args)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20002                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    -------------------------------------
    send(msg)
end

-- 请求创建角色
function LoginCGMessage:sendMessageCreateRole20004(args)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20004                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = LoginManager:getInstance()._tLoginSessionId     -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.roleCareer = args.roleCareer                   -- 职业类型
    msg.body.roleName = args.roleName                       -- 角色名称
    msg.body.zoneId = args.zoneId                           -- 服务器id
    -------------------------------------
    send(msg)
end

-- 没有roleid 请求重新链接
function LoginCGMessage:sendMessageReconnectWithSessionId(sessionId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20012                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = sessionId     -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.verifySerial = mmo.HelpFunc:gXorCoding(LoginManager:getInstance()._tDeviceInfo.device_id)  -- 序列码验证
    msg.body.roleId =                                 -- 要切换的角色ID
    -------------------------------------
    send(msg)
end

-- 请求断线重新连接
function LoginCGMessage:sendMessageReconnect(roleId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 20012                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = LoginManager:getInstance()._tLoginSessionId     -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.verifySerial = mmo.HelpFunc:gXorCoding(LoginManager:getInstance()._tDeviceInfo.device_id)  -- 序列码验证
    msg.body.roleId = roleId                                -- 要切换的角色ID
    -------------------------------------
    send(msg)
end

--获取公告标签列表请求
function LoginCGMessage:sendMessageGetNoticeTag()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 10006                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)
end

--获取公告内容请求
function LoginCGMessage:sendMessageNotice(nIndex)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 10008                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.tagIndex = nIndex                              -- 下表

    send(msg)
end

-- 选择分区请求
function LoginCGMessage:sendMessageSelectZone(nZoneId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 10010                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.zoneId = nZoneId                              -- 选择分区 

    send(msg)
end

-- 选择分区请求
function LoginCGMessage:sendMessageQueryRank(nZoneId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 10012                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.zoneId = nZoneId                              -- 选择分区 
    send(msg)
end


-- 取消排队
function LoginCGMessage:sendMessageCancelRank()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 10014                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)
end



