--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  RoleDetailLeftPanel.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/10/23
--===================================================

local RoleDetailLeftPanel = class("RoleDetailLeftPanel",function()
    return cc.Layer:create()
end)

-- 构造函数
function RoleDetailLeftPanel:ctor()
    self._strName = "RoleDetailLeftPanel"            -- 层名称
    self._pHeadIcon = nil                            --人物头像
    self._pVipFnt = nil                              --vip等级
    self._pNameText = nil                            --人物名字
    self._pChangeNameBtn = nil                       --改名按钮
    self._pRoleLv = nil                              --人物等级
    self._pJobText = nil                             --职业
    self._pPowerFnt = nil                            --战斗力
    self._pExpBar = nil                              --进度条
    self._pCurAndMaxExp = nil                        --当前经验/总经验
    self._pCurTitleName = nil                        --当前称号
    self._pCurFamilyName = nil                       --当前工会名称
    self._pPvpNum = nil                              --pvp排名
    self._pGoldNum = nil                             --金币
    self._pYBNum = nil                               --玉璧
    self._pHonorNum = nil                            --荣誉值数量
    self._pPveTextNum = nil                          --pve点数量
    self._pFamilyHonorNum = nil                      --家族容易点数量
end

-- 创建函数
function RoleDetailLeftPanel:create()
    local layer = RoleDetailLeftPanel.new()
    layer:dispose()
    return layer
end

-- 处理函数
function RoleDetailLeftPanel:dispose()
    -- 注册网络回调事件
     NetRespManager:getInstance():addEventListener(kNetCmd.kUpdateFisance ,handler(self, self.updateFisance))
    -- 加载资源
    ResPlistManager:getInstance():addSpriteFrames("PlayerInfleft.plist")
    -- 加载dialog组件
    local params = require("PlayerInfleftParams"):create()
    self._pCCS = params._pCCS
    self._pHeadIcon = params._pHeadIcon                --人物头像
    self._pVipFnt = params._pVipFnt                    --vip等级
    self._pNameText = params._pNameText                --人物名字
    self._pChangeNameBtn = params._pReameButton        --改名按钮
    self._pRoleLv = params._pLvText                    --人物等级
    self._pJobText = params._pJobText                  --职业
    self._pPowerFnt = params._pPowerFnt                --战斗力
    self._pExpBar = params._pExpBar                    --进度条
    self._pCurAndMaxExp = params._pLvExpText           --当前经验/总经验
    self._pCurTitleName = params._pChText              --当前称号
    self._pCurFamilyName = params._pGhText             --当前工会名称
    self._pPvpNum = params._pJjText                    --pvp排名
    self._pGoldNum = params._pTqTextNum                --金币
    self._pYBNum = params._pYbTextNum                  --玉璧
    self._pHonorNum = params._pRyTextNum               --荣誉值数量
    self._pPveTextNum = params._pPveTextNum            --pve点数量
    self._pFamilyHonorNum = params._pJzRyTextNum       --家族容易点数量

    --刷新人物信息
    self:refreshRoleInfo()
    --刷新金钱
    self:updateFinaceNum()   

    
    local onTouchChangeRoleName = function(sender, eventType)
        if eventType == ccui.TouchEventType.ended then
           if DialogManager:getInstance():getDialogByName(RolesChangeNameDialog) == nil then 
              DialogManager:getInstance():showDialog("RolesChangeNameDialog",{kChangeNameType.kChangeRoleName})
           end
        elseif eventType == ccui.TouchEventType.began then
           AudioManager:getInstance():playEffect("ButtonClick") 
        end
    end

    --更改昵称 button
    self._pChangeNameBtn:addTouchEventListener(onTouchChangeRoleName)
    self._pChangeNameBtn:setZoomScale(nButtonZoomScale)
    self._pChangeNameBtn:setPressedActionEnabled(true)

    self:addChild(self._pCCS)
    ------------------- 结点事件------------------------
    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitRoleDetailLeftPanel()
        end
    end
    self:registerScriptHandler(onNodeEvent)
end


--刷新页面信息
function RoleDetailLeftPanel:refreshRoleInfo()
    local pRolrInfo = RolesManager:getInstance()._pMainRoleInfo
    local RoleIcons = {"headers/Header_zs.png" , "headers/Header_fs.png" , "headers/Header_ck.png"}
    self._tTempletetInfo = TableTempleteCareers[pRolrInfo.roleCareer]

    --人物头像
    self._pHeadIcon:loadTexture(RoleIcons[pRolrInfo.roleCareer],ccui.TextureResType.plistType)
    --vip等级
    self._pVipFnt:setString(pRolrInfo.vipInfo.vipLevel)
    --人物名字
    self._pNameText:setString(pRolrInfo.roleName)
    --人物等级
    self._pRoleLv:setString("等级:"..pRolrInfo.level)
    --职业
    self._pJobText:setString("职业:"..kRoleCareerTitle[pRolrInfo.roleCareer])
    --战斗力
    self._pPowerFnt:setString(pRolrInfo.roleAttrInfo.fightingPower)    
    --经验进度条
    if TableLevel[pRolrInfo.level].Exp == 0 then   --玩家满级
        self._pExpBar:setPercent(100)  --角色经验进度条 bar
        self._pCurAndMaxExp:setString("")                     --角色经验比例   label
    else
        local nPercent = TableLevel[pRolrInfo.level].Exp
        self._pExpBar:setPercent(pRolrInfo.exp/nPercent*100)  --角色经验进度条 bar
        self._pCurAndMaxExp:setString( pRolrInfo.exp.."/"..nPercent)                     --角色经验比例   label
    end
    --当前称号
    self._pCurTitleName:setString("无")
    --当前工会名称
    if FamilyManager:getInstance()._bOwnFamily == true then --有工会
       self._pCurFamilyName:setString(FamilyManager:getInstance()._pFamilyInfo.familyName)   
    else
       self._pCurFamilyName:setString("无")   
    end
    --pvp排名   
    self._pPvpNum:setString("第"..ArenaManager:getInstance()._nCurPvpRank.."名")     
end


--刷新金钱类物品
function RoleDetailLeftPanel:updateFinaceNum()
    --金币
    self._pGoldNum:setString(FinanceManager:getInstance():getValueByFinanceType(kFinance.kCoin))
    --玉璧
    self._pYBNum:setString(FinanceManager:getInstance():getValueByFinanceType(kFinance.kDiamond))             
    --荣誉值数量                  
    self._pHonorNum:setString(FinanceManager:getInstance():getValueByFinanceType(kFinance.kHR))     
    --pve点数量
    self._pPveTextNum:setString(FinanceManager:getInstance():getValueByFinanceType(kFinance.kSP))            
    --家族荣誉点数量             
    self._pFamilyHonorNum:setString(FinanceManager:getInstance():getValueByFinanceType(kFinance.kFC))                      
end

function RoleDetailLeftPanel:updateFisance(event)
    self:updateFinaceNum()
end

-- 退出函数
function RoleDetailLeftPanel:onExitRoleDetailLeftPanel()
    ResPlistManager:getInstance():removeSpriteFrames("PlayerInfleft.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end


-- 循环更新
function RoleDetailLeftPanel:update(dt)
    return
end

return RoleDetailLeftPanel
