/****************************************************************************
*	Copyright (c) 2014, zhongying.game
*	All rights reserved.
*****************************************************************************
*	filename:	DataHelper.h
*  author:		ye.tao
*	e-mail:		553681974@qq.com
*	created:	2015/06/25
*	descript:   数据助手
****************************************************************************/
#ifndef __DATA_HELPER_H__
#define __DATA_HELPER_H__

#include "cocos2d.h"
USING_NS_CC;

class DataHelper
{
public:
    // ---------------- 嘟嘟语音 ----------------------------
	// 获取最近一次发送出去的语音id
	static std::string getLastVoiceId();

	// 设置最近一次发送出去的语音id
	static void setLastVoiceId(std::string id);

	// 获取最近一次发送出去的语音时间
	static int getLastVoiceDuration();

	// 设置最近一次发送出去的语音的时间
	static void setLastVoiceDuration(int duration);

	// 获取语音是否发送成功
	static bool getPlayVoiceOver();

	// 设置语音发送成功
	static void setPlayVoiceOver();

	//发送失败回调
	static bool getSendFaildCallBack();

	static void setSendFaildCallBack();

    // ------------------- 母包SDK相关 ---------------------------
	// 获取登录成功后的信息集合
	static ValueMap getLoginOverParams();

	// 设置登录成功后的信息集合
	static void setLoginOverParams(std::string mobileType, std::string token, std::string accid, std::string imei, std::string mac, int channel, std::string ip);
	

protected:
	static std::string _strLastVoiceId;
	static int _nLastVoiceDuration;
	static bool _bPlayVoiceOver;
	static ValueMap _mLoginOverParams;
	static bool _bHasSendFaild ;
};

#endif  //__DATA_HELPER_H__