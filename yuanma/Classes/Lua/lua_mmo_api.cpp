#include "lua_mmo_api.hpp"
#include "MMO.h"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"



int lua_mmo_api_VisibleRect_leftBottom(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"VisibleRect",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_VisibleRect_leftBottom'", nullptr);
            return 0;
        }
        cocos2d::Vec2 ret = VisibleRect::leftBottom();
        vec2_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "VisibleRect:leftBottom",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_VisibleRect_leftBottom'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_VisibleRect_rightBottom(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"VisibleRect",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_VisibleRect_rightBottom'", nullptr);
            return 0;
        }
        cocos2d::Vec2 ret = VisibleRect::rightBottom();
        vec2_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "VisibleRect:rightBottom",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_VisibleRect_rightBottom'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_VisibleRect_right(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"VisibleRect",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_VisibleRect_right'", nullptr);
            return 0;
        }
        cocos2d::Vec2 ret = VisibleRect::right();
        vec2_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "VisibleRect:right",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_VisibleRect_right'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_VisibleRect_center(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"VisibleRect",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_VisibleRect_center'", nullptr);
            return 0;
        }
        cocos2d::Vec2 ret = VisibleRect::center();
        vec2_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "VisibleRect:center",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_VisibleRect_center'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_VisibleRect_bottom(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"VisibleRect",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_VisibleRect_bottom'", nullptr);
            return 0;
        }
        cocos2d::Vec2 ret = VisibleRect::bottom();
        vec2_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "VisibleRect:bottom",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_VisibleRect_bottom'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_VisibleRect_getVisibleRect(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"VisibleRect",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_VisibleRect_getVisibleRect'", nullptr);
            return 0;
        }
        cocos2d::Rect ret = VisibleRect::getVisibleRect();
        rect_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "VisibleRect:getVisibleRect",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_VisibleRect_getVisibleRect'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_VisibleRect_getVisibleSize(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"VisibleRect",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_VisibleRect_getVisibleSize'", nullptr);
            return 0;
        }
        cocos2d::Size ret = VisibleRect::getVisibleSize();
        size_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "VisibleRect:getVisibleSize",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_VisibleRect_getVisibleSize'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_VisibleRect_height(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"VisibleRect",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_VisibleRect_height'", nullptr);
            return 0;
        }
        double ret = VisibleRect::height();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "VisibleRect:height",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_VisibleRect_height'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_VisibleRect_width(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"VisibleRect",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_VisibleRect_width'", nullptr);
            return 0;
        }
        double ret = VisibleRect::width();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "VisibleRect:width",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_VisibleRect_width'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_VisibleRect_leftTop(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"VisibleRect",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_VisibleRect_leftTop'", nullptr);
            return 0;
        }
        cocos2d::Vec2 ret = VisibleRect::leftTop();
        vec2_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "VisibleRect:leftTop",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_VisibleRect_leftTop'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_VisibleRect_rightTop(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"VisibleRect",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_VisibleRect_rightTop'", nullptr);
            return 0;
        }
        cocos2d::Vec2 ret = VisibleRect::rightTop();
        vec2_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "VisibleRect:rightTop",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_VisibleRect_rightTop'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_VisibleRect_top(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"VisibleRect",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_VisibleRect_top'", nullptr);
            return 0;
        }
        cocos2d::Vec2 ret = VisibleRect::top();
        vec2_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "VisibleRect:top",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_VisibleRect_top'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_VisibleRect_left(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"VisibleRect",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_VisibleRect_left'", nullptr);
            return 0;
        }
        cocos2d::Vec2 ret = VisibleRect::left();
        vec2_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "VisibleRect:left",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_VisibleRect_left'.",&tolua_err);
#endif
    return 0;
}
static int lua_mmo_api_VisibleRect_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (VisibleRect)");
    return 0;
}

int lua_register_mmo_api_VisibleRect(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"VisibleRect");
    tolua_cclass(tolua_S,"VisibleRect","VisibleRect","",nullptr);

    tolua_beginmodule(tolua_S,"VisibleRect");
        tolua_function(tolua_S,"leftBottom", lua_mmo_api_VisibleRect_leftBottom);
        tolua_function(tolua_S,"rightBottom", lua_mmo_api_VisibleRect_rightBottom);
        tolua_function(tolua_S,"right", lua_mmo_api_VisibleRect_right);
        tolua_function(tolua_S,"center", lua_mmo_api_VisibleRect_center);
        tolua_function(tolua_S,"bottom", lua_mmo_api_VisibleRect_bottom);
        tolua_function(tolua_S,"getVisibleRect", lua_mmo_api_VisibleRect_getVisibleRect);
        tolua_function(tolua_S,"getVisibleSize", lua_mmo_api_VisibleRect_getVisibleSize);
        tolua_function(tolua_S,"height", lua_mmo_api_VisibleRect_height);
        tolua_function(tolua_S,"width", lua_mmo_api_VisibleRect_width);
        tolua_function(tolua_S,"leftTop", lua_mmo_api_VisibleRect_leftTop);
        tolua_function(tolua_S,"rightTop", lua_mmo_api_VisibleRect_rightTop);
        tolua_function(tolua_S,"top", lua_mmo_api_VisibleRect_top);
        tolua_function(tolua_S,"left", lua_mmo_api_VisibleRect_left);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(VisibleRect).name();
    g_luaType[typeName] = "VisibleRect";
    g_typeCast["VisibleRect"] = "VisibleRect";
    return 1;
}

int lua_mmo_api_HelpFunc_gTimeToFrames(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        double arg0;
        ok &= luaval_to_number(tolua_S, 2,&arg0, "HelpFunc:gTimeToFrames");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_gTimeToFrames'", nullptr);
            return 0;
        }
        int ret = HelpFunc::gTimeToFrames(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:gTimeToFrames",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_gTimeToFrames'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_setZoneId(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "HelpFunc:setZoneId");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_setZoneId'", nullptr);
            return 0;
        }
        HelpFunc::setZoneId(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:setZoneId",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_setZoneId'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_switchAccountZTGame(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_switchAccountZTGame'", nullptr);
            return 0;
        }
        HelpFunc::switchAccountZTGame();
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:switchAccountZTGame",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_switchAccountZTGame'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_setIsPlayingVideo(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        bool arg0;
        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "HelpFunc:setIsPlayingVideo");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_setIsPlayingVideo'", nullptr);
            return 0;
        }
        HelpFunc::setIsPlayingVideo(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:setIsPlayingVideo",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_setIsPlayingVideo'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_isHasQuitDialog(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_isHasQuitDialog'", nullptr);
            return 0;
        }
        bool ret = HelpFunc::isHasQuitDialog();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:isHasQuitDialog",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_isHasQuitDialog'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_setLongRecordTime(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        int arg0;
        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "HelpFunc:setLongRecordTime");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_setLongRecordTime'", nullptr);
            return 0;
        }
        HelpFunc::setLongRecordTime(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:setLongRecordTime",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_setLongRecordTime'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_removeWaveEffectByShader(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        cocos2d::Sprite3D* arg0;
        ok &= luaval_to_object<cocos2d::Sprite3D>(tolua_S, 2, "cc.Sprite3D",&arg0);
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_removeWaveEffectByShader'", nullptr);
            return 0;
        }
        HelpFunc::removeWaveEffectByShader(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:removeWaveEffectByShader",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_removeWaveEffectByShader'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_cancelVibrate(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_cancelVibrate'", nullptr);
            return 0;
        }
        HelpFunc::cancelVibrate();
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:cancelVibrate",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_cancelVibrate'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_roleLevelUpZTGame(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 5)
    {
        std::string arg0;
        std::string arg1;
        std::string arg2;
        std::string arg3;
        int arg4;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "HelpFunc:roleLevelUpZTGame");
        ok &= luaval_to_std_string(tolua_S, 3,&arg1, "HelpFunc:roleLevelUpZTGame");
        ok &= luaval_to_std_string(tolua_S, 4,&arg2, "HelpFunc:roleLevelUpZTGame");
        ok &= luaval_to_std_string(tolua_S, 5,&arg3, "HelpFunc:roleLevelUpZTGame");
        ok &= luaval_to_int32(tolua_S, 6,(int *)&arg4, "HelpFunc:roleLevelUpZTGame");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_roleLevelUpZTGame'", nullptr);
            return 0;
        }
        HelpFunc::roleLevelUpZTGame(arg0, arg1, arg2, arg3, arg4);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:roleLevelUpZTGame",argc, 5);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_roleLevelUpZTGame'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_createNormalMappedNode(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 5)
    {
        cocos2d::Node* arg0;
        std::string arg1;
        std::string arg2;
        std::string arg3;
        int arg4;
        ok &= luaval_to_object<cocos2d::Node>(tolua_S, 2, "cc.Node",&arg0);
        ok &= luaval_to_std_string(tolua_S, 3,&arg1, "HelpFunc:createNormalMappedNode");
        ok &= luaval_to_std_string(tolua_S, 4,&arg2, "HelpFunc:createNormalMappedNode");
        ok &= luaval_to_std_string(tolua_S, 5,&arg3, "HelpFunc:createNormalMappedNode");
        ok &= luaval_to_int32(tolua_S, 6,(int *)&arg4, "HelpFunc:createNormalMappedNode");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_createNormalMappedNode'", nullptr);
            return 0;
        }
        cocos2d::Node* ret = HelpFunc::createNormalMappedNode(arg0, arg1, arg2, arg3, arg4);
        object_to_luaval<cocos2d::Node>(tolua_S, "cc.Node",(cocos2d::Node*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:createNormalMappedNode",argc, 5);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_createNormalMappedNode'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_getSystemSTime(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_getSystemSTime'", nullptr);
            return 0;
        }
        long long ret = HelpFunc::getSystemSTime();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:getSystemSTime",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_getSystemSTime'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_setShortRecordTime(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        int arg0;
        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "HelpFunc:setShortRecordTime");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_setShortRecordTime'", nullptr);
            return 0;
        }
        HelpFunc::setShortRecordTime(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:setShortRecordTime",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_setShortRecordTime'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_playVibrator(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        int arg0;
        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "HelpFunc:playVibrator");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_playVibrator'", nullptr);
            return 0;
        }
        HelpFunc::playVibrator(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:playVibrator",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_playVibrator'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_quitZTGame(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_quitZTGame'", nullptr);
            return 0;
        }
        HelpFunc::quitZTGame();
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:quitZTGame",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_quitZTGame'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_gFramesToTime(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        int arg0;
        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "HelpFunc:gFramesToTime");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_gFramesToTime'", nullptr);
            return 0;
        }
        double ret = HelpFunc::gFramesToTime(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:gFramesToTime",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_gFramesToTime'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_getSystemMTime(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_getSystemMTime'", nullptr);
            return 0;
        }
        long long ret = HelpFunc::getSystemMTime();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:getSystemMTime",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_getSystemMTime'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_gAngleAnalyseForRotation(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 4)
    {
        double arg0;
        double arg1;
        double arg2;
        double arg3;
        ok &= luaval_to_number(tolua_S, 2,&arg0, "HelpFunc:gAngleAnalyseForRotation");
        ok &= luaval_to_number(tolua_S, 3,&arg1, "HelpFunc:gAngleAnalyseForRotation");
        ok &= luaval_to_number(tolua_S, 4,&arg2, "HelpFunc:gAngleAnalyseForRotation");
        ok &= luaval_to_number(tolua_S, 5,&arg3, "HelpFunc:gAngleAnalyseForRotation");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_gAngleAnalyseForRotation'", nullptr);
            return 0;
        }
        double ret = HelpFunc::gAngleAnalyseForRotation(arg0, arg1, arg2, arg3);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:gAngleAnalyseForRotation",argc, 4);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_gAngleAnalyseForRotation'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_isSocketConnect(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_isSocketConnect'", nullptr);
            return 0;
        }
        bool ret = HelpFunc::isSocketConnect();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:isSocketConnect",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_isSocketConnect'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_vibrateWithPattern(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        cocos2d::ValueVector arg0;
        int arg1;
        ok &= luaval_to_ccvaluevector(tolua_S, 2, &arg0, "HelpFunc:vibrateWithPattern");
        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "HelpFunc:vibrateWithPattern");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_vibrateWithPattern'", nullptr);
            return 0;
        }
        HelpFunc::vibrateWithPattern(arg0, arg1);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:vibrateWithPattern",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_vibrateWithPattern'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_setVibratorEnabled(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        bool arg0;
        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "HelpFunc:setVibratorEnabled");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_setVibratorEnabled'", nullptr);
            return 0;
        }
        HelpFunc::setVibratorEnabled(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:setVibratorEnabled",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_setVibratorEnabled'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_isHasCenterZTGame(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_isHasCenterZTGame'", nullptr);
            return 0;
        }
        bool ret = HelpFunc::isHasCenterZTGame();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:isHasCenterZTGame",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_isHasCenterZTGame'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_playVoice(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "HelpFunc:playVoice");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_playVoice'", nullptr);
            return 0;
        }
        HelpFunc::playVoice(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:playVoice",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_playVoice'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_setNeedToRestartVideo(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        bool arg0;
        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "HelpFunc:setNeedToRestartVideo");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_setNeedToRestartVideo'", nullptr);
            return 0;
        }
        HelpFunc::setNeedToRestartVideo(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:setNeedToRestartVideo",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_setNeedToRestartVideo'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_removeAllTimelineActions(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_removeAllTimelineActions'", nullptr);
            return 0;
        }
        HelpFunc::removeAllTimelineActions();
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:removeAllTimelineActions",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_removeAllTimelineActions'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_onRegister(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "HelpFunc:onRegister");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_onRegister'", nullptr);
            return 0;
        }
        HelpFunc::onRegister(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:onRegister",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_onRegister'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_isPlayingVideo(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_isPlayingVideo'", nullptr);
            return 0;
        }
        bool ret = HelpFunc::isPlayingVideo();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:isPlayingVideo",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_isPlayingVideo'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_doRippleNodeTouch(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 4)
    {
        cocos2d::Node* arg0;
        cocos2d::Point arg1;
        double arg2;
        double arg3;
        ok &= luaval_to_object<cocos2d::Node>(tolua_S, 2, "cc.Node",&arg0);
        ok &= luaval_to_point(tolua_S, 3, &arg1, "HelpFunc:doRippleNodeTouch");
        ok &= luaval_to_number(tolua_S, 4,&arg2, "HelpFunc:doRippleNodeTouch");
        ok &= luaval_to_number(tolua_S, 5,&arg3, "HelpFunc:doRippleNodeTouch");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_doRippleNodeTouch'", nullptr);
            return 0;
        }
        HelpFunc::doRippleNodeTouch(arg0, arg1, arg2, arg3);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:doRippleNodeTouch",argc, 4);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_doRippleNodeTouch'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_loginZTGame(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 3)
    {
        std::string arg0;
        std::string arg1;
        bool arg2;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "HelpFunc:loginZTGame");
        ok &= luaval_to_std_string(tolua_S, 3,&arg1, "HelpFunc:loginZTGame");
        ok &= luaval_to_boolean(tolua_S, 4,&arg2, "HelpFunc:loginZTGame");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_loginZTGame'", nullptr);
            return 0;
        }
        HelpFunc::loginZTGame(arg0, arg1, arg2);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:loginZTGame",argc, 3);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_loginZTGame'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_bitAnd(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        int arg0;
        int arg1;
        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "HelpFunc:bitAnd");
        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "HelpFunc:bitAnd");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_bitAnd'", nullptr);
            return 0;
        }
        int ret = HelpFunc::bitAnd(arg0, arg1);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:bitAnd",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_bitAnd'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_setUserIDForBugly(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "HelpFunc:setUserIDForBugly");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_setUserIDForBugly'", nullptr);
            return 0;
        }
        HelpFunc::setUserIDForBugly(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:setUserIDForBugly",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_setUserIDForBugly'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_addWaveEffectByShader(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 4)
    {
        cocos2d::Sprite3D* arg0;
        std::string arg1;
        std::string arg2;
        cocos2d::Vec4 arg3;
        ok &= luaval_to_object<cocos2d::Sprite3D>(tolua_S, 2, "cc.Sprite3D",&arg0);
        ok &= luaval_to_std_string(tolua_S, 3,&arg1, "HelpFunc:addWaveEffectByShader");
        ok &= luaval_to_std_string(tolua_S, 4,&arg2, "HelpFunc:addWaveEffectByShader");
        ok &= luaval_to_vec4(tolua_S, 5, &arg3, "HelpFunc:addWaveEffectByShader");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_addWaveEffectByShader'", nullptr);
            return 0;
        }
        HelpFunc::addWaveEffectByShader(arg0, arg1, arg2, arg3);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:addWaveEffectByShader",argc, 4);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_addWaveEffectByShader'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_gXorCoding(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "HelpFunc:gXorCoding");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_gXorCoding'", nullptr);
            return 0;
        }
        std::string ret = HelpFunc::gXorCoding(arg0);
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:gXorCoding",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_gXorCoding'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_gGetMinuteStr(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        double arg0;
        ok &= luaval_to_number(tolua_S, 2,&arg0, "HelpFunc:gGetMinuteStr");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_gGetMinuteStr'", nullptr);
            return 0;
        }
        std::string ret = HelpFunc::gGetMinuteStr(arg0);
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:gGetMinuteStr",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_gGetMinuteStr'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_print(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "HelpFunc:print");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_print'", nullptr);
            return 0;
        }
        HelpFunc::print(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:print",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_print'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_showWaveEffectByShader(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        cocos2d::Sprite3D* arg0;
        ok &= luaval_to_object<cocos2d::Sprite3D>(tolua_S, 2, "cc.Sprite3D",&arg0);
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_showWaveEffectByShader'", nullptr);
            return 0;
        }
        HelpFunc::showWaveEffectByShader(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:showWaveEffectByShader",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_showWaveEffectByShader'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_createRippleNode(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "HelpFunc:createRippleNode");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_createRippleNode'", nullptr);
            return 0;
        }
        cocos2d::Node* ret = HelpFunc::createRippleNode(arg0);
        object_to_luaval<cocos2d::Node>(tolua_S, "cc.Node",(cocos2d::Node*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:createRippleNode",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_createRippleNode'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_pressRecordVoice(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_pressRecordVoice'", nullptr);
            return 0;
        }
        HelpFunc::pressRecordVoice();
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:pressRecordVoice",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_pressRecordVoice'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_gNumToStr(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        int arg0;
        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "HelpFunc:gNumToStr");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_gNumToStr'", nullptr);
            return 0;
        }
        std::string ret = HelpFunc::gNumToStr(arg0);
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:gNumToStr",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_gNumToStr'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_getRefCount(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        cocos2d::Ref* arg0;
        ok &= luaval_to_object<cocos2d::Ref>(tolua_S, 2, "cc.Ref",&arg0);
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_getRefCount'", nullptr);
            return 0;
        }
        int ret = HelpFunc::getRefCount(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:getRefCount",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_getRefCount'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_getCollidingDirections(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        cocos2d::Rect arg0;
        cocos2d::Rect arg1;
        ok &= luaval_to_rect(tolua_S, 2, &arg0, "HelpFunc:getCollidingDirections");
        ok &= luaval_to_rect(tolua_S, 3, &arg1, "HelpFunc:getCollidingDirections");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_getCollidingDirections'", nullptr);
            return 0;
        }
        int ret = HelpFunc::getCollidingDirections(arg0, arg1);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:getCollidingDirections",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_getCollidingDirections'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_enterCenterZTGame(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_enterCenterZTGame'", nullptr);
            return 0;
        }
        HelpFunc::enterCenterZTGame();
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:enterCenterZTGame",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_enterCenterZTGame'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_gCreateFileWithContent(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        std::string arg0;
        std::string arg1;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "HelpFunc:gCreateFileWithContent");
        ok &= luaval_to_std_string(tolua_S, 3,&arg1, "HelpFunc:gCreateFileWithContent");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_gCreateFileWithContent'", nullptr);
            return 0;
        }
        HelpFunc::gCreateFileWithContent(arg0, arg1);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:gCreateFileWithContent",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_gCreateFileWithContent'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_gGetRandNumber(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        int arg0;
        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "HelpFunc:gGetRandNumber");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_gGetRandNumber'", nullptr);
            return 0;
        }
        int ret = HelpFunc::gGetRandNumber(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:gGetRandNumber",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_gGetRandNumber'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_getPlatform(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_getPlatform'", nullptr);
            return 0;
        }
        int ret = HelpFunc::getPlatform();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:getPlatform",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_getPlatform'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_gTimeToStr(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        double arg0;
        ok &= luaval_to_number(tolua_S, 2,&arg0, "HelpFunc:gTimeToStr");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_gTimeToStr'", nullptr);
            return 0;
        }
        std::string ret = HelpFunc::gTimeToStr(arg0);
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:gTimeToStr",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_gTimeToStr'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_gShowRectLogInfo(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        cocos2d::Rect arg0;
        ok &= luaval_to_rect(tolua_S, 2, &arg0, "HelpFunc:gShowRectLogInfo");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_gShowRectLogInfo'", nullptr);
            return 0;
        }
        HelpFunc::gShowRectLogInfo(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:gShowRectLogInfo",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_gShowRectLogInfo'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_gAngleAnalyseForQuad(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 4)
    {
        double arg0;
        double arg1;
        double arg2;
        double arg3;
        ok &= luaval_to_number(tolua_S, 2,&arg0, "HelpFunc:gAngleAnalyseForQuad");
        ok &= luaval_to_number(tolua_S, 3,&arg1, "HelpFunc:gAngleAnalyseForQuad");
        ok &= luaval_to_number(tolua_S, 4,&arg2, "HelpFunc:gAngleAnalyseForQuad");
        ok &= luaval_to_number(tolua_S, 5,&arg3, "HelpFunc:gAngleAnalyseForQuad");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_gAngleAnalyseForQuad'", nullptr);
            return 0;
        }
        double ret = HelpFunc::gAngleAnalyseForQuad(arg0, arg1, arg2, arg3);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:gAngleAnalyseForQuad",argc, 4);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_gAngleAnalyseForQuad'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_cancelSendVoice(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_cancelSendVoice'", nullptr);
            return 0;
        }
        HelpFunc::cancelSendVoice();
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:cancelSendVoice",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_cancelSendVoice'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_payZTGame(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 7)
    {
        std::string arg0;
        std::string arg1;
        std::string arg2;
        int arg3;
        int arg4;
        bool arg5;
        std::string arg6;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "HelpFunc:payZTGame");
        ok &= luaval_to_std_string(tolua_S, 3,&arg1, "HelpFunc:payZTGame");
        ok &= luaval_to_std_string(tolua_S, 4,&arg2, "HelpFunc:payZTGame");
        ok &= luaval_to_int32(tolua_S, 5,(int *)&arg3, "HelpFunc:payZTGame");
        ok &= luaval_to_int32(tolua_S, 6,(int *)&arg4, "HelpFunc:payZTGame");
        ok &= luaval_to_boolean(tolua_S, 7,&arg5, "HelpFunc:payZTGame");
        ok &= luaval_to_std_string(tolua_S, 8,&arg6, "HelpFunc:payZTGame");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_payZTGame'", nullptr);
            return 0;
        }
        HelpFunc::payZTGame(arg0, arg1, arg2, arg3, arg4, arg5, arg6);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:payZTGame",argc, 7);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_payZTGame'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_gGetRandNumberBetween(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        int arg0;
        int arg1;
        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "HelpFunc:gGetRandNumberBetween");
        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "HelpFunc:gGetRandNumberBetween");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_gGetRandNumberBetween'", nullptr);
            return 0;
        }
        int ret = HelpFunc::gGetRandNumberBetween(arg0, arg1);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:gGetRandNumberBetween",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_gGetRandNumberBetween'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_hideWaveEffectByShader(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        cocos2d::Sprite3D* arg0;
        ok &= luaval_to_object<cocos2d::Sprite3D>(tolua_S, 2, "cc.Sprite3D",&arg0);
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_hideWaveEffectByShader'", nullptr);
            return 0;
        }
        HelpFunc::hideWaveEffectByShader(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:hideWaveEffectByShader",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_hideWaveEffectByShader'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_isLogined(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_isLogined'", nullptr);
            return 0;
        }
        bool ret = HelpFunc::isLogined();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:isLogined",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_isLogined'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_createRoleZTGame(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 5)
    {
        std::string arg0;
        std::string arg1;
        std::string arg2;
        std::string arg3;
        std::string arg4;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "HelpFunc:createRoleZTGame");
        ok &= luaval_to_std_string(tolua_S, 3,&arg1, "HelpFunc:createRoleZTGame");
        ok &= luaval_to_std_string(tolua_S, 4,&arg2, "HelpFunc:createRoleZTGame");
        ok &= luaval_to_std_string(tolua_S, 5,&arg3, "HelpFunc:createRoleZTGame");
        ok &= luaval_to_std_string(tolua_S, 6,&arg4, "HelpFunc:createRoleZTGame");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_createRoleZTGame'", nullptr);
            return 0;
        }
        HelpFunc::createRoleZTGame(arg0, arg1, arg2, arg3, arg4);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:createRoleZTGame",argc, 5);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_createRoleZTGame'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_initDuduVoice(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        int arg0;
        int arg1;
        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "HelpFunc:initDuduVoice");
        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "HelpFunc:initDuduVoice");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_initDuduVoice'", nullptr);
            return 0;
        }
        HelpFunc::initDuduVoice(arg0, arg1);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:initDuduVoice",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_initDuduVoice'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_createLightNode(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "HelpFunc:createLightNode");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_createLightNode'", nullptr);
            return 0;
        }
        cocos2d::Node* ret = HelpFunc::createLightNode(arg0);
        object_to_luaval<cocos2d::Node>(tolua_S, "cc.Node",(cocos2d::Node*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:createLightNode",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_createLightNode'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_gDirectionAnalyse(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 4)
    {
        double arg0;
        double arg1;
        double arg2;
        double arg3;
        ok &= luaval_to_number(tolua_S, 2,&arg0, "HelpFunc:gDirectionAnalyse");
        ok &= luaval_to_number(tolua_S, 3,&arg1, "HelpFunc:gDirectionAnalyse");
        ok &= luaval_to_number(tolua_S, 4,&arg2, "HelpFunc:gDirectionAnalyse");
        ok &= luaval_to_number(tolua_S, 5,&arg3, "HelpFunc:gDirectionAnalyse");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_gDirectionAnalyse'", nullptr);
            return 0;
        }
        int ret = HelpFunc::gDirectionAnalyse(arg0, arg1, arg2, arg3);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:gDirectionAnalyse",argc, 4);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_gDirectionAnalyse'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_getSystemMSTime(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_getSystemMSTime'", nullptr);
            return 0;
        }
        long long ret = HelpFunc::getSystemMSTime();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:getSystemMSTime",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_getSystemMSTime'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_enableDebugMode(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_enableDebugMode'", nullptr);
            return 0;
        }
        HelpFunc::enableDebugMode();
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:enableDebugMode",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_enableDebugMode'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_setMaxTouchesNum(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        int arg0;
        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "HelpFunc:setMaxTouchesNum");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_setMaxTouchesNum'", nullptr);
            return 0;
        }
        HelpFunc::setMaxTouchesNum(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:setMaxTouchesNum",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_setMaxTouchesNum'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_gDirectionAnalyseByAngle(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        double arg0;
        ok &= luaval_to_number(tolua_S, 2,&arg0, "HelpFunc:gDirectionAnalyseByAngle");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_gDirectionAnalyseByAngle'", nullptr);
            return 0;
        }
        int ret = HelpFunc::gDirectionAnalyseByAngle(arg0);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:gDirectionAnalyseByAngle",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_gDirectionAnalyseByAngle'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_removeAllSprite3DData(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_removeAllSprite3DData'", nullptr);
            return 0;
        }
        HelpFunc::removeAllSprite3DData();
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:removeAllSprite3DData",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_removeAllSprite3DData'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_onLogin(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "HelpFunc:onLogin");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_onLogin'", nullptr);
            return 0;
        }
        HelpFunc::onLogin(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:onLogin",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_onLogin'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_releaseSendVoice(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_releaseSendVoice'", nullptr);
            return 0;
        }
        HelpFunc::releaseSendVoice();
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:releaseSendVoice",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_releaseSendVoice'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_isNeedToRestartVideo(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_isNeedToRestartVideo'", nullptr);
            return 0;
        }
        bool ret = HelpFunc::isNeedToRestartVideo();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:isNeedToRestartVideo",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_isNeedToRestartVideo'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_createWebView(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        cocos2d::Node* arg0;
        std::string arg1;
        ok &= luaval_to_object<cocos2d::Node>(tolua_S, 2, "cc.Node",&arg0);
        ok &= luaval_to_std_string(tolua_S, 3,&arg1, "HelpFunc:createWebView");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_createWebView'", nullptr);
            return 0;
        }
        HelpFunc::createWebView(arg0, arg1);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:createWebView",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_createWebView'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_share(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 5)
    {
        const char* arg0;
        const char* arg1;
        const char* arg2;
        const char* arg3;
        const char* arg4;
        std::string arg0_tmp; ok &= luaval_to_std_string(tolua_S, 2, &arg0_tmp, "HelpFunc:share"); arg0 = arg0_tmp.c_str();
        std::string arg1_tmp; ok &= luaval_to_std_string(tolua_S, 3, &arg1_tmp, "HelpFunc:share"); arg1 = arg1_tmp.c_str();
        std::string arg2_tmp; ok &= luaval_to_std_string(tolua_S, 4, &arg2_tmp, "HelpFunc:share"); arg2 = arg2_tmp.c_str();
        std::string arg3_tmp; ok &= luaval_to_std_string(tolua_S, 5, &arg3_tmp, "HelpFunc:share"); arg3 = arg3_tmp.c_str();
        std::string arg4_tmp; ok &= luaval_to_std_string(tolua_S, 6, &arg4_tmp, "HelpFunc:share"); arg4 = arg4_tmp.c_str();
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_share'", nullptr);
            return 0;
        }
        HelpFunc::share(arg0, arg1, arg2, arg3, arg4);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:share",argc, 5);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_share'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_bitOr(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        int arg0;
        int arg1;
        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "HelpFunc:bitOr");
        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "HelpFunc:bitOr");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_bitOr'", nullptr);
            return 0;
        }
        int ret = HelpFunc::bitOr(arg0, arg1);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:bitOr",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_bitOr'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_loginOKZTGame(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 5)
    {
        std::string arg0;
        std::string arg1;
        std::string arg2;
        std::string arg3;
        std::string arg4;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "HelpFunc:loginOKZTGame");
        ok &= luaval_to_std_string(tolua_S, 3,&arg1, "HelpFunc:loginOKZTGame");
        ok &= luaval_to_std_string(tolua_S, 4,&arg2, "HelpFunc:loginOKZTGame");
        ok &= luaval_to_std_string(tolua_S, 5,&arg3, "HelpFunc:loginOKZTGame");
        ok &= luaval_to_std_string(tolua_S, 6,&arg4, "HelpFunc:loginOKZTGame");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_loginOKZTGame'", nullptr);
            return 0;
        }
        HelpFunc::loginOKZTGame(arg0, arg1, arg2, arg3, arg4);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:loginOKZTGame",argc, 5);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_loginOKZTGame'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_isHasSwitchAccountZTGame(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_isHasSwitchAccountZTGame'", nullptr);
            return 0;
        }
        bool ret = HelpFunc::isHasSwitchAccountZTGame();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:isHasSwitchAccountZTGame",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_isHasSwitchAccountZTGame'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_HelpFunc_gGetSecondStr(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"HelpFunc",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        double arg0;
        ok &= luaval_to_number(tolua_S, 2,&arg0, "HelpFunc:gGetSecondStr");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_HelpFunc_gGetSecondStr'", nullptr);
            return 0;
        }
        std::string ret = HelpFunc::gGetSecondStr(arg0);
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "HelpFunc:gGetSecondStr",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_HelpFunc_gGetSecondStr'.",&tolua_err);
#endif
    return 0;
}
static int lua_mmo_api_HelpFunc_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (HelpFunc)");
    return 0;
}

int lua_register_mmo_api_HelpFunc(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"HelpFunc");
    tolua_cclass(tolua_S,"HelpFunc","HelpFunc","",nullptr);

    tolua_beginmodule(tolua_S,"HelpFunc");
        tolua_function(tolua_S,"gTimeToFrames", lua_mmo_api_HelpFunc_gTimeToFrames);
        tolua_function(tolua_S,"setZoneId", lua_mmo_api_HelpFunc_setZoneId);
        tolua_function(tolua_S,"switchAccountZTGame", lua_mmo_api_HelpFunc_switchAccountZTGame);
        tolua_function(tolua_S,"setIsPlayingVideo", lua_mmo_api_HelpFunc_setIsPlayingVideo);
        tolua_function(tolua_S,"isHasQuitDialog", lua_mmo_api_HelpFunc_isHasQuitDialog);
        tolua_function(tolua_S,"setLongRecordTime", lua_mmo_api_HelpFunc_setLongRecordTime);
        tolua_function(tolua_S,"removeWaveEffectByShader", lua_mmo_api_HelpFunc_removeWaveEffectByShader);
        tolua_function(tolua_S,"cancelVibrate", lua_mmo_api_HelpFunc_cancelVibrate);
        tolua_function(tolua_S,"roleLevelUpZTGame", lua_mmo_api_HelpFunc_roleLevelUpZTGame);
        tolua_function(tolua_S,"createNormalMappedNode", lua_mmo_api_HelpFunc_createNormalMappedNode);
        tolua_function(tolua_S,"getSystemSTime", lua_mmo_api_HelpFunc_getSystemSTime);
        tolua_function(tolua_S,"setShortRecordTime", lua_mmo_api_HelpFunc_setShortRecordTime);
        tolua_function(tolua_S,"playVibrator", lua_mmo_api_HelpFunc_playVibrator);
        tolua_function(tolua_S,"quitZTGame", lua_mmo_api_HelpFunc_quitZTGame);
        tolua_function(tolua_S,"gFramesToTime", lua_mmo_api_HelpFunc_gFramesToTime);
        tolua_function(tolua_S,"getSystemMTime", lua_mmo_api_HelpFunc_getSystemMTime);
        tolua_function(tolua_S,"gAngleAnalyseForRotation", lua_mmo_api_HelpFunc_gAngleAnalyseForRotation);
        tolua_function(tolua_S,"isSocketConnect", lua_mmo_api_HelpFunc_isSocketConnect);
        tolua_function(tolua_S,"vibrateWithPattern", lua_mmo_api_HelpFunc_vibrateWithPattern);
        tolua_function(tolua_S,"setVibratorEnabled", lua_mmo_api_HelpFunc_setVibratorEnabled);
        tolua_function(tolua_S,"isHasCenterZTGame", lua_mmo_api_HelpFunc_isHasCenterZTGame);
        tolua_function(tolua_S,"playVoice", lua_mmo_api_HelpFunc_playVoice);
        tolua_function(tolua_S,"setNeedToRestartVideo", lua_mmo_api_HelpFunc_setNeedToRestartVideo);
        tolua_function(tolua_S,"removeAllTimelineActions", lua_mmo_api_HelpFunc_removeAllTimelineActions);
        tolua_function(tolua_S,"onRegister", lua_mmo_api_HelpFunc_onRegister);
        tolua_function(tolua_S,"isPlayingVideo", lua_mmo_api_HelpFunc_isPlayingVideo);
        tolua_function(tolua_S,"doRippleNodeTouch", lua_mmo_api_HelpFunc_doRippleNodeTouch);
        tolua_function(tolua_S,"loginZTGame", lua_mmo_api_HelpFunc_loginZTGame);
        tolua_function(tolua_S,"bitAnd", lua_mmo_api_HelpFunc_bitAnd);
        tolua_function(tolua_S,"setUserIDForBugly", lua_mmo_api_HelpFunc_setUserIDForBugly);
        tolua_function(tolua_S,"addWaveEffectByShader", lua_mmo_api_HelpFunc_addWaveEffectByShader);
        tolua_function(tolua_S,"gXorCoding", lua_mmo_api_HelpFunc_gXorCoding);
        tolua_function(tolua_S,"gGetMinuteStr", lua_mmo_api_HelpFunc_gGetMinuteStr);
        tolua_function(tolua_S,"print", lua_mmo_api_HelpFunc_print);
        tolua_function(tolua_S,"showWaveEffectByShader", lua_mmo_api_HelpFunc_showWaveEffectByShader);
        tolua_function(tolua_S,"createRippleNode", lua_mmo_api_HelpFunc_createRippleNode);
        tolua_function(tolua_S,"pressRecordVoice", lua_mmo_api_HelpFunc_pressRecordVoice);
        tolua_function(tolua_S,"gNumToStr", lua_mmo_api_HelpFunc_gNumToStr);
        tolua_function(tolua_S,"getRefCount", lua_mmo_api_HelpFunc_getRefCount);
        tolua_function(tolua_S,"getCollidingDirections", lua_mmo_api_HelpFunc_getCollidingDirections);
        tolua_function(tolua_S,"enterCenterZTGame", lua_mmo_api_HelpFunc_enterCenterZTGame);
        tolua_function(tolua_S,"gCreateFileWithContent", lua_mmo_api_HelpFunc_gCreateFileWithContent);
        tolua_function(tolua_S,"gGetRandNumber", lua_mmo_api_HelpFunc_gGetRandNumber);
        tolua_function(tolua_S,"getPlatform", lua_mmo_api_HelpFunc_getPlatform);
        tolua_function(tolua_S,"gTimeToStr", lua_mmo_api_HelpFunc_gTimeToStr);
        tolua_function(tolua_S,"gShowRectLogInfo", lua_mmo_api_HelpFunc_gShowRectLogInfo);
        tolua_function(tolua_S,"gAngleAnalyseForQuad", lua_mmo_api_HelpFunc_gAngleAnalyseForQuad);
        tolua_function(tolua_S,"cancelSendVoice", lua_mmo_api_HelpFunc_cancelSendVoice);
        tolua_function(tolua_S,"payZTGame", lua_mmo_api_HelpFunc_payZTGame);
        tolua_function(tolua_S,"gGetRandNumberBetween", lua_mmo_api_HelpFunc_gGetRandNumberBetween);
        tolua_function(tolua_S,"hideWaveEffectByShader", lua_mmo_api_HelpFunc_hideWaveEffectByShader);
        tolua_function(tolua_S,"isLogined", lua_mmo_api_HelpFunc_isLogined);
        tolua_function(tolua_S,"createRoleZTGame", lua_mmo_api_HelpFunc_createRoleZTGame);
        tolua_function(tolua_S,"initDuduVoice", lua_mmo_api_HelpFunc_initDuduVoice);
        tolua_function(tolua_S,"createLightNode", lua_mmo_api_HelpFunc_createLightNode);
        tolua_function(tolua_S,"gDirectionAnalyse", lua_mmo_api_HelpFunc_gDirectionAnalyse);
        tolua_function(tolua_S,"getSystemMSTime", lua_mmo_api_HelpFunc_getSystemMSTime);
        tolua_function(tolua_S,"enableDebugMode", lua_mmo_api_HelpFunc_enableDebugMode);
        tolua_function(tolua_S,"setMaxTouchesNum", lua_mmo_api_HelpFunc_setMaxTouchesNum);
        tolua_function(tolua_S,"gDirectionAnalyseByAngle", lua_mmo_api_HelpFunc_gDirectionAnalyseByAngle);
        tolua_function(tolua_S,"removeAllSprite3DData", lua_mmo_api_HelpFunc_removeAllSprite3DData);
        tolua_function(tolua_S,"onLogin", lua_mmo_api_HelpFunc_onLogin);
        tolua_function(tolua_S,"releaseSendVoice", lua_mmo_api_HelpFunc_releaseSendVoice);
        tolua_function(tolua_S,"isNeedToRestartVideo", lua_mmo_api_HelpFunc_isNeedToRestartVideo);
        tolua_function(tolua_S,"createWebView", lua_mmo_api_HelpFunc_createWebView);
        tolua_function(tolua_S,"share", lua_mmo_api_HelpFunc_share);
        tolua_function(tolua_S,"bitOr", lua_mmo_api_HelpFunc_bitOr);
        tolua_function(tolua_S,"loginOKZTGame", lua_mmo_api_HelpFunc_loginOKZTGame);
        tolua_function(tolua_S,"isHasSwitchAccountZTGame", lua_mmo_api_HelpFunc_isHasSwitchAccountZTGame);
        tolua_function(tolua_S,"gGetSecondStr", lua_mmo_api_HelpFunc_gGetSecondStr);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(HelpFunc).name();
    g_luaType[typeName] = "HelpFunc";
    g_typeCast["HelpFunc"] = "HelpFunc";
    return 1;
}

int lua_mmo_api_Stick_onTouchMoved(lua_State* tolua_S)
{
    int argc = 0;
    Stick* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"Stick",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Stick*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_Stick_onTouchMoved'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Point arg0;

        ok &= luaval_to_point(tolua_S, 2, &arg0, "Stick:onTouchMoved");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_Stick_onTouchMoved'", nullptr);
            return 0;
        }
        cobj->onTouchMoved(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "Stick:onTouchMoved",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_Stick_onTouchMoved'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_Stick_handleTouchChange(lua_State* tolua_S)
{
    int argc = 0;
    Stick* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"Stick",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Stick*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_Stick_handleTouchChange'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Point arg0;

        ok &= luaval_to_point(tolua_S, 2, &arg0, "Stick:handleTouchChange");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_Stick_handleTouchChange'", nullptr);
            return 0;
        }
        cobj->handleTouchChange(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "Stick:handleTouchChange",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_Stick_handleTouchChange'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_Stick_setLocked(lua_State* tolua_S)
{
    int argc = 0;
    Stick* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"Stick",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Stick*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_Stick_setLocked'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        bool arg0;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "Stick:setLocked");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_Stick_setLocked'", nullptr);
            return 0;
        }
        cobj->setLocked(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "Stick:setLocked",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_Stick_setLocked'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_Stick_hide(lua_State* tolua_S)
{
    int argc = 0;
    Stick* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"Stick",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Stick*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_Stick_hide'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_Stick_hide'", nullptr);
            return 0;
        }
        cobj->hide();
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "Stick:hide",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_Stick_hide'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_Stick_getAngle(lua_State* tolua_S)
{
    int argc = 0;
    Stick* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"Stick",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Stick*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_Stick_getAngle'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_Stick_getAngle'", nullptr);
            return 0;
        }
        double ret = cobj->getAngle();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "Stick:getAngle",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_Stick_getAngle'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_Stick_hideOver(lua_State* tolua_S)
{
    int argc = 0;
    Stick* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"Stick",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Stick*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_Stick_hideOver'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_Stick_hideOver'", nullptr);
            return 0;
        }
        cobj->hideOver();
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "Stick:hideOver",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_Stick_hideOver'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_Stick_getIsWorking(lua_State* tolua_S)
{
    int argc = 0;
    Stick* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"Stick",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Stick*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_Stick_getIsWorking'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_Stick_getIsWorking'", nullptr);
            return 0;
        }
        bool ret = cobj->getIsWorking();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "Stick:getIsWorking",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_Stick_getIsWorking'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_Stick_getFrameSize(lua_State* tolua_S)
{
    int argc = 0;
    Stick* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"Stick",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Stick*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_Stick_getFrameSize'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_Stick_getFrameSize'", nullptr);
            return 0;
        }
        cocos2d::Size ret = cobj->getFrameSize();
        size_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "Stick:getFrameSize",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_Stick_getFrameSize'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_Stick_needUpdate(lua_State* tolua_S)
{
    int argc = 0;
    Stick* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"Stick",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Stick*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_Stick_needUpdate'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_Stick_needUpdate'", nullptr);
            return 0;
        }
        bool ret = cobj->needUpdate();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "Stick:needUpdate",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_Stick_needUpdate'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_Stick_onTouchBegan(lua_State* tolua_S)
{
    int argc = 0;
    Stick* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"Stick",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Stick*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_Stick_onTouchBegan'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Point arg0;

        ok &= luaval_to_point(tolua_S, 2, &arg0, "Stick:onTouchBegan");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_Stick_onTouchBegan'", nullptr);
            return 0;
        }
        bool ret = cobj->onTouchBegan(arg0);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "Stick:onTouchBegan",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_Stick_onTouchBegan'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_Stick_init(lua_State* tolua_S)
{
    int argc = 0;
    Stick* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"Stick",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Stick*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_Stick_init'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        std::string arg0;
        std::string arg1;

        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "Stick:init");

        ok &= luaval_to_std_string(tolua_S, 3,&arg1, "Stick:init");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_Stick_init'", nullptr);
            return 0;
        }
        bool ret = cobj->init(arg0, arg1);
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "Stick:init",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_Stick_init'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_Stick_getDirection(lua_State* tolua_S)
{
    int argc = 0;
    Stick* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"Stick",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Stick*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_Stick_getDirection'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_Stick_getDirection'", nullptr);
            return 0;
        }
        int ret = cobj->getDirection();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "Stick:getDirection",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_Stick_getDirection'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_Stick_setIsWorking(lua_State* tolua_S)
{
    int argc = 0;
    Stick* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"Stick",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Stick*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_Stick_setIsWorking'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        bool arg0;

        ok &= luaval_to_boolean(tolua_S, 2,&arg0, "Stick:setIsWorking");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_Stick_setIsWorking'", nullptr);
            return 0;
        }
        cobj->setIsWorking(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "Stick:setIsWorking",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_Stick_setIsWorking'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_Stick_onTouchEnded(lua_State* tolua_S)
{
    int argc = 0;
    Stick* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"Stick",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Stick*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_Stick_onTouchEnded'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Point arg0;

        ok &= luaval_to_point(tolua_S, 2, &arg0, "Stick:onTouchEnded");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_Stick_onTouchEnded'", nullptr);
            return 0;
        }
        cobj->onTouchEnded(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "Stick:onTouchEnded",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_Stick_onTouchEnded'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_Stick_setStartPosition(lua_State* tolua_S)
{
    int argc = 0;
    Stick* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"Stick",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (Stick*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_Stick_setStartPosition'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::Point arg0;

        ok &= luaval_to_point(tolua_S, 2, &arg0, "Stick:setStartPosition");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_Stick_setStartPosition'", nullptr);
            return 0;
        }
        cobj->setStartPosition(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "Stick:setStartPosition",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_Stick_setStartPosition'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_Stick_createWithFrameName(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"Stick",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        std::string arg0;
        std::string arg1;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "Stick:createWithFrameName");
        ok &= luaval_to_std_string(tolua_S, 3,&arg1, "Stick:createWithFrameName");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_Stick_createWithFrameName'", nullptr);
            return 0;
        }
        Stick* ret = Stick::createWithFrameName(arg0, arg1);
        object_to_luaval<Stick>(tolua_S, "Stick",(Stick*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "Stick:createWithFrameName",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_Stick_createWithFrameName'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_Stick_constructor(lua_State* tolua_S)
{
    int argc = 0;
    Stick* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif



    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_Stick_constructor'", nullptr);
            return 0;
        }
        cobj = new Stick();
        cobj->autorelease();
        int ID =  (int)cobj->_ID ;
        int* luaID =  &cobj->_luaID ;
        toluafix_pushusertype_ccobject(tolua_S, ID, luaID, (void*)cobj,"Stick");
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "Stick:Stick",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_Stick_constructor'.",&tolua_err);
#endif

    return 0;
}

static int lua_mmo_api_Stick_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (Stick)");
    return 0;
}

int lua_register_mmo_api_Stick(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"Stick");
    tolua_cclass(tolua_S,"Stick","Stick","cc.Node",nullptr);

    tolua_beginmodule(tolua_S,"Stick");
        tolua_function(tolua_S,"new",lua_mmo_api_Stick_constructor);
        tolua_function(tolua_S,"onTouchMoved",lua_mmo_api_Stick_onTouchMoved);
        tolua_function(tolua_S,"handleTouchChange",lua_mmo_api_Stick_handleTouchChange);
        tolua_function(tolua_S,"setLocked",lua_mmo_api_Stick_setLocked);
        tolua_function(tolua_S,"hide",lua_mmo_api_Stick_hide);
        tolua_function(tolua_S,"getAngle",lua_mmo_api_Stick_getAngle);
        tolua_function(tolua_S,"hideOver",lua_mmo_api_Stick_hideOver);
        tolua_function(tolua_S,"getIsWorking",lua_mmo_api_Stick_getIsWorking);
        tolua_function(tolua_S,"getFrameSize",lua_mmo_api_Stick_getFrameSize);
        tolua_function(tolua_S,"needUpdate",lua_mmo_api_Stick_needUpdate);
        tolua_function(tolua_S,"onTouchBegan",lua_mmo_api_Stick_onTouchBegan);
        tolua_function(tolua_S,"init",lua_mmo_api_Stick_init);
        tolua_function(tolua_S,"getDirection",lua_mmo_api_Stick_getDirection);
        tolua_function(tolua_S,"setIsWorking",lua_mmo_api_Stick_setIsWorking);
        tolua_function(tolua_S,"onTouchEnded",lua_mmo_api_Stick_onTouchEnded);
        tolua_function(tolua_S,"setStartPosition",lua_mmo_api_Stick_setStartPosition);
        tolua_function(tolua_S,"createWithFrameName", lua_mmo_api_Stick_createWithFrameName);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(Stick).name();
    g_luaType[typeName] = "Stick";
    g_typeCast["Stick"] = "Stick";
    return 1;
}

int lua_mmo_api_RectsHelper_clearCache(lua_State* tolua_S)
{
    int argc = 0;
    RectsHelper* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"RectsHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (RectsHelper*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_RectsHelper_clearCache'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        int arg0;
        int arg1;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "RectsHelper:clearCache");

        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "RectsHelper:clearCache");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_RectsHelper_clearCache'", nullptr);
            return 0;
        }
        cobj->clearCache(arg0, arg1);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "RectsHelper:clearCache",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_RectsHelper_clearCache'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_RectsHelper_removeRect(lua_State* tolua_S)
{
    int argc = 0;
    RectsHelper* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"RectsHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (RectsHelper*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_RectsHelper_removeRect'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 3) 
    {
        int arg0;
        int arg1;
        int arg2;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "RectsHelper:removeRect");

        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "RectsHelper:removeRect");

        ok &= luaval_to_int32(tolua_S, 4,(int *)&arg2, "RectsHelper:removeRect");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_RectsHelper_removeRect'", nullptr);
            return 0;
        }
        cobj->removeRect(arg0, arg1, arg2);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "RectsHelper:removeRect",argc, 3);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_RectsHelper_removeRect'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_RectsHelper_isCollidingBottomOnBodysInArea(lua_State* tolua_S)
{
    int argc = 0;
    RectsHelper* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"RectsHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (RectsHelper*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_RectsHelper_isCollidingBottomOnBodysInArea'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        int arg0;
        cocos2d::Rect arg1;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "RectsHelper:isCollidingBottomOnBodysInArea");

        ok &= luaval_to_rect(tolua_S, 3, &arg1, "RectsHelper:isCollidingBottomOnBodysInArea");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_RectsHelper_isCollidingBottomOnBodysInArea'", nullptr);
            return 0;
        }
        int ret = cobj->isCollidingBottomOnBodysInArea(arg0, arg1);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    if (argc == 3) 
    {
        int arg0;
        cocos2d::Rect arg1;
        bool arg2;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "RectsHelper:isCollidingBottomOnBodysInArea");

        ok &= luaval_to_rect(tolua_S, 3, &arg1, "RectsHelper:isCollidingBottomOnBodysInArea");

        ok &= luaval_to_boolean(tolua_S, 4,&arg2, "RectsHelper:isCollidingBottomOnBodysInArea");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_RectsHelper_isCollidingBottomOnBodysInArea'", nullptr);
            return 0;
        }
        int ret = cobj->isCollidingBottomOnBodysInArea(arg0, arg1, arg2);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    if (argc == 4) 
    {
        int arg0;
        cocos2d::Rect arg1;
        bool arg2;
        int arg3;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "RectsHelper:isCollidingBottomOnBodysInArea");

        ok &= luaval_to_rect(tolua_S, 3, &arg1, "RectsHelper:isCollidingBottomOnBodysInArea");

        ok &= luaval_to_boolean(tolua_S, 4,&arg2, "RectsHelper:isCollidingBottomOnBodysInArea");

        ok &= luaval_to_int32(tolua_S, 5,(int *)&arg3, "RectsHelper:isCollidingBottomOnBodysInArea");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_RectsHelper_isCollidingBottomOnBodysInArea'", nullptr);
            return 0;
        }
        int ret = cobj->isCollidingBottomOnBodysInArea(arg0, arg1, arg2, arg3);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "RectsHelper:isCollidingBottomOnBodysInArea",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_RectsHelper_isCollidingBottomOnBodysInArea'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_RectsHelper_insertBodyRect(lua_State* tolua_S)
{
    int argc = 0;
    RectsHelper* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"RectsHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (RectsHelper*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_RectsHelper_insertBodyRect'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        int arg0;
        cocos2d::Rect arg1;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "RectsHelper:insertBodyRect");

        ok &= luaval_to_rect(tolua_S, 3, &arg1, "RectsHelper:insertBodyRect");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_RectsHelper_insertBodyRect'", nullptr);
            return 0;
        }
        cobj->insertBodyRect(arg0, arg1);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "RectsHelper:insertBodyRect",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_RectsHelper_insertBodyRect'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_RectsHelper_insertBottomRect(lua_State* tolua_S)
{
    int argc = 0;
    RectsHelper* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"RectsHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (RectsHelper*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_RectsHelper_insertBottomRect'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        int arg0;
        cocos2d::Rect arg1;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "RectsHelper:insertBottomRect");

        ok &= luaval_to_rect(tolua_S, 3, &arg1, "RectsHelper:insertBottomRect");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_RectsHelper_insertBottomRect'", nullptr);
            return 0;
        }
        cobj->insertBottomRect(arg0, arg1);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "RectsHelper:insertBottomRect",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_RectsHelper_insertBottomRect'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_RectsHelper_isCollidingBottomOnBottomsInArea(lua_State* tolua_S)
{
    int argc = 0;
    RectsHelper* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"RectsHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (RectsHelper*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_RectsHelper_isCollidingBottomOnBottomsInArea'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        int arg0;
        cocos2d::Rect arg1;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "RectsHelper:isCollidingBottomOnBottomsInArea");

        ok &= luaval_to_rect(tolua_S, 3, &arg1, "RectsHelper:isCollidingBottomOnBottomsInArea");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_RectsHelper_isCollidingBottomOnBottomsInArea'", nullptr);
            return 0;
        }
        int ret = cobj->isCollidingBottomOnBottomsInArea(arg0, arg1);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    if (argc == 3) 
    {
        int arg0;
        cocos2d::Rect arg1;
        bool arg2;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "RectsHelper:isCollidingBottomOnBottomsInArea");

        ok &= luaval_to_rect(tolua_S, 3, &arg1, "RectsHelper:isCollidingBottomOnBottomsInArea");

        ok &= luaval_to_boolean(tolua_S, 4,&arg2, "RectsHelper:isCollidingBottomOnBottomsInArea");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_RectsHelper_isCollidingBottomOnBottomsInArea'", nullptr);
            return 0;
        }
        int ret = cobj->isCollidingBottomOnBottomsInArea(arg0, arg1, arg2);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    if (argc == 4) 
    {
        int arg0;
        cocos2d::Rect arg1;
        bool arg2;
        int arg3;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "RectsHelper:isCollidingBottomOnBottomsInArea");

        ok &= luaval_to_rect(tolua_S, 3, &arg1, "RectsHelper:isCollidingBottomOnBottomsInArea");

        ok &= luaval_to_boolean(tolua_S, 4,&arg2, "RectsHelper:isCollidingBottomOnBottomsInArea");

        ok &= luaval_to_int32(tolua_S, 5,(int *)&arg3, "RectsHelper:isCollidingBottomOnBottomsInArea");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_RectsHelper_isCollidingBottomOnBottomsInArea'", nullptr);
            return 0;
        }
        int ret = cobj->isCollidingBottomOnBottomsInArea(arg0, arg1, arg2, arg3);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "RectsHelper:isCollidingBottomOnBottomsInArea",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_RectsHelper_isCollidingBottomOnBottomsInArea'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_RectsHelper_insertUndefRect(lua_State* tolua_S)
{
    int argc = 0;
    RectsHelper* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"RectsHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (RectsHelper*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_RectsHelper_insertUndefRect'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        int arg0;
        cocos2d::Rect arg1;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "RectsHelper:insertUndefRect");

        ok &= luaval_to_rect(tolua_S, 3, &arg1, "RectsHelper:insertUndefRect");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_RectsHelper_insertUndefRect'", nullptr);
            return 0;
        }
        cobj->insertUndefRect(arg0, arg1);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "RectsHelper:insertUndefRect",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_RectsHelper_insertUndefRect'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_RectsHelper_getInst(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"RectsHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_RectsHelper_getInst'", nullptr);
            return 0;
        }
        RectsHelper* ret = RectsHelper::getInst();
        object_to_luaval<RectsHelper>(tolua_S, "RectsHelper",(RectsHelper*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "RectsHelper:getInst",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_RectsHelper_getInst'.",&tolua_err);
#endif
    return 0;
}
static int lua_mmo_api_RectsHelper_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (RectsHelper)");
    return 0;
}

int lua_register_mmo_api_RectsHelper(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"RectsHelper");
    tolua_cclass(tolua_S,"RectsHelper","RectsHelper","",nullptr);

    tolua_beginmodule(tolua_S,"RectsHelper");
        tolua_function(tolua_S,"clearCache",lua_mmo_api_RectsHelper_clearCache);
        tolua_function(tolua_S,"removeRect",lua_mmo_api_RectsHelper_removeRect);
        tolua_function(tolua_S,"isCollidingBottomOnBodysInArea",lua_mmo_api_RectsHelper_isCollidingBottomOnBodysInArea);
        tolua_function(tolua_S,"insertBodyRect",lua_mmo_api_RectsHelper_insertBodyRect);
        tolua_function(tolua_S,"insertBottomRect",lua_mmo_api_RectsHelper_insertBottomRect);
        tolua_function(tolua_S,"isCollidingBottomOnBottomsInArea",lua_mmo_api_RectsHelper_isCollidingBottomOnBottomsInArea);
        tolua_function(tolua_S,"insertUndefRect",lua_mmo_api_RectsHelper_insertUndefRect);
        tolua_function(tolua_S,"getInst", lua_mmo_api_RectsHelper_getInst);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(RectsHelper).name();
    g_luaType[typeName] = "RectsHelper";
    g_typeCast["RectsHelper"] = "RectsHelper";
    return 1;
}

int lua_mmo_api_TriggersHelper_isCollidingBottomOnTriggerRectInArea(lua_State* tolua_S)
{
    int argc = 0;
    TriggersHelper* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"TriggersHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (TriggersHelper*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_TriggersHelper_isCollidingBottomOnTriggerRectInArea'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        int arg0;
        cocos2d::Rect arg1;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "TriggersHelper:isCollidingBottomOnTriggerRectInArea");

        ok &= luaval_to_rect(tolua_S, 3, &arg1, "TriggersHelper:isCollidingBottomOnTriggerRectInArea");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_TriggersHelper_isCollidingBottomOnTriggerRectInArea'", nullptr);
            return 0;
        }
        int ret = cobj->isCollidingBottomOnTriggerRectInArea(arg0, arg1);
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "TriggersHelper:isCollidingBottomOnTriggerRectInArea",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_TriggersHelper_isCollidingBottomOnTriggerRectInArea'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_TriggersHelper_clearCache(lua_State* tolua_S)
{
    int argc = 0;
    TriggersHelper* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"TriggersHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (TriggersHelper*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_TriggersHelper_clearCache'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        int arg0;
        int arg1;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "TriggersHelper:clearCache");

        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "TriggersHelper:clearCache");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_TriggersHelper_clearCache'", nullptr);
            return 0;
        }
        cobj->clearCache(arg0, arg1);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "TriggersHelper:clearCache",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_TriggersHelper_clearCache'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_TriggersHelper_insertTriggerRect(lua_State* tolua_S)
{
    int argc = 0;
    TriggersHelper* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"TriggersHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (TriggersHelper*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_TriggersHelper_insertTriggerRect'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        int arg0;
        cocos2d::Rect arg1;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "TriggersHelper:insertTriggerRect");

        ok &= luaval_to_rect(tolua_S, 3, &arg1, "TriggersHelper:insertTriggerRect");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_TriggersHelper_insertTriggerRect'", nullptr);
            return 0;
        }
        cobj->insertTriggerRect(arg0, arg1);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "TriggersHelper:insertTriggerRect",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_TriggersHelper_insertTriggerRect'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_TriggersHelper_removeTriggerRect(lua_State* tolua_S)
{
    int argc = 0;
    TriggersHelper* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"TriggersHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (TriggersHelper*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_TriggersHelper_removeTriggerRect'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        int arg0;
        int arg1;

        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "TriggersHelper:removeTriggerRect");

        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "TriggersHelper:removeTriggerRect");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_TriggersHelper_removeTriggerRect'", nullptr);
            return 0;
        }
        cobj->removeTriggerRect(arg0, arg1);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "TriggersHelper:removeTriggerRect",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_TriggersHelper_removeTriggerRect'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_TriggersHelper_getInst(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"TriggersHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_TriggersHelper_getInst'", nullptr);
            return 0;
        }
        TriggersHelper* ret = TriggersHelper::getInst();
        object_to_luaval<TriggersHelper>(tolua_S, "TriggersHelper",(TriggersHelper*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "TriggersHelper:getInst",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_TriggersHelper_getInst'.",&tolua_err);
#endif
    return 0;
}
static int lua_mmo_api_TriggersHelper_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (TriggersHelper)");
    return 0;
}

int lua_register_mmo_api_TriggersHelper(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"TriggersHelper");
    tolua_cclass(tolua_S,"TriggersHelper","TriggersHelper","",nullptr);

    tolua_beginmodule(tolua_S,"TriggersHelper");
        tolua_function(tolua_S,"isCollidingBottomOnTriggerRectInArea",lua_mmo_api_TriggersHelper_isCollidingBottomOnTriggerRectInArea);
        tolua_function(tolua_S,"clearCache",lua_mmo_api_TriggersHelper_clearCache);
        tolua_function(tolua_S,"insertTriggerRect",lua_mmo_api_TriggersHelper_insertTriggerRect);
        tolua_function(tolua_S,"removeTriggerRect",lua_mmo_api_TriggersHelper_removeTriggerRect);
        tolua_function(tolua_S,"getInst", lua_mmo_api_TriggersHelper_getInst);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(TriggersHelper).name();
    g_luaType[typeName] = "TriggersHelper";
    g_typeCast["TriggersHelper"] = "TriggersHelper";
    return 1;
}

int lua_mmo_api_AStarHelper_ComputeAStar(lua_State* tolua_S)
{
    int argc = 0;
    AStarHelper* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"AStarHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (AStarHelper*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_AStarHelper_ComputeAStar'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 2) 
    {
        cocos2d::Vec2 arg0;
        cocos2d::Vec2 arg1;

        ok &= luaval_to_vec2(tolua_S, 2, &arg0, "AStarHelper:ComputeAStar");

        ok &= luaval_to_vec2(tolua_S, 3, &arg1, "AStarHelper:ComputeAStar");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_AStarHelper_ComputeAStar'", nullptr);
            return 0;
        }
        cocos2d::ValueVector ret = cobj->ComputeAStar(arg0, arg1);
        ccvaluevector_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "AStarHelper:ComputeAStar",argc, 2);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_AStarHelper_ComputeAStar'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_AStarHelper_InitMapAttris(lua_State* tolua_S)
{
    int argc = 0;
    AStarHelper* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"AStarHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (AStarHelper*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_AStarHelper_InitMapAttris'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 1) 
    {
        cocos2d::ValueVector arg0;

        ok &= luaval_to_ccvaluevector(tolua_S, 2, &arg0, "AStarHelper:InitMapAttris");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_AStarHelper_InitMapAttris'", nullptr);
            return 0;
        }
        cobj->InitMapAttris(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "AStarHelper:InitMapAttris",argc, 1);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_AStarHelper_InitMapAttris'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_AStarHelper_clearCache(lua_State* tolua_S)
{
    int argc = 0;
    AStarHelper* cobj = nullptr;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif


#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertype(tolua_S,1,"AStarHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    cobj = (AStarHelper*)tolua_tousertype(tolua_S,1,0);

#if COCOS2D_DEBUG >= 1
    if (!cobj) 
    {
        tolua_error(tolua_S,"invalid 'cobj' in function 'lua_mmo_api_AStarHelper_clearCache'", nullptr);
        return 0;
    }
#endif

    argc = lua_gettop(tolua_S)-1;
    if (argc == 0) 
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_AStarHelper_clearCache'", nullptr);
            return 0;
        }
        cobj->clearCache();
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d \n", "AStarHelper:clearCache",argc, 0);
    return 0;

#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_AStarHelper_clearCache'.",&tolua_err);
#endif

    return 0;
}
int lua_mmo_api_AStarHelper_getInst(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"AStarHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_AStarHelper_getInst'", nullptr);
            return 0;
        }
        AStarHelper* ret = AStarHelper::getInst();
        object_to_luaval<AStarHelper>(tolua_S, "AStarHelper",(AStarHelper*)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "AStarHelper:getInst",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_AStarHelper_getInst'.",&tolua_err);
#endif
    return 0;
}
static int lua_mmo_api_AStarHelper_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (AStarHelper)");
    return 0;
}

int lua_register_mmo_api_AStarHelper(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"AStarHelper");
    tolua_cclass(tolua_S,"AStarHelper","AStarHelper","",nullptr);

    tolua_beginmodule(tolua_S,"AStarHelper");
        tolua_function(tolua_S,"ComputeAStar",lua_mmo_api_AStarHelper_ComputeAStar);
        tolua_function(tolua_S,"InitMapAttris",lua_mmo_api_AStarHelper_InitMapAttris);
        tolua_function(tolua_S,"clearCache",lua_mmo_api_AStarHelper_clearCache);
        tolua_function(tolua_S,"getInst", lua_mmo_api_AStarHelper_getInst);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(AStarHelper).name();
    g_luaType[typeName] = "AStarHelper";
    g_typeCast["AStarHelper"] = "AStarHelper";
    return 1;
}

int lua_mmo_api_DebugHelper_setDebugString(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"DebugHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "DebugHelper:setDebugString");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_DebugHelper_setDebugString'", nullptr);
            return 0;
        }
        DebugHelper::setDebugString(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "DebugHelper:setDebugString",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_DebugHelper_setDebugString'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_DebugHelper_showJavaLog(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"DebugHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "DebugHelper:showJavaLog");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_DebugHelper_showJavaLog'", nullptr);
            return 0;
        }
        DebugHelper::showJavaLog(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "DebugHelper:showJavaLog",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_DebugHelper_showJavaLog'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_DebugHelper_getDebugString(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"DebugHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_DebugHelper_getDebugString'", nullptr);
            return 0;
        }
        std::string ret = DebugHelper::getDebugString();
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "DebugHelper:getDebugString",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_DebugHelper_getDebugString'.",&tolua_err);
#endif
    return 0;
}
static int lua_mmo_api_DebugHelper_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (DebugHelper)");
    return 0;
}

int lua_register_mmo_api_DebugHelper(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"DebugHelper");
    tolua_cclass(tolua_S,"DebugHelper","DebugHelper","",nullptr);

    tolua_beginmodule(tolua_S,"DebugHelper");
        tolua_function(tolua_S,"setDebugString", lua_mmo_api_DebugHelper_setDebugString);
        tolua_function(tolua_S,"showJavaLog", lua_mmo_api_DebugHelper_showJavaLog);
        tolua_function(tolua_S,"getDebugString", lua_mmo_api_DebugHelper_getDebugString);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(DebugHelper).name();
    g_luaType[typeName] = "DebugHelper";
    g_typeCast["DebugHelper"] = "DebugHelper";
    return 1;
}

int lua_mmo_api_DataHelper_getLoginOverParams(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"DataHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_DataHelper_getLoginOverParams'", nullptr);
            return 0;
        }
        cocos2d::ValueMap ret = DataHelper::getLoginOverParams();
        ccvaluemap_to_luaval(tolua_S, ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "DataHelper:getLoginOverParams",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_DataHelper_getLoginOverParams'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_DataHelper_setPlayVoiceOver(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"DataHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_DataHelper_setPlayVoiceOver'", nullptr);
            return 0;
        }
        DataHelper::setPlayVoiceOver();
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "DataHelper:setPlayVoiceOver",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_DataHelper_setPlayVoiceOver'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_DataHelper_getSendFaildCallBack(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"DataHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_DataHelper_getSendFaildCallBack'", nullptr);
            return 0;
        }
        bool ret = DataHelper::getSendFaildCallBack();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "DataHelper:getSendFaildCallBack",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_DataHelper_getSendFaildCallBack'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_DataHelper_setLastVoiceDuration(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"DataHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        int arg0;
        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "DataHelper:setLastVoiceDuration");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_DataHelper_setLastVoiceDuration'", nullptr);
            return 0;
        }
        DataHelper::setLastVoiceDuration(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "DataHelper:setLastVoiceDuration",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_DataHelper_setLastVoiceDuration'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_DataHelper_getPlayVoiceOver(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"DataHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_DataHelper_getPlayVoiceOver'", nullptr);
            return 0;
        }
        bool ret = DataHelper::getPlayVoiceOver();
        tolua_pushboolean(tolua_S,(bool)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "DataHelper:getPlayVoiceOver",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_DataHelper_getPlayVoiceOver'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_DataHelper_setSendFaildCallBack(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"DataHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_DataHelper_setSendFaildCallBack'", nullptr);
            return 0;
        }
        DataHelper::setSendFaildCallBack();
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "DataHelper:setSendFaildCallBack",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_DataHelper_setSendFaildCallBack'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_DataHelper_setLastVoiceId(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"DataHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 1)
    {
        std::string arg0;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "DataHelper:setLastVoiceId");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_DataHelper_setLastVoiceId'", nullptr);
            return 0;
        }
        DataHelper::setLastVoiceId(arg0);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "DataHelper:setLastVoiceId",argc, 1);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_DataHelper_setLastVoiceId'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_DataHelper_getLastVoiceId(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"DataHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_DataHelper_getLastVoiceId'", nullptr);
            return 0;
        }
        std::string ret = DataHelper::getLastVoiceId();
        tolua_pushcppstring(tolua_S,ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "DataHelper:getLastVoiceId",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_DataHelper_getLastVoiceId'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_DataHelper_getLastVoiceDuration(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"DataHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 0)
    {
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_DataHelper_getLastVoiceDuration'", nullptr);
            return 0;
        }
        int ret = DataHelper::getLastVoiceDuration();
        tolua_pushnumber(tolua_S,(lua_Number)ret);
        return 1;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "DataHelper:getLastVoiceDuration",argc, 0);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_DataHelper_getLastVoiceDuration'.",&tolua_err);
#endif
    return 0;
}
int lua_mmo_api_DataHelper_setLoginOverParams(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"DataHelper",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 7)
    {
        std::string arg0;
        std::string arg1;
        std::string arg2;
        std::string arg3;
        std::string arg4;
        int arg5;
        std::string arg6;
        ok &= luaval_to_std_string(tolua_S, 2,&arg0, "DataHelper:setLoginOverParams");
        ok &= luaval_to_std_string(tolua_S, 3,&arg1, "DataHelper:setLoginOverParams");
        ok &= luaval_to_std_string(tolua_S, 4,&arg2, "DataHelper:setLoginOverParams");
        ok &= luaval_to_std_string(tolua_S, 5,&arg3, "DataHelper:setLoginOverParams");
        ok &= luaval_to_std_string(tolua_S, 6,&arg4, "DataHelper:setLoginOverParams");
        ok &= luaval_to_int32(tolua_S, 7,(int *)&arg5, "DataHelper:setLoginOverParams");
        ok &= luaval_to_std_string(tolua_S, 8,&arg6, "DataHelper:setLoginOverParams");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_mmo_api_DataHelper_setLoginOverParams'", nullptr);
            return 0;
        }
        DataHelper::setLoginOverParams(arg0, arg1, arg2, arg3, arg4, arg5, arg6);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "DataHelper:setLoginOverParams",argc, 7);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_mmo_api_DataHelper_setLoginOverParams'.",&tolua_err);
#endif
    return 0;
}
static int lua_mmo_api_DataHelper_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (DataHelper)");
    return 0;
}

int lua_register_mmo_api_DataHelper(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"DataHelper");
    tolua_cclass(tolua_S,"DataHelper","DataHelper","",nullptr);

    tolua_beginmodule(tolua_S,"DataHelper");
        tolua_function(tolua_S,"getLoginOverParams", lua_mmo_api_DataHelper_getLoginOverParams);
        tolua_function(tolua_S,"setPlayVoiceOver", lua_mmo_api_DataHelper_setPlayVoiceOver);
        tolua_function(tolua_S,"getSendFaildCallBack", lua_mmo_api_DataHelper_getSendFaildCallBack);
        tolua_function(tolua_S,"setLastVoiceDuration", lua_mmo_api_DataHelper_setLastVoiceDuration);
        tolua_function(tolua_S,"getPlayVoiceOver", lua_mmo_api_DataHelper_getPlayVoiceOver);
        tolua_function(tolua_S,"setSendFaildCallBack", lua_mmo_api_DataHelper_setSendFaildCallBack);
        tolua_function(tolua_S,"setLastVoiceId", lua_mmo_api_DataHelper_setLastVoiceId);
        tolua_function(tolua_S,"getLastVoiceId", lua_mmo_api_DataHelper_getLastVoiceId);
        tolua_function(tolua_S,"getLastVoiceDuration", lua_mmo_api_DataHelper_getLastVoiceDuration);
        tolua_function(tolua_S,"setLoginOverParams", lua_mmo_api_DataHelper_setLoginOverParams);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(DataHelper).name();
    g_luaType[typeName] = "DataHelper";
    g_typeCast["DataHelper"] = "DataHelper";
    return 1;
}
TOLUA_API int register_all_mmo_api(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	
	tolua_module(tolua_S,"mmo",0);
	tolua_beginmodule(tolua_S,"mmo");

	lua_register_mmo_api_VisibleRect(tolua_S);
	lua_register_mmo_api_RectsHelper(tolua_S);
	lua_register_mmo_api_HelpFunc(tolua_S);
	lua_register_mmo_api_DataHelper(tolua_S);
	lua_register_mmo_api_AStarHelper(tolua_S);
	lua_register_mmo_api_Stick(tolua_S);
	lua_register_mmo_api_TriggersHelper(tolua_S);
	lua_register_mmo_api_DebugHelper(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;
}

