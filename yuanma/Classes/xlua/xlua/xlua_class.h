
#ifndef _XLUA_CLASS_H_
#define _XLUA_CLASS_H_

#include "xlua_type.h"
#include "xlua_state.h"
#include "lua_tinker.h"

namespace xlua {

template<typename Class>
class LuaClass
{
	LuaThreadPtr m_ptrThread;

public:
	LuaClass(LuaThreadPtr ptrThread, const char* classname)
		: m_ptrThread(ptrThread)
	{
		ASSERT(classname);
		lua_tinker::class_add<Class>(*m_ptrThread, classname);
	}

	// API Tinker Class Inheritence
	template<typename P>
	LuaClass& inh()
	{
		lua_tinker::class_inh<Class, P>(*m_ptrThread);
		return *this;
	}

	// API Tinker Class Constructor
	template<typename F>
	LuaClass& con(F func)
	{
		lua_tinker::class_con<Class, F>(*m_ptrThread, func);
		return *this;
	}

	// API Tinker Class Functions import C++ Class member func
	template<typename F>
	LuaClass& def(const char* name, F func) 
	{
		lua_tinker::class_def<Class, F>(*m_ptrThread, name, func);
		return *this;
	}

	// API Tinker Class member Variables
	template<typename BASE, typename VAR>
	LuaClass& mem(const char* name, VAR BASE::*val) 
	{ 
		lua_tinker::class_mem<Class, BASE, VAR>(*m_ptrThread, name, val);
		return *this;
	}
};

}//namespace xlua

using namespace xlua;

#endif//_XLUA_CLASS_H_