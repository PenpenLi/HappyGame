--竞技界面
local PvpRenderParams = class("PvpRenderParams")

function PvpRenderParams:ctor()
    self._pCCS = cc.CSLoader:createNode("PvpRender.csb")
    --滚动框中对手信息底板
    self._pRakingBg = self._pCCS:getChildByName("RakingBg")
    --角色头像底框
    self._pHeadIconBg = self._pRakingBg:getChildByName("HeadIconBg")
    --角色头像
    self._pHeadIcon = self._pHeadIconBg:getChildByName("HeadIcon")
    --对手等级文字
    self._pOverPLvText = self._pRakingBg:getChildByName("OverPLvText")
    --对手昵称
    self._pOverPaiHangName = self._pRakingBg:getChildByName("OverPaiHangName")
    --排行文字
    self._pOverPaiHangText = self._pRakingBg:getChildByName("OverPaiHangText")
    --具体排行
    self._pOverPaiHangNum = self._pRakingBg:getChildByName("OverPaiHangNum")
    --战斗力艺术字
    self._pOverPowerFnt = self._pRakingBg:getChildByName("OverPowerFnt")
    --奖励滚动框
    self._pGiftScrollView = self._pRakingBg:getChildByName("GiftScrollView")
    -- 奖励物品的节点
    self._pItemNode = self._pGiftScrollView:getChildByName("itemNode") 
    --奖励图标1
    self._pGiftIcon1 = self._pItemNode:getChildByName("GiftIcon1")
    --奖励数值1
    self._pGift1Num = self._pItemNode:getChildByName("Gift1Num")
    --挑战按钮
    self._pPvpButton = self._pRakingBg:getChildByName("PvpButton")
end

function PvpRenderParams:create()
    local params = PvpRenderParams.new()
    return params
end

return PvpRenderParams
