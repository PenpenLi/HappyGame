--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FriendHelpBattleCell.lua
-- author:    liyuhang
-- created:   2015/9/22
-- descrip:   好友助战cell
--===================================================
local FriendHelpBattleCell = class("FriendHelpBattleCell",function()
    return ccui.ImageView:create()
end)

-- 构造函数
function FriendHelpBattleCell:ctor()
    -- 层名称
    self._strName = "FriendHelpBattleCell"        

    self._fNormalScale = 1.0                  -- 正常大小尺寸
    self._fBigScale = 1.04                    -- 按下时的放大尺寸
    -- 地图背景
    self._pParams = nil
    self._pBg = nil
    self._recBg = cc.rect(0,0,0,0)  -- 背景框所在矩形

    self._pDataInfo = nil
    self._fCallback = nil

    --FIXED 是否在CD中 lzx
    self._bInCD = false
end

-- 创建函数
function FriendHelpBattleCell:create(dataInfo)
    local dialog = FriendHelpBattleCell.new()
    dialog:dispose(dataInfo)
    return dialog
end

-- 处理函数
function FriendHelpBattleCell:dispose(dataInfo)
    --注册（好友技能配置信息更新）
    NetRespManager:getInstance():addEventListener(kNetCmd.kUpdateFriendSkillDatas, handler(self, self.hanleMsgUpdateFriendSkill))

    ResPlistManager:getInstance():addSpriteFrames("FriendListInfo.plist")
    self._pDataInfo = dataInfo

    self:initUI()

    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        local pLocal = self._pCCS:convertTouchToNodeSpace(touch)
        if cc.rectContainsPoint(self._recBg,pLocal) == false then
            return false
        else
            return true
        end


    end
    local function onTouchMoved(touch,event)
        local location = self._pBg:convertTouchToNodeSpace(touch)

    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        local pLocal = self._pBg:convertTouchToNodeSpace(touch)

        if cc.rectContainsPoint(self._recBg,pLocal) == true then
        --DialogManager:getInstance():showDialog("FriendTipsDialog") 
        end
    end
    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(false)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitFriendHelpBattleCell()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end

function FriendHelpBattleCell:initUI()
    --图标按钮
    local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then

        end
    end

    --图标按钮
    local  onTouchBg = function (sender, eventType)
        if eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
            self:toBigScale()
            self._fMoveDis = 0
        elseif eventType == ccui.TouchEventType.moved then
            self._fMoveDis = self._fMoveDis + 1
            if self._fMoveDis >= 5 then
                self:toNormalScale()
            end
        elseif eventType == ccui.TouchEventType.ended then
            if self:getScale() > self._fNormalScale then
                -- 显示邮件内容弹框
               -- DialogManager:getInstance():showDialog("FriendTipsDialog",{self._pDataInfo})
               --FIXED 用显示判断是否有CD不保险 lzx
               --local beInCD = self._pParams._pZzTextTime:isVisible()
               if self._bInCD then
               	    NoticeManager:showSystemMessage("有cd")
               	    return
               end
               
               if self._fCallback ~= nil then
                    self._fCallback(self._pDataInfo)
               end
            end
            self:toNormalScale()
            self._fMoveDis = 0
        end
    end
    -- 加载csb 组件
    local params = require("FriendListInfoParams"):create()
    self._pParams = params
    self._pCCS = params._pCCS
    self._pBg = params._pListInfoBg

    self._pBg:setSwallowTouches(false)
    self._pBg:addTouchEventListener(onTouchBg)

    local x,y = self._pBg:getPosition()
    local size = self._pBg:getContentSize()
    local anchor = self._pBg:getAnchorPoint()
    local posBg = self._pCCS:convertToWorldSpace(cc.p(x - size.width*anchor.x,y - size.height*anchor.y))
    self._recBg = cc.rect(posBg.x,posBg.y,size.width,size.height)

    self._pCCS:setPosition(0, 0)
    self._pCCS:setAnchorPoint(cc.p(0,0))
    self:addChild(self._pCCS)

    self:updateData()
end

function FriendHelpBattleCell:updateData()
    if self._pDataInfo == nil then
        return
    end
    self._pParams._pHeadIcon:loadTexture(
        kRoleIcons[self._pDataInfo.roleCareer],
        ccui.TextureResType.plistType)

    self._pParams._pPlayerNameText:setString(self._pDataInfo.roleName)
    self._pParams._pPowerFont:setString(self._pDataInfo.fightingPower)
    self._pParams._pIntimacyNum:setString(self._pDataInfo.friendship)

    if self._pDataInfo.offlineTime == 4294967295 then
        --在线
        unDarkNode(self._pParams._pHeadIcon:getVirtualRenderer():getSprite())
        self._pParams._pText:setString("")
    else
        darkNode(self._pParams._pHeadIcon:getVirtualRenderer():getSprite())

        local nowTime = os.time() - self._pDataInfo.offlineTime
        self._pParams._pText:setString(gOneTimeToStr(nowTime).."前")
    end

    self._pParams._pPlayerJobText:setString(kRoleCareerTitle[self._pDataInfo.roleCareer])
    self._pParams._pPlayerLvText:setString("Lv"..self._pDataInfo.level)

    if FriendManager:getInstance()._nMountFriendSkill ~= nil then
        if FriendManager:getInstance()._nMountFriendSkill.roleId == self._pDataInfo.roleId then
            self._pParams._pAlreadyIcon:setVisible(true)
        else
            self._pParams._pAlreadyIcon:setVisible(false)
        end
    else
        self._pParams._pAlreadyIcon:setVisible(false)
    end

    self._pParams._pVipFnt:setString(self._pDataInfo.vipLevel)
    
    -- 好友助战cd
    local lastHelpTime = os.time() - self._pDataInfo.cheerTime
    --local lastHelpTime = 100
    --判断是否有cd
    if lastHelpTime - TableConstants.FriendsAssistCD.Value < 0 then        
        self._pParams._pZzTextTime:setString(TableConstants.FriendsAssistCD.Value - lastHelpTime.."秒") 
        local timeCallBack = function(time,id)
            if  self._pParams._pZzTextTime then
                --FIXED   lzx
                self._pParams._pZzTextTime:setVisible(true)
                self._pParams._pZzTextTime:setString(time.."秒")
                self._bInCD = true
            end
            if time == 0 then
                --FIXED   lzx
                --self._pParams._pZzTextTime:setVisible(false)
                self._pParams._pZzTextTime:setString("0秒")
                self._bInCD = false
            end
        end
        if lastHelpTime <= TableConstants.FriendsAssistCD.Value then
            CDManager:getInstance():insertCD({"friendHelpFight"..self._pDataInfo.roleId,TableConstants.FriendsAssistCD.Value - lastHelpTime,timeCallBack})
        end
    else
        --FIXED   lzx
        --self._pParams._pZzTextTime:setVisible(false)
        self._pParams._pZzTextTime:setString("0秒")
        self._bInCD = false
    end
end

-- 整体到放大尺寸
function FriendHelpBattleCell:toBigScale()
    self:setScale(self._fBigScale)
end

-- 整体到正常尺寸
function FriendHelpBattleCell:toNormalScale()
    self:setScale(self._fNormalScale)
end

function FriendHelpBattleCell:setInfo(info)
    self._pDataInfo = info

    self:updateData()
end

-- 退出函数
function FriendHelpBattleCell:onExitFriendHelpBattleCell()
    NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("FriendListInfo.plist")
    CDManager:getInstance():deleteOneCdByKey("friendHelpFight"..self._pDataInfo.roleId)
end

function FriendHelpBattleCell:hanleMsgUpdateFriendSkill(event)
    if FriendManager:getInstance()._nMountFriendSkill ~= nil then
        if FriendManager:getInstance()._nMountFriendSkill.roleId == self._pDataInfo.roleId then
            self._pParams._pAlreadyIcon:setVisible(true)
        else
            self._pParams._pAlreadyIcon:setVisible(false)
        end
    else
        self._pParams._pAlreadyIcon:setVisible(false)
    end
end

return FriendHelpBattleCell
