--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  StoryGuideManager.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/5/18
-- descrip:   剧情引导管理器
--===================================================
StoryGuideManager = {}

local instance = nil

-- 单例
function StoryGuideManager:getInstance()
    if not instance then
        instance = StoryGuideManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function StoryGuideManager:clearCache()
  self._pStoryGuideLayer = nil --场景对话层
  self._pBattleUILayer = nil   --战斗对话层
  self._pBattleLayer = nil     --地图层
  self._pWorldUILayer = nil    --家园ui层
  self._pWorldLayer = nil      --家园层
  self._bIsStory = false       --是否在进行剧情动画
  self._bActionHasStop = true --移除Story的时候有动画，此值是记录动画执行完毕
  self._pCurGuideInfo = nil    --当前的引导信息
  self._tAllCreateRole = {}    --所有创建的角色(npc，角色，怪物)
  self._pCurGuideIndex = 0     --当前引导的进度，按照配置表里面的index

end

--得到对话层
function StoryGuideManager:getStoryGuideLayer()
	  if self._pStoryGuideLayer == nil then
        self._pStoryGuideLayer = cc.Director:getInstance():getRunningScene():getLayerByName("StoryGuideLayer")
    end
    return self._pStoryGuideLayer
end

-- 获取战斗UI层
function StoryGuideManager:getBattleUILayer()
    if self._pBattleUILayer == nil then
        self._pBattleUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("BattleUILayer")
    end
    return self._pBattleUILayer
end

--获取地图层
function StoryGuideManager:getBattleLayer()
    if self._pBattleLayer == nil then
        self._pBattleLayer = cc.Director:getInstance():getRunningScene():getLayerByName("BattleLayer")
    end
    return self._pBattleLayer
end

--获取家园Ui层
function StoryGuideManager:getWorldUILayer()
   if self._pWorldUILayer == nil then
        self._pWorldUILayer = cc.Director:getInstance():getRunningScene():getLayerByName("WorldUILayer")
    end
    return self._pWorldUILayer
end

--获取家园Ui层
function StoryGuideManager:getWorldLayer()
   if self._pWorldLayer == nil then
        self._pWorldLayer = cc.Director:getInstance():getRunningScene():getLayerByName("WorldLayer")
    end
    return self._pWorldLayer
end



--停止一切动画强制返回（快速跳过）
function StoryGuideManager:fastJumpStoryGuide()
  self:getStoryGuideLayer():stopAllActions()
  self:getStoryGuideLayer()._pTmxMap:stopAllActions()
  self:endGuideAction()
end


--设置剧情模式是否开启，设置其他东西
function StoryGuideManager:setIsOpenStoryGuideAndUiVisible(bBool)
    self._bIsStory = bBool --开启剧情模式
    --在剧情模式下，先关闭所有的dialog
    DialogManager:getInstance():closeAllDialogs()
    if bBool then --开启剧情模式
      self:getStoryGuideLayer():cloudIn()
    else --退出剧情模式
       self:getStoryGuideLayer():cloudOut()
    end
end

--场景表里面配置的id
function StoryGuideManager:createStoryGuideById(nId) 
  --开启剧情模式
  self._pCurGuideInfo = TableGuideStory[nId]
  self:getStoryGuideLayer():createStoryGuide(self._pCurGuideInfo.MapsName,self._pCurGuideInfo.MapsPvrName)
  self:setIsOpenStoryGuideAndUiVisible(true)
  self._bActionHasStop = false --说明剧情动画正在执行
  self:runNextGuideAction()
end

--更具实例id来找到创建的对象（一个地图上，实例id唯一）
function StoryGuideManager:getRoleByInstenceId(nInstenceId)
    if table.getn(self._tAllCreateRole) == 0 or  nInstenceId == nil then 
        return nil
    end
    for k,v in pairs(self._tAllCreateRole) do
        if v._pInstenceId == nInstenceId then 
            return v
        end
    end
    return nil
end

function StoryGuideManager:removeRoleByInstenceId(nInstenceId)
   if table.getn(self._tAllCreateRole) == 0 or  nInstenceId == nil then 
        return nil
    end
    for k,v in pairs(self._tAllCreateRole) do
        if v._pInstenceId == nInstenceId then 
            table.remove(self._tAllCreateRole,k)
            return
        end
    end
  
end


--进行行为队列
function StoryGuideManager:runNextGuideAction()
    if self._bIsStory == false then --如果这个剧情对话因为外界原因已经结束(强制不执行)
       return 
    end
     self._pCurGuideIndex = self._pCurGuideIndex + 1 --引导开始，下标开始读取 
    if self._pCurGuideIndex > table.getn(self._pCurGuideInfo.QueueId)then 
       self:endGuideAction()
       return
    end
    self:playNextGuideAction( self._pCurGuideInfo.QueueId[self._pCurGuideIndex])
end

--行为队列到已经结束了
function StoryGuideManager:endGuideAction()
    self._pCurGuideIndex = 0
    self:setIsOpenStoryGuideAndUiVisible(false)
end

function StoryGuideManager:playNextGuideAction(pGuideId)
  --具体的引导的事情的信息
  --[[
  local tTalkInfo = {{TalkId = 1,Contents = {ID=1,RoleType=1,TempleteID=1,InstanceID =1,StartX =10,StartY=10}}, --创建角色
                    {TalkId = 2,Contents = {ID=1,RoleType=2,TempleteID=1,InstanceID =2,StartX =20,StartY=20}},   --创建npc
                    {TalkId = 3,Contents = {ID=2,InstanceID =1,EndX =30,EndY=30}},    --移动
                    {TalkId = 4,Contents = {ID=3,InstanceID = 1,TalkID = 1}},    --对话
                    {TalkId = 5,Contents = {ID=6,InstanceID = 1,Rotation = 90}}, --旋转
                    {TalkId = 6,Contents = {ID=6,InstanceID = 1,Rotation = 180}}, --旋转
                    {TalkId = 7,Contents = {ID=6,InstanceID = 1,Rotation = 270}}, --旋转
                    {TalkId = 8,Contents = {ID=8,WaitingTime = 4.0}}, --等待
                    {TalkId = 9,Contents = {ID=7,StartX =2000,StartY=10,MoveTime = 3}},
                    {TalkId = 10,Contents = {ID=4,InstanceID =1,PlayActionNum=1,SkillName = "MageSkill0101",SkillStartFrame=0,SkillEndFrame=48,SkillWeightTime =0,SkillDisplaceX=0,SkillDisplaceY=0,SkillVoice = "SkillProcessSound1"}},
                    {TalkId = 11,Contents = {ID=5,InstanceID =1}}, } --镜头移动
   ]]

    if self._bIsStory == false then --如果没有触发就返回
       return
    end

  local pTalkInfo = TableGuideStoryTalk[pGuideId].Contents
   local pRole = nil

  local pMainRoleInfo = RolesManager:getInstance()._pMainRoleInfo
  if pTalkInfo.ID == kStoryGuideTalkType.kCreate then          --创建Npc,主角或者怪物
    pRole = require("StoryRole"):create(pTalkInfo,pMainRoleInfo)
    self:getStoryGuideLayer()._pTmxMap:addChild(pRole)
    table.insert(self._tAllCreateRole,pRole)
    NetRespManager:getInstance():dispatchEvent(kNetCmd.kStoryGuideEnd)

  elseif pTalkInfo.ID == kStoryGuideTalkType.kMove then        --玩家，npc，怪物，移动
    pRole = self:getRoleByInstenceId(pTalkInfo.InstanceID)
    pRole:moveRole(self:toPos(pTalkInfo.EndX,pTalkInfo.EndY,true),pTalkInfo.Speed)

  elseif pTalkInfo.ID == kStoryGuideTalkType.kTalk then        --当前位置对话
    TalksManager:getInstance():setCurTalks(pTalkInfo.TalkID)
  elseif pTalkInfo.ID == kStoryGuideTalkType.kSkill then       --原地放技能
    pRole = self:getRoleByInstenceId(pTalkInfo.InstanceID)
    pRole:playAttackSkill(pTalkInfo)

  elseif pTalkInfo.ID == kStoryGuideTalkType.kRemove then      --移除npc或者怪物或者主角
    pRole = self:getRoleByInstenceId(pTalkInfo.InstanceID)
    pRole:removeRole()

  elseif pTalkInfo.ID == kStoryGuideTalkType.kRotation then    --旋转
    pRole = self:getRoleByInstenceId(pTalkInfo.InstanceID)
    pRole:setAngle3D(pTalkInfo.Rotation)
    NetRespManager:getInstance():dispatchEvent(kNetCmd.kStoryGuideEnd)
  elseif pTalkInfo.ID == kStoryGuideTalkType.kCameraMove then  --镜头移动
    self:moveToGuideLayerTmxToPos(pTalkInfo.StartX,pTalkInfo.StartY,pTalkInfo.MoveTime)

  elseif pTalkInfo.ID == kStoryGuideTalkType.kWaiting then     --延时等待
    local timeCallBack = function ()
       NetRespManager:getInstance():dispatchEvent(kNetCmd.kStoryGuideEnd)
    end
      self:getStoryGuideLayer():runAction(cc.Sequence:create(cc.DelayTime:create(pTalkInfo.WaitingTime),cc.CallFunc:create(timeCallBack)))   
  elseif pTalkInfo.ID == kStoryGuideTalkType.kPlayMusic then    --播放音乐
    if pTalkInfo.Loop == -1 then --音乐不循环播放
       AudioManager:getInstance():playMusic(pTalkInfo.MusicName)
    else
       AudioManager:getInstance():playMusic(pTalkInfo.MusicName,true)
    end
     NetRespManager:getInstance():dispatchEvent(kNetCmd.kStoryGuideEnd)
    
  elseif pTalkInfo.ID == kStoryGuideTalkType.kPlayEffect then   --播放音效
    if pTalkInfo.Loop == -1 then --音效不循环播放
       AudioManager:getInstance():playEffect(pTalkInfo.EffectName,nil,true)
    else
       AudioManager:getInstance():playEffect(pTalkInfo.EffectName,true,true)
    end
      NetRespManager:getInstance():dispatchEvent(kNetCmd.kStoryGuideEnd)
  end

end


--地图移动到指定位置
function StoryGuideManager:moveToGuideLayerTmxToPos(pX,pY,pTime)
  local timeCallBack = function()
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kStoryGuideEnd)
  end
   local pPos = self:moveCamera(self:toPos(pX,pY))
   print("Posx"..pPos.x)
   print("Posy"..pPos.y)
   self:getStoryGuideLayer()._pTmxMap:runAction( cc.Sequence :create(cc.MoveTo:create(pTime,pPos),cc.CallFunc:create(timeCallBack)))
end


function StoryGuideManager:moveCamera(pPos)

  local sMapRectPixelSize = self:getStoryGuideLayer()._sMapRectPixelSize
  local pRect = cc.size(mmo.VisibleRect:width(), mmo.VisibleRect:height())
  local pX = 0
  local pY = 0
  if pPos.x > sMapRectPixelSize.width then --如果pos大于屏幕屏宽度
    pX = -sMapRectPixelSize.width + pRect.width
  elseif pPos.x <= pRect.width/2 then
    pX  = 0
  elseif pPos.x + pRect.width/2 > sMapRectPixelSize.width then  --如果以目标函数的坐标做屏幕最左边，然后+屏幕宽度 >地图最大值
    pX = -sMapRectPixelSize.width + pRect.width
  else
    pX = pRect.width/2 - pPos.x
  end


  if pPos.y > sMapRectPixelSize.height then --如果pos大于屏幕屏宽度 
     pY = -sMapRectPixelSize.height + pRect.height
  elseif pPos.y <= pRect.height/2 then
    pY = 0
  elseif pPos.y + pRect.height/2 > sMapRectPixelSize.height then
    pY = -sMapRectPixelSize.height + pRect.height
  else
    pY = pRect.height/2 - pPos.y

  end

  return cc.p(pX,pY)
end


--传入策划填写的行，(bool)代表是取得  列返回pos
function StoryGuideManager:toPos(pX,pY,bool)
  local sTiledPixelSize = self:getStoryGuideLayer()._sTiledPixelSize
  local sMapIndexHeight = self:getStoryGuideLayer()._sMapRectPixelSize.height
  local pPos = cc.p(sTiledPixelSize.width*pX-sTiledPixelSize.width/2,sTiledPixelSize.height*pY-sTiledPixelSize.height/2)

  if bool == true then --人物创建，镜头移动，这个格子是反的
    pPos.y = sMapIndexHeight - pPos.y
  end
  return pPos
end

function StoryGuideManager:update(dt)
  if self._tAllCreateRole ~= nil and table.getn(self._tAllCreateRole) > 0 then
      for k,v in pairs(self._tAllCreateRole) do
        if v._bActive == true then
            v:updateStoryRole(dt)
      end
    end
    end
    return
end



