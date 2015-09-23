#include "lua_message.h"
#include "xcore_define.h"
#include "xcore_macro.h"
#include "common_message.h"

bool LuaMessageHelper::load_message_file(LuaThreadPtr luaThread)
{
	LuaTablePtr globleTable = luaThread->GetGlobal();
	LuaTableIterator it = globleTable->Iterator();
	while (it.HasNext())
	{
		LuaObjectPtr key_ = it.GetKey();
		LuaObjectPtr value_ = it.GetValue();
		
		if (key_->IsString() && value_->IsTable())
		{
			LuaTablePtr tablevalue = value_->ToTable();
			LuaObjectPtr id_ = tablevalue->GetField("id");
			LuaObjectPtr attribs_ =  tablevalue->GetField("attribs"); 
			LuaObjectPtr name_ = tablevalue->GetField("name");
			if ((attribs_->IsTable() || attribs_->IsNil()) && id_->IsNumber() && name_->IsString()) 
			{
				uint32 cmdNum = (uint32)id_->ToNumber();
				if (cmdNum != 0){
					m_msg_body[cmdNum] = tablevalue;
				}
				else{
					m_msg_unit[name_->ToString()] = tablevalue;						
				}
			}
			else
			{
				string key_str = key_->ToString();
				if (key_str.size() > 0 && key_str[0] == 'k')
				{
					m_enum_unit[key_->ToString()] = value_->ToTable();
				}
			}
		}
	}
	return true;
}

LuaMessageHelper* LuaMessageHelper::m_instance;

bool ByteToLuaTableHelper::get_luatable_message(const byte* data, uint32 len, LuaTablePtr msgObj)
{
	XByteParser parser((char*)data, len);
	uint32 cmdNum = 0, result = 0;
	LuaTablePtr header = msgObj->CreateTable("header");
	LuaTablePtr body = msgObj->CreateTable("body");
	if (!this->get_header_object(header, cmdNum, result, parser)) return false;
	if (result != 0 && parser.remain() == 0) return true;
	if (!this->get_body_object(body, cmdNum, parser)) return false;	
	if (parser.remain() > 0) return false;
	return true;
}

bool ByteToLuaTableHelper::get_header_object(LuaTablePtr header, uint32& cmdNum, uint32& result, XByteParser& parser)
{
	if (parser.remain() < sizeof(CommonCmdHeader_)) return false;

	CommonCmdHeader_* cmd = (CommonCmdHeader_*)parser.start();
	header->SetNumber("cmdNum", (double)cmd->m_cmdNum);
	header->SetNumber("cmdSeq", (double)cmd->m_cmdSeq );
	header->SetNumber("reserve", (double)cmd->m_reserve);
	cmdNum = cmd->m_cmdNum;
	if (cmd->m_cmdNum % 2 == 0) // «Î«Û
	{
		if (parser.remain() < sizeof(CommonReqHeader_)) return false;
		CommonReqHeader_* req = (CommonReqHeader_*)parser.start();
		header->SetNumber("srcId", (double)req->m_srcId);
		header->SetNumber("sessionId", (double)req->m_session);
		parser.set_pos(parser.start() + sizeof(CommonReqHeader_));
	}
	else  // ªÿ∏¥
	{
		if (parser.remain() < sizeof(CommonRespHeader_)) return false;
		CommonRespHeader_* rsp =  (CommonRespHeader_*)parser.start();
		header->SetNumber("result", (double)rsp->m_result);
		parser.set_pos(parser.start() + sizeof(CommonRespHeader_));
		result = rsp->m_result;
	}
	return true;
}

bool ByteToLuaTableHelper::get_body_object(LuaTablePtr body, uint32 cmdNum, XByteParser& parser)
{
	return this->get_object(body, cmdNum, parser);
}

bool ByteToLuaTableHelper::get_object(LuaTablePtr object, uint32 id, XByteParser& parser)
{
	LuaTablePtr msgDesObj = LuaMessageHelper::instance()->find_obj_by_id(id);
	return get_object(object, msgDesObj, parser);
}
bool ByteToLuaTableHelper::get_object(LuaTablePtr object, const string& name, XByteParser& parser)
{
	LuaTablePtr msgDesObj = LuaMessageHelper::instance()->find_obj_by_name(name);
	return get_object(object, msgDesObj, parser);
}

bool ByteToLuaTableHelper::get_object(LuaTablePtr object, const LuaTablePtr msgDes, XByteParser& parser)
{
	if (!msgDes.get()) return false;
	LuaObjectPtr attribs = msgDes->GetField("attribs");
	if (attribs->IsNil()) return true;
	if (!attribs->IsTable()) return false;
	LuaTablePtr attribsTable = attribs->ToTable();
	for (uint32 i = 1; i <= attribsTable->RawLen(); ++i)
	{
		LuaObjectPtr subAttr = attribsTable->GetField(i);
		if (!subAttr->IsTable()) return false;
		LuaTablePtr subAttrTable = subAttr->ToTable();
		if (subAttrTable->RawLen() < 2) return false;
		bool repeat = subAttrTable->RawLen() >= 3;
		string name = subAttrTable->GetField(1)->ToString();
		string type = subAttrTable->GetField(2)->ToString();
		if (repeat)
		{
			uint16 count = 0;
			if (!parser.get_uint16(count)) return false;
			LuaTablePtr eleTable = object->CreateTable(name.c_str());
			for (uint16 i = 1; i  <= count; i ++)
			{
				if (!this->get_element(eleTable, type, i, parser)) return false; 
			}
		}
		else
		{
			if (!this->get_element(object, type, name, parser)) return false; 
		}
	}
	return true;
}

bool ByteToLuaTableHelper::get_element(LuaTablePtr element, const string& type, const string& name,  XByteParser& parser)
{
	if (type == "uint32")	{
		uint32 tmp = 0;
		if (!parser.get_uint32(tmp)) return false;
		element->SetNumber(name.c_str(), (double)tmp);
	}
	else if (type == "int32")
	{
		int32 tmp = 0;
		if (!parser.get_int32(tmp)) return false;
		element->SetNumber(name.c_str(), (double)tmp);
	}
	else if (type == "uint64")
	{
		return false;
	}
	else if (type == "int64")
	{
		return false;
	}
	else if (type == "uint16")
	{
		uint16 tmp = 0;
		if (!parser.get_uint16(tmp)) return false;
		element->SetNumber(name.c_str(), (double)tmp);
	}
	else if (type == "int16")
	{
		int16 tmp = 0;
		if (!parser.get_int16(tmp)) return false;
		element->SetNumber(name.c_str(), (double)tmp);
	}
	else if (type == "uint8")
	{
		uint8 tmp = 0;
		if (!parser.get_uint8(tmp)) return false;
		element->SetNumber(name.c_str(), (double)tmp);
	}
	else if (type == "int8")
	{
		return false;
	}
	else if (type == "bool")
	{
		bool tmp = false;
		if (!parser.get_bool(tmp)) return false;
		element->SetBoolean(name.c_str(), tmp);
	}
	else if (type == "double")
	{
		double tmp = 0.0;
		if (!parser.get_double(tmp)) return false;
		element->SetNumber(name.c_str(), tmp);
	}
	else if (type == "string")
	{
		string tmp;
		if (!parser.get_string(tmp)) return false;
		element->SetString(name.c_str(), tmp);
	}
	else
	{
		// √∂æŸ¿‡–Õ
		LuaTablePtr enumobj = LuaMessageHelper::instance()->find_enum_by_name(type);
		if (enumobj.get())
		{
			uint16 tmp = 0;
			if (!parser.get_uint16(tmp)) return false;
			element->SetNumber(name.c_str(), (double)tmp);
			return true;			
		}

		// ◊‘∂®“ÂΩ·ππ
		LuaTablePtr desobj = LuaMessageHelper::instance()->find_obj_by_name(type);
		LuaTablePtr subtable = element->CreateTable(name.c_str());
		if (!this->get_object(subtable, desobj, parser)) return false;			
	}
	return true;
}

bool ByteToLuaTableHelper::get_element(LuaTablePtr element, const string& type, int32 index, XByteParser& parser)
{
	if (type == "uint32")	{
		uint32 tmp = 0;
		if (!parser.get_uint32(tmp)) return false;
		element->SetNumber(index, (double)tmp);
	}
	else if (type == "int32")
	{
		int32 tmp = 0;
		if (!parser.get_int32(tmp)) return false;
		element->SetNumber(index, (double)tmp)	;
	}
	else if (type == "uint64")
	{
		return false;
	}
	else if (type == "int64")
	{
		return false;
	}
	else if (type == "uint16")
	{
		uint16 tmp = 0;
		if (!parser.get_uint16(tmp)) return false;
		element->SetNumber(index, (double)tmp);
	}
	else if (type == "int16")
	{
		int16 tmp = 0;
		if (!parser.get_int16(tmp)) return false;
		element->SetNumber(index, (double)tmp);
	}
	else if (type == "uint8" )
	{
		uint8 tmp = 0;
		if (!parser.get_uint8(tmp)) return false;
		element->SetNumber(index, (double)tmp);
	}
	else if (type == "int8")
	{
		return false;
	}
	else if (type == "bool")
	{
		bool tmp = false;
		if (!parser.get_bool(tmp)) return false;
		element->SetBoolean(index, tmp);
	}
	else if (type == "double")
	{
		double tmp = 0.0;
		if (!parser.get_double(tmp)) return false;
		element->SetNumber(index, tmp);
	}
	else if (type == "string")
	{
		string tmp;
		if (!parser.get_string(tmp)) return false;
		element->SetString(index, tmp);
	}
	else
	{
		// √∂æŸ¿‡–Õ
		LuaTablePtr enumobj = LuaMessageHelper::instance()->find_enum_by_name(type);
		if (enumobj.get())
		{
			uint16 tmp = 0;
			if (!parser.get_uint16(tmp)) return false;
			element->SetNumber(index, (double)tmp);
			return true;			
		}

		// ◊‘∂®“ÂΩ·ππ
		LuaTablePtr desobj = LuaMessageHelper::instance()->find_obj_by_name(type);
		LuaTablePtr subtable = element->CreateTable(index);
		if (!this->get_object(subtable, desobj, parser)) return false;
	}
	return true;
}

//////////////////////////////////////////////////////////////////////////

bool LuaTableToByteHelper::get_byte_message(byte** data, uint32& len, lua_State* L)
{
	if (lua_gettop(L) != 1) return false;
	if (!lua_istable(L, -1)) return false;
	
	byte tmpdata[20 * 1024] = {0};
	uint32 datalen = 0, cmdNum = 0;

	lua_getfield(L, -1, "header");
	if (!this->get_header_byte(tmpdata, datalen, cmdNum, L)) return false;
	lua_pop(L, 1);

	lua_getfield(L, -1, "body");
	if (!this->get_body_byte(tmpdata, datalen, cmdNum, L)) return false;
	lua_pop(L, 1);

	byte* p = new byte[datalen];
	memcpy(p, tmpdata, datalen);
	*data = p;
	len = datalen;

	return true;
}

bool LuaTableToByteHelper::get_lua_data(lua_State* L, const string& filed, uint32& data)
{
	lua_getfield(L, -1, filed.c_str());
	if (!lua_isnumber(L, -1)) return false;
	data = lua_tointeger(L, -1);
	lua_pop(L, 1);
	return true;
}

bool LuaTableToByteHelper::get_lua_data_default(lua_State* L, const string& filed, uint32& data)
{
	lua_getfield(L, -1, filed.c_str());
	if (!lua_isnumber(L, -1)) data = 0;
	else data = lua_tointeger(L, -1);
	lua_pop(L, 1);
	return true;
}

bool LuaTableToByteHelper::get_header_byte(byte* data, uint32& len, uint32& cmdNum, lua_State* L)
{
	if (len != 0) return false;
	if (!lua_istable(L, -1)) return false;
	
	if (!this->get_lua_data(L, "cmdNum", cmdNum)) return false;

	if (cmdNum % 2 == 0) // «Î«Û
	{
		uint32 sessionId = 0, srcId = 0, cmdSeq = 0, reserve = 0;
		if (!this->get_lua_data(L, "sessionId", sessionId)) return false;
		if (!this->get_lua_data(L, "srcId", srcId)) return false;
		if (!this->get_lua_data(L, "cmdSeq", cmdSeq)) return false;
		if (!this->get_lua_data(L, "reserve", reserve)) return false;

		CommonReqHeader_* tmp_data = (CommonReqHeader_*) data;
		tmp_data->m_cmdNum = cmdNum;
		tmp_data->m_cmdSeq = cmdSeq;
		tmp_data->m_reserve = reserve;
		tmp_data->m_session = sessionId;
		tmp_data->m_srcId = srcId;
		len = sizeof(CommonReqHeader_);
	}
	else // ªÿ∏¥
	{
		uint32 result = 0, cmdSeq = 0, reserve = 0;
		if (!this->get_lua_data(L, "result", result)) return false;
		if (!this->get_lua_data(L, "cmdSeq", cmdSeq)) return false;
		if (!this->get_lua_data(L, "reserve", reserve)) return false;

		CommonRespHeader_* tmp_data = (CommonRespHeader_*) data;
		tmp_data->m_cmdNum = cmdNum;
		tmp_data->m_cmdSeq = cmdSeq;
		tmp_data->m_reserve = reserve;
		tmp_data->m_result = result;
		len = sizeof(CommonRespHeader_);
	}
	return true;
}

bool LuaTableToByteHelper::get_body_byte(byte* data, uint32& len, uint32 cmdNum, lua_State* L)
{
	return this->get_element(data, len, cmdNum, L);
}

bool LuaTableToByteHelper::get_element(byte* data, uint32& len, uint32 id, lua_State* L)
{
	LuaTablePtr elementobj = LuaMessageHelper::instance()->find_obj_by_id(id);
	return this->get_element(data, len, elementobj, L);
}

bool LuaTableToByteHelper::get_element(byte* data, uint32& len, const string& name, lua_State* L)
{
	// √∂æŸ¥¶¿Ì
	LuaTablePtr enumobj = LuaMessageHelper::instance()->find_enum_by_name(name);
	if (enumobj.get())
	{
		return this->process(data, len, "uint16", L);
	}
	
	//  ∆‰À˚¥¶¿Ì
	LuaTablePtr elementobj = LuaMessageHelper::instance()->find_obj_by_name(name);
	return this->get_element(data, len, elementobj, L);
}

bool LuaTableToByteHelper::get_element(byte* data, uint32& len, const LuaTablePtr elementobj, lua_State* L)
{
	if (!elementobj.get()) return false;
	LuaObjectPtr attribObj = elementobj->GetField("attribs");
	if (attribObj->IsNil()) return true;
	if (!attribObj->IsTable()) return false;
	LuaTablePtr attribTable = attribObj->ToTable();
	for (uint32 i = 1; i <= attribTable->RawLen(); ++i)
	{
		LuaObjectPtr ite = attribTable->GetField(i);
		if (!ite->IsTable()) return false;
		LuaTablePtr iteTable = ite->ToTable();
		bool repeat = iteTable->RawLen() >= 3;

		LuaObjectPtr nameobj =iteTable->GetField(1);
		LuaObjectPtr typeobj = iteTable->GetField(2);
		if ((!nameobj->IsString()) || (!typeobj->IsString())) return false;
		string name = nameobj->ToString();
		string type = typeobj->ToString();
		
		lua_getfield(L, -1, name.c_str());
		if (repeat)
		{
			if (lua_isnil(L, -1)){
				byte* start_pos = data + len;
				*(uint16*) start_pos = 0;
				len += sizeof(uint16);
			}
			if (lua_istable(L, -1))
			{
				uint32 objlen = lua_objlen(L, -1);
				byte* len_pos = data + len;
				*(uint16*)len_pos = (uint16)objlen;
				len += sizeof(uint16);
				for (uint32 i = 1; i <= objlen; ++i)
				{
					lua_rawgeti(L, -1, i);
					if (!this->process(data, len, type, L)) return false;	
					lua_pop(L, 1);
				}
			}
		}
		else
		{
			if (!this->process(data, len, type, L)) return false;		
		}
		lua_pop(L, 1);
	}
	return true;
}

bool LuaTableToByteHelper::process(byte* data, uint32& len, const string& type, lua_State* L)
{
	byte* start_pos = data + len;
	if (type == "uint8") {
		uint8 value_ = 0;
		if (lua_isnumber(L, -1)) value_ = lua_tointeger(L, -1);
		*(uint8*)start_pos = value_;
		len += sizeof(uint8);
	}
	else if (type == "int8"){
		int8 value_ = 0;
		if (lua_isnumber(L, -1)) value_ = lua_tointeger(L, -1);
		*(int8*)start_pos = value_;
		len += sizeof(int8);
	}
	else if (type == "uint16"){
		uint16 value_ = 0;
		if (lua_isnumber(L, -1)) value_ = lua_tointeger(L, -1);
		*(uint16*)start_pos = value_;
		len += sizeof(uint16);
	}
	else if (type == "int16")	{
		int16 value_ = 0;
		if (lua_isnumber(L, -1)) value_ = lua_tointeger(L, -1);
		*(int16*)start_pos = value_;
		len += sizeof(int16);
	}
	else if (type == "uint32"){
		uint32 value_ = 0;
		if (lua_isnumber(L, -1)) value_ = lua_tointeger(L, -1);
		*(uint32*)start_pos = value_;
		len += sizeof(uint32);
	}
	else if (type == "int32")	{
		int32 value_ = 0;
		if (lua_isnumber(L, -1)) value_ = lua_tointeger(L, -1);
		*(int32*)start_pos = value_;
		len += sizeof(int32);
	}
	else if (type == "uint64"){
		uint64 value_ = 0;
		if (lua_isnumber(L, -1)) value_ = lua_tointeger(L, -1);
		*(uint64*)start_pos = value_;
		len += sizeof(uint64);
	}
	else if (type == "int64")	{
		int64 value_ = 0;
		if (lua_isnumber(L, -1)) value_ = lua_tointeger(L, -1);
		*(int64*)start_pos = value_;
		len += sizeof(int64);
	}
	else if (type == "bool"){
		int32 value_ = 0;
		if (lua_isboolean(L, -1)) value_ = lua_toboolean(L, -1);
		if (value_ > 0) *(uint8*)start_pos = 1;
		else *(uint8*)start_pos = 0;
		len += sizeof(uint8);
	}
	else if (type == "double")
	{
		double value_ = false;
		if (lua_isnumber(L, -1)) value_ = lua_tonumber(L, -1);
		*(double*)start_pos = value_;
		len += sizeof(double);
	}
	else if (type == "string"){
		uint16 strlen_ = 0;
		string value_ = "";
		if (lua_isstring(L, -1)) value_ = lua_tostring(L, -1);
		strlen_ = value_.length();
		*(uint16*)start_pos = strlen_;
		start_pos += sizeof(uint16);
		len += sizeof(uint16) + strlen_;
		memcpy(start_pos, value_.c_str(), strlen_);
	}
	else	{
		if (!this->get_element(data, len, type, L)) return false;
	}
	return true;
}
