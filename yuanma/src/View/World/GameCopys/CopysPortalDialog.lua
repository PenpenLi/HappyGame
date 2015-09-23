--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  CopysPortalDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/3/17
-- descrip:   副本入口
--===================================================
local CopysPortalDialog = class("CopysPortalDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function CopysPortalDialog:ctor()
    self._strName = "CopysPortalDialog"        -- 层名称
    self._pCCS = nil
    self._pBg = nil
    self._pscrollview = nil
    self._pCloseButton = nil
    self._pscrollview = nil                    --副本的ScrollView
    self._tCopyBgButton = {}                   --点击button时显示下面的button和信息
    self._tNodecopys = {}                      --各个界面的挂载node  用来设置缩放
    self._tLockIcon = {}                       --解锁图标
    self._tLockActNode = {}                    --未解锁的特效挂载点
    self._tCopyAttackButton = {}               --进入副本的button
    self._tCopyType = {}                       --副本的类型
    self._tCopysDiscBg = {}                    --下面的要执行动画的层
    self._tCopyOpenLv = {}                     --副本开启的等级
    self._tCopyHasLock = {}                    --记录副本解锁
    self._tOpenlvLable = {}                    --说明多少级开启副本
end

-- 创建函数
function CopysPortalDialog:create(args)
    local dialog = CopysPortalDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function CopysPortalDialog:dispose(args)

    ResPlistManager:getInstance():addSpriteFrames("ExerciseCopysDialog.plist")
    ResPlistManager:getInstance():addSpriteFrames("CopysBgLock.plist")
    local params = require("ExerciseCopysDialogParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pbackground
    self._pCloseButton = params._pclosebutton
    self._pscrollview = params._pscrollview
    self._tCopyBgButton ={params._pcopyspicture01,params._pcopyspicture02,params._pcopyspicture03} --点击button时显示下面的button和信息
    self._tNodecopys = { params._pnodecopys01,params._pnodecopys02,params._pnodecopys03,params}              --各个界面的挂载node
    self._tLockIcon = {params._plock01,params._plock02,params._plock03}                                    --解锁图标
    self._tLockActNode ={params._pnodelock01,params._pnodelock02,params._pnodelock03}                  --未解锁的图标特效挂在node
    self._tCopyAttackButton = {params._pcopysbutton01,params._pcopysbutton02,params._pcopysbutton03}--进入副本的button
    self._tCopysDiscBg = {params._pCopysDiscBg1,params._pCopysDiscBg2,params._pCopysDiscBg3}         --下面的灰色要执行动画的层
    self._tOpenlvLable = { params._plocktext01,params._plocktext02,params._plocktext03}                --说明多少级开启副本
    local nx,ny = params._pCopysDiscBg1:getPosition()
    self._pCopysDiscBgPos = cc.p(nx,ny)
    -- 初始化dialog的基础组件
    self:disposeCSB()
    --初始化界面需要的数据
    self:createCopysDate()
    --初始化界面UI
    self:createCopysUi()


    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
            self:close()
        end
        return false   --可以向下传递事件
    end
    local function onTouchMoved(touch,event)
        local location = touch:getLocation()
        print("touch move ".."x="..location.x.."  y="..location.y)
    end
    local function onTouchEnded(touch,event)
        local location = touch:getLocation()
        print("touch end ".."x="..location.x.."  y="..location.y)
    end

    -- 添加监听器
    self._pTouchListener = cc.EventListenerTouchOneByOne:create()
    self._pTouchListener:setSwallowTouches(true)
    self._pTouchListener:registerScriptHandler(onTouchBegin,cc.Handler.EVENT_TOUCH_BEGAN )
    self._pTouchListener:registerScriptHandler(onTouchMoved,cc.Handler.EVENT_TOUCH_MOVED )
    self._pTouchListener:registerScriptHandler(onTouchEnded,cc.Handler.EVENT_TOUCH_ENDED )
    self:getEventDispatcher():addEventListenerWithSceneGraphPriority(self._pTouchListener, self)

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitCopysPortalDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return

end
function CopysPortalDialog:createCopysDate()
   
    self._tCopyOpenLv = {TableNewFunction[20].Level,TableNewFunction[21].Level,TableNewFunction[22].Level}  --副本开启的等级
    local nRoleLevel = RolesManager:getInstance()._pMainRoleInfo.level    --当前人物的等级
    local nHasLock = false
    
    for k,v in pairs(self._tCopyOpenLv) do
        if v <= nRoleLevel then
           nHasLock = true
        else
           nHasLock = false
        end
        table.insert(self._tCopyHasLock,nHasLock)
    end
    
    self._tCopyType = {kType.kCopy.kChallenge,kType.kCopy.kMaze,kType.kCopy.kTower}  --副本的类型

end


--创建UI
function CopysPortalDialog:createCopysUi()

    self._pscrollview:setBounceEnabled(false) --设置ScrollView是否会滑动
    --挑战button的回调事件
    local buttonCallBack = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local nTag = sender:getTag()
            --local nCopyType = kType.kCopy.kNone
            print("nTag is "..nTag)
            if self._tCopyType[nTag] == kType.kCopy.kTower then
                MessageGameInstance:sendMessageQueryTowerBattleList21012()
            else
                MessageGameInstance:sendMessageQueryBattleList21000({self._tCopyType[nTag]})
            end    
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end


    for i=1,table.getn(self._tCopyAttackButton) do
        local pCopyAttackButton = self._tCopyAttackButton[i]
        --pCopyAttackButton:getTitleRenderer():enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-2))
        pCopyAttackButton:addTouchEventListener(buttonCallBack)
        pCopyAttackButton:setTouchEnabled(false)
        pCopyAttackButton:setTag(i)
        pCopyAttackButton:setZoomScale(nButtonZoomScale)
        pCopyAttackButton:setPressedActionEnabled(true)
    end


    --整个item的按下回调 需要做放大和执行动画
    local copyBgButtonCallBack = function (sender, eventType)
        local nTag = sender:getTag()
        if eventType == ccui.TouchEventType.ended then
            self._tNodecopys[nTag]:setScale(1.0)
            --执行要做的动画
            self:playCopyDecActByTag(nTag)

        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
            self._tNodecopys[nTag]:setScale(0.9)
        elseif eventType == ccui.TouchEventType.canceled then
            self._tNodecopys[nTag]:setScale(1.0)
        end

    end

    for i=1,table.getn(self._tCopyBgButton) do
        self._tCopyBgButton[i]:setTag(i)
        --self._tCopyBgButton[i]:setTouchEnabled(true)
        self._tCopyBgButton[i]:addTouchEventListener(copyBgButtonCallBack)

    end

    --设置下面的灰色不显示
    for i=1,table.getn(self._tCopysDiscBg) do
        self._tCopysDiscBg[i]:setOpacity(0)
        self._tOpenlvLable[i]:setString("达到".. self._tCopyOpenLv[i].."级")
    end
    --设置界面解锁和未解锁的状态
    self:setItemHasLockState()
end

--设置界面的解锁和未解锁状态
function CopysPortalDialog:setItemHasLockState()

    for i=1,table.getn(self._tCopyHasLock) do
        local bHasLock =  self._tCopyHasLock[i]
        self._tLockIcon[i]:setVisible(not bHasLock)
        self._tCopyBgButton[i]:setTouchEnabled(bHasLock)

        if bHasLock == false then --未解锁
            --加载动画
            darkNode( self._tCopyBgButton[i]:getVirtualRenderer():getSprite())
            local pCopysLock = cc.CSLoader:createNode("CopysBgLock.csb")
            self._tLockActNode[i]:addChild(pCopysLock)
            local pCopysLockAct = cc.CSLoader:createTimeline("CopysBgLock.csb")
            pCopysLockAct:gotoFrameAndPlay(0,pCopysLockAct:getDuration(),true)
            pCopysLockAct:setTimeSpeed(0.3)
            pCopysLock:runAction(pCopysLockAct)
        end


    end

end

--点击button要执行的动画
function CopysPortalDialog:playCopyDecActByTag(nTag)

    for i=1,table.getn(self._tCopysDiscBg) do
        self._tCopysDiscBg[i]:setOpacity(0)
        self._tCopyAttackButton[i]:setTouchEnabled(false)
    end

    local actionCallBack = function()
        self._tCopyAttackButton[nTag]:setTouchEnabled(true)
    end
    
    local pClickBg = self._tCopysDiscBg[nTag]
    local nHeight = pClickBg:getContentSize().height
    pClickBg:stopAllActions()
    pClickBg:setPosition( self._pCopysDiscBgPos.x, self._pCopysDiscBgPos.y-nHeight) --先设置改按钮往下移动
    pClickBg:runAction(cc.Sequence:create(cc.Spawn:create(cc.EaseIn:create(cc.MoveTo:create(0.15,cc.p(self._pCopysDiscBgPos)),6), cc.FadeIn:create(0.15)),cc.CallFunc:create(actionCallBack)))
end

-- 退出函数
function CopysPortalDialog:onExitCopysPortalDialog()
    self:onExitDialog()
    -- 释放掉login合图资源
    ResPlistManager:getInstance():removeSpriteFrames("ExerciseCopysDialog.plist")
    ResPlistManager:getInstance():removeSpriteFrames("CopysBgLock.plist")
end

-- 循环更新
function CopysPortalDialog:update(dt)
    return
end

-- 显示结束时的回调
function CopysPortalDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function CopysPortalDialog:doWhenCloseOver()
    return
end

return CopysPortalDialog
