/****************************************************************************
*	Copyright (c) 2014, zhongying.game
*	All rights reserved.
*****************************************************************************
*	filename:	DataHelper.cpp
*  author:		ye.tao
*	e-mail:		553681974@qq.com
*	created:	2015/06/25
*	descript:   数据助手
****************************************************************************/
#include "DataHelper.h"

std::string DataHelper::_strLastVoiceId = "";
int DataHelper::_nLastVoiceDuration = 0;
bool DataHelper::_bPlayVoiceOver = false;
ValueMap DataHelper::_mLoginOverParams;
bool DataHelper::_bHasSendFaild = false;

std::string DataHelper::getLastVoiceId()
{
	std::string str = _strLastVoiceId;
	_strLastVoiceId.clear();
	return str;
}

void DataHelper::setLastVoiceId( std::string id )
{
	_strLastVoiceId = id;
}

int DataHelper::getLastVoiceDuration()
{
	int duration = _nLastVoiceDuration;
	_nLastVoiceDuration = 0;
	return duration;
}

void DataHelper::setLastVoiceDuration( int duration )
{
	_nLastVoiceDuration = duration;
}

bool DataHelper::getPlayVoiceOver()
{
	bool isOver = _bPlayVoiceOver;
	_bPlayVoiceOver = false;
	return isOver;
}

void DataHelper::setPlayVoiceOver()
{
	_bPlayVoiceOver = true;
}

ValueMap DataHelper::getLoginOverParams()
{
	ValueMap params = _mLoginOverParams;
	_mLoginOverParams.clear();
	return params;
}

void DataHelper::setSendFaildCallBack()
{
	_bHasSendFaild = true;
}

bool DataHelper::getSendFaildCallBack()
{
	bool sendFaild =  _bHasSendFaild;
	_bHasSendFaild = false;
	return sendFaild;
}

void DataHelper::setLoginOverParams( std::string mobileType, std::string token, std::string accid, std::string imei, std::string mac, int channel, std::string ip )
{
	_mLoginOverParams.clear();
	_mLoginOverParams["mobile_type"] = Value(mobileType);
	_mLoginOverParams["token"] = Value(token);
	_mLoginOverParams["accid"] = Value(accid);
	_mLoginOverParams["imei"] = Value(imei);
	_mLoginOverParams["mac"] = Value(mac);
	_mLoginOverParams["channel"] = Value(channel);
	_mLoginOverParams["ip"] = Value(ip);
	return;
}
