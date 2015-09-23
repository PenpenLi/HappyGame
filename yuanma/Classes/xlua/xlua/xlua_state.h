// 2014-04-30
// xlua_state.h
// guosh
// lua状态机和协程支持类

#include "xlua_type.h"

#ifndef _XLUA_STATE_H_
#define _XLUA_STATE_H_

namespace xlua {

////////////////////////////////////////////////////////////////////////////////
// class LuaThread
////////////////////////////////////////////////////////////////////////////////
class LuaThread : public xcore::enable_shared_from_this<LuaThread>
{
	friend class LuaState;
	friend class LuaObject;
	LuaStatePtr m_ptrState;
	lua_State*  m_thread;

	LuaThread(LuaStatePtr ptrState, lua_State* thread_);
	LuaThread(const LuaThread&);            // not implemented
	LuaThread& operator=(const LuaThread&); // not implemented

public:
	virtual ~LuaThread();
	operator lua_State*();
	LuaThreadPtr CreateThread();
	LuaTablePtr GetGlobal();

	void PrintStack();
	bool DoString(const string& lua);
	bool DoFile(const string& file);
};

////////////////////////////////////////////////////////////////////////////////
// class LuaState
////////////////////////////////////////////////////////////////////////////////
class LuaState : public xcore::enable_shared_from_this<LuaState>
{
	lua_State* m_state;

	LuaState(const LuaState&);            // not implemented
	LuaState& operator=(const LuaState&); // not implemented
	LuaState(lua_State* state_);

public:
	static LuaStatePtr NewState();
	static LuaState* Lua_State_To_LuaState(lua_State* state);
	
public:
	virtual ~LuaState();
	LuaThreadPtr CreateThread();
};

}//namespace xlua

using namespace xlua;

#endif//_XLUA_STATE_H_