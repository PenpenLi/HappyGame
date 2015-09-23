
#include "xlua_state.h"
#include "xlua_object.h"
#include "xlua_table.h"
#include "lua_tinker.h"
#include "cocos2d.h"

namespace xlua {
	

///////////////////////////////////////////////////////////////////////////////
LuaThread::LuaThread(LuaStatePtr ptrState, lua_State* thread_)
	: m_ptrState(ptrState)
	, m_thread(thread_)
{
	ASSERT(m_ptrState.get());
	ASSERT(m_thread);
}

LuaThread::~LuaThread()
{
	//lua_pushlightuserdata(m_thread, m_thread);
	//lua_pushnil(m_thread);
	//lua_settable(m_thread, LUA_REGISTRYINDEX);
}

LuaThread::operator lua_State*()
{
	return m_thread;
}

LuaThreadPtr LuaThread::CreateThread()
{
	return m_ptrState->CreateThread();
}

LuaTablePtr LuaThread::GetGlobal()
{
	lua_getglobal(m_thread, "_G");
	ASSERT(lua_istable(m_thread, -1));
	LuaObjectPtr ptrObject = LuaObjectPtr(new LuaObject(this->shared_from_this(), lua_gettop(m_thread), LuaObjectPtr()));
	return LuaTablePtr(new LuaTable(ptrObject));
}

void LuaThread::PrintStack()
{
	cocos2d::log("----------------- stack begin -----------------\n");
	for (int i = lua_gettop(m_thread); i >= 1; i--)
	{
		switch (lua_type(m_thread, i))
		{
		case LUA_TBOOLEAN:
			printf("stack#%02d: boolean(%s)\n", i, lua_toboolean(m_thread, i) ? "true" : " false");
			break;
		case LUA_TLIGHTUSERDATA:
			printf("stack#%02d: lightuserdata(0X%p)\n", i, lua_touserdata(m_thread, i));
			break;
		case LUA_TNUMBER:
			printf("stack#%02d: number(%lf)\n", i, lua_tonumber(m_thread, i));
			break;
		case LUA_TSTRING:
			printf("stack#%02d: string('%s')\n", i, lua_tostring(m_thread, i));
			break;
		case LUA_TTABLE:
			printf("stack#%02d: table(0X%p)\n", i, lua_topointer(m_thread, i));
			break;
		case LUA_TFUNCTION:
			printf("stack#%02d: function(0X%p)\n", i, lua_topointer(m_thread, i));
			break;
		case LUA_TUSERDATA:
			printf("stack#%02d: userdata(0X%p)\n", i, lua_touserdata(m_thread, i));
			break;
		case LUA_TTHREAD:
			printf("stack#%02d: thread(0X%p)\n", i, lua_topointer(m_thread, i));
			break;
		case LUA_TNIL:
			printf("stack#%02d: nil()\n", i);
			break;
		default:
			printf("stack#%02d: unknown()\n", i);
			break;
		}
	}
	printf("----------------- stack   end -----------------\n");
}

bool LuaThread::DoString(const string& lua)
{
	//lua_settop(m_thread, 0);
	luaL_loadbuffer(m_thread, lua.c_str(), lua.size(), "");
	if (lua_pcall(m_thread, 0, LUA_MULTRET, NULL))
	{
		printf("LuaThread::DoString, lua_pcall error:%s\n", lua_tostring(m_thread, -1));
		lua_pop(m_thread, 1);
		return false;
	}
	return true;
}

bool LuaThread::DoFile(const string& file)
{
	//lua_settop(m_thread, 0);
	if (luaL_loadfile(m_thread, file.c_str()))
	{
		printf("LuaThread::DoFile, luaL_loadfile error: %s\n", lua_tostring(m_thread, -1));
		lua_pop(m_thread, 1);
		return false;
	}
	if (lua_pcall(m_thread, 0, LUA_MULTRET, NULL))
	{
		printf("LuaThread::DoFile, lua_pcall error:%s\n", lua_tostring(m_thread, -1));
		lua_pop(m_thread, 1);
		return false;
	}
	return true;
}

///////////////////////////////////////////////////////////////////////////////

LuaState::LuaState(lua_State* state_)
	: m_state(state_)
{
	ASSERT(m_state);
}

LuaState::~LuaState()
{
	//if (m_state)
	//{
	//	lua_close(m_state);
	//	m_state = NULL;
	//}
}

LuaStatePtr LuaState::NewState()
{
	lua_State* state = luaL_newstate();
	if (state == NULL) return LuaStatePtr();

	luaL_openlibs(state);

	// 对64位整数的支持
	lua_tinker::init_s64(state);
	lua_tinker::init_u64(state);

	return LuaStatePtr(new LuaState(state));
}

LuaState* LuaState::Lua_State_To_LuaState(lua_State* state)
{
	if (state == NULL) return NULL;
	LuaState* newstate = new LuaState(state);
	lua_tinker::init_s64(state);
	lua_tinker::init_u64(state);
	return newstate;
}

LuaThreadPtr LuaState::CreateThread()
{
	//lua_lock(m_state);
	lua_checkstack(m_state, 1); // 检查栈空间，空间不足时会自动分配
	lua_State* thread_ = lua_newthread(m_state);
	ASSERT(thread_);
	lua_pushlightuserdata(thread_, thread_);
	lua_pushthread(thread_);
	lua_settable(thread_, LUA_REGISTRYINDEX); // 把线程放到全局注册表以保持计数
	lua_pop(m_state, 1);
	//lua_unlock(m_state);

	return LuaThreadPtr(new LuaThread(this->shared_from_this(), thread_));
}

}//namespace xlua
