
--------------------------------
-- @module HelpFunc
-- @parent_module mmo

--------------------------------
-- 
-- @function [parent=#HelpFunc] gTimeToFrames 
-- @param self
-- @param #double time
-- @return int#int ret (return value: int)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] setZoneId 
-- @param self
-- @param #string zoneId
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] switchAccountZTGame 
-- @param self
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] setIsPlayingVideo 
-- @param self
-- @param #bool playing
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] isHasQuitDialog 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] setLongRecordTime 
-- @param self
-- @param #int time
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] removeWaveEffectByShader 
-- @param self
-- @param #cc.Sprite3D sprite
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] cancelVibrate 
-- @param self
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] roleLevelUpZTGame 
-- @param self
-- @param #string roleId
-- @param #string roleName
-- @param #string zoneId
-- @param #string zoneName
-- @param #int level
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] getSystemSTime 
-- @param self
-- @return long long#long long ret (return value: long long)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] setShortRecordTime 
-- @param self
-- @param #int time
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] playVibrator 
-- @param self
-- @param #int time
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] quitZTGame 
-- @param self
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] gFramesToTime 
-- @param self
-- @param #int frames
-- @return double#double ret (return value: double)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] getSystemMTime 
-- @param self
-- @return long long#long long ret (return value: long long)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] gAngleAnalyseForRotation 
-- @param self
-- @param #float startX
-- @param #float startY
-- @param #float endX
-- @param #float endY
-- @return float#float ret (return value: float)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] isSocketConnect 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] vibrateWithPattern 
-- @param self
-- @param #array_table pattern
-- @param #int repeat
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] setVibratorEnabled 
-- @param self
-- @param #bool enable
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] isHasCenterZTGame 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] playVoice 
-- @param self
-- @param #string id
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] setNeedToRestartVideo 
-- @param self
-- @param #bool need
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] removeAllTimelineActions 
-- @param self
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] onRegister 
-- @param self
-- @param #string account
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] isPlayingVideo 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] loginZTGame 
-- @param self
-- @param #string zoneId
-- @param #string zoneName
-- @param #bool isAutoLogin
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] bitAnd 
-- @param self
-- @param #int p1
-- @param #int p2
-- @return int#int ret (return value: int)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] setUserIDForBugly 
-- @param self
-- @param #string userID
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] addWaveEffectByShader 
-- @param self
-- @param #cc.Sprite3D sprite
-- @param #string sprite3DPvrName
-- @param #string effectPvrName
-- @param #vec4_table color
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] gXorCoding 
-- @param self
-- @param #string str
-- @return string#string ret (return value: string)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] gGetMinuteStr 
-- @param self
-- @param #float fTime
-- @return string#string ret (return value: string)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] print 
-- @param self
-- @param #string str
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] showWaveEffectByShader 
-- @param self
-- @param #cc.Sprite3D sprite
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] pressRecordVoice 
-- @param self
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] gNumToStr 
-- @param self
-- @param #int nNum
-- @return string#string ret (return value: string)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] getRefCount 
-- @param self
-- @param #cc.Ref ref
-- @return int#int ret (return value: int)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] getCollidingDirections 
-- @param self
-- @param #rect_table rect1
-- @param #rect_table rect2
-- @return int#int ret (return value: int)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] enterCenterZTGame 
-- @param self
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] gCreateFileWithContent 
-- @param self
-- @param #string fileName
-- @param #string content
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] gGetRandNumber 
-- @param self
-- @param #int nRange
-- @return int#int ret (return value: int)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] getPlatform 
-- @param self
-- @return int#int ret (return value: int)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] gTimeToStr 
-- @param self
-- @param #float fTime
-- @return string#string ret (return value: string)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] gShowRectLogInfo 
-- @param self
-- @param #rect_table rect
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] gAngleAnalyseForQuad 
-- @param self
-- @param #float startX
-- @param #float startY
-- @param #float endX
-- @param #float endY
-- @return float#float ret (return value: float)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] cancelSendVoice 
-- @param self
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] payZTGame 
-- @param self
-- @param #string moneyName
-- @param #string productName
-- @param #string productId
-- @param #int amount
-- @param #int exchangedRatio
-- @param #bool isMonthCard
-- @param #string extraInfo
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] gGetRandNumberBetween 
-- @param self
-- @param #int nBegin
-- @param #int nEnd
-- @return int#int ret (return value: int)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] hideWaveEffectByShader 
-- @param self
-- @param #cc.Sprite3D sprite
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] isLogined 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] createRoleZTGame 
-- @param self
-- @param #string roleId
-- @param #string roleName
-- @param #string roleLevel
-- @param #string zoneId
-- @param #string zoneName
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] initDuduVoice 
-- @param self
-- @param #int zid
-- @param #int uid
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] gDirectionAnalyse 
-- @param self
-- @param #float startX
-- @param #float startY
-- @param #float endX
-- @param #float endY
-- @return int#int ret (return value: int)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] getSystemMSTime 
-- @param self
-- @return long long#long long ret (return value: long long)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] enableDebugMode 
-- @param self
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] setMaxTouchesNum 
-- @param self
-- @param #int num
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] gDirectionAnalyseByAngle 
-- @param self
-- @param #float angle
-- @return int#int ret (return value: int)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] removeAllSprite3DData 
-- @param self
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] onLogin 
-- @param self
-- @param #string account
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] releaseSendVoice 
-- @param self
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] isNeedToRestartVideo 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] createWebView 
-- @param self
-- @param #cc.Node pNode
-- @param #string sUrl
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] share 
-- @param self
-- @param #char title
-- @param #char content
-- @param #char imagePath
-- @param #char description
-- @param #char url
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] bitOr 
-- @param self
-- @param #int p1
-- @param #int p2
-- @return int#int ret (return value: int)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] loginOKZTGame 
-- @param self
-- @param #string roleId
-- @param #string roleName
-- @param #string roleLevel
-- @param #string zoneId
-- @param #string zoneName
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] isHasSwitchAccountZTGame 
-- @param self
-- @return bool#bool ret (return value: bool)
        
--------------------------------
-- 
-- @function [parent=#HelpFunc] gGetSecondStr 
-- @param self
-- @param #float fTime
-- @return string#string ret (return value: string)
        
return nil
