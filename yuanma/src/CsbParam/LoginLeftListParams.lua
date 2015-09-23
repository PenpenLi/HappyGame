local LoginLeftListParams = class("LoginLeftListParams")
--创建家族界面左侧列表信息
function LoginLeftListParams:ctor()
    self._pCCS = cc.CSLoader:createNode("LoginLeftList.csb")
    --大底板
    self._pListBg = self._pCCS:getChildByName("ListBg")
    --编号
    self._pText_1 = self._pListBg:getChildByName("Text_1")
    --家族名称
    self._pText_2 = self._pListBg:getChildByName("Text_2")
    --家族等级
    self._pText_3 = self._pListBg:getChildByName("Text_3")
    --家族人数
    self._pText_4 = self._pListBg:getChildByName("Text_4")
    --族长昵称
    self._pText_6 = self._pListBg:getChildByName("Text_6")
    --已申请标签
    self._pApplication = self._pListBg:getChildByName("Application")

end
function LoginLeftListParams:create()
    local params = LoginLeftListParams.new()
    return params
end

return LoginLeftListParams
