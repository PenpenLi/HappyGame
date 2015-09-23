--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  LoginManager.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/23
-- descrip:   登录管理器
--===================================================
LoginManager = {}

local instance = nil

-- 单例
function LoginManager:getInstance()
    if not instance then
        instance = LoginManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function LoginManager:clearCache()
    self._tDeviceInfo = {}                  -- 设备信息
    self._tAppInfo = {}                     -- APP信息
    self._strUserId = ""                    -- 用户Id唯一标示用户（静态）
    self._strSerialCode = ""                -- 账户唯一标示（动态）
    self._strExtData = ""                   -- 账户的扩展字段
    self._strVerifyKeyForDeviceID = ""      -- deviceID的序列码验证
    self._strDeviceToken = ""               -- 推送平台标识码(用于推送消息,不需要推送的置空)
    
    self._tLastServer = {}                  -- 上一次登录的服务器信息
    self._tCurSessionId = nil               -- 标示登陆验证的sessionId
    self._tServerList = {}                  -- 服务器列表，元素：table
    self._tZoneFlags = {}                   -- 当前角色所创建角色所在的zoneId集合
    
    self._tRoleDisplayInfosList = {}        -- 账户持有的角色表现信息列表
    self._tLoginSessionId = nil             -- 账号登录的sessionId 用于创建跟断线从连用
    self._nIsService = nil                  -- 是否可以登录
    self._nRoleId = 0
end

-- 初始化设备信息
function LoginManager:initDeviceInfo()
    self._tDeviceInfo.device_id = ""       -- 设备ID(唯一标识该设备)
    self._tDeviceInfo.locale = "CHN"       -- 国家和地区
    self._tDeviceInfo.language = "Chinese" -- 语言
    self._tDeviceInfo.model = ""           -- 设备型号(HTC渴望v5、Iphone5)
    self._tDeviceInfo.os = ""              -- 操作系统(IOS5、Android4.2)
    if isIOSMobilePlatform() == true then
        self._tDeviceInfo.os = "IOS"
    elseif isAndroidMobilePlatform() == true then
        self._tDeviceInfo.os = "ANDROID"
    end
    self._tDeviceInfo.width_pixels = 0     -- 屏幕分辨率宽度
    self._tDeviceInfo.high_pixels = 0      -- 屏幕分辨率高度
    self._tDeviceInfo.idfa = ""            -- 苹果(ios6和ios7取IDFA,ios5及以下取UDID),安卓(暂置空),winphone(暂置空)
    self._tDeviceInfo.ip = ""              -- IP地址(客户端可能获取的为内网地址,服务端需要对该字段更新)
    self._tDeviceInfo.mac = ""             -- MAC地址(不能获取则置空)
    self._tDeviceInfo.ext = ""             -- 扩展信息

end

-- 初始化APP信息
function LoginManager:initAppInfo()
    self._tAppInfo.app_id = kAppIdType.APPID_MISSION           -- 应用ID
    self._tAppInfo.platform = kPlatformType.PFT_UNKNOWN        -- 平台(渠道)ID
    self._tAppInfo.major_version = 0                           -- 客户端主版本号
    self._tAppInfo.minor_version = 1                           -- 客户端子版本号
    self._tAppInfo.version_info = "内部开发版"                  -- 版本扩展信息(产品名、发布时间、描述等)
end

-- 初始化默认服务器信息
function LoginManager:initDefaultServerInfo()
    local nZoneId = cc.UserDefault:getInstance():getIntegerForKey("LastServerZoneId")
    -- 查找对应id的服务器信息
    for k,v in pairs(self._tServerList) do 
        if v.zoneId == nZoneId then        -- 推荐服务器
            self._tLastServer = v
            break
        end
    end
    
    if self._strUserId ~= "" then
        local index = 1
        for i=1,3 do
            local flag = cc.UserDefault:getInstance():getIntegerForKey("ZoneRoleFlag_"..self._strUserId.."_"..i)
            if flag ~= 0 then
                LoginManager:getInstance()._tZoneFlags[index] = flag
                index = index + 1
            end
        end
    else
        self._strUserId = cc.UserDefault:getInstance():getStringForKey("UserId")
    end
    
    
end

-- 获取上一次的服务器选项
function LoginManager:getLastServerInfo()
    self:initDefaultServerInfo()
    if self._tLastServer.zoneId == nil then  -- 没有上一次服务器记录信息时，默认显示推荐的服务器信息
        local servers = {}
        for k,v in pairs(self._tServerList) do 
            if v.zoneType == kZoneType.ZT_RECOMMEND and v.zoneStatus ~= kZoneStateType.SST_STOP then        -- 推荐服务器
                table.insert(servers,v)
            end
        end
        if table.getn(servers) ~= 0 then
            self:setCurServerInfo(servers[getRandomNumBetween(1,table.getn(servers))])
        end
    end

    if self._tLastServer.zoneId == nil then  -- 没有上一次服务器记录信息时，默认显示新的服务器信息
        local servers = {}
        for k,v in pairs(self._tServerList) do 
            if v.zoneType == kZoneType.ZT_NEW and v.zoneStatus ~= kZoneStateType.SST_STOP then        -- 新服务器
                table.insert(servers,v)
            end
        end
        if table.getn(servers) ~= 0 then
            self:setCurServerInfo(servers[getRandomNumBetween(1,table.getn(servers))])
        end
    end

    return self._tLastServer
end

-- 记录当前的服务器选项
function LoginManager:setCurServerInfo(info)
    if info ~= nil then
        self._tLastServer = info
        cc.UserDefault:getInstance():setIntegerForKey("LastServerZoneId", self._tLastServer.zoneId)
        for k,v in pairs(self._tZoneFlags) do 
            cc.UserDefault:getInstance():setIntegerForKey("ZoneRoleFlag_"..self._strUserId.."_"..k, v)
        end
        cc.UserDefault:getInstance():setStringForKey("UserId",self._strUserId)

    end  
end
