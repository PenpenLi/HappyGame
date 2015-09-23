/****************************************************************************
*	Copyright (c) 2014, zhongying.game
*	All rights reserved.
*****************************************************************************
*	filename:	DebugHelper.cpp
*  author:		ye.tao
*	e-mail:		553681974@qq.com
*	created:	2015/02/11
*	descript:   调试助手
****************************************************************************/
#include "DebugHelper.h"

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "platform/CCCommon.h"
#include "jni/Java_org_cocos2dx_lib_Cocos2dxHelper.h"
#include <stdlib.h>
#define  LOG_TAG    "CCFileUtils-android.cpp"
#define  LOGD(...)  __android_log_print(ANDROID_LOG_DEBUG,LOG_TAG,__VA_ARGS__)
#endif

std::string DebugHelper::_strDebugInfo = "";

std::string DebugHelper::getDebugString()
{
	std::string str = _strDebugInfo;
	_strDebugInfo.clear();
	return str;
}

void DebugHelper::setDebugString( std::string str )
{
	_strDebugInfo = _strDebugInfo.append(str);
}

void DebugHelper::showJavaLog( std::string content )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	LOGD("showJavaLog: %s",content.c_str());
#endif
	CCLOG("showJavaLog: %s", content.c_str());

}
