// 2014-04-30
// xlua_object.h
// guosh
// lua对象支持类

#include "xlua_type.h"

#ifndef _XLUA_OBJECT_H_
#define _XLUA_OBJECT_H_

namespace xlua {

////////////////////////////////////////////////////////////////////////////////
// class LuaObject
// 调用lua函数出错时，栈上的错误字符串作为一种特殊的类型，也生成一个LuaObject
////////////////////////////////////////////////////////////////////////////////
class LuaObject : public xcore::enable_shared_from_this<LuaObject>
{
	friend class LuaThread;
	friend class LuaFunction;
	friend class LuaModule;
	friend class LuaTable;
	friend class LuaTableIterator;
	LuaThreadPtr m_ptrThread;
	LuaObjectPtr m_ptrParentObject; // 父对象
	int m_stack_idx;
	bool m_is_error;

	LuaObject(LuaThreadPtr ptrThread, int stack_idx, LuaObjectPtr ptrParentObject, bool is_error = false);
	LuaObject(const LuaObject&);            // not implemented
	LuaObject& operator=(const LuaObject&); // not implemented

public:
	virtual ~LuaObject();

	string TypeName() const;

	bool IsNil() const;
	bool IsBoolean() const;
	bool IsNumber() const;
	bool IsString() const;
	bool IsUserData() const;
	bool IsLightUserData() const;
	bool IsTable() const;
	bool IsThread() const;
	bool IsCFunction() const; // is c function
	bool IsFunction() const; // is lua function
	bool IsNone() const; // not a lua object
	bool IsError() const; // LUA函数调用失败返回的错误

	bool   ToBoolean();
	double ToNumber();
	string ToString();
	void*  ToUserData();
	void*  ToLightUserData();
	LuaTablePtr ToTable();
	LuaFunction ToFunction();

	void Push();
	void Print();
};

}

#endif//_XLUA_OBJECT_H_
