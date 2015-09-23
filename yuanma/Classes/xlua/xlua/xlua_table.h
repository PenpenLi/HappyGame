// 2014-04-30
// xlua_table.h
// guosh
// lua表支持类

#include "xlua_type.h"

#ifndef _XLUA_TABLE_H_
#define _XLUA_TABLE_H_

namespace xlua {

////////////////////////////////////////////////////////////////////////////////
// class LuaTable
////////////////////////////////////////////////////////////////////////////////
class LuaTable : public xcore::enable_shared_from_this<LuaTable>
{
	friend class LuaThread;
	friend class LuaObject;
	friend class LuaModule;
	friend class LuaTableIterator;
	LuaObjectPtr m_ptrObject;

	LuaTable(LuaObjectPtr ptrObject);
	LuaTable(const LuaTable&);            // not implemented
	LuaTable& operator=(const LuaTable&); // not implemented

public:
	virtual ~LuaTable();

	LuaTablePtr CreateTable(const char* key);
	LuaTablePtr CreateTable(int key);
	LuaTable& SetNil(const char* key);
	LuaTable& SetNil(int key);
	LuaTable& SetBoolean(const char* key, bool value);
	LuaTable& SetBoolean(int key, bool value);
	LuaTable& SetNumber(const char* key, double value);
	LuaTable& SetNumber(int key, double value);
	LuaTable& SetString(const char* key, const char* value, int len = -1);
	LuaTable& SetString(int key, const char* value, int len = -1);
	LuaTable& SetString(const char* key, const string& value);
	LuaTable& SetString(int key, const string& value);
	LuaTable& SetUserData(const char* key, void* value);
	LuaTable& SetUserData(int key, void* value);
	LuaTable& SetLightUserData(const char* key, void* value);
	LuaTable& SetLightUserData(int key, void* value);
	LuaTable& SetCFunction(const char* key, lua_CFunction func);
	LuaTable& SetCFunction(int key, lua_CFunction func);

	LuaObjectPtr GetField(int key);
	LuaObjectPtr GetField(const char* key);

	uint32 RawLen();
	uint32 lua_rawlen(lua_State* state, int index);

	LuaTableIterator Iterator();
};

///////////////////////////////////////////////////////////////////////////////
class LuaTableIterator
{
	friend class LuaTable;
	LuaObjectPtr m_ptrObject;
	LuaObjectPtr m_ptrKey;
	LuaObjectPtr m_ptrValue;

	LuaTableIterator(LuaObjectPtr ptrObject);

public:
	~LuaTableIterator();
	bool HasNext();
	LuaObjectPtr GetKey();
	LuaObjectPtr GetValue();
	void Reset();
};

}//namespace xlua

using namespace xlua;

#endif//_XLUA_TABLE_H_
