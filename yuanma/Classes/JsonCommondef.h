/****************************************************************************
*	Copyright (c) 2014, zhongying.game
*	All rights reserved.
*****************************************************************************
*	filename:	JsonCommondef.h
*  author:		ye.tao
*	e-mail:		553681974@qq.com
*	created:	2014/09/22
*	descript:   RapidJson接口封装
****************************************************************************/
#ifndef __JSON_COMMON_DEF_H__
#define __JSON_COMMON_DEF_H__

#include "json/document.h"
#include "json/rapidjson.h"
#include "json/stringbuffer.h"
#include "json/writer.h"

// 定义json变量
#define RAPID_DEFINE_JSON(__JSON__)	rapidjson::Document __JSON__; __JSON__.SetObject();
// 将字符串转换成json格式
#define RAPID_CSTR_TO_JSON(__CSTR__, __JSON__) __JSON__.Parse<rapidjson::kParseDefaultFlags>(__CSTR__);
// 将json格式转换成字符串
#define RAPID_JSON_TO_STR(__JSON__, __STR__) rapidjson::StringBuffer  __buffer__;\
																rapidjson::Writer<rapidjson::StringBuffer> __writer__(__buffer__);\
																__JSON__.Accept(__writer__);\
																__STR__ = __buffer__.GetString();

#endif  //__JSON_COMMON_DEF_H__