--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  BladeSoulCellDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/3/18
-- descrip:   buff的Node
--===================================================
local BossHpNode = class("BossHpNode",function()
    return cc.Node:create()
end)

-- 构造函数
function BossHpNode:ctor()
    self._strName = "BossHpNode"               -- 层名称
    self._tBossHpBar = {}                      --血条集合
    self._tBossHpBarCache = {}                 --血条缓存集合
    self._tBoss = nil                         --当前依附的怪物
end

-- 创建函数
function BossHpNode:create(pBossHpNum)
    local BossHpNode = BossHpNode.new()
    BossHpNode:dispose(pBossHpNum)
    return BossHpNode
end

-- 处理函数
function BossHpNode:dispose(pBossHpNum)
    ResPlistManager:getInstance():addSpriteFrames("battle_boss_hp_ui.plist")
    --84
    -- 初始化Boss血条
    local pBossBG = cc.Sprite:createWithSpriteFrameName("BossHpUi/bossHpFrame.png")
    self:addChild(pBossBG)

    local pBossBgWidth = pBossBG:getContentSize().width
    local pBossBgHeight = pBossBG:getContentSize().height
    
    local pBossBarCache = cc.Sprite:createWithSpriteFrameName("BossHpUi/bossHPCache.png")
    local pBossBarWidth = pBossBarCache:getContentSize().width
    local pBossBarHeight = pBossBarCache:getContentSize().height

    local pBossBarNode = cc.Node:create()
    pBossBarNode:setPosition(cc.p((pBossBgWidth - pBossBarWidth)/2+23,(pBossBgHeight-pBossBarHeight)/2))
    pBossBG:addChild(pBossBarNode)

    local pBossHpBar = nil
    local pBossHpCache = nil

    for k=1,pBossHpNum do 
        local pBossBar = cc.Sprite:createWithSpriteFrameName("BossHpUi/bossHP"..k..".png")
        pBossHpCache = cc.ProgressTimer:create(pBossBarCache)
        pBossHpCache:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        pBossHpCache:setMidpoint(cc.p(1,0))
        pBossHpCache:setBarChangeRate(cc.p(1,0))
        pBossHpCache:setPercentage(100)
        pBossHpCache:setRotation(180)
        pBossHpCache:setPosition(cc.p(pBossBarWidth/2,pBossBarHeight/2))
        
        pBossHpBar = cc.ProgressTimer:create(pBossBar)
        pBossHpBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
        pBossHpBar:setMidpoint(cc.p(1,0))
        pBossHpBar:setBarChangeRate(cc.p(1,0))
        pBossHpBar:setPercentage(100)
        pBossHpBar:setRotation(180)
        pBossHpBar:setPosition(cc.p(pBossBarWidth/2,pBossBarHeight/2))

        pBossBarNode:addChild(pBossHpBar,k+1)
        pBossBarNode:addChild(pBossHpCache,k)
       
        -- Boss的血条集合
        table.insert(self._tBossHpBar, pBossHpBar)
        -- Boss的血条缓冲集合
        table.insert(self._tBossHpBarCache, pBossHpCache)            
     end 

    -- Boss名称
    self._pBossNameText = cc.Label:createWithTTF("", strCommonFontName, 18)
    self._pBossNameText:enableShadow(cc.c4b(0, 0, 0, 255),cc.size(1,-1))
    self._pBossNameText:setTextColor(cFontWhite)
    self._pBossNameText:enableOutline(cFontOutline,2)
    self._pBossNameText:setPosition(cc.p(pBossBarWidth/2,pBossBarHeight/2))
    pBossBarNode:addChild(self._pBossNameText,100)

    --boss的血XX
    self._pBossHpNumText = cc.Label:createWithTTF("X2", strCommonFontName, 23)
    self._pBossHpNumText:setTextColor(cFontWhite)
    self._pBossHpNumText:enableOutline(cFontOutline,2)
    self._pBossHpNumText:setAnchorPoint(cc.p(0,0.5))
    self._pBossHpNumText:setPosition(cc.p(pBossBarWidth-60,pBossBarHeight/2))
    pBossBarNode:addChild(self._pBossHpNumText,100)


    --boss血条保护背景
    self._pBossProtectBG = cc.Sprite:createWithSpriteFrameName("BossHpUi/ArmorBar.png")
    self._pBossProtectBG:setPosition(-self._pBossProtectBG:getContentSize().width/2+6,4 )
    pBossBarNode:addChild(self._pBossProtectBG,100)
    --boss血保护
    local pBossProtect = cc.Sprite:createWithSpriteFrameName("BossHpUi/ArmorBarFrame.png")
    self._pBossProtectBar = cc.ProgressTimer:create(pBossProtect)
    self._pBossProtectBar:setType(cc.PROGRESS_TIMER_TYPE_BAR)
    self._pBossProtectBar:setMidpoint(cc.p(1,0))
    self._pBossProtectBar:setBarChangeRate(cc.p(1,0))
    self._pBossProtectBar:setPercentage(100)
    self._pBossProtectBar:setRotation(-90)
    self._pBossProtectBar:setPosition(cc.p( self._pBossProtectBG:getContentSize().width/2, self._pBossProtectBG:getContentSize().height/2))
    self._pBossProtectBG :addChild(self._pBossProtectBar)

    --boss破甲时候出现的图片
    self._pHasProtectImage = cc.Sprite:createWithSpriteFrameName("BossHpUi/zjm40.png")
    self._pHasProtectImage:setPosition(-self._pHasProtectImage:getContentSize().width/2+6,4 )
    pBossBarNode:addChild(self._pHasProtectImage,100)
    self._pHasProtectImage:setVisible(false)

    --buff
    self._pBossBuffIconsNode =require("BuffNode"):create()
    self._pBossBuffIconsNode:setPosition(cc.p(8,-32))
    pBossBarNode:addChild(self._pBossBuffIconsNode)


    if MonstersManager:getInstance()._pBoss then
        self._tBoss = MonstersManager:getInstance()._pBoss
    elseif RolesManager:getInstance()._pPvpPlayerRole then
        self._tBoss = RolesManager:getInstance()._pPvpPlayerRole
    end
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitBossHpNode()
        end
    end
    self:registerScriptHandler(onNodeEvent)
    return
end


--设置最大值
function BossHpNode:setBossHpMax(nMaxHp)
   self._nMaxHpNum = nMaxHp
end

--设置boss的名字
function BossHpNode:setBossName(name)
   self._pBossNameText:setString(name)
end

--设置当前boss血的条目数
function BossHpNode:setBossHpNum(bossHpNum)
    self._pBossNumHp = bossHpNum
     if  self._pBossHpNumText then 
         self._pBossHpNumText:setString("X"..bossHpNum)
         if bossHpNum == 1 then --如果血条是1条就不显示
            self._pBossHpNumText:setVisible(false)
         end
    end
end

--设置当前的boss血条数
function BossHpNode:setBossHpCur(bossHpCur)
    local tParent = self:getBossHpNumByCurHp(bossHpCur)
   if table.getn(tParent) > 0 then
        local pCount = table.getn(tParent)
        for k,v in pairs(tParent) do
            self._pBossNumHp = tParent[1][1]
            self:setBossHpNum(self._pBossNumHp)   
            for i = 1,table.getn(self._tBossHpBar) do
                if v[1] == i then 
                     -- Boss的血条集合
                     -- Boss的血条缓冲集合
                    self._tBossHpBar[i]:setPercentage(v[2])
                    print("第"..i.."进度条"..v[2])
                    self._tBossHpBarCache[i]:stopAllActions()
                     pCount = pCount - 1
                    self._tBossHpBarCache[i]:runAction(cc.Sequence:create( cc.DelayTime:create(0.1+0.4*pCount),cc.ProgressTo:create(0.3,v[2])))

                end
            end
        end
    end
end


-- 退出函数
function BossHpNode:onExitBossHpNode()
   ResPlistManager:getInstance():removeSpriteFrames("battle_boss_hp_ui.plist")
end

-- 循环更新
function BossHpNode:update(dt)
    if self._pBossBuffIconsNode then
       self._pBossBuffIconsNode:update(dt)
    end
    if  self._pBossProtectBar and self._tBoss then 
        self._pBossProtectBar:setPercentage((1-self._tBoss._nCurComboInterupt/self._tBoss._pRoleInfo.ComboInterupt)*100)

        if self._tBoss:getBuffControllerMachine():isBuffExist(kType.kController.kBuff.kBattleSunderArmorBuff) == true or self._tBoss._nCurHp == 0 then --如果破甲buff存在
            self._pBossProtectBG:setVisible(false)
            self._pHasProtectImage:setVisible(true)
        else --破甲buff不存在
             self._pBossProtectBG:setVisible(true)
             self._pHasProtectImage:setVisible(false)

        end
    end
    return
end

function BossHpNode:getBossHpNumByCurHp(bossHpCur)
    local tParent = {}
    local pCurHpNum = 0   --当前的血条数目
    local pHpBarNum = 0   --boss的血条总数
    if self._tBoss then 
      local pMaxHp =  self._tBoss._nHpMax
  
      if self._tBoss._kRoleType ==  kType.kRole.kMonster then --boss
         pHpBarNum = self._tBoss._pRoleInfo.HpBarNumber
         pCurHpNum = self._pBossNumHp

      elseif self._tBoss._kRoleType ==  kType.kRole.kPlayer then --pvp对手
         pHpBarNum = 1   --pvp的当前跟总数都是1
         pCurHpNum = 1
      end

      local pNum, pParent = math.modf(bossHpCur/(pMaxHp/pHpBarNum))
 
      for i = pNum + 1, pCurHpNum do
            if i == (pNum + 1) then
            table.insert(tParent,{i,pParent * 100})
        else
            table.insert(tParent,{i, 0})
        end
      end
    end
    return tParent
end

return BossHpNode
