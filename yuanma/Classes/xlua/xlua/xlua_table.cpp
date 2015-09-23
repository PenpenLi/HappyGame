
#include "xlua_table.h"
#include "xlua_state.h"
#include "xlua_object.h"

namespace xlua {

///////////////////////////////////////////////////////////////////////////////
LuaTable::LuaTable(LuaObjectPtr ptrObject)
	: m_ptrObject(ptrObject)
{
	ASSERT(m_ptrObject.get());
	ASSERT(lua_istable(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx));
}

LuaTable::~LuaTable()
{
	// empty
}

LuaTablePtr LuaTable::CreateTable(const char* key)
{
	// 先存一个空表到父表占位
	lua_newtable(*m_ptrObject->m_ptrThread);
	lua_setfield(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx, key);

	// 再把空表取到栈上
	lua_getfield(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx, key);
	
	LuaObjectPtr ptrObject = LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject));
	return LuaTablePtr(new LuaTable(ptrObject));
}

LuaTablePtr LuaTable::CreateTable(int key)
{
	// 先存一个空表到父表占位
	lua_pushnumber(*m_ptrObject->m_ptrThread, key);
	lua_newtable(*m_ptrObject->m_ptrThread);
	lua_settable(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);

	// 再把空表取到栈上
	lua_pushnumber(*m_ptrObject->m_ptrThread, key);
	lua_gettable(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);

	LuaObjectPtr ptrObject = LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject));
	return LuaTablePtr(new LuaTable(ptrObject));
}

LuaTable& LuaTable::SetNil(const char* key)
{
	lua_pushstring(*m_ptrObject->m_ptrThread, key);
	lua_pushnil(*m_ptrObject->m_ptrThread);
	lua_settable(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
	return *this;
}

LuaTable& LuaTable::SetNil(int key)
{
	lua_pushnumber(*m_ptrObject->m_ptrThread, key);
	lua_pushnil(*m_ptrObject->m_ptrThread);
	lua_settable(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
	return *this;
}

LuaTable& LuaTable::SetBoolean(const char* key, bool value)
{
	lua_pushstring(*m_ptrObject->m_ptrThread, key);
	lua_pushboolean(*m_ptrObject->m_ptrThread, value);
	lua_settable(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
	return *this;
}
LuaTable& LuaTable::SetBoolean(int key, bool value)
{
	lua_pushnumber(*m_ptrObject->m_ptrThread, key);
	lua_pushboolean(*m_ptrObject->m_ptrThread, value);
	lua_settable(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
	return *this;
}

LuaTable& LuaTable::SetNumber(const char* key, double value)
{
	lua_pushstring(*m_ptrObject->m_ptrThread, key);
	lua_pushnumber(*m_ptrObject->m_ptrThread, value);
	lua_settable(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
	return *this;
}

LuaTable& LuaTable::SetNumber(int key, double value)
{
	lua_pushnumber(*m_ptrObject->m_ptrThread, key);
	lua_pushnumber(*m_ptrObject->m_ptrThread, value);
	lua_settable(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
	return *this;
}

LuaTable& LuaTable::SetString(const char* key, const char* value, int len)
{
	lua_pushstring(*m_ptrObject->m_ptrThread, key);
	lua_pushlstring(*m_ptrObject->m_ptrThread, value, len < 0 ? strlen(value) : len);
	lua_settable(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
	return *this;
}

LuaTable& LuaTable::SetString(int key, const char* value, int len)
{
	lua_pushnumber(*m_ptrObject->m_ptrThread, key);
	lua_pushlstring(*m_ptrObject->m_ptrThread, value, len < 0 ? strlen(value) : len);
	lua_settable(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
	return *this;
}

LuaTable& LuaTable::SetString(const char* key, const string& value)
{
	lua_pushstring(*m_ptrObject->m_ptrThread, key);
	lua_pushlstring(*m_ptrObject->m_ptrThread, value.c_str(), value.size());
	lua_settable(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
	return *this;
}

LuaTable& LuaTable::SetString(int key, const string& value)
{
	lua_pushnumber(*m_ptrObject->m_ptrThread, key);
	lua_pushlstring(*m_ptrObject->m_ptrThread, value.c_str(), value.size());
	lua_settable(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
	return *this;
}

LuaTable& LuaTable::SetUserData(const char* key, void* value)
{
	lua_pushstring(*m_ptrObject->m_ptrThread, key);
	lua_pushlightuserdata(*m_ptrObject->m_ptrThread, value);
	lua_settable(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
	return *this;
}

LuaTable& LuaTable::SetUserData(int key, void* value)
{
	lua_pushnumber(*m_ptrObject->m_ptrThread, key);
	lua_pushlightuserdata(*m_ptrObject->m_ptrThread, value);
	lua_settable(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
	return *this;
}

LuaTable& LuaTable::SetLightUserData(const char* key, void* value)
{
	lua_pushstring(*m_ptrObject->m_ptrThread, key);
	lua_pushlightuserdata(*m_ptrObject->m_ptrThread, value);
	lua_settable(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
	return *this;
}

LuaTable& LuaTable::SetLightUserData(int key, void* value)
{
	lua_pushnumber(*m_ptrObject->m_ptrThread, key);
	lua_pushlightuserdata(*m_ptrObject->m_ptrThread, value);
	lua_settable(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
	return *this;
}

LuaTable& LuaTable::SetCFunction(const char* key, lua_CFunction func)
{
	lua_pushstring(*m_ptrObject->m_ptrThread, key);
	lua_pushcfunction(*m_ptrObject->m_ptrThread, func);
	lua_settable(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
	return *this;
}

LuaTable& LuaTable::SetCFunction(int key, lua_CFunction func)
{
	lua_pushnumber(*m_ptrObject->m_ptrThread, key);
	lua_pushcfunction(*m_ptrObject->m_ptrThread, func);
	lua_settable(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
	return *this;
}

LuaObjectPtr LuaTable::GetField(int key)
{
	lua_pushnumber(*m_ptrObject->m_ptrThread, key);
	lua_gettable(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
	return LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject));
}

LuaObjectPtr LuaTable::GetField(const char* key)
{
	lua_pushstring(*m_ptrObject->m_ptrThread, key);
	lua_gettable(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
	return LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject));
}

uint32 LuaTable::RawLen()
{
	return lua_rawlen(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
}

uint32 LuaTable::lua_rawlen(lua_State* state, int index)
{
	uint32 count = 0;
	LuaTableIterator it = this->Iterator();
	while(it.HasNext()) ++count;
	return count;
}

LuaTableIterator LuaTable::Iterator()
{
	return LuaTableIterator(m_ptrObject);
}

///////////////////////////////////////////////////////////////////////////////
LuaTableIterator::LuaTableIterator(LuaObjectPtr ptrObject)
	: m_ptrObject(ptrObject)
{
	ASSERT(m_ptrObject.get());
	ASSERT(lua_istable(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx));

	lua_pushnil(*m_ptrObject->m_ptrThread);
	m_ptrKey = LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject));
}

LuaTableIterator::~LuaTableIterator()
{
	// empty
}

bool LuaTableIterator::HasNext()
{
	m_ptrValue.reset();
	lua_checkstack(*m_ptrObject->m_ptrThread, 2); // 防止栈空间不够
	if (lua_gettop(*m_ptrObject->m_ptrThread) != m_ptrKey->m_stack_idx)
	{
		lua_pushvalue(*m_ptrObject->m_ptrThread, m_ptrKey->m_stack_idx);
		m_ptrKey = LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject));
	}
	if (lua_next(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx))
	{
		m_ptrValue = LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject));
		return true;
	}

	m_ptrValue.reset();
	m_ptrKey.reset();
	return false;
}

LuaObjectPtr LuaTableIterator::GetKey()
{
	return m_ptrKey;
}

LuaObjectPtr LuaTableIterator::GetValue()
{
	return m_ptrValue;
}

void LuaTableIterator::Reset()
{
	m_ptrValue.reset();
	m_ptrKey.reset();
	lua_pushnil(*m_ptrObject->m_ptrThread);
	m_ptrKey = LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject));
}

}//namespace xlua
