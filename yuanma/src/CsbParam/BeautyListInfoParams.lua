local BeautyListInfoParams = class("BeautyListInfoParams")
--群芳阁左侧美人列表
function BeautyListInfoParams:ctor()
    self._pCCS = cc.CSLoader:createNode("BeautyListInfo.csb")
    --大底板
    self._pListBg = self._pCCS:getChildByName("ListBg")
    --头像底板
    self._pBelleIcon01Bg = self._pListBg:getChildByName("BelleIcon01Bg")
    --头像
    self._pBelleIcon01 = self._pListBg:getChildByName("BelleIcon01")
    --美人数量
    self._pGetNumText = self._pListBg:getChildByName("GetNumText")
    --美人名称
    self._pGetNameText = self._pListBg:getChildByName("GetNameText")
    --心图标1
    self._pQinM01 = self._pListBg:getChildByName("QinM01")
    self._pQinM02 = self._pListBg:getChildByName("QinM02")
    self._pQinM03 = self._pListBg:getChildByName("QinM03")
    self._pQinM04 = self._pListBg:getChildByName("QinM04")
    self._pQinM05 = self._pListBg:getChildByName("QinM05")
end
function BeautyListInfoParams:create()
    local params = BeautyListInfoParams.new()
    return params
end

return BeautyListInfoParams
