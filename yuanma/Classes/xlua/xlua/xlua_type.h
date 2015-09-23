
#ifndef _XLUA_TYPE_H_
#define _XLUA_TYPE_H_

#include "types_define.h"
#include "smart_ptr.h"
#include "lua.hpp"

namespace xlua {

class LuaObject;
class LuaFunction;
class LuaTable;
class LuaModule;
class LuaThread;
class LuaState;
class LuaTableIterator;
typedef xcore::shared_ptr<LuaObject> LuaObjectPtr;
typedef xcore::shared_ptr<LuaTable> LuaTablePtr;
typedef xcore::shared_ptr<LuaThread> LuaThreadPtr;
typedef xcore::shared_ptr<LuaState> LuaStatePtr;
struct LuaNil {};

}//namespace xlua

using namespace xlua;

#endif//_XLUA_TYPE_H_
