--游戏的开始界面
local StartGamePanelParams = class("StartGamePanelParams")

function StartGamePanelParams:ctor()
    self._pCCS = cc.CSLoader:createNode("StartGamePanel.csb")

	-- 当前服务器说明栏
    self._pSeverInfPoint = self._pCCS:getChildByName("SeverInfPoint")
    --背景图
    self._pSeverInfBg = self._pSeverInfPoint:getChildByName("SeverInfBg")
    --服务器状态
    self._pStateSeverText = self._pSeverInfBg:getChildByName("StateSeverText")
    --服务器名称
    self._pSeverNameText = self._pSeverInfBg:getChildByName("ServerNameText")
    --切换服务器按钮
    self._pChangeServerButton = self._pSeverInfBg:getChildByName("ChangeServerButton")
    --进入游戏
    self._pGameStartPoint = self._pCCS:getChildByName("GameStartPoint")
    self._pGameStartButton = self._pGameStartPoint:getChildByName("GameStartButton")
    --版本号
    self._pVersionPoint = self._pCCS:getChildByName("VersionPoint")
    self._pVersionText = self._pVersionPoint:getChildByName("VersionText")
    --登入账号
    self._pAccountPutInPoint = self._pCCS:getChildByName("AccountPutInPoint")
    --输入框背景图
    self._pAccountBg = self._pAccountPutInPoint:getChildByName("AccountBg")
    --debug输入文字区
    self._pAccountText = self._pAccountBg:getChildByName("AccountText")
    --debug登入按钮
    self._pEnterButton = self._pAccountPutInPoint:getChildByName("EnterButton")
    --设置按钮节点
    self._pSetSystemNode = self._pCCS:getChildByName("SetSystemNode")
    --设置按钮
    self._pSetButton = self._pSetSystemNode:getChildByName("SetButton")
    --渠道相关按钮节点
    self._pChannelNode = self._pCCS:getChildByName("ChannelNode")
    --用户中心按钮
    self._pUserCenterButton = self._pChannelNode:getChildByName("UserCenterButton")
    --切换账户按钮
    self._pChangeAccountButton = self._pChannelNode:getChildByName("ChangeAccountButton")
    --退出游戏按钮
    self._pQuitButton = self._pChannelNode:getChildByName("QuitButton")
    
    
end

function StartGamePanelParams:create()
    local params = StartGamePanelParams.new()
    return params  
end

return StartGamePanelParams
