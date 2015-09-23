--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  StoryCopyPageItem.lua
-- author:    yuanjiashun
-- created:   2015/4/15
-- descrip:   剧情副本item
--===================================================

local StoryCopyPageItem = class("StoryCopyPageItem",function()
    return ccui.Layout:create()
end)

-- 构造函数
function StoryCopyPageItem:ctor()
    self._strName = "StoryCopyPageItem"        -- 层名称
    self._pCCS = nil
    self._pBackGround = nil                                --背景框
    self._pCCS = nil
    self._pNodeClick = nil                                 --默认选中的
    self._tNodeCopy = nil                                  --副本的挂载点
    self._pLSloadingbar = nil                              --宝箱的进度条
    self._tBoxButton = {}                                  --宝箱 Button
    self._tBoxneedStarNum = {}                             --星星需要的数量

    self._pStoryBattleInfo = nil                           --副本的信息
    self._pStoryBattleDateInfo = nil
    self._nGetStartNum = 0
    self._fStoryCopy = nil
    self._pSpriteClick = nil
    self._tBoxOpenEffect = {}


end

-- 创建函数
function StoryCopyPageItem:create(args,func)
    local layer = StoryCopyPageItem.new()
    layer:dispose(args,func)
    return layer
end

-- 处理函数
function StoryCopyPageItem:dispose(args,func)
    NetRespManager:getInstance():addEventListener(kNetCmd.kDrawStoryBox ,handler(self,self.drawStoryBox))
    self._pStoryBattleInfo = args
    self._fStoryCopy = func
    self._pStoryBattleDateInfo = TableStoryChapter[self._pStoryBattleInfo.storyId]
    self:initUI()
    self:initUIDate()
    self:initBoxDate()


    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitStoryCopyPageItem()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end


--初始化界面
function StoryCopyPageItem:initUI()

    local tStoryChapter = self._pStoryBattleDateInfo
    ResPlistManager:getInstance():addSpriteFrames("BoxOpenEffect.plist")
    ResPlistManager:getInstance():addSpriteFrames(tStoryChapter.PlistName..".plist")
    local params = require(tStoryChapter.LuaName):create()
    self._pCCS = params._pCCS
    self._pBackGround = params._pBackGround                --背景框
    self._pCCS = params._pCCS
    self._pNodeClick = params._pNodeClick                  --默认选中的
    self._tNodeCopy = params._tNodeCopy                    --副本的挂载点
    self._pLSloadingbar =  params._pLSloadingbar           --宝箱的进度条
    self._tBoxneedStarNum = params._tLsText                --宝箱需要的星星数量
    self._tBoxButton = params._tBoxButton
    local nSize = self._pBackGround:getContentSize()
    self._pCCS:setPosition(cc.p(nSize.width/2,nSize.height/2))
    self:addChild(self._pCCS)


    local pCopysLock = cc.CSLoader:createNode("StoryCopyLock.csb")
    self._pNodeClick:addChild(pCopysLock)
    local pCopysLockAct = cc.CSLoader:createTimeline("StoryCopyLock.csb")
    pCopysLockAct:gotoFrameAndPlay(0,pCopysLockAct:getDuration(),true)
    pCopysLockAct:setTimeSpeed(0.3)
    pCopysLock:runAction(pCopysLockAct)
   
    for k,v in pairs(self._tBoxButton) do
      
      local  pBoxAni = cc.CSLoader:createNode("BoxOpenEffect.csb")
      pBoxAni:setVisible(false)
      pBoxAni:setPosition(cc.p(30,26))
      v:addChild(pBoxAni,-1)
      local pBoxAct = cc.CSLoader:createTimeline("BoxOpenEffect.csb")
      pBoxAct:gotoFrameAndPlay(0,pBoxAct:getDuration(),true)
      pBoxAct:setTimeSpeed(0.3)
      pBoxAni:runAction(pBoxAct)
      table.insert(self._tBoxOpenEffect,pBoxAni)
    end
    
   

end

--设置选中框是否显示和显示的位置
function StoryCopyPageItem:setClickNodePosition()
    self._pNodeClick:setVisible(false)
    for k,v in pairs(self._pStoryBattleDateInfo.TheCopys) do
        if v == self._fStoryCopy._nClickBattleId then --章节id是选中状态
            local nX,nY = self._tNodeCopy[k]:getPosition()
            self._pNodeClick:setPosition(cc.p(nX,nY))
            self._pNodeClick:setVisible(true)
            break
        end
    end
end

--设置弹出的关卡详细信息框
function StoryCopyPageItem:showStoryInfoByBattleId(nBattleId)
    self._fStoryCopy._nClickBattleId = nBattleId --先设置选中状态
    self:setClickNodePosition() --设置选中框是否显示
    local pInfo = nil
    for k,v in pairs(self._pStoryBattleInfo.btInfos)do 
    	if v.battleId == nBattleId  then --标示当前关卡是选中的状态    
            pInfo = v
            break    		
    	end
	end
    if pInfo then
        DialogManager:getInstance():showDialog("StoryInfoDialog",{TableStoryCopys[nBattleId-10000],pInfo})--{ --服务器传过来的数据（消耗次数跟星级）,本地数据}
    else
        if self._fStoryCopy._bHasOpen == true then --手动开启所有章节
            pInfo = {["battleId"] = nBattleId,["bestStar"] = 0,["currentCount"] = 5,["extCount"] = 0,["text"] = true}
        end
        DialogManager:getInstance():showDialog("StoryInfoDialog",{TableStoryCopys[nBattleId-10000],pInfo})--{ --服务器传过来的数据（消耗次数跟星级）,本地数据}
	end
    local pZouder = DialogManager:getInstance():getDialogByName("StoryCopyDialog"):getLocalZOrder()
    DialogManager:getInstance():getDialogByName("StoryInfoDialog"):setLocalZOrder(pZouder+1)
end


--初始化界面数据
function StoryCopyPageItem:initUIDate()

    local  onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            local nTag = sender:getTag()
            local nBattleId = self._pStoryBattleDateInfo.TheCopys[nTag]
            self:showStoryInfoByBattleId(nBattleId)
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    for k,v in pairs(self._pStoryBattleDateInfo.TheCopys) do
        local copyItemInfo = TableStoryCopys[v-10000]
        local tOpenCopyItemInfo = self._pStoryBattleInfo.btInfos
        local cell =  require("StoryCopyItem"):create()
        cell._pIconBtn:addTouchEventListener(onTouchButton)
        cell._pIconBtn:setTag(k)
        cell:setItemInfo(copyItemInfo)
        self._tNodeCopy[k]:addChild(cell)

        --特殊处理(有了额外的奖励，需要从新设置父节点的权重)
        if copyItemInfo.FirstClear ~= nil and table.getn(copyItemInfo.FirstClear) ~= 0 then
              self._tNodeCopy[k]:setLocalZOrder(100)
        end


        local pHasOpen = false
        local pDateIndex = 1
        for k1,v1 in pairs(tOpenCopyItemInfo) do
            if v1.battleId == v then --关卡开启
        		pHasOpen = true
                pDateIndex = k1
        		break
        	end
        end
        
        if pHasOpen then  --副本标示已经开启的
            if tOpenCopyItemInfo[pDateIndex].bestStar ~= 0 then  --说明副本开启了且有评级
                self._nGetStartNum = self._nGetStartNum + tOpenCopyItemInfo[pDateIndex].bestStar
                cell:setStartNum(tOpenCopyItemInfo[pDateIndex].bestStar)
                cell:setFirstClearBgHasVisible(false)
            end
        else
            cell:setItemGray(copyItemInfo) --设置灰色
        end
    end
   
    self:setClickNodePosition() --设置选中框是否显示

end

--初始化宝箱数据
function StoryCopyPageItem:initBoxDate()
    local tBoxHasGet = {false,false,false}
    for k,v in pairs(self._tBoxneedStarNum) do  --宝箱需要的星星数量
    local pString = "StarBox"..k
          v:setString(self._pStoryBattleDateInfo[pString])
    end


    local tDraw = self._pStoryBattleInfo.draw --设置宝箱是否开启
    local  pBoxCloseIcon= "StoryCopysCom/rwjm12.png"
    local  pBoxOpenIcon= "StoryCopysCom/rwjm19.png"

    --宝箱的点击事件
    local  onTouchBoxButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then   
            local nTag = sender:getTag()
            local tBoxInfo = {self._pStoryBattleDateInfo.BoxItem1,self._pStoryBattleDateInfo.BoxItem2,self._pStoryBattleDateInfo.BoxItem3}
            DialogManager:getInstance():showDialog("BoxInfoDialog",{tBoxInfo[nTag], tBoxHasGet[nTag],boxInfoShowType.kBoxstoryCopy,{self._pStoryBattleInfo.storyId,nTag}})
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    local pMaxStart = 0
    for i=1,table.getn( self._tBoxButton)do
        self._tBoxButton[i]:setTag(i)
        if tDraw[i] == false then --未开启
            self._tBoxButton[i]:loadTextures(pBoxCloseIcon,pBoxCloseIcon,pBoxCloseIcon,ccui.TextureResType.plistType)
            
        else --已经开启
            self._tBoxButton[i]:loadTextures(pBoxOpenIcon,pBoxOpenIcon,pBoxOpenIcon,ccui.TextureResType.plistType)
            self._tBoxButton[i]:setTouchEnabled(false)
        end
        self._tBoxButton[i]:addTouchEventListener(onTouchBoxButton)
        
        self._tBoxOpenEffect[i]:setVisible(false)
        --初始化3个宝箱是否能领取
        local pString = "StarBox"..i
        if tDraw[i] == false and self._nGetStartNum >= self._pStoryBattleDateInfo[pString] then
            tBoxHasGet[i] = true
            self._tBoxOpenEffect[i]:setVisible(true)
        end
        pMaxStart = self._pStoryBattleDateInfo[pString]
    end

    --进度条
    local nPercent = (self._nGetStartNum/pMaxStart)*100
    self._pLSloadingbar:setPercent(nPercent)

end

--宝箱开启的回调
function StoryCopyPageItem:drawStoryBox(event)
    if self._pStoryBattleInfo.storyId == event.storyId then --说明是本章节的
        self._pStoryBattleInfo.draw[event.index]=true
    	 self:initBoxDate() 
    end
end

-- 退出函数
function StoryCopyPageItem:onExitStoryCopyPageItem()

    ResPlistManager:getInstance():removeSpriteFrames("BoxOpenEffect.plist")
    ResPlistManager:getInstance():removeSpriteFrames(self._pStoryBattleDateInfo.PlistName..".plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

-- 循环更新
function StoryCopyPageItem:update(dt)
    return
end

-- 显示结束时的回调
function StoryCopyPageItem:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function StoryCopyPageItem:doWhenCloseOver()
    return
end

return StoryCopyPageItem
