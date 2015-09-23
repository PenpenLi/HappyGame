local CyListParams = class("CyListParams")
--成员申请列表信息
function CyListParams:ctor()
    self._pCCS = cc.CSLoader:createNode("CyList.csb")
    --大底板
    self._pListBg = self._pCCS:getChildByName("ListBg")
   -- 编号
   self._pText_1 = self._pListBg:getChildByName("Text_1")
   --昵称
   self._pText_2 = self._pListBg:getChildByName("Text_2")
   --等级
   self._pText_3 = self._pListBg:getChildByName("Text_3")
   --职业
   self._pText_4 = self._pListBg:getChildByName("Text_4")
   --战斗力
   self._pText_5 = self._pListBg:getChildByName("Text_5")
   --在线状态
   self._pText_6 = self._pListBg:getChildByName("Text_6")
   --通过按钮
   self._pButton_1 = self._pListBg:getChildByName("Button_1")
   --拒绝按钮
   self._pButton_2 = self._pListBg:getChildByName("Button_2")
end
function CyListParams:create()
    local params = CyListParams.new()
    return params
end

return CyListParams
