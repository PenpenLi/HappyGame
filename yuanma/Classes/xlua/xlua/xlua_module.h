
#include "xlua_type.h"
#include "xlua_state.h"
#include "xlua_table.h"

#ifndef _XLUA_MODULE_H_
#define _XLUA_MODULE_H_

namespace xlua {

class LuaModule
{
	LuaTablePtr  m_ptrTable;

public:
	LuaModule(LuaThreadPtr ptrThread)
	{
		m_ptrTable = ptrThread->GetGlobal();
	}

	LuaModule(LuaThreadPtr ptrThread, const char* name)
	{
		m_ptrTable = ptrThread->GetGlobal()->CreateTable(name);
	}

	LuaModule(LuaTablePtr ptrTable)
	{
		m_ptrTable = ptrTable;
	}

	LuaModule& def(const char* name, lua_CFunction func)
	{
		m_ptrTable->SetCFunction(name, func);
		return *this;
	}

	template<typename F>
	LuaModule& def(const char* name, F func)
	{ 
		lua_pushlightuserdata(*m_ptrTable->m_ptrObject->m_ptrThread, (void*)func);
		lua_tinker::push_functor(*m_ptrTable->m_ptrObject->m_ptrThread, func);
		lua_setfield(*m_ptrTable->m_ptrObject->m_ptrThread, m_ptrTable->m_ptrObject->m_stack_idx, name);
		return *this;
	}
};

}//namespace xlua

using namespace xlua;

#endif//_XLUA_MODULE_H_
