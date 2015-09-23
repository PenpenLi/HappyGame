--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  funcs.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   全局函数
--===================================================
-- 平台类型
nTtargetPlatform = cc.Application:getInstance():getTargetPlatform()

-- 判定是否为移动平台
function isMobilePlatform()
	if (cc.PLATFORM_OS_IPHONE == nTtargetPlatform) or (cc.PLATFORM_OS_IPAD == nTtargetPlatform) or (cc.PLATFORM_OS_ANDROID == nTtargetPlatform) then
	   return true
	else
	   return false
	end
end

-- 判定是否为ios平台
function isIOSMobilePlatform()
    if (cc.PLATFORM_OS_IPHONE == nTtargetPlatform) or (cc.PLATFORM_OS_IPAD == nTtargetPlatform) then
        return true
    else
        return false
    end
end

-- 判定是否为android平台
function isAndroidMobilePlatform()
    if (cc.PLATFORM_OS_ANDROID == nTtargetPlatform) then
        return true
    else
        return false
    end
end

-- 回收内存
function collectMems()
    for i = 1,10 do
        collectgarbage("collect")
    end
end

-- cclog
function cclog(...)
    if string.format(...) == "" then
        return
    end
    print(string.format(...))
    if bOpenScreenLog == true then
        local scene = LayerManager:getInstance()._pAppSence
        if scene and scene._pDebugInfoText then
            table.insert(scene._tDebugContent, (string.format(...)))
            if table.getn(scene._tDebugContent) > 28 then
                table.remove(scene._tDebugContent, 1)
            end
            local strContent = ""
            for k,v in pairs(scene._tDebugContent) do
                strContent = strContent.."\n"..v
            end
            scene._pDebugInfoText:setString(strContent)

            local clearContent = function()
                scene._tDebugContent = {}
            end
            scene._pDebugInfoText:stopAllActions()
            scene._pDebugInfoText:setOpacity(255)
            scene._pDebugInfoText:runAction(cc.Sequence:create(cc.DelayTime:create(10.0),cc.FadeOut:create(1.0),cc.CallFunc:create(clearContent)))
        end
    end

end

-- 字符串转换到 Lua的table
function StrToLua(str)
    local strLuaContext = "return "..str
    local funcTable = loadstring(strLuaContext)
    return funcTable()
end

-- 获取num1到num2之间的一个随机数
-- 参数1：区间开始点，区间结束点  闭区间
seedNum = 0
function getRandomNumBetween(num1,num2)
    seedNum = seedNum + 1357531
    math.randomseed(tostring(os.time()+seedNum):reverse():sub(1, 6))
    return (math.random(num1,num2))
end

-- 合并两个table
function joinWithTables(tableFront ,tableEnd)
    local tableResult = {}
    local index = 1

    if table.getn(tableFront) == 0 and table.getn(tableEnd) ~= 0 then
        return tableEnd
    end
    
    if table.getn(tableFront) ~= 0 and table.getn(tableEnd) == 0 then
        return tableFront
    end
    
    for i = 1,table.getn(tableFront) do
        table.insert(tableResult, tableFront[i])
	end
	
    for i = 1,table.getn(tableEnd) do
        table.insert(tableResult, tableEnd[i])
    end
    
    return tableResult
end

-- 浅复制一个表
function shallowcopy(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in pairs(orig) do
            copy[orig_key] = orig_value
        end
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

-- 网络回调时封装的闭包
function handler(obj, method)
    return {hostObj = obj , handle = method, doHandle = function(...)
    	method(obj,...)
    end}
end

--打印lua的table内容
function print_lua_table (lua_table, indent)
    if lua_table == nil or type(lua_table) ~= "table" then
        return
    end

    local function print_func(str)
        print("[Dongyuxxx] " .. tostring(str))
    end
    indent = indent or 0
    for k, v in pairs(lua_table) do
        if type(k) == "string" then
            k = string.format("%q", k)
        end
        local szSuffix = ""
        if type(v) == "table" then
            szSuffix = "{"
        end
        local szPrefix = string.rep("    ", indent)
        formatting = szPrefix.."["..k.."]".." = "..szSuffix
        if type(v) == "table" then
            print_func(formatting)
            print_lua_table(v, indent + 1)
            print_func(szPrefix.."},")
        else
            local szValue = ""
            if type(v) == "string" then
                szValue = string.format("%q", v)
            else
                szValue = tostring(v)
            end
            print_func(formatting..szValue..",")
        end
    end
end

-- 按照距离的2次幂从小到大排序的算法（为table.sort提供的排序算法）
function fromSmallToBigOnDistance2(a,b)
    return a.distance2 < b.distance2
end

-- 按照buff的ID号从小到大排序的算法（为table.sort提供的排序算法）
function fromSmallToBigOnBuffIDs(a,b)
    return a._nID < b._nID
end

-- 按照buff的ID号从大到小排序的算法（为table.sort提供的排序算法）
function fromBigToSmallOnBuffIDs(a,b)
    return a._nID > b._nID
end

-- 选择法排序（从小到大）
function select_sort(t)
    for i=1, #t - 1 do
        local min = i
        for j=i+1, #t do
            if t[j] < t[min]  then
                min = j
            end
        end
        if min ~= i then
            t[min], t[i] = t[i], t[min]
        end
    end
end

-- 获取最小值
function sortSmallest(t)
    for i=1, #t - 1 do
        local min = i
        for j=i+1, #t do
            if t[j] < t[min]  then
                min = j
            end
        end
        return t[min]
    end
end

-- 获取最大值
function sortBiggest(t)
    for i=1, #t - 1 do
        local max = i
        for j=i+1, #t do
            if t[j] > t[max]  then
                max = j
            end
        end
        return t[max]
    end
end

-- 显示alert（只有确定按钮）
function showAlertDialog(msg, okCallbackFunc)
    if okCallbackFunc then  -- 有回调处理
        local alert = require("AlertDialog"):create(msg, okCallbackFunc)
        alert:setNoCancelBtn()
        cc.Director:getInstance():getRunningScene():showDialog(alert,kZorder.kMax)
    else  -- 没有回调处理
        local alert = require("AlertDialog"):create(msg)
        alert:setNoCancelBtn()
        cc.Director:getInstance():getRunningScene():showDialog(alert,kZorder.kMax)
    end
end

-- 显示confirm（取消和确定按钮都有）
function showConfirmDialog(msg, okCallbackFunc)
    cc.Director:getInstance():getRunningScene():showDialog(require("AlertDialog"):create(msg, okCallbackFunc))
end

-- 显示系统提示字（悬浮文字，自动消失）
function showSystemMessage(msg)
    --cc.Director:getInstance():getRunningScene():ShowSystemMessage(msg)
    NoticeManager:getInstance():showSystemMessage(msg)
end

-- ItemInfo 获取数据表，模板表
function GetCompleteItemInfo(itemInfo,roleCareer)
    local _tDataTemple = {
        {itemType = kItemType.kEquip, dataTable = TableEquips, dataTableIdOffset = 100000, templeTable = TableTempleteEquips, templeTableIdOffset = 0 },
        {itemType = kItemType.kStone, dataTable = TableStones, dataTableIdOffset = 300000, templeTable = TableTempleteItems, templeTableIdOffset = 0 },
        {itemType = kItemType.kBox, dataTable = TableBoxAndCards, dataTableIdOffset = 400000, templeTable = TableTempleteItems, templeTableIdOffset = 0 },
        {itemType = kItemType.kFeed, dataTable = TableItems, dataTableIdOffset = 200000, templeTable = TableTempleteItems, templeTableIdOffset = 0 },
        {itemType = kItemType.kCounter, dataTable = TableItems, dataTableIdOffset = 200000, templeTable = TableTempleteItems, templeTableIdOffset = 0 },
        {itemType = kItemType.kCounter, dataTable = TableItems, dataTableIdOffset = 200000, templeTable = TableTempleteItems, templeTableIdOffset = 0 },
    }
    -- 数据项
    local dataModul = _tDataTemple[itemInfo.baseType]
    itemInfo.dataInfo = dataModul.dataTable[itemInfo.id - dataModul.dataTableIdOffset]
    
    -- 模板项
    local templeteID = nil
    if itemInfo.baseType ~= kItemType.kEquip then
        templeteID = itemInfo.dataInfo.TempleteID
        itemInfo.templeteInfo = dataModul.templeTable[templeteID - dataModul.templeTableIdOffset]
    else
        if RolesManager:getInstance()._pMainRoleInfo and roleCareer == nil then
            templeteID = itemInfo.dataInfo.TempleteID[RolesManager:getInstance()._pMainRoleInfo.roleCareer]
            itemInfo.templeteInfo = dataModul.templeTable[templeteID - dataModul.templeTableIdOffset]
        end
        if roleCareer ~= nil then
            templeteID = itemInfo.dataInfo.TempleteID[roleCareer]
            itemInfo.templeteInfo = dataModul.templeTable[templeteID - dataModul.templeTableIdOffset]
        end
    end
    
    return itemInfo
end

-- 通过下标和id查询物品信息 1为境界表  2为剑灵表
function GetCompleteItemInfoById(itemInfo,nTableIndex)
    if nTableIndex == 1 then        -- 境界表
        itemInfo.dataInfo = TableFairyLandDan[itemInfo.id]
    elseif nTableIndex == 2 then    -- 剑灵表
        itemInfo.dataInfo = TableIBladeSoul[itemInfo.id]
    end
    itemInfo.templeteInfo = TableTempleteItems[itemInfo.dataInfo.TempleteID]
    return itemInfo
end

function setNetErrorShow(erroID,msg)
    local tErrorInfo = TableNetError["e"..erroID]
    
    -- 如果返回错误码20000 重发确认链接协议
    if erroID == 20020 then
        if LoginManager:getInstance()._nRoleId ~= 0 then
            LoginCGMessage:sendMessageReconnect(LoginManager:getInstance()._nRoleId)
        end
    end
    
    if tErrorInfo then 
            if tErrorInfo["Type"] == 1 then --服务器错误码，只需要显示，不需要其他逻辑
                showAlertDialog(tErrorInfo["Desc"])
            elseif tErrorInfo["Type"] == 2 then --服务器错误码，需要弹框
            
            elseif tErrorInfo["Type"] == 3 then --只是文字提示
            --申请加入家族(特殊处理)
            if erroID == 20277 then 
                local nOurTime = gOneTimeToStr(msg)
                NoticeManager:getInstance():showSystemMessage("您还需要等待"..nOurTime.."才能再次加入家族") 
             else
                NoticeManager:getInstance():showSystemMessage(tErrorInfo["Desc"])
             end      
            end
            
        NetRespManager:getInstance():dispatchEvent(kNetCmd.kNetErrorInfo, {errorInfo  = tErrorInfo ,erroId = erroID})
     else
        showAlertDialog("服务器返回不知道的错误码")
     end
end

-- 获得属性的真实数据(属性名字：+ value)
function getStrAttributeRealValue(kAttributeType,attributeValue)

    local propName = kAttributeNameTypeTitle[kAttributeType]
    local sign = attributeValue >= 0 and "+" or "" 
    -- 向上取整
    local strValue = math.ceil(attributeValue)
    return propName..sign..strValue
end

-- 或的属性的真实值 ( +vaue)
function getStrNoTitleAttributeValue(kAttributeType,attributeValue)
    local sign = attributeValue >= 0 and "+" or ""   
    -- 向上取整
    local strValue  = math.ceil(attributeValue)
    return sign..strValue
end

--通过时间来获取加速需要的钻石数
function getConstDiamondByTime(nSecond)
    if nSecond == 0 then
		return 0
	end
    return math.ceil(TableConstants.BladeSoulFast1.Value*((nSecond/60)^TableConstants.BladeSoulFast2.Value))
end

-- 精灵颜色置灰
function redNode(node)
    local vertDefaultSource = "\n"..
        "attribute vec4 a_position; \n" ..
        "attribute vec2 a_texCoord; \n" ..
        "attribute vec4 a_color; \n"..                                                    
        "#ifdef GL_ES  \n"..
        "varying lowp vec4 v_fragmentColor;\n"..
        "varying mediump vec2 v_texCoord;\n"..
        "#else                      \n" ..
        "varying vec4 v_fragmentColor; \n" ..
        "varying vec2 v_texCoord;  \n"..
        "#endif    \n"..
        "void main() \n"..
        "{\n" ..
        "gl_Position = CC_PMatrix * a_position; \n"..
        "v_fragmentColor = a_color;\n"..
        "v_texCoord = a_texCoord;\n"..
        "}"

    --local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,pszFragSource)
    local fileUtiles = cc.FileUtils:getInstance()
    local vertSource = vertDefaultSource
    local fragSource = fileUtiles:getStringFromFile("res/shaders/redSprite.fsh")
    local pProgram = cc.GLProgram:createWithByteArrays(vertSource, fragSource)


    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:updateUniforms()
    node:setGLProgram(pProgram)
end

-- 精灵颜色置灰
function darkNode(node)
    local vertDefaultSource = "\n"..
        "attribute vec4 a_position; \n" ..
        "attribute vec2 a_texCoord; \n" ..
        "attribute vec4 a_color; \n"..                                                    
        "#ifdef GL_ES  \n"..
        "varying lowp vec4 v_fragmentColor;\n"..
        "varying mediump vec2 v_texCoord;\n"..
        "#else                      \n" ..
        "varying vec4 v_fragmentColor; \n" ..
        "varying vec2 v_texCoord;  \n"..
        "#endif    \n"..
        "void main() \n"..
        "{\n" ..
        "gl_Position = CC_PMatrix * a_position; \n"..
        "v_fragmentColor = a_color;\n"..
        "v_texCoord = a_texCoord;\n"..
        "}"

    --local pProgram = cc.GLProgram:createWithByteArrays(vertDefaultSource,pszFragSource)
    local fileUtiles = cc.FileUtils:getInstance()
    local vertSource = vertDefaultSource
    local fragSource = fileUtiles:getStringFromFile("res/shaders/greySprite.fsh")
    local pProgram = cc.GLProgram:createWithByteArrays(vertSource, fragSource)


    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_POSITION,cc.VERTEX_ATTRIB_POSITION)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_COLOR,cc.VERTEX_ATTRIB_COLOR)
    pProgram:bindAttribLocation(cc.ATTRIBUTE_NAME_TEX_COORD,cc.VERTEX_ATTRIB_FLAG_TEX_COORDS)
    pProgram:link()
    pProgram:updateUniforms()
    node:setGLProgram(pProgram)
end

-- 精灵颜色恢复正常
function unDarkNode(node)
    local pProgram = cc.GLProgramCache:getInstance():getGLProgram("ShaderPositionTextureColor_noMVP")
    node:setGLProgram(pProgram)
end

function gTimeToStr(fTime)
    local strDes = ""
    local nNewTime = fTime + 0.99
    local nNum = fTime%3600
    
    if math.modf(fTime/3600/24) ~= 0 then
        strDes = strDes..mmo.HelpFunc:gNumToStr(fTime/3600/24).."天 "  -- 天
        if math.modf(fTime/3600%24) ~= 0 then
            strDes = strDes.. mmo.HelpFunc:gNumToStr(fTime/3600%24).."时"  -- 小时
        end
    elseif math.modf(fTime/3600) ~= 0 then
        strDes = strDes..mmo.HelpFunc:gNumToStr(fTime/3600).."时 "             -- 小时
        if math.modf(nNum/60) ~= 0 then
            strDes = strDes.. mmo.HelpFunc:gNumToStr(nNum/60).."分"          -- 分钟
        end
        if math.modf(fTime%60) ~= 0 then
            strDes = strDes..mmo.HelpFunc:gNumToStr(nNum%60).."秒"           --秒
        end
    elseif math.modf(nNum/60) ~= 0 then  --从分钟记起
        strDes = strDes.. mmo.HelpFunc:gNumToStr(nNum/60).."分 "               -- 分钟
        if math.modf(nNum%60) ~= 0 then
            strDes = strDes..mmo.HelpFunc:gNumToStr(nNum%60).."秒"  -- 秒
        end
    elseif math.modf(nNum%60) ~= 0 then  --从秒记起
        strDes = strDes..mmo.HelpFunc:gNumToStr(nNum%60).."秒";  -- 秒
    elseif fTime  == 0 then
        strDes = "0秒";
    elseif fTime ~= 0 then
        strDes = "1秒"
    end
    return strDes;
end

--得到时间（只有一个单位xx天，xx时，xx分）
function gOneTimeToStr(fTime)
    local strDes = ""
    local nNewTime = fTime + 0.99
    local nNum = fTime%3600

    if math.modf(fTime/3600/24) ~= 0 then
        strDes = strDes..mmo.HelpFunc:gNumToStr(fTime/3600/24).."天"  -- 天
        
    elseif math.modf(fTime/3600) ~= 0 then
        strDes = strDes..mmo.HelpFunc:gNumToStr(fTime/3600).."小时"             -- 小时
       
    elseif math.modf(nNum/60) ~= 0 then  --从分钟记起
        strDes = strDes.. mmo.HelpFunc:gNumToStr(nNum/60).."分钟"               -- 分钟
    elseif math.modf(nNum%60) ~= 0 then  --从秒记起
        strDes = "1分钟"
    elseif fTime  == 0 then
        strDes =  "1分钟"
    elseif fTime ~= 0 then
        strDes =  "1分钟"
    end
    return strDes;
end

--得到宝箱的信息，通过本地表中的数据
function getBoxInfo(tDate)
	local tAllViewDate = {}
    if tDate == nil or table.getn(tDate) == 0 then
        return
    end

    for k,v in pairs(tDate) do
        local tTempDate = {}
        if tDate[k][1] >kFinance.kNone and tDate[k][1] <=kFinance.kFC then 
            tTempDate = FinanceManager:getInstance():getIconByFinanceType(tDate[k][1])
            tTempDate.amount = tDate[k][2]
            tTempDate.id = tDate[k][1]
            tTempDate.finance = true   --标示物品还是金钱的字段
        else --物品
            tTempDate = {id = tDate[k][1], baseType = tDate[k][3], value = tDate[k][2], finance = false }
            GetCompleteItemInfo(tTempDate)

        end
        table.insert(tAllViewDate,tTempDate)
    end

	return tAllViewDate
end

--获取跑马灯的node
function getMarqueeNode(tDate)
    local pNode = cc.Node:create()

    local pIndex = 1 --引用基数
    local pMarqueeInfo = clone(TableMarqueeMessge[tDate.mtp].Desc)

    for k,v in pairs(pMarqueeInfo) do
        if v.text == nil then --标示要用服务器的代码
            if tDate.args[pIndex] == nil then
        	  tDate.args[pIndex] = ""
            end
            v.text = tDate.args[pIndex]
            pIndex = pIndex + 1
        end
        if v.color == nil then --标示用默认颜色(白色)
            v.color = cWhite
        end
        if v.size == nil then --表示用默认的字体大小
            v.size = 22
        end

    end

    --创建lable
    local nStartX = 0
    local ndistance = 2
    for k,v in pairs(pMarqueeInfo) do
        local pLable = cc.Label:createWithTTF(v.text, strCommonFontName, v.size)
        pLable:setAnchorPoint(cc.p(0,0.5))
        pLable:setPosition(cc.p(nStartX,0))
        pLable:setColor(v.color)
        pNode:addChild(pLable)
        nStartX = nStartX +pLable:getContentSize().width+ndistance

    end

    return pNode,nStartX
end


--- 获取utf8编码字符串正确长度的方法
function utfstrlen(str)
    local len = #str
    local left = len
    local cnt = 0
    local arr={0,0xc0,0xe0,0xf0,0xf8,0xfc}
    while left ~= 0 do
        local tmp=string.byte(str,-left)
        local i=#arr
        while arr[i] do
            if tmp>=arr[i] then left=left-i;break;end
            i=i-1
        end
        cnt=cnt+1
    end
    return cnt
end

-- 时间戳转换为字符串(2015-07-14)
function timeStampConvertToString(timeStamp)
    --local date_string = string.format(os.date("%x",timeStamp))
    local date_table = os.date("*t",timeStamp)
    return (date_table.year.."-"..date_table.month.."-"..date_table.day)  
end

--判断是否有emoji表情
function strIsHaveMoji(str)
    local pLen = #str
    for i=1,pLen do
        local pcode = string.byte(str,i)
        if pcode == 240 then
            return true,i
        end
    end

    return false
end

--emoj表情替换成□
function unicodeToUtf8(str)
    local pStr = ""
    local pFunc
    pFunc = function(pString)
        local pLen = string.len(pString)
        for i=1,pLen do
            local pcode = string.byte(pString,i)
           -- cclog("def:"..pcode)
            if (pcode == 240 and string.byte(pString,i+1) ==159)then
                if i==1 then
                    pStr = pStr.."□"
                else
                    pStr = pStr..string.sub(pString,1,i-1).."□"
                end

                str = string.sub(pString,i+4,pLen)
                pFunc(str)
                break
            end
        end
    end
    pFunc(str)
    return  pStr..str
end

--得到一个editBox
function createEditBoxBySize(nViewSize,nMaxLength,nOpacity,sDefString)
    local pEditBox = nil
    local editBoxTextEventHandle = function(strEventName,pSender)
        local edit = pSender
        local strFmt 
        if strEventName == "began" then
            --release_print("1")
        elseif strEventName == "ended" then
            --release_print("2")
        elseif strEventName == "return" then
           -- release_print("3")
        elseif strEventName == "changed" then
            --release_print("editBox changed")
            local pText = pEditBox:getText()
            local pString = unicodeToUtf8(pText)
            --cclog("inputS:"..pString)
            pEditBox:setText(pString)
        end
    end
    if nOpacity == nil then
       nOpacity = 255
    end

  
    pEditBox = ccui.EditBox:create(nViewSize, "ccsComRes/sprite9.png",ccui.TextureResType.plistType)
    pEditBox:setFontName("simhei.ttf")
    pEditBox:setOpacity(nOpacity)
    pEditBox:setFontSize(25)
    pEditBox:setFontColor(cc.c3b(255,255,255))
    pEditBox:setMaxLength(nMaxLength)
    pEditBox:setReturnType(cc.KEYBOARD_RETURNTYPE_DONE )
    pEditBox:setInputMode(cc.EDITBOX_INPUT_MODE_ANY )
    if sDefString then 
       pEditBox:setPlaceHolder(sDefString)
       pEditBox:setPlaceholderFontColor(cc.c3b(255,255,255))

    end

    --Handler
    pEditBox:registerScriptEditBoxHandler(editBoxTextEventHandle)

    return pEditBox
end
