--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  OptionManager.lua
-- author:    liyuhang
-- created:   2015/7/14
-- descrip:   设置管理器
--===================================================
OptionManager = {}

local instance = nil

-- 单例
function OptionManager:getInstance()
    if not instance then
        instance = OptionManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function OptionManager:clearCache()
    -- 是否开启音乐
    self._bOpenMusic = cc.UserDefault:getInstance():getBoolForKey("Option_Music",true)    
    -- 是否开启音效              
    self._bOpenSoundEffect = cc.UserDefault:getInstance():getBoolForKey("Option_SoundEffect",true)       
    -- 是否显示昵称     
    self._bPlayersNameShowOrNot = cc.UserDefault:getInstance():getBoolForKey("Option_PlayersNameShow",true)  
    -- 是否锁定摇杆     
    self._bStickLock = cc.UserDefault:getInstance():getBoolForKey("Option_StickLock",true)   
    -- 是否开启手机震动               
    self._bShake = cc.UserDefault:getInstance():getBoolForKey("Option_Shake",false)  
    mmo.HelpFunc:setVibratorEnabled(self._bShake)
    -- 同屏人数   1:高级   2:中级   3:低级
    self._nPlayersRoleShowLevel = cc.UserDefault:getInstance():getIntegerForKey("Option_ShowLevel",1)         
end
-- 设置音乐开启
function OptionManager:setOptionMusic(args)
    self._bOpenMusic = args
    
    if self._bOpenMusic == false then
    	AudioManager:getInstance():stopMusic()
    end

    cc.UserDefault:getInstance():setBoolForKey("Option_Music", args)
    cc.UserDefault:getInstance():flush()
end
-- 设置音效开启
function OptionManager:setOptionSoundEffect(args)
    self._bOpenSoundEffect = args
    
    if self._bOpenSoundEffect == false then
        AudioManager:stopAllEffects()
    end

    cc.UserDefault:getInstance():setBoolForKey("Option_SoundEffect", args)
    cc.UserDefault:getInstance():flush()
end
-- 设置昵称是否显示开启
function OptionManager:setOptionPlayersNameShow(args)
    self._bPlayersNameShowOrNot = args

    cc.UserDefault:getInstance():setBoolForKey("Option_PlayersNameShow", args)
    cc.UserDefault:getInstance():flush()
end
-- 设置摇杆锁定
function OptionManager:setOptionStickLock(args)
    self._bStickLock = args
    
    NetRespManager:dispatchEvent(kNetCmd.kSetStickLocked,{locked = self._bStickLock})

    cc.UserDefault:getInstance():setBoolForKey("Option_StickLock", args)
    cc.UserDefault:getInstance():flush()
end
-- 设置震动
function OptionManager:setOptionShake(args)
    self._bShake = args
    
    mmo.HelpFunc:setVibratorEnabled(self._bShake)

    cc.UserDefault:getInstance():setBoolForKey("Option_Shake", args)
    cc.UserDefault:getInstance():flush()
end
-- 设置同屏显示人数
function OptionManager:setOptionShowLevel(args)
    self._nPlayersRoleShowLevel = args

    cc.UserDefault:getInstance():setIntegerForKey("Option_ShowLevel", self._nPlayersRoleShowLevel)
    cc.UserDefault:getInstance():flush()
end


