#include "xcore_define.h"
#include "xcore_parser.h"
#include "xlua.hpp"
using namespace std;

class LuaMessageHelper
{
public:
	LuaMessageHelper() {}
	~LuaMessageHelper() {}
	
	static LuaMessageHelper* instance()
	{
		if (m_instance == NULL)
		{
			m_instance = new LuaMessageHelper();
		}
		return m_instance;
	};

	static void destroy()
	{
		delete m_instance;
		m_instance = NULL;
	}


public:
	bool load_message_file(LuaThreadPtr luaThread);

	LuaTablePtr find_obj_by_id(uint32 msgid)
	{
		map<uint32, LuaTablePtr>::iterator it = m_msg_body.find(msgid);
		if (it == m_msg_body.end()) return LuaTablePtr();
		return it->second;
	}

	LuaTablePtr find_obj_by_name(const string& msgname)
	{
		map<string, LuaTablePtr>::iterator it = m_msg_unit.find(msgname);
		if (it == m_msg_unit.end()) return LuaTablePtr();
		return it->second;
	}

	LuaTablePtr find_enum_by_name(const string& enumtype)
	{
		map<string, LuaTablePtr>::iterator it = m_enum_unit.find(enumtype);
		if (it == m_enum_unit.end()) return LuaTablePtr();
		return it->second;
	}

	LuaThreadPtr threadPtr;
private:
	static LuaMessageHelper* m_instance;
	map<uint32, LuaTablePtr> m_msg_body;
	map<string, LuaTablePtr> m_msg_unit;
	map<string, LuaTablePtr> m_enum_unit;	
};

class ByteToLuaTableHelper
{
public:
	ByteToLuaTableHelper(){}
	~ByteToLuaTableHelper(){}

	bool get_luatable_message(const byte* data, uint32 len, LuaTablePtr obj);

private:
	bool get_header_object(LuaTablePtr header, uint32& cmdNum, uint32& result, XByteParser& parser);
	bool get_body_object(LuaTablePtr body, uint32 cmdNum, XByteParser& parser);

	bool get_element(LuaTablePtr element, const string& type, const string& name,  XByteParser& parser);
	bool get_element(LuaTablePtr element, const string& type, int32 index, XByteParser& parser);

	bool get_object(LuaTablePtr object, uint32 id, XByteParser& parser);
	bool get_object(LuaTablePtr object, const string& name, XByteParser& parser);
	bool get_object(LuaTablePtr object, const LuaTablePtr msgDes, XByteParser& parser);
};

class LuaTableToByteHelper
{
public:
	LuaTableToByteHelper() {}
	~LuaTableToByteHelper() {}

public:
	bool get_byte_message(byte** data, uint32& len, lua_State* L);
	bool get_header_byte(byte* data, uint32& len, uint32& cmdNum, lua_State* L);
	bool get_body_byte(byte* data, uint32& len, uint32 cmdNum, lua_State* L);

	bool get_element(byte* data, uint32& len, uint32 id, lua_State* L);
	bool get_element(byte* data, uint32& len, const string& name, lua_State* L);
	bool get_element(byte* data, uint32& len, const LuaTablePtr elementobj, lua_State* L);

private:
	bool get_lua_data(lua_State* L, const string& filed, uint32& data);
	bool get_lua_data_default(lua_State* L, const string& filed, uint32& data);

	bool process(byte* data, uint32& len, const string& type, lua_State* L);
};