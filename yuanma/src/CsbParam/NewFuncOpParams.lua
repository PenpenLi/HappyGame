--新功能开启提示
local NewFuncOpParams = class("NewFuncOpParams")

function NewFuncOpParams:ctor()
    self._pCCS = cc.CSLoader:createNode("NewFuncOp.csb")
	--挂点
    self._pNodeNewFunc = self._pCCS:getChildByName("NodeNewFunc")
	--图标底板
	--self._pIconBg = self._pNodeNewFunc:getChildByName("IconBg")
	--图标
    --self._pIcon = self._pNodeNewFunc:getChildByName("Icon")
    --提示文字
    self._pFuncText = self._pNodeNewFunc:getChildByName("FuncText")
end

function NewFuncOpParams:create()
    local params = NewFuncOpParams.new()
    return params  
end

return NewFuncOpParams
