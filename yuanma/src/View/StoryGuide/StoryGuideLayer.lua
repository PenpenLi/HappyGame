--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  StoryGuideLayer.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/10/9
-- descrip:   剧情副本
--===================================================
local StoryGuideLayer = class("StoryGuideLayer",function()
    return require("Layer"):create()
end)

-- 构造函数
function StoryGuideLayer:ctor()
    self._strName = "StoryGuideLayer"       -- 层名称
    self._strMapName = ""                   -- 当前地图名称
    self._pStoryGuideInfo = nil             --场景信息
    self._pMaskClolorLayer = nil            --最上面的黑屏层
end

-- 创建函数
function StoryGuideLayer:create()
    local layer = StoryGuideLayer.new()
    layer:dispose()
    return layer
end

-- 处理函数
function StoryGuideLayer:dispose()
    --某个事情结束回调
   NetRespManager:getInstance():addEventListener(kNetCmd.kStoryGuideEnd ,handler(self, self.handleStoryGuideEndCallBack))
   self._pMaskClolorLayer = cc.LayerColor:create(cc.c4b(0,0,0,0))
   self:addChild(self._pMaskClolorLayer,10)
   self:createFastJumpStoryGuideButton()
   self:setFashJumpStoryGuideBtnIsVisible(false)

    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitStoryGuideLayer()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    
    return
end

--创建地图
function StoryGuideLayer:createStoryGuide(MapsName,MapsPvrName)
  self:createMapWithTMX(MapsName,MapsPvrName)
end


function StoryGuideLayer:createMapWithTMX(tmxFileNames,texFileTexutre)
 -- 记录并加载到纹理缓存中
     ResPlistManager:getInstance():addPvrNameToColllectorAndLoadPvr(texFileTexutre)
     if self._pTmxMap == nil then
      print("加载地图")
        self._pTmxMap = ccexp.TMXTiledMap:create(tmxFileNames..".tmx")
        self._sMapIndexSize = self._pTmxMap:getMapSize()
        self._sTiledPixelSize = self._pTmxMap:getTileSize()
        self._sMapRectPixelSize = cc.size(self._sMapIndexSize.width*self._sTiledPixelSize.width, self._sMapIndexSize.height*self._sTiledPixelSize.height)
        self._pTmxMap:setAnchorPoint(cc.p(0,0))
        self._pTmxMap:setPosition(cc.p(0,0))
        self._pTmxMap:setVisible(false)
        self:addChild(self._pTmxMap)
        self._f3DZ = 6000/self._sMapIndexSize.height
        self._pTmxMap:setCameraMask(cc.CameraFlag.USER1)
        self._pTmxMap:getLayer("BlockLayer"):setVisible(enable)
    end

end


--创建快速跳过按钮
function StoryGuideLayer:createFastJumpStoryGuideButton()
  local  onTouchButton = function (sender, eventType)
      if eventType == ccui.TouchEventType.ended then
          StoryGuideManager:getInstance():fastJumpStoryGuide()
      elseif eventType == ccui.TouchEventType.began then
          AudioManager:getInstance():playEffect("ButtonClick")
      end
  end
    self._pFashJumpButton = ccui.Button:create("ccsComRes/common001.png","ccsComRes/common001.png",nil,ccui.TextureResType.plistType)
    self._pFashJumpButton:setTouchEnabled(true)
    self._pFashJumpButton:setPosition(cc.p(mmo.VisibleRect:width() - self._pFashJumpButton:getContentSize().width/2,mmo.VisibleRect:height() - self._pFashJumpButton:getContentSize().height/2))
    self._pFashJumpButton:setVisible(false)
    self._pFashJumpButton:setTitleText("快速跳过")
    self._pFashJumpButton:setZoomScale(nButtonZoomScale)  
    self._pFashJumpButton:setPressedActionEnabled(true)
    self:addChild(self._pFashJumpButton,2)
    self._pFashJumpButton:addTouchEventListener(onTouchButton)
end

--设置跳过按钮是否显示
function StoryGuideLayer:setFashJumpStoryGuideBtnIsVisible(bBool)
  self._pFashJumpButton:setVisible(bBool)
end


function StoryGuideLayer:handleStoryGuideEndCallBack( event )
   if StoryGuideManager:getInstance()._bIsStory == false then --如果这个剧情对话因为外界原因已经结束(强制不执行)
       return 
   end
   StoryGuideManager:getInstance():runNextGuideAction()
end

-- 进入
function StoryGuideLayer:cloudIn()
    AudioManager:getInstance():stopMusic()
    AudioManager:getInstance():stopAllEffects()
    local onProgress = function()
        self._pTmxMap:setVisible(true)
        self._pFashJumpButton:setVisible(true)
        self:setOtherUiLayerVisible(false)
        self:setFashJumpStoryGuideBtnIsVisible(true)
    end
    self._pMaskClolorLayer:runAction(cc.Sequence:create(cc.EaseInOut:create(cc.FadeTo:create(1.0, 255), 2.0),  cc.CallFunc:create(onProgress),
                                                       cc.DelayTime:create(0.5), 
                                                       cc.EaseInOut:create(cc.FadeTo:create(1.0, 0), 2.0)))
end

--退出
function StoryGuideLayer:cloudOut()
    AudioManager:getInstance():stopMusic()
    AudioManager:getInstance():stopAllEffects()
    TalksManager:getInstance():setCurTalksFinished()
    --关闭所有的对话  
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
       StoryGuideManager:getInstance():getBattleUILayer():showCurTalks()
    elseif cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then        -- 战斗场景只有白天
       StoryGuideManager:getInstance():getWorldUILayer():showCurTalks()
    end

    local onProgress = function()
        self._pTmxMap:setVisible(false)
        self._pTmxMap:removeFromParent(true)
        self._pTmxMap = nil
        print("地图删除成功")
        self._pFashJumpButton:setVisible(false)
        self:setOtherUiLayerVisible(true)
        self:setFashJumpStoryGuideBtnIsVisible(false)
    end

    local onSuccess = function()
        AudioManager:getInstance():replayMusic()
        AudioManager:getInstance():replayEffect()
        StoryGuideManager:getInstance()._bActionHasStop = true
        if StoryGuideManager:getInstance()._pCurGuideInfo.ID == TableConstants.NewbieQueneID.Value then --标记这是新手第一场战斗
            -- 如果为新手引导中的第一场战斗，则不进行任何战斗结果相关的检测
            if LayerManager:getInstance():getCurSenceLayerSessionId() == kSession.kBattle and BattleManager:getInstance()._bIsFirstBattleOfNewbie == true then
                if MonstersManager:getInstance()._bIsBossDead == true or BattleManager:getInstance()._bIsBossDead == true then 
                    if cc.Director:getInstance():getRunningScene():getLayerByName("BattleLayer")._bIsShowingDoomsday == false then
                        cc.Director:getInstance():getRunningScene():getLayerByName("BattleLayer"):showDoomsday()   -- 显示世界末日
                        cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer"):showCaptionContentAfterDoomsdayWithDelay(6)
                    end
                end

            end
        end

    end

   self._pMaskClolorLayer:runAction(cc.Sequence:create(cc.EaseInOut:create(cc.FadeTo:create(1.0, 255), 2.0), cc.DelayTime:create(0.5),
                                                       cc.CallFunc:create(onProgress),
                                                       cc.EaseInOut:create(cc.FadeTo:create(1.0, 0), 2.0),cc.CallFunc:create(onSuccess)))

end


function StoryGuideLayer:setOtherUiLayerVisible(bBool)
    if cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kBattle then
        StoryGuideManager:getInstance():getBattleLayer():setVisible(bBool) --屏蔽ui层的人物
         StoryGuideManager:getInstance():getBattleUILayer():setAllUIVisible(bBool) --隐藏ui层的东西
        if bBool then --开启剧情模式
           BattleManager:getInstance():pauseTime()  --时间暂停
        else
           BattleManager:getInstance():resumeTime()  --回复计时
        end
     elseif cc.Director:getInstance():getRunningScene()._kCurSessionKind == kSession.kWorld then        -- 战斗场景只有白天
         StoryGuideManager:getInstance():getWorldLayer():setVisible(bBool) --屏蔽ui层的人物
         StoryGuideManager:getInstance():getWorldUILayer():setAllUIVisible(bBool) --隐藏ui层的东西
    end
end


-- 退出函数
function StoryGuideLayer:onExitStoryGuideLayer()
    self:onExitLayer()   
    -- 释放网络监听事件
   NetRespManager:getInstance():removeEventListenersByHost(self)
end

-- 循环更新
function StoryGuideLayer:update(dt)
   StoryGuideManager:getInstance():update(dt)
   return
end

-- 显示结束时的回调
function StoryGuideLayer:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function StoryGuideLayer:doWhenCloseOver()    
end


return StoryGuideLayer
