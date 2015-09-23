#include "AppDelegate.h"
#include "CCLuaEngine.h"
#include "SimpleAudioEngine.h"
#include "cocos2d.h"
#include "CodeIDESupport.h"
#include "Runtime.h"
#include "ConfigParser.h"
#include "lua_module_register.h"
#include "lua_assetsmanager_test_sample.h"
#include "lua_mmo_api.hpp"
#include "xcore_define.h"
#include "lua_message.h"
#include "xnet_server.h"
#include "lua.hpp"
#include "HelpFunc.h"
#include "DebugHelper.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS )
#include "C2DXShareSDK.h"
#include "DebugHelper.h"
using namespace cn::sharesdk;
#endif


USING_NS_CC;
using namespace CocosDenshion;
using namespace std;

static LuaThreadPtr runThread;
static LuaStatePtr runState;

static int isConnect(lua_State *L)
{
    bool isOpen = XSockServer::sharedSockServer()->isOpen();
    
    lua_getglobal(L, "respConnectedStatus");
    lua_pushboolean(L, isOpen);
    if (lua_pcall(L, 1, 1, 0) != 0)
    {
        return false;
    }
    return true;
}

static int LoadMessageFile(lua_State *L)
{   
    LuaMessageHelper::instance()->load_message_file(LuaMessageHelper::instance()->threadPtr);
    return 0;
}

static int disconnect()
{
    XSockServer::sharedSockServer()->close();
    return 0;
}

static int connectToServer(lua_State *L)
{
    int port = lua_tointeger(L,-1);
    const char* ip = lua_tostring(L,-2);
    //int count = lua_gettop(L);
    
    XSockAddr sock_addr(ip, port);
    if (!XSockServer::sharedSockServer()->open(sock_addr, "123456"))
    {
        //ASSERT(false);
    }
    return 0;
}

static int sendMessage(lua_State *L)
{
    int count = lua_gettop(L);
    LuaTableToByteHelper parser;
    byte* data = NULL;
    uint32 len = 0;

	if (parser.get_byte_message(&data, len, L) == false)
	{
		log("send: protocol is different!");
		return 0;
	}

    //ASSERT(parser.get_byte_message(&data, len, L));
    //printf("len: %d", len);
    //for ( int i = 0; i < len; ++i)
    //{
    //	printf("%d", data[i]);
    //}
    count = lua_gettop(L);
    
    XSockServer::sharedSockServer()->sendMessage(data, len);
    
    return 0;
}

static int socketUpdate(lua_State *L)
{
    //return;
    static int i = 0;
    
    XSockServer::sharedSockServer()->update();
    
    XSockServer::Event netEvent;
    if (XSockServer::sharedSockServer()->getEvent(netEvent))
    {
        if (netEvent.m_type == XSockServer::MESSAGE)
        {
            string msgName = string("msg") + XStrUtil::to_str(++i);
            LuaTablePtr table = runThread->GetGlobal()->CreateTable(msgName.c_str());
            ByteToLuaTableHelper bytepar;
			if(bytepar.get_luatable_message(netEvent.m_msg, netEvent.m_len, table) == false)
			{
				log("recv: protocol is different!");
				delete [] netEvent.m_msg;
				return 0;
			}
            
            lua_getglobal(L, "executeData");
            lua_pushstring(L, msgName.c_str());
            if (lua_pcall(L, 1, 1, 0) != 0)
            {
                return false;
            }
            delete [] netEvent.m_msg;
        }
		else if(netEvent.m_type == XSockServer::TIMEOUT)
		{
			DebugHelper::showJavaLog("taoye:timeout");
			//lua 超时事件传递到lua层
			/****
			

			***/
				log("net is TimeOut");
			lua_getglobal(L, "socketTimeOut");
            lua_pushstring(L, "net is TimeOut");
            if (lua_pcall(L, 1, 1, 0) != 0)
            {
                return false;
            }
			delete [] netEvent.m_msg;
		}
		else if (netEvent.m_type == XSockServer::DISCONNECTED)
		{
			DebugHelper::showJavaLog("taoye:disconnect");

			log("net is DisConnected");
			lua_getglobal(L, "socketDisconnected");
            lua_pushstring(L, "net is DisConnected");
            if (lua_pcall(L, 1, 1, 0) != 0)
            {
                return false;
            }
		}
		
    }
    
    return 0;
}

int LoadSocketLua()
{
    auto engine = LuaEngine::getInstance();
    lua_State* L = engine->getLuaStack()->getLuaState();

	runState = LuaStatePtr(LuaState::Lua_State_To_LuaState(L));
    
    LuaMessageHelper::instance()->threadPtr = runState->CreateThread();

    runThread = runState->CreateThread();
    LuaModule(runThread, "net")
    .def("send", sendMessage)
    .def("update",socketUpdate)
    .def("connectToServer",connectToServer)
    .def("loadMessageFile",LoadMessageFile)
    .def("disconnect",disconnect)
    .def("isConnected",isConnect);
    //	runThread->DoFile("E:\\mmorpg1\\Client\\MMO\\src\\Net\\Controllers\\NetProcess.lua");
    
    return 0;
}

AppDelegate::AppDelegate()
{
}

AppDelegate::~AppDelegate()
{
	LuaMessageHelper::destroy();
    SimpleAudioEngine::end();

#if (COCOS2D_DEBUG > 0 && CC_CODE_IDE_DEBUG_SUPPORT > 0)
	// NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
	endRuntime();
#endif

	ConfigParser::purge();
}

//if you want a different context,just modify the value of glContextAttrs
//it will takes effect on all platforms
void AppDelegate::initGLContextAttrs()
{
    //set OpenGL context attributions,now can only set six attributions:
    //red,green,blue,alpha,depth,stencil
    GLContextAttrs glContextAttrs = {8, 8, 8, 8, 24, 8};

    GLView::setGLContextAttrs(glContextAttrs);
}

bool AppDelegate::applicationDidFinishLaunching()
{
#if (COCOS2D_DEBUG > 0 && CC_CODE_IDE_DEBUG_SUPPORT > 0)
    // NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
    initRuntime();
#endif
    
    // initialize director
    auto director = Director::getInstance();
    auto glview = director->getOpenGLView();    
    if(!glview) {
        Size viewSize = ConfigParser::getInstance()->getInitViewSize();
        string title = ConfigParser::getInstance()->getInitViewName();
#if (CC_TARGET_PLATFORM == CC_PLATFORM_WIN32 || CC_TARGET_PLATFORM == CC_PLATFORM_MAC) && (COCOS2D_DEBUG > 0 && CC_CODE_IDE_DEBUG_SUPPORT > 0)
        extern void createSimulator(const char* viewName, float width, float height, bool isLandscape = true, float frameZoomFactor = 1.0f);
        bool isLanscape = ConfigParser::getInstance()->isLanscape();
        createSimulator(title.c_str(),viewSize.width,viewSize.height, isLanscape);
#else
        glview = cocos2d::GLViewImpl::createWithRect(title.c_str(), Rect(0, 0, viewSize.width, viewSize.height));
        director->setOpenGLView(glview);
#endif
    }
   
    auto engine = LuaEngine::getInstance();
    ScriptEngineManager::getInstance()->setScriptEngine(engine);
    lua_State* L = engine->getLuaStack()->getLuaState();
    lua_module_register(L);

	#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS )
		//初始化ShareSDK
		C2DXShareSDK::open("9886bf363d80", false);
	
		//初始化社交平台信息
		this->initPlatformConfig();
	#endif


		#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID )
		//初始化ShareSDK
		C2DXShareSDK::open("98fef33cb310", false);
	#endif


    // If you want to use Quick-Cocos2d-X, please uncomment below code
    // register_all_quick_manual(L);

    LuaStack* stack = engine->getLuaStack();
    stack->setXXTEAKeyAndSign("MMO_CFANIM_BIG_BIG_MONEY", strlen("MMO_CFANIM_BIG_BIG_MONEY"), "MMO_CFANIM_740928_MONEY", strlen("MMO_CFANIM_740928_MONEY"));
    
    //register custom function
	register_assetsmanager_test_sample(stack->getLuaState());
    register_all_mmo_api(stack->getLuaState());

	//socket lua start load
	LoadSocketLua();

#if (COCOS2D_DEBUG > 0 && CC_CODE_IDE_DEBUG_SUPPORT > 0)
    // NOTE:Please don't remove this call if you want to debug with Cocos Code IDE
    startRuntime();
#else
    engine->executeScriptFile(ConfigParser::getInstance()->getEntryFile().c_str());
#endif
    
    return true;
}

// This function will be called when the app is inactive. When comes a phone call,it's be invoked too
void AppDelegate::applicationDidEnterBackground()
{
    Director::getInstance()->stopAnimation();

    SimpleAudioEngine::getInstance()->pauseBackgroundMusic();

}

// this function will be called when the app is active again
void AppDelegate::applicationWillEnterForeground()
{
    Director::getInstance()->startAnimation();

    SimpleAudioEngine::getInstance()->resumeBackgroundMusic();

	if(HelpFunc::isPlayingVideo())
	{
		HelpFunc::setNeedToRestartVideo(true);
	}
}
void AppDelegate::initPlatformConfig()
{

	#if (CC_TARGET_PLATFORM == CC_PLATFORM_IOS )

		    //新浪微博
		__Dictionary *sinaConfigDict = __Dictionary::create();
		sinaConfigDict -> setObject(String::create("568898243"), "app_key");
		sinaConfigDict -> setObject(String::create("38a4f8204cc784f81f9f0daaf31e02e3"), "app_secret");
		sinaConfigDict -> setObject(String::create("http://www.sharesdk.cn"), "redirect_uri");
		C2DXShareSDK::setPlatformConfig(C2DXPlatTypeSinaWeibo, sinaConfigDict);

		//微信
		__Dictionary *wcConfigDict = __Dictionary::create();
		wcConfigDict -> setObject(String::create("wx63c2bc49f4b63f41"), "app_id");
		C2DXShareSDK::setPlatformConfig(C2DXPlatTypeWeixiSession, wcConfigDict);
		C2DXShareSDK::setPlatformConfig(C2DXPlatTypeWeixiTimeline, wcConfigDict);

	#endif




}
