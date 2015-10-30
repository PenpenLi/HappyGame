--角色属性面板
local PlayerInfleftParams = class("PlayerInfleftParams")

function PlayerInfleftParams:ctor()
    self._pCCS = cc.CSLoader:createNode("PlayerInfleft.csb")
	-- 底板
    self._pInfFrameleftPoint = self._pCCS:getChildByName("InfFrameleftPoint")
    self._pInfBg = self._pInfFrameleftPoint:getChildByName("InfBg")
    --左侧信息底板
    self._pInfBg_Left = self._pInfFrameleftPoint:getChildByName("InfBg_Left")
    --角色头像icon
    self._pHeadIcon = self._pInfBg_Left:getChildByName("HeadIcon")
    --角色vip等级文字
    self._pVipFnt = self._pInfBg_Left:getChildByName("VipFnt")
    --角色名称文字
    self._pNameText = self._pInfBg_Left:getChildByName("NameText")
    --修改名称按钮
    self._pReameButton = self._pInfBg_Left:getChildByName("ReameButton")
    --角色等级
    self._pLvText = self._pInfBg_Left:getChildByName("LvText")
    --角色职业
    self._pJobText = self._pInfBg_Left:getChildByName("JobText")
    --角色战斗力值
    self._pPowerFnt = self._pInfBg_Left:getChildByName("PowerFnt")
    --角色经验条
    self._pExpBar = self._pInfBg_Left:getChildByName("ExpBar")
    --角色当前经验/升级经验
    self._pLvExpText = self._pInfBg_Left:getChildByName("LvExpText")
    --角色当前称号
    self._pChText = self._pInfBg_Left:getChildByName("Text_Title")
    --工会名称
    self._pGhText = self._pInfBg_Left:getChildByName("Text_Family")
    --竞技排名
    self._pJjText = self._pInfBg_Left:getChildByName("Text_Jingj")
    --金币数量
    self._pTqTextNum= self._pInfBg_Left:getChildByName("TqTextNum")
    --玉璧数量
    self._pYbTextNum = self._pInfBg_Left:getChildByName("YbTextNum")
    --荣誉值数量
    self._pRyTextNum = self._pInfBg_Left:getChildByName("RyTextNum")
    --pve点数量
    self._pPveTextNum = self._pInfBg_Left:getChildByName("PveTextNum")
    --家族荣誉数量
    self._pJzRyTextNum = self._pInfBg_Left:getChildByName("JzRyTextNum")

end

function PlayerInfleftParams:create()
    local params = PlayerInfleftParams.new()
    return params  
end

return PlayerInfleftParams