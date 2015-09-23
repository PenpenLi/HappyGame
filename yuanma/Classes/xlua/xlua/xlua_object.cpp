
#include "xlua_object.h"
#include "xlua_state.h"
#include "xlua_table.h"
#include "xlua_function.h"

namespace xlua {
	
///////////////////////////////////////////////////////////////////////////////
LuaObject::LuaObject(LuaThreadPtr ptrThread, int stack_idx, LuaObjectPtr ptrParentObject, bool is_error)
	: m_ptrThread(ptrThread)
	, m_stack_idx(stack_idx)
	, m_ptrParentObject(ptrParentObject)
	, m_is_error(is_error)
{
	ASSERT(m_ptrThread.get());
	ASSERT(lua_gettop(*m_ptrThread) >= stack_idx);
	ASSERT(!m_is_error || IsString());
}

LuaObject::~LuaObject()
{
	// 1. 把lua栈上的对象替换成lua-thread作为特殊标记
	lua_pushthread(m_ptrThread->m_thread);
	lua_replace(*m_ptrThread, m_stack_idx);
	
	// 2. 从lua栈顶向下查找所有lua-thread删除
	for (int i = lua_gettop(*m_ptrThread); i > 0; i--)
	{
		if (!lua_isthread(*m_ptrThread, i)) break;
		lua_pop(*m_ptrThread, 1);
	}
}

string LuaObject::TypeName() const
{
	return lua_typename(*m_ptrThread, lua_type(*m_ptrThread, m_stack_idx));
}

bool LuaObject::IsNil() const
{
	return lua_isnil(*m_ptrThread, m_stack_idx);
}

bool LuaObject::IsBoolean() const
{
	return lua_isboolean(*m_ptrThread, m_stack_idx);
}



bool LuaObject::IsNumber() const
{
	return (lua_type(*m_ptrThread, m_stack_idx) == LUA_TNUMBER);
}

bool LuaObject::IsString() const
{
	return (lua_type(*m_ptrThread, m_stack_idx) == LUA_TSTRING) && !m_is_error;
}

bool LuaObject::IsUserData() const
{
	return !!lua_isuserdata(*m_ptrThread, m_stack_idx);
}

bool LuaObject::IsLightUserData() const
{
	return lua_islightuserdata(*m_ptrThread, m_stack_idx);
}

bool LuaObject::IsTable() const
{
	return lua_istable(*m_ptrThread, m_stack_idx);
}

bool LuaObject::IsThread() const
{
	return !!lua_isthread(*m_ptrThread, m_stack_idx);
}

bool LuaObject::IsCFunction() const
{
	return !!lua_iscfunction(*m_ptrThread, m_stack_idx);
}

bool LuaObject::IsFunction() const
{
	return lua_isfunction(*m_ptrThread, m_stack_idx);
}

bool LuaObject::IsNone() const
{
	return lua_isnone(*m_ptrThread, m_stack_idx);
}

bool LuaObject::IsError() const
{
	return m_is_error;
}

bool LuaObject::ToBoolean()
{
	ASSERT(IsBoolean());
	return !!lua_toboolean(*m_ptrThread, m_stack_idx);
}

double LuaObject::ToNumber()
{
	ASSERT(IsNumber());
	return lua_tonumber(*m_ptrThread, m_stack_idx);
}

string LuaObject::ToString()
{
	ASSERT(IsString() || IsError() || IsNumber());
	size_t len = 0;
	const char* str = lua_tolstring(*m_ptrThread, m_stack_idx, &len);
	return str ? string(str, len) : "";
}

void* LuaObject::ToUserData()
{
	ASSERT(IsUserData());
	return lua_touserdata(*m_ptrThread, m_stack_idx);
}

void* LuaObject::ToLightUserData()
{
	ASSERT(IsLightUserData());
	return lua_touserdata(*m_ptrThread, m_stack_idx);
}

LuaTablePtr LuaObject::ToTable()
{
	ASSERT(IsTable());
	return LuaTablePtr(new LuaTable(this->shared_from_this()));
}

LuaFunction LuaObject::ToFunction()
{
	ASSERT(IsFunction());
	return LuaFunction(this->shared_from_this());
}

void LuaObject::Push()
{
	lua_pushvalue(*m_ptrThread, m_stack_idx);
}

void LuaObject::Print()
{
	if (IsNil())
	{
		printf("nil");
	}
	else if (IsBoolean())
	{
		printf("bool(%s)", ToBoolean() ? "true" : "false");
	}
	else if (IsNumber())
	{
		printf("number(%lf)", ToNumber());
	}
	else if (IsString())
	{
		printf("string('%s')", ToString().c_str());
	}
	else if (IsUserData())
	{
		printf("userdata(0X%p)", ToUserData());
	}
	else if (IsLightUserData())
	{
		printf("lightuserdata(0X%p)", ToLightUserData());
	}
	else if (IsTable())
	{
		printf("table(0X%p)", lua_topointer(*m_ptrThread, m_stack_idx));
	}
	else if (IsThread())
	{
		printf("thread(0X%p)", lua_topointer(*m_ptrThread, m_stack_idx));
	}
	else if (IsCFunction())
	{
		printf("function(0X%p)", lua_tocfunction(*m_ptrThread, m_stack_idx));
	}
	else if (IsError())
	{
		printf("error(%s)", ToString().c_str());
	}
	else
	{
		printf("unknown");
	}
}

}//namespace xlua
