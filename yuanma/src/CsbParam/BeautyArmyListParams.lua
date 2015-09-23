local BeautyArmyListParams = class("BeautyArmyListParams")
--右侧美人图镶嵌信息
function BeautyArmyListParams:ctor()
    self._pCCS = cc.CSLoader:createNode("BeautyArmyList.csb")
    --大底板
    self._pArmyBg = self._pCCS:getChildByName("ArmyBg")
    --阵型标题底板
    self._pTitleBg = self._pArmyBg:getChildByName("TitleBg")
    --阵型标题
    self._pDisecText = self._pTitleBg:getChildByName("DisecText")
    --查看按钮
    self._pHelpButton = self._pArmyBg:getChildByName("HelpButton")
    --阵型激活图标
    self._pActivatedImage = self._pCCS:getChildByName("ActivatedImage")
    --属性1文字
    self._pUpText01 = self._pCCS:getChildByName("UpText01")
    --属性2文字
    self._pUpText02 = self._pCCS:getChildByName("UpText02")
    --属性3文字
    self._pUpText03 = self._pCCS:getChildByName("UpText03")
    --美人图1挂点
    self._pBelleNode01 = self._pCCS:getChildByName("BelleNode01")
    --美人图2挂点
    self._pBelleNode02 = self._pCCS:getChildByName("BelleNode02")
    --美人图3挂点
    self._pBelleNode03 = self._pCCS:getChildByName("BelleNode03")
    --美人图4挂点
    self._pBelleNode04 = self._pCCS:getChildByName("BelleNode04")
    --美人图5挂点
    self._pBelleNode05 = self._pCCS:getChildByName("BelleNode05")
end

function BeautyArmyListParams:create()
    local params = BeautyArmyListParams.new()
    return params
end

return BeautyArmyListParams
