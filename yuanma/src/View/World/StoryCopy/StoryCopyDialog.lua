--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  StoryCopyDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/4/15
-- descrip:   剧情副本入口
--===================================================
local StoryCopyDialog = class("StoryCopyDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function StoryCopyDialog:ctor()
    self._strName = "StoryCopyDialog"       -- 层名称
    self._pBg = nil
    self._pCloseButton = nil
    self._pPageView = nil                   -- 界面的pageView
    self._pNextButton = nil                 -- 下一个章节按钮
    self._pLastButton = nil                 -- 上一个章节按钮

    self._nClickBattleId = nil              -- 选中具体副本的副本id
    self._nClickStoryId = nil               -- 选中的具体章节id
    self._tPageViewIndex = {}               -- pageView已经加载过的章节
    self._tStoryBattleInfo = {}             -- 副本的总信息
    self._bHasAllLoad = false               -- 是否一次性加载过来
    self._nCurPageIdx = 0                   -- 当前的index
    self._pArgs = nil

    self._bHasOpen = false                  -- 测试，直接全部打开战斗

end

-- 创建函数
function StoryCopyDialog:create(args)
    local dialog = StoryCopyDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function StoryCopyDialog:dispose(args)
    NetRespManager:getInstance():addEventListener(kNetCmd.kQueryStory ,handler(self, self.updatePageView))
    self._pArgs = args
    self:initUI()
    -- 初始化dialog的基础组件
    self:disposeCSB()
    MessageGameInstance:sendMessageQueryStoryBattleList21008(0)
    NewbieManager:showOutAndRemoveWithRunTime()

    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false then
            --self:close()
        end
        return true   --可以向下传递事件
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
            self:onExitStoryCopyDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end


--初始化界面
function StoryCopyDialog:initUI()

    ResPlistManager:getInstance():addSpriteFrames("StoryCopysDialog.plist")
    ResPlistManager:getInstance():addSpriteFrames("StoryCopyLock.plist")
    
    local params = require("StoryCopysDialogParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    self._pPageView = params._pStoryCopysPageView
    self._pNextButton = params._pNextButton
    self._pLastButton = params._pPreviousButton
    self._pPageView:setTouchEnabled(false)

    for i=1,table.getn(TableStoryChapter)+1 do
        local newPage = ccui.Layout:create()
        self._pPageView:addPage(newPage)
    end

    local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local ncurIndex = self._nCurPageIdx
            local nTag = sender:getTag()
            if nTag == 1 then --下一步
            if self:nextStoryHasOpenByLevel() then
               if self:selectStoryIdHasExist(ncurIndex+2) then --判断本地有没有下一章的信息
                  self:toStage(ncurIndex+2)
               end
            end
                
            elseif nTag == 2 then --上一步
            
             if self:selectStoryIdHasExist(ncurIndex) then --判断本地有没有下一章的信息
                self:toStage(ncurIndex)
             end 
            end

            print("nPage is "..ncurIndex)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    self._pNextButton:addTouchEventListener(onTouchButton)
    self._pNextButton:setTag(1)
    self._pLastButton:addTouchEventListener(onTouchButton)
    self._pLastButton:setTag(2)

-----------------------------测试-------------------------------------
 local  onOpenTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            NoticeManager:getInstance():showSystemMessage("开启随便进入副本模式（切勿结算）") 
            self._bHasOpen = true
            MessageGameInstance:sendMessageQueryStoryBattleList21008(0)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
end

   self._pIconBtn = nil
    self._pIconBtn = ccui.Button:create(
        "ccsComRes/common001.png",
        "ccsComRes/common002.png",
        "ccsComRes/common002.png",
        ccui.TextureResType.plistType)
    self._pIconBtn:setTouchEnabled(true)
    self._pIconBtn:setPosition(20,100)
    self._pIconBtn:setAnchorPoint(cc.p(0, 0))
    self._pIconBtn:setVisible(bStoryCopyTestBtn)
    self:addChild(self._pIconBtn)
    self._pIconBtn:addTouchEventListener(onOpenTouchButton)

-----------------------------测试-------------------------------------
end

--刷新章节数据
function StoryCopyDialog:updatePageView(event)
    self._pCloseButton:setVisible(true)
    local pBool = false
    if self._pArgs then
        self._nClickStoryId =  self._pArgs[1]                   -- 选中的章节id
        self._nClickBattleId =  self._pArgs[2]                  -- 选中的副本id
        self._pArgs = nil
        pBool = true
    else
        self._nClickStoryId =  event.lastStory                  -- 选中的章节id
        self._nClickBattleId =   event.lastBattle               -- 选中的副本id 
        pBool = false
    end

    --服务器的章节信息
    self._tStoryBattleInfo = event.stories
    --加载章节是否开启下一个章节的信息
    self:initStoryInfo()
    
    if self._bHasAllLoad then
        for i=1,table.getn(event.stories)do
            local tStorie = event.stories[i]
            if self:selectStoryHasLoadById(tStorie.storyId) == false then --判断pageView里面是否加载了改章节
                self:insertViewPageByStoryId(tStorie.storyId)
            end
        end
    end

    if self._bHasOpen then
        for i=table.getn(event.stories)+1,table.getn(TableStoryChapter) do
           self:setNotOpenStoryInfoById(i)
        end
    end



    self:toStage(self._nClickStoryId,self._nClickBattleId,pBool)
end

--初始化章节数据
function StoryCopyDialog:initStoryInfo()
    for k,v in pairs(self._tStoryBattleInfo) do
        local pDateInfo = TableStoryChapter[v.storyId]
        if pDateInfo.LookForward then
            for i=1,table.getn(v.btInfos) do 
                if pDateInfo.LookForward == v.btInfos[i].battleId then --如果能找到开启等级。下一章等级默认开启
                	self:setNextStoryHasOpen(k+1)
                	break
                end
            end
        end
    end
	
end

--根据章节id来向pageView添加一个章节
function StoryCopyDialog:insertViewPageByStoryId(nStoryID)
    table.insert(self._tPageViewIndex,nStoryID)
    local pPageViewItem = require("StoryCopyPageItem"):create(self._tStoryBattleInfo[nStoryID],self)
    self._pPageView:removePageAtIndex(nStoryID-1)
    self._pPageView:insertPage(pPageViewItem,nStoryID-1)
end

--设置下一个章节开启
function StoryCopyDialog:setNextStoryHasOpen(nStoryId)
    if self:selectStoryIdHasExist(nStoryId) == false then 
        self:setNotOpenStoryInfoById(nStoryId)
    end
end


--通过章节id判断本地是否有本章节的信息
function StoryCopyDialog:selectStoryIdHasExist(nStoryId)    
    for i=1,table.getn(self._tStoryBattleInfo) do
        if self._tStoryBattleInfo[i].storyId == nStoryId then
            return true
        end
    end
    return false
end

--通过id判断pageView是否加载了该章节
function StoryCopyDialog:selectStoryHasLoadById(nStoryId)
    for i=1,table.getn(self._tPageViewIndex) do
        if self._tPageViewIndex[i] == nStoryId then
            return true
        end
    end
    return false
end

--根据章节id判断等级是否满足
function StoryCopyDialog:nextStoryHasOpenByLevel()
  local pRoleLevel = RolesManager:getInstance()._pMainRoleInfo.level
  local pNeedLevel = TableStoryChapter[self._nCurPageIdx+1].Level
  if pRoleLevel < pNeedLevel and  self._bHasOpen == false then
    NoticeManager:getInstance():showSystemMessage("等级不足，下一章的开启等级为"..pNeedLevel.."级") 
  	return false
  end
	return true
end


--通过当前的章节id判断是否next跟last按钮显示
function StoryCopyDialog:buttonHasVisableById(battleId)
    local bNextHasVis = nil
    if battleId == table.getn( self._tStoryBattleInfo) then
        bNextHasVis = false
    else
        bNextHasVis =true
    end

    self._pNextButton:setVisible(bNextHasVis)                --下一个章节按钮

    local bLastHasVis = nil
    if battleId == 1 then
        bLastHasVis = false
    else
        bLastHasVis =true
    end 
    self._pLastButton:setVisible(bLastHasVis)                --下一个章节按钮
end

--手动开启某个章节
function StoryCopyDialog:setNotOpenStoryInfoById(nStoryId)
    local tStoryBattle = {storyId = nStoryId, draw = {false,false,false},btInfos = {}}
    table.insert(self._tStoryBattleInfo,tStoryBattle)
end

--跳转到某个章节
function StoryCopyDialog:toStage(storyID, battleID,pBool)
    self._nCurPageIdx = storyID -1
    if self:selectStoryIdHasExist(storyID) then --标示开启的章节是非法的。本地没有开启的章节信息
        if self:selectStoryHasLoadById(storyID) == false then --判断pageView里面是否加载了改章节
           self:insertViewPageByStoryId(storyID)
        end
        self._pPageView:scrollToPage(storyID-1)
        self._pPageView:getPage(storyID-1):setClickNodePosition()
        self:buttonHasVisableById(storyID)
        if battleID and pBool then
           self._nClickBattleId = battleID         --先设置点击的battleId
           self._pPageView:getPage(storyID-1):showStoryInfoByBattleId(battleID)
        end
    end 
end

-- 退出函数
function StoryCopyDialog:onExitStoryCopyDialog()
    self:onExitDialog()
    -- 释放掉login合图资源
    NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("StoryCopyLock.plist")
    ResPlistManager:getInstance():removeSpriteFrames("StoryCopysDialog.plist")
end

--显示不带动画
function StoryCopyDialog:showWithAni()
    self:setVisible(true)
    self:stopAllActions()
    return
end


-- 循环更新
function StoryCopyDialog:update(dt)
    return
end

-- 显示结束时的回调
function StoryCopyDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function StoryCopyDialog:doWhenCloseOver()
    return
end

return StoryCopyDialog
