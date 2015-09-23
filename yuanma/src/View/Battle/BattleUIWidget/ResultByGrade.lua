--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  ResultByGrade.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/8/25
-- descrip:   评分结算的Node
--===================================================

local ResultByGrade = class("ResultByGrade",function()
    return cc.Node:create()
end)

-- 构造函数
function ResultByGrade:ctor()
    self._strName = "ResultByGrade"               -- 层名称
    self._pTouchListener = nil                    -- 触摸监听器
    self._pGradeImage = nil                       --评星图片
    self._pLoadingBarBg = nil                     --积分的背景
    self._pTimeText = nil                         --时间

    self._tGreadeImageTexture = {}                -- 一到五星的数据信息
    self._tGreedDate = {}                         -- 一到五星的评星数
    self._pCurResultType = 0                      -- 当前控件的类型
    self._pCurStart = 0                           -- 当前的评星数 
end

-- 创建函数
function ResultByGrade:create(args)
    local ResultByGrade = ResultByGrade.new()
    ResultByGrade:dispose(args)
    return ResultByGrade
end

-- 处理函数（积分的类型(1，凭时间评分        2：凭积分评分)，初始化x星）
function ResultByGrade:dispose(args)
    NetRespManager:getInstance():addEventListener(kNetCmd.kResultByGradeResp ,handler(self, self.updateLoadingBar))
    ResPlistManager:getInstance():addSpriteFrames("LevelStarTips.plist")
    
    if args then
       self._pCurResultType = args[1]
       self._pCurStart = args[2]
    end
    
    -- 加载组件
    local params = require("LevelStarTipsParams"):create()
    self._pPanelCCS = params._pCCS
    self._pGradeImage = params._pstart              --评星图片
    self._pLoadingBarBg = params._pLoadingBarBack   --积分的背景
    self._pTimeText  = params._pText                --时间
    self:addChild( self._pPanelCCS)
    self._pTimeText:setVisible(false)
    
    self:initResultUi()
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitResultByGrade()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end


--初始化界面
function ResultByGrade:initResultUi()
    --5星评价的数目
   local pCopyDateInfo = StagesManager:getInstance():getCurStageDataInfo()
   self._tGreedDate = {pCopyDateInfo.OneStarGrade,pCopyDateInfo.TwoStarGrade,pCopyDateInfo.ThreeStarGrade,pCopyDateInfo.FourStarGrade,pCopyDateInfo.FiveStarGrade}
    self._tGreadeImageTexture = {"LevelStarTipsRes/star01.png","LevelStarTipsRes/star02.png","LevelStarTipsRes/star03.png","LevelStarTipsRes/star04.png","LevelStarTipsRes/star05.png"}
   
    --经验条
    self._pLoadingBar = self:createRoleExpBar()
    self._pLoadingBar:setPosition(cc.p(self._pLoadingBarBg:getContentSize().width/2,self._pLoadingBarBg:getContentSize().height/2))
    self._pLoadingBarBg:addChild(self._pLoadingBar)

--根据副本类型来确定一些控件的显示
  if  self._pCurResultType == kResultType.kGreadResult then 
     self._pGradeImage:loadTexture(self._tGreadeImageTexture[1],ccui.TextureResType.plistType)
     self._pLoadingBar:setVisible(true)
    -- self._pTimeText:setVisible(false)
 elseif  self._pCurResultType == kResultType.kTimeResult then
     self._pGradeImage:loadTexture(self._tGreadeImageTexture[5],ccui.TextureResType.plistType)
     self._pLoadingBar:setVisible(false)
     --self._pTimeText:setVisible(false)
    end
end


--创建一个进度条
function ResultByGrade:createRoleExpBar()
    -- 进度条
    local pSprite = cc.Sprite:createWithSpriteFrameName("LevelStarTipsRes/fbjm13.png")
    local pLoadingBar = cc.ProgressTimer:create(pSprite)
    pLoadingBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    pLoadingBar:setMidpoint(cc.p(0, 0))
    pLoadingBar:setBarChangeRate(cc.p(1, 0))
    pLoadingBar:setPercentage(100)
    pLoadingBar:setScaleX(1.17)
    return pLoadingBar
end

--积分有变化的回调
function ResultByGrade:updateLoadingBar(event)
    if  self._pCurResultType == kResultType.kGreadResult then 
         local pGread = BattleManager:getInstance()._pMonsterDeadGread
         local nStart,nParent = self:getStartAndParentByGread(pGread)
         
         if nStart ==  self._pCurStart then
            self:setLoadBarPercent(nParent,false)
          else
            self._pCurStart = nStart
            self:setLoadBarPercent(nParent,true)
            self._pGradeImage:loadTexture(self._tGreadeImageTexture[nStart],ccui.TextureResType.plistType)
         end
    end

end

--通过积分来确定评分是几星，比例
function ResultByGrade:getStartAndParentByGread(nGread)

 local pStart = 5
 for k,v in pairs(self._tGreedDate) do
     if nGread < v then 
        pStart = k-1
        break
     end
 end
 
 local nParent = 0
 if pStart == 5 then --如果当前已经5星，则直接100
 	nParent = 100
 else
   nParent = (nGread - self._tGreedDate[pStart])/(self._tGreedDate[pStart+1]-self._tGreedDate[pStart])*100
 end
 
 return pStart,nParent
 
end


--经验条 bBool (true:没有升级，代表需要需要走动画     false：有升级直接弄成0）
function ResultByGrade:setLoadBarPercent(nPercent,bBool)
    self._pLoadingBar:stopAllActions()
    if bBool then 
       self._pLoadingBar:setPercentage(nPercent)
    else
      self._pLoadingBar:runAction(cc.Sequence:create(cc.DelayTime:create(0.1), cc.ProgressTo:create(0.3, nPercent)))
    end
  end

-- 退出函数
function ResultByGrade:onExitResultByGrade()
    ResPlistManager:getInstance():removeSpriteFrames("LevelStarTips.plist")
    print(self._strName.." onExit!")
end

return ResultByGrade
