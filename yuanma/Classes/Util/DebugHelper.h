/****************************************************************************
*	Copyright (c) 2014, zhongying.game
*	All rights reserved.
*****************************************************************************
*	filename:	DebugHelper.h
*  author:		ye.tao
*	e-mail:		553681974@qq.com
*	created:	2015/02/11
*	descript:   调试助手
****************************************************************************/
#ifndef __DEBUG_HELPER_H__
#define __DEBUG_HELPER_H__

#include "cocos2d.h"
USING_NS_CC;

class DebugHelper
{
public:
	// 获取调试信息
	static std::string getDebugString();

	// 设置调试信息 
	static void setDebugString(std::string str);

	// 打印Java下的log信息
	static void showJavaLog(std::string content);

protected:
	static std::string _strDebugInfo;
};

#endif  //__DEBUG_HELPER_H__