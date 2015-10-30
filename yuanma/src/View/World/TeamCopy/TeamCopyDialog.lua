--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  TeamCopyDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/10/27
-- descrip:   组队副本界面
--===================================================
local TeamCopyDialog = class("TeamCopyDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function TeamCopyDialog:ctor()
    self._strName = "TeamCopyDialog"       -- 层名称
    self._pBg = nil
    self._pCloseButton = nil
    self._pScrollView = nil                                 --副本ScrollView
    self._pPowerBar = nil                                   --体力进度条
    self._pPowerText = nil                                  --体力的text
    self._pAddPowerBtn = nil                                --增加体力的按钮
    self._pTeamCopyName = nil                               --副本的名字
    self._pCopyNum = nil                                    --今日剩余次数的次数 3/3、
    self._pRewardScrollView = nil                           --奖励的物品滑动框
    self._tRewardNode = nil                                 --{奖励的挂载node，奖励的图片，奖励的数目}   
    self._pSureButton = nil                                 --进入副本
    self._tCopyButton = nil                                 --组队副本的button集合

    self._pCurClickCopyIndex = nil                          --默认选中了第几个副本
end

-- 创建函数
function TeamCopyDialog:create(args)
    local dialog = TeamCopyDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function TeamCopyDialog:dispose(args)
    NetRespManager:getInstance():addEventListener(kNetCmd.kQueryBattleList ,handler(self, self.queryBattleListResp))
    self._pArgs = args
    self:initUI()
    self:initBtn()

    MessageGameInstance:sendMessageQueryBattleList21000({kCopy.kTeamAIFight})

    --local event = {battleExts = {{battleId =11001 ,extCount = 0,currentCount = 2},{battleId =11002 ,extCount = 0,currentCount = 2},{battleId =11001 ,extCount = 0,currentCount = 3}}}
    --self:queryBattleListResp(event)

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
            self:onExitTeamCopyDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return

end


--初始化界面
function TeamCopyDialog:initUI()

    ResPlistManager:getInstance():addSpriteFrames("MultiplayerCopyOne.plist")
    ResPlistManager:getInstance():addSpriteFrames("MultiplayerUI.plist")
    
    local params = require("MultiplayerUIParams"):create()
    self._pCCS = params._pCCS
    self._pCloseButton = params._pCloseButton
    self._pBg = params._pBackGround
    self._pScrollView = params._pScrollView                 --副本ScrollView
    self._pPowerBar = params._pLoadingBar                   --体力进度条
    self._pPowerText = params._pLoadingBarText              --体力的text
    self._pAddPowerBtn = params._pBuyButton                 --增加体力的按钮
    self._pTeamCopyName = params._pName                     --副本的名字
    self._pCopyNum = params._pTimeText02                    --今日剩余次数的次数 3/3、
    self._pRewardScrollView =  params._pRewardScrollView    --奖励的物品滑动框
    --{奖励的挂载node，奖励的图片，奖励的数目}
    self._tRewardNode = {{params._pNodeMoneyIcon01,params._pMoneyIcon01,params._pMIconText01},
                         {params._pNodeMoneyIcon02,params._pMoneyIcon02,params._pMIconText02},
                         {params._pNodeMoneyIcon03,params._pMoneyIcon03,params._pMIconText03}}
    self._pSureButton = params._pSureButton                 --进入副本


    -- 初始化dialog的基础组件
    self:disposeCSB()

    -- 初始化剧情副本滑动
    self._pCopyListController = require("ListController"):create(self,self._pScrollView,listLayoutType.LayoutType_vertiacl,280,100)
    self._pCopyListController:setVertiaclDis(6)
    self._pCopyListController:setHorizontalDis(3)

    --具体某个副本里面的奖励
    self._pRewardListController = require("ListController"):create(self,self._pRewardScrollView,listLayoutType.LayoutType_rows,100,100)
    self._pRewardListController:setVertiaclDis(6)
    self._pRewardListController:setHorizontalDis(3)

    --体力
    local pCurStrenght = RolesManager:getInstance()._pMainRoleInfo.strength
    local pMaxStrength = TableConstants.PowerNumLimit.Value
    self._pPowerBar:setPercent(pCurStrenght/pMaxStrength*100)
    self._pPowerText:setString(pCurStrenght.."/"..pMaxStrength)
    
end


function TeamCopyDialog:initBtn()

    --增加体力
    local onTouchAddRewardButton = function( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
           DialogManager:getInstance():showDialog("BuyStrengthDialog",{kBuyThingsType.kBuyStrength})
        elseif eventType == ccui.TouchEventType.began then
           AudioManager:getInstance():playEffect("ButtonClick")
        end
    end

    --进入副本
    local onTouchSuureButton = function( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
          --进入副本
          local pInfo = self._tTeamCopyInfo[self._pCurClickCopyIndex]
        --本地表里的本副本的信息
        local pCopyInfo = TableTeamAIFightCopys[math.fmod(pInfo.battleId,100)]
        if (pInfo.currentCount+pInfo.extCount) == 0 then
            NoticeManager:getInstance():showSystemMessage("没有次数了")
            return --没有次数了
        end
           DialogManager:getInstance():showDialog("TeamMatchDialog",{pInfo.battleId})
        elseif eventType == ccui.TouchEventType.began then
           AudioManager:getInstance():playEffect("ButtonClick")
        end
    end


    self._pAddPowerBtn:setZoomScale(nButtonZoomScale)
    self._pAddPowerBtn:setPressedActionEnabled(true)
    self._pAddPowerBtn:addTouchEventListener(onTouchAddRewardButton)
    self._pSureButton:setZoomScale(nButtonZoomScale)
    self._pSureButton:setPressedActionEnabled(true)
    self._pSureButton:addTouchEventListener(onTouchSuureButton)

end

function TeamCopyDialog:initScrollViewItem()
    self._tCopyButton = {}    
    self._pCopyListController._pDataSourceDelegateFunc = function (delegate,controller, index)
        local pInfo =   self._tTeamCopyInfo[index]
        local cell = controller:dequeueReusableCell()
        if cell == nil then
            local params = require("MultiplayerCopyOneParams"):create()
            cell = params._pCCS
        end
        self:setCopyDialogItemInfo(cell,pInfo,index)
        return cell
    end
    self._pCopyListController._pNumOfCellDelegateFunc = function ()
        return table.getn(self._tTeamCopyInfo)
    end
    
    self._pCopyListController:setDataSource(self._tTeamCopyInfo)
    self:updateCopyButtonStateByIndex(1)
end


--设置初始化界面的组队副本
function TeamCopyDialog:setCopyDialogItemInfo(params,pInfo,nIndex)

--本地表里的本副本的信息
local pCopyInfo = TableTeamAIFightCopys[math.fmod(pInfo.battleId,100)]
    --副本的按钮
    local pCopyButton = params:getChildByName("CopyBG")
    --副本的名称
    local pCopyName = pCopyButton:getChildByName("Name")
    --副本的图片
    local pCopyIcon = pCopyButton:getChildByName("CopyIcon")
    pCopyName:setString(pCopyInfo.Name)
    pCopyIcon:loadTexture("MultiplayerCopyOneRes/"..pCopyInfo.MapIcon..".png", ccui.TextureResType.plistType)
    local onTouchCopyIconCallBack = function( sender, eventType )
        if eventType == ccui.TouchEventType.ended then
         local nTag = sender:getTag()
          --点击某个副本
          self:updateTeamCopyInfoByIndex(nTag)
          self:updateCopyButtonStateByIndex(nTag)
        elseif eventType == ccui.TouchEventType.began then
           AudioManager:getInstance():playEffect("ButtonClick")
        end
    end
    pCopyButton:setTag(nIndex)
    pCopyButton:addTouchEventListener(onTouchCopyIconCallBack)
    table.insert(self._tCopyButton,pCopyButton)
end

--更新副本按钮的显示状态
function TeamCopyDialog:updateCopyButtonStateByIndex(nIndex)
    local pNomal = "MultiplayerCopyOneRes/zbfj9.png"
    local pPush = "MultiplayerCopyOneRes/zbfj9-2.png"
    for k,v in pairs(self._tCopyButton)do
       if k == nIndex then --选中的
        v:loadTextures(pPush,pNomal,nil, ccui.TextureResType.plistType)
       else --未选中的
        v:loadTextures(pNomal,pPush,nil, ccui.TextureResType.plistType)
       end
    end
    self._pCurClickCopyIndex = nIndex
end

--更新副本信息界面
function TeamCopyDialog:updateTeamCopyInfoByIndex(nIndex)

local pInfo = self._tTeamCopyInfo[nIndex]
--本地表里的本副本的信息
local pCopyInfo = TableTeamAIFightCopys[math.fmod(pInfo.battleId,100)]
--可以获得的物品信息
local tRewardItemInfo = self:getScrollViewDate(pCopyInfo.MayDropItems)
--今日剩余次数的次数 3/3、
self._pCopyNum:setString((pInfo.currentCount+pInfo.extCount).."/"..pCopyInfo.Times)
--副本名称
self._pTeamCopyName:setString(pCopyInfo.Name)


 self._pRewardListController._pDataSourceDelegateFunc = function (delegate,controller, index)
        local pInfo = tRewardItemInfo[index]
        local cell = controller:dequeueReusableCell()
        if cell == nil then
            cell = require("BattleItemCell"):create()
            cell:setTouchEnabled(false)
        end
        cell:setItemInfo(pInfo)
        return cell
    end
    self._pRewardListController._pNumOfCellDelegateFunc = function ()
        return table.getn(tRewardItemInfo)
    end
    
    self._pRewardListController:setDataSource(tRewardItemInfo)


 --self._tRewardNode = {{奖励的挂载node，奖励的图片，奖励的数目},{},{}}
    local pFinanceInfo = pCopyInfo.MoneyReward
    for k, v in pairs(self._tRewardNode) do
        v[1]:setVisible(false)
        if pFinanceInfo[k] ~= nil then
            v[1]:setVisible(true)
            v[2]:loadTexture(FinanceManager:getInstance():getIconByFinanceType(pFinanceInfo[k][1]).filename, ccui.TextureResType.plistType)
            v[3]:setString(pFinanceInfo[k][2])
        end

    end
end


--副本请求回复
function TeamCopyDialog:queryBattleListResp(event)
    print("aaaaaaaaaaaaaaaaaaaaaa")
self._tTeamCopyInfo = event.battleExts
--初始化界面左侧的副本信息
self:initScrollViewItem()
--初始化右侧的某个副本信息
self:updateTeamCopyInfoByIndex(1)

end


function TeamCopyDialog:getScrollViewDate(tDate)
local pScrollViewDate  = {}
    for i=1,table.getn(tDate) do
        local pInfo = {id=tDate[i][1],baseType = tDate[i][2],value = 0}
        
        table.insert(pScrollViewDate,GetCompleteItemInfo(pInfo))
    end
    return pScrollViewDate
end

-- 退出函数
function TeamCopyDialog:onExitTeamCopyDialog()
    self:onExitDialog()
    -- 释放掉login合图资源
    NetRespManager:getInstance():removeEventListenersByHost(self)
    ResPlistManager:getInstance():removeSpriteFrames("MultiplayerCopyOne.plist")
    ResPlistManager:getInstance():removeSpriteFrames("MultiplayerUI.plist")
end

-- 循环更新
function TeamCopyDialog:update(dt)
    return
end

-- 显示结束时的回调
function TeamCopyDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function TeamCopyDialog:doWhenCloseOver()
    return
end

return TeamCopyDialog
