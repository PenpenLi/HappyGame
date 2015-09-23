--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  AudioManager.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2015/6/4
-- descrip:   音频管理器
--===================================================
AudioManager = {}

local instance = nil

-- 单例
function AudioManager:getInstance()
    if not instance then
        instance = AudioManager
        instance:clearCache()
    end
    return instance
end

-- 清空缓存
function AudioManager:clearCache()  
    self._sCurMusicName = nil
    self._pStringFormat = ""
    if isIOSMobilePlatform() then               -- ios直接打开url
        self._pStringFormat = ".mp3"
    elseif isAndroidMobilePlatform() then        -- android开始下载渠道最新apk
        self._pStringFormat = ".ogg"
    end
end

-- 重新播放关闭的音乐
function AudioManager:replayMusic()
    if self._sCurMusicName ~= nil and OptionManager:getInstance()._bOpenMusic == true then
        AudioEngine.playMusic(self._sCurMusicName.. self._pStringFormat,true)
	end
end
--播放背景音乐的接口 背景音乐统一用mp3
function AudioManager:playMusic(name,loop)
      if OptionManager:getInstance()._bOpenMusic == false then
        if loop ~= nil and loop == true then
            self._sCurMusicName = name
        end
        return
    end

    if name ~= "none" and name ~= "" then
        AudioEngine.playMusic(name..".mp3" ,loop)
    end
end


-- 停止背景音乐
function AudioManager:stopMusic()
    AudioEngine.stopMusic()
end

-- 播放音效
function AudioManager:playEffect(name,loop)
    if OptionManager:getInstance()._bOpenSoundEffect == false then
    	return
    end

    if name ~= "none" and name ~= "" then
        return AudioEngine.playEffect(name..self._pStringFormat,loop)
    end
end

-- 停止音效
function AudioManager:stopEffect(id)
    if OptionManager:getInstance()._bOpenSoundEffect == false then
        return
    end

    if id ~= -1 then
        AudioEngine.stopEffect(id)
    end
end

-- 停止所有音效
function AudioManager:stopAllEffects()
    AudioEngine.stopAllEffects()
end

-- 停止所有音效
function AudioManager:purgeAudioEngineData()
    AudioEngine.destroyInstance()
end

--预加载音效
function AudioManager:preloadEffect(name)
    if OptionManager:getInstance()._bOpenSoundEffect == false then
        return
    end

    if name ~= "none" and name ~= "" then
        AudioEngine.preloadEffect(name..self._pStringFormat)
    end
   
end

--释放已经预加载的音效
function AudioManager:unloadEffect(name)
    AudioEngine.unloadEffect(name..self._pStringFormat)
end
