// 2014-04-30
// xlua_function.h
// guosh
// lua函数支持类

#include "xlua_type.h"
#include "xlua_object.h"
#include "lua_tinker.h"

#ifndef _XLUA_FUNCTION_H_
#define _XLUA_FUNCTION_H_

namespace xlua {

////////////////////////////////////////////////////////////////////////////////
// class LuaFunction
////////////////////////////////////////////////////////////////////////////////
class LuaFunction
{
	friend class LuaObject;
	LuaObjectPtr m_ptrObject;

	LuaFunction(LuaObjectPtr ptrObject)
		: m_ptrObject(ptrObject)
	{
		ASSERT(m_ptrObject.get());
		ASSERT(lua_isfunction(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx));
	}

public:
	LuaObjectPtr operator()()
	{
		lua_checkstack(*m_ptrObject->m_ptrThread, 1);
		lua_pushvalue(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
		if (lua_pcall(*m_ptrObject->m_ptrThread, 0, 1, 0))
		{
			printf("lua_pcall error: %s\n", lua_tostring(*m_ptrObject->m_ptrThread, -1));
			return LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject, true));
		}

		return LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject));
	}

	template <typename P1>
	LuaObjectPtr operator()(P1 p1)
	{
		lua_checkstack(*m_ptrObject->m_ptrThread, 2);
		lua_pushvalue(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p1);
		m_ptrObject->m_ptrThread->PrintStack();
		if (lua_pcall(*m_ptrObject->m_ptrThread, 1, 1, 0))
		{
			std::string str = lua_tostring(*m_ptrObject->m_ptrThread, -1);
			m_ptrObject->m_ptrThread->PrintStack();

			printf("lua_pcall error: %s\n", lua_tostring(*m_ptrObject->m_ptrThread, -1));

			return LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject, true));
		}
		m_ptrObject->m_ptrThread->PrintStack();

		return LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject));
	}

	template <typename P1, typename P2>
	LuaObjectPtr operator()(P1 p1, P2 p2)
	{
		lua_checkstack(*m_ptrObject->m_ptrThread, 3);
		lua_pushvalue(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p1);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p2);
		if (lua_pcall(*m_ptrObject->m_ptrThread, 2, 1, 0))
		{
			printf("lua_pcall error: %s\n", lua_tostring(*m_ptrObject->m_ptrThread, -1));
			return LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject, true));
		}

		return LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject));
	}

	template <typename P1, typename P2, typename P3>
	LuaObjectPtr operator()(P1 p1, P2 p2, P3 p3)
	{
		lua_checkstack(*m_ptrObject->m_ptrThread, 4);
		lua_pushvalue(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p1);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p2);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p3);
		if (lua_pcall(*m_ptrObject->m_ptrThread, 3, 1, 0))
		{
			printf("lua_pcall error: %s\n", lua_tostring(*m_ptrObject->m_ptrThread, -1));
			return LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject, true));
		}
		return LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject));
	}

	template <typename P1, typename P2, typename P3, typename P4>
	LuaObjectPtr operator()(P1 p1, P2 p2, P3 p3, P4 p4)
	{
		lua_checkstack(*m_ptrObject->m_ptrThread, 5);
		lua_pushvalue(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p1);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p2);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p3);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p4);
		if (lua_pcall(*m_ptrObject->m_ptrThread, 4, 1, 0))
		{
			printf("lua_pcall error: %s\n", lua_tostring(*m_ptrObject->m_ptrThread, -1));
			return LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject, true));
		}

		return LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject));
	}

	template <typename P1, typename P2, typename P3, typename P4, typename P5>
	LuaObjectPtr operator()(P1 p1, P2 p2, P3 p3, P4 p4, P5 p5)
	{
		lua_checkstack(*m_ptrObject->m_ptrThread, 6);
		lua_pushvalue(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p1);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p2);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p3);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p4);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p5);
		if (lua_pcall(*m_ptrObject->m_ptrThread, 5, 1, 0))
		{
			printf("lua_pcall error: %s\n", lua_tostring(*m_ptrObject->m_ptrThread, -1));
			return LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject, true));
		}

		return LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject));
	}

	template <typename P1, typename P2, typename P3, typename P4, typename P5, typename P6>
	LuaObjectPtr operator()(P1 p1, P2 p2, P3 p3, P4 p4, P5 p5, P6 p6)
	{
		lua_checkstack(*m_ptrObject->m_ptrThread, 7);
		lua_pushvalue(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p1);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p2);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p3);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p4);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p5);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p6);
		if (lua_pcall(*m_ptrObject->m_ptrThread, 6, 1, 0))
		{
			printf("lua_pcall error: %s\n", lua_tostring(*m_ptrObject->m_ptrThread, -1));
			return LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject, true));
		}

		return LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject));
	}

	template <typename P1, typename P2, typename P3, typename P4, typename P5, typename P6, typename P7>
	LuaObjectPtr operator()(P1 p1, P2 p2, P3 p3, P4 p4, P5 p5, P6 p6, P7 p7)
	{
		lua_checkstack(*m_ptrObject->m_ptrThread, 8);
		lua_pushvalue(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p1);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p2);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p3);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p4);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p5);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p6);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p7);
		if (lua_pcall(*m_ptrObject->m_ptrThread, 7, 1, 0))
		{
			printf("lua_pcall error: %s\n", lua_tostring(*m_ptrObject->m_ptrThread, -1));
			return LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject, true));
		}

		return LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject));
	}

	template <typename P1, typename P2, typename P3, typename P4, typename P5, typename P6, typename P7, typename P8>
	LuaObjectPtr operator()(P1 p1, P2 p2, P3 p3, P4 p4, P5 p5, P6 p6, P7 p7, P8 p8)
	{
		lua_checkstack(*m_ptrObject->m_ptrThread, 9);
		lua_pushvalue(*m_ptrObject->m_ptrThread, m_ptrObject->m_stack_idx);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p1);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p2);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p3);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p4);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p5);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p6);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p7);
		lua_tinker::push(*m_ptrObject->m_ptrThread, p8);
		if (lua_pcall(*m_ptrObject->m_ptrThread, 8, 1, 0))
		{
			printf("lua_pcall error: %s\n", lua_tostring(*m_ptrObject->m_ptrThread, -1));
			return LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject, true));
		}

		return LuaObjectPtr(new LuaObject(m_ptrObject->m_ptrThread, lua_gettop(*m_ptrObject->m_ptrThread), m_ptrObject));
	}
};
}//namespace xlua

using namespace xlua;

#endif//_XLUA_FUNCTION_H_

