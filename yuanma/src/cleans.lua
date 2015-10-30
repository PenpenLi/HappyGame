--===================================================
-- (c) copyright 2014 - 2015, www.cfanim.cn
-- All Rights Reserved.
--==================================================
-- filename:  cleans.lua
-- author:    taoye
-- e-mail:    553681974@qq.com
-- created:   2014/12/7
-- descrip:   缓存清理操作
--===================================================
function cleansAllLogicManagersCache(parameters)
    -- 清空所有管理器缓存 
    FinanceManager:getInstance():clearCache()
    LoginManager:getInstance():clearCache()
    BuffManager:getInstance():clearCache()
    StoryGuideManager:getInstance():clearCache()
    EntitysManager:getInstance():clearCache()
    RectsManager:getInstance():clearCache()
    RolesManager:getInstance():clearCache()
    PetsManager:getInstance():clearCache()
    MonstersManager:getInstance():clearCache()
    TriggersManager:getInstance():clearCache()
    UserManager:getInstance():clearCache()
    AudioManager:getInstance():clearCache()
    ResPlistManager:getInstance():clearCache()
    MapManager:getInstance():clearCache()
    SkillsManager:getInstance():clearCache()
    NetHandlersManager:getInstance():clearCache()
    NetRespManager:getInstance():clearCache()
    BagCommonManager:getInstance():clearCache()
    NoticeManager:getInstance():clearCache()
    LayerManager:getInstance():clearCache()
    DialogManager:getInstance():clearCache()
    BattleManager:getInstance():clearCache()
    AIManager:getInstance():clearCache()
    StagesManager:getInstance():clearCache()
    BeautyManager:getInstance():clearCache()
    TasksManager:getInstance():clearCache()
    PurposeManager:getInstance():clearCache()
    EmailManager:getInstance():clearCache()
    CDManager:getInstance():clearCache()
    ChatManager:getInstance():clearCache()
    OptionManager:getInstance():clearCache()
    SturaLibraryManager:getInstance():clearCache()
    ActivityManager:getInstance():clearCache()
end

