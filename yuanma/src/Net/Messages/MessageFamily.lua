--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  MessageFamily.lua
-- author:    wuqd
-- created:   2015/07/08
-- descrip:   竞技场相关【请求消息格式】
--===================================================

FamilyCGMessage = {}

-- 获取家族排行榜
function FamilyCGMessage:queryFamilyListReq22300(beginIdx,stepCount)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22300                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.beginIndex = beginIdx                          -- 开始索引(0开始)
    msg.body.stepCount = stepCount                          -- 步长不超过30
    -------------------------------------
    send(msg)
end

-- 进入家族请求
function FamilyCGMessage:entryFamilyReq22302()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22302                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)
end

-- 查找家族请求
function FamilyCGMessage:findFamilyReq22304(familyName)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22304                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.familyName = familyName                        -- 家族的名字
    -------------------------------------
    send(msg)   
end

-- 创建家族的请求
function FamilyCGMessage:createFamilyReq22306(familyName,familyPurpose)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22306                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.name = familyName                              -- 家族的名字
    msg.body.purpose = familyPurpose                        -- 家族宗旨
    -------------------------------------
    send(msg)   
end

-- 申请家族的请求
function FamilyCGMessage:applyFamilyReq22308(familyId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22308                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.familyId = familyId                            -- 家族的编号
    -------------------------------------
    send(msg)  
end 

-- 修改家族名字请求
function FamilyCGMessage:changeFamilyNameReq22310(familyName)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22310                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.newName = familyName                           -- 家族的名字
    -------------------------------------
    send(msg)   
end

-- 修改家族宗旨的请求
function FamilyCGMessage:changeFamilyPurposeReq22312(familyPurpose)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22312                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.newPurpose = familyPurpose                        -- 家族的名字
    -------------------------------------
    send(msg)   
end

-- 家族捐献请求   
-- @param donateType 0:家族贡献值 1:家族资金
function FamilyCGMessage:donateFamilyReq22314(nDonateType,nDonateGrade)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22314                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.donateType = nDonateType                       -- 捐献类型
    msg.body.donateGrade = nDonateGrade                     -- 捐献的级别
    -------------------------------------
    send(msg)   
end

-- 家族升级请求
function FamilyCGMessage:upgradeFamilyReq22316()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22316                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)   
end

-- 家族申请者列表
function FamilyCGMessage:queryFamilyApplysReq22318()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22318                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)   
end

-- 批复家族申请请求
function FamilyCGMessage:resplyFamilyApplyReq22320(roleId,isAgree,isAuto)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22320                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.roleId = roleId                                -- 申请者的编号
    msg.body.isAgree = isAgree                              -- 是否同意加入工会
    msg.body.isAuto = isAuto                                -- 是否一键同意
    -------------------------------------
    send(msg)   
end

-- 获取家族成员列表
function FamilyCGMessage:queryFamilyMemberReq22322()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22322                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)   
end

-- 任命家族成员请求
function FamilyCGMessage:familyAppointReq22324(roleId,position)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22324                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.roleId = roleId                                -- 申请者的编号
    msg.body.position = position                            -- 是否同意加入工会
    send(msg)   
end

-- 开除成员请求
function FamilyCGMessage:dismissFamilyMemberReq22326(roleId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22326                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.roleId = roleId                                -- 要开除的成员
    send(msg)   
end

-- 退出家族请求
function FamilyCGMessage:quitFamilyReq22328()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22328                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)   
end    

-- 获取家族动态请求
function FamilyCGMessage:querFamilyNewsReq22330()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22330                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)   
end

-- 获取研究院信息请求
function FamilyCGMessage:querFamilyAcademyReq22332()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22332                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)   
end

-- 升级研究院请求
function FamilyCGMessage:upgradeFamilyAcademyReq22334()
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22334                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    send(msg)   
end

-- 激活研究院科技请求
function FamilyCGMessage:activateFamilyTechReq22336(nTechId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22336                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.techId = nTechId                                -- 科技id
    send(msg)   
end


-- 升级研究院科技请求
function FamilyCGMessage:upgradeFamilyTechReq22338(nTechId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22338                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.techId = nTechId                                -- 科技id
    send(msg)   
end



-- 查找家族通过id
function FamilyCGMessage:FindFamilyByIdReq22340(nFamilyId)
    local msg = {}
    -------------------------------------
    msg.header = {}
    msg.header.cmdNum = 22340                               -- 消息协议号
    msg.header.cmdSeq = nSeqNum                             -- 消息序列号（每次加1）
    msg.header.reserve = 1                                  -- 保留字段
    msg.header.srcId = 0                                    -- 角色ID字段
    msg.header.sessionId = 0                                -- 会话Id字段
    -------------------------------------
    msg.body = {}
    msg.body.familyId = nFamilyId                             -- 家族id
    send(msg)   
end



