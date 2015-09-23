--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FamilyTechPanel.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/7/16
-- descrip:   家族科技界面
--===================================================

local FamilyTechPanel = class("FamilyTechPanel",function()
    return require("BasePanel"):create()
end)

-- 构造函数
function FamilyTechPanel:ctor()
    self._strName = "FamilyTechPanel" -- 层名称
    self._pCCS  = nil                               --背景
    self._pCurBuffListView = nil   --当前buff的ListView
    self._pAllBuffListView = nil   -- 未生效的buffListView
    self._pTechIcon = nil          -- 研究院图标
    self._pTechLevel = nil         -- 研究院等级
    self._pTechDesc = nil          -- 研究院的说明信息
    self._pTechNotic = nil         -- 研究院提示
    self._pTechUpBtn = nil         -- 研究院升级按钮

    --数据信息
    --研究院等级
    self._nTechLevel = nil
    --科技列表
    self._nTechList = {}
    --正在cd的科技lable
    self._tCdBuffLable = {}
end

-- 创建函数
function FamilyTechPanel:create(func)
    local layer = FamilyTechPanel.new()
    layer:dispose(func)
    return layer
end

-- 处理函数
function FamilyTechPanel:dispose(func)
    --获取研究院信息
    NetRespManager:getInstance():addEventListener(kNetCmd.kQueryFamilyAcademyResp ,handler(self, self.queryFamilyAcademy))
    --升级研究院
    NetRespManager:getInstance():addEventListener(kNetCmd.kUpgradeFamilyAcademyResp ,handler(self, self.upgradeFamilyAcademy))
    --激活研究院科技
    NetRespManager:getInstance():addEventListener(kNetCmd.kActivateFamilyTechResp ,handler(self, self.activateFamilyTech))
    --升级研究院信息
    NetRespManager:getInstance():addEventListener(kNetCmd.kUpgradeFamilyTechResp ,handler(self, self.upgradeFamilyTech))
    --正在cd的buff
    NetRespManager:getInstance():addEventListener(kNetCmd.kHomeBuffTime ,handler(self, self.techBuffTimeInform))
    
    ResPlistManager:getInstance():addSpriteFrames("OurHomeBuffPanel.plist")
    ResPlistManager:getInstance():addSpriteFrames("Buffwei.plist")
    ResPlistManager:getInstance():addSpriteFrames("BuffNow.plist")
    --初始化界面UI
    self:initFamilyTechUi()
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitFamilyTechPanel()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end

--初始化界面UI
function FamilyTechPanel:initFamilyTechUi()
    --大背景
    local params = require("OurHomeBuffPanelParams"):create()
    self._pCCS = params._pCCS
    self._pCurBuffListView = params._pListViewNow      --当前buff的ListView
    self._pAllBuffListView = params._pBuffScrollView   -- 未生效的buffListView
    self._pTechIcon = params._pBuffIcon                     -- 研究院图标
    self._pTechLevel = params._pText_3                    -- 研究院等级
    self._pTechDesc = params._pText_6                     -- 研究院的说明信息
    self._pTechNotic = params._pText_4                    -- 研究院提示信息
    self._pTechUpBtn = params._pButton_3                  -- 研究院升级按钮
    self._pCDBuffNum = params._pSxTextNum                 -- 已经生效的buff数量
    self:addChild(self._pCCS)

end

--根据研究院等级初始化数据
function FamilyTechPanel:updateTechInfoByLevel(nLevel)

  local pTableTechTabInfo = TableFamilyLab[nLevel+1]

    local onTouchButton = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
            if FamilyManager:getInstance():whetherHasPermission(kFamilyChiefType.kUpgradeLab) then --是否有权限升级家族研究院
                if pTableTechTabInfo.RequiredLevel > FamilyManager:getInstance()._pFamilyInfo.level then
                    NoticeManager:getInstance():showSystemMessage("家族等级不足，研究院升级到下一级需要家族".. pTableTechTabInfo.RequiredLevel.."级")
                    return
                end
            DialogManager:getInstance():showDialog("FamilyUpLevelDialog",{kFamilyUpLevelType.kUpTechLevel,pTableTechTabInfo})
            end
        elseif eventType == ccui.TouchEventType.began then
            AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
  
  -- 研究院升级按钮
  self._pTechUpBtn:addTouchEventListener(onTouchButton)
  --研究院图标
  --self._pTechIcon:loadTexture("aa.png",ccui.TextureResType.plistType)
  --研究院等级
   self._pTechLevel:setString(nLevel.."级研究院")
   --研究院提示信息
    self._pTechNotic:setString("下一等级需家族"..pTableTechTabInfo.RequiredLevel.."级")
  --研究院文字说明
    self._pTechDesc:setString(pTableTechTabInfo.Text)

    --如果当前研究院等级为0
    if nLevel == 0 then 
       self._pTechLevel:setString("研究院未开启")  
    end
    
    --满级了
    if pTableTechTabInfo.RequiredLevel == 0 then
       self._pTechUpBtn:setTouchEnabled(false)
       darkNode( self._pTechUpBtn:getVirtualRenderer():getSprite())
    end
    
    --如果需要的研究院等级大于研究院的等级，或者等级为0的时候 提示不显示
    if pTableTechTabInfo.RequiredLevel <= FamilyManager:getInstance()._pFamilyInfo.level or nLevel == 0  then 
        self._pTechNotic:setVisible(false)
    else
        self._pTechNotic:setVisible(true)
    end
	
end


--更新buff
 function FamilyTechPanel:updateTechListInfo(tTechList)
 
    self._tCdBuffLable = {}
    self._pCurBuffListView:removeAllItems()
    self._pAllBuffListView:removeAllItems()
 
    --正在cd的信息，不在cd的信息，没有开启的信息
    local pCdInfo,pNotCdInfo,pNotOpenId = self:soryListDate(tTechList)
 
    --加载正在cd的buff Item信息
    self:createCdBuffInfo(pCdInfo)
    --加载已经开放的buff item信息
    self:createGetBuffInfo(pNotCdInfo)
    --加载未开放的buff
    self:createNotOpenBuffInfo(pNotOpenId)
    --更新buff数量
    self:updateCdBuffNum(table.getn(pCdInfo))

end

--通过数据加载正在cdBuff的信息
function FamilyTechPanel:createCdBuffInfo(pCdInfo)
	
    for k,v in pairs(pCdInfo) do
        local params = require("BuffNowParams"):create()
        local pCCs = params._pCCS
        local pTableInfo = FamilyManager:getInstance():getTechInfoByIdAndLevel(v.techId,v.level)
        --buff Icon
        params._pBuffIcon:loadTexture(pTableInfo.Icon..".png",ccui.TextureResType.plistType)
        --buff 名字
        params._pBuffName:setString(pTableInfo.Name)
        --buff 等级
        params._pBuffLv:setString(v.level.."级")
        --buff 说明
        params._pBuffSM:setString(pTableInfo.Text)
        --经验条底板
        local pBar = self:createExpBar()
        pBar:setPosition(cc.p(params._pExpBg:getContentSize().width/2,params._pExpBg:getContentSize().height/2))
        params._pExpBg:addChild(pBar)
        local nAllCDTime = TableHomeBuff[pTableInfo.BuffID].Duration
        pBar:setPercentage(v.remainTime/nAllCDTime*100)
        pBar:runAction(cc.Sequence:create(cc.ProgressTo:create(v.remainTime, 0))) 
        --把buff显示的时间lable添加到表里
        
        params._pTimeTextNum:setString(gTimeToStr(v.remainTime))
        self._tCdBuffLable[pTableInfo.BuffID] = params._pTimeTextNum  
        
        local pSize = cc.size(params._pBackBg:getContentSize().width,params._pBackBg:getContentSize().height)
        local widget = ccui.Widget:create()
        widget:setContentSize(pSize)
        pCCs:setPosition(cc.p(pSize.width/2,pSize.height/2))
        widget:addChild(pCCs)
        
        self._pCurBuffListView:pushBackCustomItem(widget)
	end
	
end

--加载已经开放的buff item信息
function FamilyTechPanel:createGetBuffInfo(pNotCdInfo)
    local pBuffNode = {}
    local tHasUpLevel = {}
    for k,v in pairs(pNotCdInfo) do
     local params = require("BuffweiParams"):create()
        local pCCs = params._pCCS
        params._pButtonNode:setVisible(false)
        local pTableInfo = FamilyManager:getInstance():getTechInfoByIdAndLevel(v.techId,v.level)
        --buff Icon
        params._pIcon:loadTexture(pTableInfo.Icon..".png",ccui.TextureResType.plistType)
        --buff 名字
        params._pNameText:setString(pTableInfo.Name)
        --buff 等级
        params._pLvText:setString(v.level.."级")
        --buff 说明
        params._pSmText:setString(pTableInfo.Text)
        --buff 条件
        params._pTjText:setString("升级需研究院"..pTableInfo.RequiredLevel.."级")
        --buff node
        table.insert(pBuffNode,params._pButtonNode) 
        
        --设置是否符合下一集条件
        if pTableInfo.RequiredLevel <= self._nTechLevel then 
            params._pTjText:setVisible(false)
            table.insert(tHasUpLevel,{true,pTableInfo.RequiredLevel})
        else
            table.insert(tHasUpLevel,{false,pTableInfo.RequiredLevel})
        end
        
        --buff已经满级
        if pTableInfo.RequiredLevel == 0 then
        	 params._pButton_2:setTouchEnabled(false)
             params._pButton_2:setTitleText("已满级")
             darkNode(params._pButton_2:getVirtualRenderer():getSprite())
        end
        
        --buff 激活按钮
        local onTouchActiveButton = function (sender, eventType)
           if eventType == ccui.TouchEventType.ended then
              if FamilyManager:getInstance():whetherHasPermission(kFamilyChiefType.kActiveBuff) then --是否有权限激活家族科技
                 local nTag = sender:getTag()    
                 DialogManager:getInstance():showDialog("FamilyUpLevelDialog",{kFamilyUpLevelType.kActiveBuff,pNotCdInfo[nTag]})
              end 
            elseif eventType == ccui.TouchEventType.began then
                 AudioManager:getInstance():playEffect("ButtonClick")       
           end
        end
        params._pButton_1:addTouchEventListener(onTouchActiveButton)
        params._pButton_1:setTag(k)


        --buff 升级
       local onTouchUpLevelButton = function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                if FamilyManager:getInstance():whetherHasPermission(kFamilyChiefType.kUpgradeBuff) then --是否有权限升级家族科技
                  local nTag = sender:getTag()
                  if tHasUpLevel[nTag][1] == false then 
                     NoticeManager:getInstance():showSystemMessage("研究院等级不足，科技升级到下一级需要研究院".. tHasUpLevel[nTag][2].."级")
                     return 
                  end
                  DialogManager:getInstance():showDialog("FamilyUpLevelDialog",{kFamilyUpLevelType.kUpBuff,pNotCdInfo[nTag]})
               end
            elseif eventType == ccui.TouchEventType.began then
                AudioManager:getInstance():playEffect("ButtonClick")
            end
        end
        params._pButton_2:addTouchEventListener(onTouchUpLevelButton)
        params._pButton_2:setTag(k)
        local pSize = cc.size(params._pBuffBg:getContentSize().width,params._pBuffBg:getContentSize().height)
        local widget = ccui.Widget:create()
        widget:setTag(k)
        widget:setTouchEnabled(true)
        widget:setContentSize(pSize)
        pCCs:setPosition(cc.p(pSize.width/2,pSize.height/2))
        widget:addChild(pCCs)
        
        
        local onTouchItemListener = function (sender, eventType)
            if eventType == ccui.TouchEventType.ended then
                local nTag = sender:getTag()
                for i=1,table.getn(pBuffNode) do
                    if i==nTag then 
                        pBuffNode[i]:setVisible(true)
                    else
                        pBuffNode[i]:setVisible(false)
                    end
                end
            elseif eventType == ccui.TouchEventType.began then
                AudioManager:getInstance():playEffect("ButtonClick")
            end
        end

        widget:addTouchEventListener(onTouchItemListener)
        self._pAllBuffListView:pushBackCustomItem(widget)
    end

end


--加载未开放的buff

function FamilyTechPanel:createNotOpenBuffInfo(pNotOpenId)

  for k,v in pairs(pNotOpenId) do
        local params = require("BuffweiParams"):create()
        local pCCs = params._pCCS
        params._pButtonNode:setVisible(false)
        local pTableInfo = FamilyManager:getInstance():getTechInfoByIdAndLevel(v,0)
        --buff Icon
        params._pIcon:loadTexture(pTableInfo.Icon..".png",ccui.TextureResType.plistType)
        --buff 名字
        params._pNameText:setString(pTableInfo.Name)
        --buff 等级
        params._pLvText:setString("未开放")
        --buff 说明
        params._pSmText:setTextAreaSize(params._pSmText:getContentSize())
        params._pSmText:setString(pTableInfo.Text)
        --buff 条件
        params._pTjText:setString("开启需研究院"..pTableInfo.RequiredLevel.."级")
        --底板
         
        darkNode(params._pIconBg:getVirtualRenderer():getSprite())
        darkNode(params._pIcon:getVirtualRenderer():getSprite())
        
        local pSize = cc.size(params._pBuffBg:getContentSize().width,params._pBuffBg:getContentSize().height)
        local widget = ccui.Widget:create()
        widget:setContentSize(pSize)
        pCCs:setPosition(cc.p(pSize.width/2,pSize.height/2))
        widget:addChild(pCCs)
        self._pAllBuffListView:pushBackCustomItem(widget)
  end

end


--更新buff数量
function FamilyTechPanel:updateCdBuffNum(nCdNum)
    local pCurAllNum  = TableFamilyLab[self._nTechLevel+1]
    self._pCDBuffNum:setString(nCdNum.."/"..pCurAllNum.MaxEffects)
end


function FamilyTechPanel:createExpBar()
    -- 进度条
    local pSprite = cc.Sprite:createWithSpriteFrameName("BuffNowRes/jlxt8.png")
    local pBar = cc.ProgressTimer:create(pSprite)
    pBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    pBar:setScaleX(1.7)
    pBar:setMidpoint(cc.p(0, 0))
    pBar:setBarChangeRate(cc.p(1, 0))
    pBar:setPercentage(0)
    
    return pBar
end


--整理数据
function FamilyTechPanel:soryListDate(tTechList)
	local pAllTechNum = FamilyManager:getInstance():getTechNums()
	local pNotOpenId = {}   --未开启的id
	local pCdInfo  = {}     --正在走cd的buff
	local pNotCdInfo = {}   --在本地的buff
	
	for i=1, pAllTechNum do
		local pHasOpen = false
		for k,v in pairs(tTechList) do --遍历服务器发过来的信息表
		 if i == v.techId then  --如果发现这个id
	        pHasOpen = true
            if v.remainTime == 0 then --如果当前这个buff剩余时间为0 ，代表正在本地，不在cd队列
               table.insert(pNotCdInfo,v)
            else
               table.insert(pCdInfo,v)
	        end

		 end 
		end
		if pHasOpen == false then --说明这个id是未开启的
		
          table.insert(pNotOpenId,i)
		end
	end
    return pCdInfo,pNotCdInfo,pNotOpenId
end



--获取研究院信息
function FamilyTechPanel:queryFamilyAcademy(event)
    --研究院等级
    self._nTechLevel = event.academyLevel
    --科技列表
    self._nTechList = event.techList
    --更新研究院信息
    self:updateTechInfoByLevel(self._nTechLevel)
    --更新buff
    self:updateTechListInfo(self._nTechList)
end

--升级研究院
function FamilyTechPanel:upgradeFamilyAcademy(event)
    --家族贡献
    FamilyManager:getInstance()._pFamilyInfo.score = event.score
    --家族资金
    FamilyManager:getInstance()._pFamilyInfo.cash = event.cash
    --研究院等级
    self._nTechLevel = event.academyLevel
    --科技列表
    self._nTechList = event.techList
    --更新研究院信息
    self:updateTechInfoByLevel(self._nTechLevel)
    --更新buff
    self:updateTechListInfo(self._nTechList)

end
--激活Buff信息
function FamilyTechPanel:activateFamilyTech(event)
    --家族贡献
    FamilyManager:getInstance()._pFamilyInfo.score = event.score
    --家族资金
    FamilyManager:getInstance()._pFamilyInfo.cash = event.cash
    --科技列表
    self._nTechList = event.techList
    --更新buff
    self:updateTechListInfo(self._nTechList)


end
--升级Buff信息
function FamilyTechPanel:upgradeFamilyTech(event)
    --家族贡献
    FamilyManager:getInstance()._pFamilyInfo.score = event.score
    --家族资金
    FamilyManager:getInstance()._pFamilyInfo.cash = event.cash
    --科技列表
    self._nTechList = event.techList
    self:updateTechListInfo(self._nTechList)
end

--正在cd的buff
function FamilyTechPanel:techBuffTimeInform(event)
    for k,v in pairs(self._tCdBuffLable) do
    	if k == event[2] then --如果id一样
            v:setString(gTimeToStr(event[1]))
            if event[1] == 0 then --如果时间为0标示buff没了 从新请求buff信息
                FamilyCGMessage:querFamilyAcademyReq22332()
            end
            
    	end
    end
end

--清空中间数据(必须实现)
function FamilyTechPanel:clearPanelDateInfo()

end

-- 退出函数
function FamilyTechPanel:onExitFamilyTechPanel()
    -- release合图资源
    ResPlistManager:getInstance():removeSpriteFrames("OurHomeBuffPanel.plist")
    ResPlistManager:getInstance():removeSpriteFrames("Buffwei.plist")
    ResPlistManager:getInstance():removeSpriteFrames("BuffNow.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end


return FamilyTechPanel
