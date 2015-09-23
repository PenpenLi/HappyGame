--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  FamilyDialog.lua
-- author:    yuanjiashun
-- e-mail:    870428198@qq.com
-- created:   2015/7/14
-- descrip:   家族dialog的管理界面
--===================================================
local FamilyDialog = class("FamilyDialog",function()
    return require("Dialog"):create()
end)

-- 构造函数
function FamilyDialog:ctor()
    self._strName = "FamilyDialog"        -- 层名称
    self._pBg = nil
    self._pCloseButton = nil
    self._tTabBtn = nil                  --tabButton
    self._tmountNode = nil               --没个panel的挂载node
    self._pAllFamilyPanel = {}
    self._pOurFamilyInfoPanel = nil       -- 家族信息界面
    self._pFamilyApplicantPanel = nil     -- 家族申请界面
    self._pFamilyMemberPanel = nil        -- 家族成员管理
    self.FamilyTechPanel = nil            -- 家族科技
    self._pFamilyLogPanel = nil           -- 家族动态管理
end

-- 创建函数
function FamilyDialog:create(args)
    local dialog = FamilyDialog.new()
    dialog:dispose(args)
    return dialog
end

-- 处理函数
function FamilyDialog:dispose(args)
    NetRespManager:dispatchEvent(kNetCmd.kFuncWarning,{Desc = "家族按钮" , value = false}) 
    
    ResPlistManager:getInstance():addSpriteFrames("FamilyDialog.plist")
    --服务器主动推的家族变化信息
    NetRespManager:getInstance():addEventListener(kNetCmd.kEnteryFamilyResp ,handler(self, self.enteryFamilyResp))
    local params = require("FamilyDialogParams"):create()
    self._pCCS = params._pCCS
    self._pBg = params._pBackGround
    self._pCloseButton = params._pCloseButton
    self._tTabBtn = {params._pButton_1,params._pButton_2,params._pButton_3,params._pButton_4,params._pButton_5}
    self._tMountNode = params._pNode
   
    -- 初始化dialog的基础组件
    self:disposeCSB()
    --初始化触摸机制
    self:initTouches()
    --初始化点击tab
    self:initTabTouch()
    --家族dilog家族的界面
    self:initFamilyAllPanel()
    --设置家族界面的数据
   self:setFamilyPalelDate()
    --跳转到某个界面
    self:jumpFamilyPalelByType(kFamilyType.kFamilyInfo)
    

    local function onNodeEvent(event)
        if event == "exit" then
            self:onExitFamilyDialog()
        end
    end
    self:registerScriptHandler(onNodeEvent)

    return

end

-- 初始化触摸机制
function FamilyDialog:initTouches()
    -- 触摸注册
    local function onTouchBegin(touch,event)
        local location = touch:getLocation()
        print("touch begin ".."x="..location.x.."  y="..location.y)
        if cc.rectContainsPoint(self._recBg,location) == false and self._bShowOver == true then
            self:close()
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

end

--tab点击
 function FamilyDialog:initTabTouch()
 
  local onTouchBtn = function (sender, eventType)
        if eventType == ccui.TouchEventType.ended then
           local nTag = sender:getTag()
             if self:hasClickBtnByTag(nTag) then --如果你 有权限点击某个btn
                self:jumpFamilyPalelByType(nTag)	
             end
           
           
        end
  end
  
 for k,v in pairs(self._tTabBtn) do
    v:setTag(k)
    v:addTouchEventListener(onTouchBtn)
 end
end
--家族dilog家族的界面
function FamilyDialog:initFamilyAllPanel()

    local pPos = cc.p(0,0)
    
    --家族信息界面
    self._pOurFamilyInfoPanel = require("OurFamilyInfoPanel"):create()
    self._pOurFamilyInfoPanel:setPosition(pPos)
    self._tMountNode:addChild(self._pOurFamilyInfoPanel)
    table.insert(self._pAllFamilyPanel,self._pOurFamilyInfoPanel)
    
    --家族管理
    self._pFamilyMemberPanel = require("FamilyMemberPanel"):create()
    self._pFamilyMemberPanel:setPosition(pPos)
    self._tMountNode:addChild(self._pFamilyMemberPanel)
    table.insert(self._pAllFamilyPanel,self._pFamilyMemberPanel)
    
    --家族科技
    self.FamilyTechPanel = require("FamilyTechPanel"):create()
    self.FamilyTechPanel:setPosition(pPos)
    self._tMountNode:addChild(self.FamilyTechPanel)
    table.insert(self._pAllFamilyPanel,self.FamilyTechPanel)
    --家族申请                                                                               FamilyApplicatPanel
    self._pFamilyApplicantPanel = require("FamilyApplicantPanel"):create()
    self._pFamilyApplicantPanel:setPosition(pPos)
    self._tMountNode:addChild(self._pFamilyApplicantPanel)
    self._pAllFamilyPanel[kFamilyType.kFamilyApplyFor] = self._pFamilyApplicantPanel
    --家族动态
    
    self._pFamilyLogPanel = require("FamilyLogPanel"):create()
    self._pFamilyLogPanel:setPosition(pPos)
    self._tMountNode:addChild(self._pFamilyLogPanel)
    table.insert(self._pAllFamilyPanel,self._pFamilyLogPanel)
    

end

--设置家族界面的数据
function FamilyDialog:setFamilyPalelDate()


end

--跳转到某个界面
function FamilyDialog:jumpFamilyPalelByType(nType)
    --先设置某个界面的状态
    self:setFamilyPalelState(nType)
    --更新tab Btn的图片状态
    self:updateTabBtnByTag(nType)
    --清空各个界面的中间数据（暂定方法 必须实现）
     --self._pAllFamilyPanel[nType]:clearPanelDateInfo()
    --请求某个界面的数据
    self:setFamilyPalelDateByType(nType)
end

--设置每个界面的显示或者隐藏通过type
function FamilyDialog:setFamilyPalelState(nType)
    for k,v in pairs(self._pAllFamilyPanel) do
        v:setVisible(false)
	end
    if self._pAllFamilyPanel[nType] then
        self._pAllFamilyPanel[nType]:setVisible(true)
    end
end

--请求某个界面的数据
function FamilyDialog:setFamilyPalelDateByType(nType)
    if nType == kFamilyType.kFamilyInfo then          --家族信息
        local pId = FamilyManager:getInstance()._pFamilyInfo.familyId
        FamilyCGMessage:FindFamilyByIdReq22340(pId)
    elseif nType == kFamilyType.kFamilyManage then    --家族管理
        FamilyCGMessage:queryFamilyMemberReq22322()
    elseif nType == kFamilyType.kFamilyScience then   --家族科技
        FamilyCGMessage:querFamilyAcademyReq22332()
    
    elseif nType == kFamilyType.kFamilyApplyFor then  --家族申请
        FamilyCGMessage:queryFamilyApplysReq22318()
    elseif nType == kFamilyType.kFamilyDynamic then   --家族动态
        FamilyCGMessage:querFamilyNewsReq22330()
    end
end

--切换tab是图
function FamilyDialog:updateTabBtnByTag(nTag)
    local pTexture1 = {"FamilyDialogRes/jzjm10.png","FamilyDialogRes/jzjm8.png","FamilyDialogRes/jzjm6.png","FamilyDialogRes/jzjm4.png","FamilyDialogRes/jzjm2.png"}
    local pTexture2 = {"FamilyDialogRes/jzjm9.png","FamilyDialogRes/jzjm7.png","FamilyDialogRes/jzjm5.png","FamilyDialogRes/jzjm3.png","FamilyDialogRes/jzjm1.png"}

    for k,v in pairs(self._tTabBtn) do
        v:loadTextures(pTexture1[k],pTexture2[k],nil,ccui.TextureResType.plistType)
    end
    self._tTabBtn[nTag]:loadTextures(pTexture2[nTag],pTexture2[nTag],nil,ccui.TextureResType.plistType)
end

--是否可以点击某个btn(申请界面如果权限不够，点击无效)
function FamilyDialog:hasClickBtnByTag(nTag)
local pPos = FamilyManager:getInstance()._position

return true
end

--
function FamilyDialog:enteryFamilyResp(event)
 if FamilyManager:getInstance()._bOwnFamily == false then --如果当前被T出家族
 	DialogManager:getInstance():closeAllDialogs()
    NoticeManager:getInstance():showSystemMessage("您已经被族长踢出家族")
 end
	
end


-- 退出函数
function FamilyDialog:onExitFamilyDialog()
    self:onExitDialog()
    ResPlistManager:getInstance():removeSpriteFrames("FamilyDialog.plist")
    NetRespManager:getInstance():removeEventListenersByHost(self)
end

-- 循环更新
function FamilyDialog:update(dt)
    return
end

-- 显示结束时的回调
function FamilyDialog:doWhenShowOver()
    return
end

-- 关闭结束时的回调
function FamilyDialog:doWhenCloseOver()
    return
end

return FamilyDialog
