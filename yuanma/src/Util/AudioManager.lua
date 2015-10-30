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
    self._sCurEffectName = ""
    if isIOSMobilePlatform() then               -- ios直接打开url
        self._pStringFormat = ".mp3"
    elseif isAndroidMobilePlatform() then        -- android开始下载渠道最新apk
        self._pStringFormat = ".ogg"
    end
end

-- 重新播放关闭的音乐
function AudioManager:replayMusic()
    if self._sCurMusicName ~= nil and OptionManager:getInstance()._bOpenMusic == true then
        print("Std：replayMusic"..self._sCurMusicName)
        AudioEngine.playMusic(self._sCurMusicName..".mp3",true)
	end
end
--播放背景音乐的接口 背景音乐统一用mp3
function AudioManager:playMusic(name,loop)
    if loop ~= nil and loop == true and  StoryGuideManager:getInstance()._bIsStory == false then
        self._sCurMusicName = name
    end
    if OptionManager:getInstance()._bOpenMusic == false then
        return
    end

    if name ~= "none" and name ~= "" then
        print("Std：play"..name.."音乐")
        AudioEngine.playMusic(name..".mp3" ,loop)
    end
end


-- 停止背景音乐
function AudioManager:stopMusic()
    AudioEngine.stopMusic()
end

-- 重新播放关闭的音乐
function AudioManager:replayEffect()
    if self._sCurEffectName ~= nil and OptionManager:getInstance()._bOpenMusic == true then
        print("replayEffect"..self._sCurEffectName)
        AudioEngine.playEffect(self._sCurEffectName..self._pStringFormat,true)
    end
end

-- 播放音效
function AudioManager:playEffect(name,loop,bBool,bHasCache)
    --代表需要缓存的音效，如果因为部分原因停止可以replay
    if bHasCache == true then
        self._sCurEffectName = name
        print("nameis"..name)
    end

    if OptionManager:getInstance()._bOpenSoundEffect == false then
    	return
    end
   
    if name ~= "none" and name ~= "" then
        if StoryGuideManager:getInstance()._bIsStory == false then  --如果没有开启剧情
          return AudioEngine.playEffect(name..self._pStringFormat,loop)
        else
            if bBool then --如果是在剧情副本，只有bBool是true的时候才播放，记录说明是剧情引导的音效
                print("播放"..name.."音效")
               return AudioEngine.playEffect(name..self._pStringFormat,loop)
            end
        end
    end
    return nil
end

-- 停止音效
function AudioManager:stopEffect(id)
    if OptionManager:getInstance()._bOpenSoundEffect == false then
        return
    end

    if id and id ~= -1 then
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
