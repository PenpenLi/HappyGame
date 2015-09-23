local GlListParams = class("GlListParams")
--成员管理列表信息
function GlListParams:ctor()
    self._pCCS = cc.CSLoader:createNode("GlList.csb")
    --大底板
    self._pListBg = self._pCCS:getChildByName("ListBg")
   --排名
   self._pText_1 = self._pListBg:getChildByName("Text_1")
   --昵称
   self._pText_2 = self._pListBg:getChildByName("Text_2")
   --等级
   self._pText_3 = self._pListBg:getChildByName("Text_3")
   --职业
   self._pText_4 = self._pListBg:getChildByName("Text_4")
   --历史贡献
   self._pText_5 = self._pListBg:getChildByName("Text_5")
   --本周贡献
   self._pText_6 = self._pListBg:getChildByName("Text_6")
   --职位
   self._pText_7 = self._pListBg:getChildByName("Text_7")
   --战斗力
   self._pText_8 = self._pListBg:getChildByName("Text_8")
   --在线状态
   self._pText_9 = self._pListBg:getChildByName("Text_9")
end
function GlListParams:create()
    local params = GlListParams.new()
    return params
end

return GlListParams
