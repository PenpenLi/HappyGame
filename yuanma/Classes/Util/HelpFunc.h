/****************************************************************************
*	Copyright (c) 2014, zhongying.game
*	All rights reserved.
*****************************************************************************
*	filename:	HelpFunc.h
*  author:		ye.tao
*	e-mail:		553681974@qq.com
*	created:	2014/09/22
*	descript:   全局函数库
****************************************************************************/
#ifndef __HELP_FUNC_H__
#define __HELP_FUNC_H__

#include "cocos2d.h"
USING_NS_CC;

class HelpFunc
{
public:
	// 加密和解密
	static std::string gXorCoding(std::string str);

	// 由秒数转化为帧数（取整） 
	static int gTimeToFrames(double time);

	// 由帧数转化为秒数 
	static double gFramesToTime(int frames);

	// 生成本地文件
	static void gCreateFileWithContent(std::string fileName, std::string content);

	// 获取随机数：范围内的, 0 ---- nRange-1
	static int gGetRandNumber(int nRange);

	// 获取随机数：闭区间内的 begin 到 end
	static int gGetRandNumberBetween(int nBegin,int nEnd);

	// 数字转为字符串
	static std::string gNumToStr( int nNum );

	// 时间转换为字符串 传入时间为0H 0MS (大写加空格)
	static std::string gTimeToStr(float fTime);

	// 只获取时间的分的数值，转为str
	static std::string gGetMinuteStr(float fTime);

	// 只获取时间的秒的数值，转为str
	static std::string gGetSecondStr(float fTime);

	// 显示CCRect的信息
    static void gShowRectLogInfo(cocos2d::CCRect rect);

	// 获取系统时间（单位：毫秒）
	static long long getSystemMSTime();

	// 获取系统时间（单位：秒）
	static long long getSystemSTime();

	// 获取系统时间（单位：分）
	static long long getSystemMTime();

	// 计算两个点之间的角度（按照数学四象限划分）
	static float gAngleAnalyseForQuad(float startX, float startY, float endX, float endY);

	// 计算两个点之间的角度，可以用来传入setRotation中设置node的角度
	static float gAngleAnalyseForRotation(float startX, float startY, float endX, float endY);

	// 分析从起点到终点的方向（8方向）
	static int gDirectionAnalyse(float startX, float startY, float endX, float endY);

	// 根据当前Rotation的角度分析当前的方向(8方向)
	static int gDirectionAnalyseByAngle(float angle);
	
	// 获取碰撞的方向集合
    static int getCollidingDirections(cocos2d::Rect rect1, cocos2d::Rect rect2);

	// 按位“与”运算
	static int bitAnd(int p1, int p2);

	// 按位“或”运算
	static int bitOr(int p1, int p2);

	// c++中打印
	static void print(std::string str);

	// 获取是否已经断开socket连接
	static bool isSocketConnect();

	// 显示波纹Shader特效
	static void showWaveEffectByShader(Sprite3D * sprite);
	// 隐藏波纹Shader特效
	static void hideWaveEffectByShader(Sprite3D * sprite);
	// 添加波纹Shader特效
	static void addWaveEffectByShader(Sprite3D * sprite, std::string sprite3DPvrName, std::string effectPvrName, Vec4 color);
	// 移除波纹Shader特效
	static void removeWaveEffectByShader(Sprite3D * sprite);

	// 获取引用计数
	static int getRefCount(Ref *ref);

	// 释放所有3D缓存信息
	static void removeAllSprite3DData();

	// 移除所有TimelineActions
	static void removeAllTimelineActions();

	// ----------------------- 设置多点触摸数 ------------------------------
	static void setMaxTouchesNum(int num);

	// ----------------------- 视频播放相关 --------------------------
	// 设置当前是否正在播放视频
	static void setIsPlayingVideo(bool playing);
	static bool _bIsPlayingVideo;
	// 获得当前是否正在播放视频
	static bool isPlayingVideo();
	// 设置当前是否应该重放视频
	static void setNeedToRestartVideo(bool need);
	static bool _bNeedToRestartVideo;
	// 获得当前是否需要重启视频
	static bool isNeedToRestartVideo();
	

	// -----------------------【设备震动】（只限安卓）----------------------
	// 播放震动,参数1：毫秒
	static void playVibrator(int time);
	// 设置震动开关
	static void setVibratorEnabled(bool enable);
	// 震动强度,参数1：毫秒集合  参数2：-1为不循环震动，1为最高模式循环震动，2为所给参数的格式循环震动
	static void vibrateWithPattern(ValueVector pattern, int repeat);
	// 取消震动
	static void cancelVibrate();

	// 标记位：是否震动可用
	static bool _bVibratorEnabled;

	// --------------------------【嘟嘟语音】-------------------------------
	//初始化嘟嘟语音sdk 参数1：服务器id  参数2：用户id
	static void initDuduVoice(int zid, int uid);
	//按下时说话录音
	static void pressRecordVoice();
	//抬起时发送录音
	static void releaseSendVoice();
	//取消发送录音
	static void cancelSendVoice();
	//播放录音
	static void playVoice(std::string id);
	//设置录音的最短时间
	static void setShortRecordTime(int time);
	//设置录音的最长时间
	static void setLongRecordTime(int time);

	//---------------------------【bugly调用接口】-------------------------------------
	//设置用户id
	static void setUserIDForBugly(std::string userID);

	//---------------------------【母包渠道调用接口】----------------------------------
	//母包登录接口
	static void loginZTGame(std::string zoneId, std::string zoneName, bool isAutoLogin);
	//母包支付接口
	static void payZTGame(std::string moneyName, std::string productName, std::string productId, int amount, int exchangedRatio, bool isMonthCard, std::string extraInfo);
	//母包登录完成数据统计接口
	static void loginOKZTGame(std::string roleId, std::string roleName, std::string roleLevel, std::string zoneId, std::string zoneName);
	//母包创建角色数据统计接口
	static void createRoleZTGame(std::string roleId, std::string roleName, std::string roleLevel, std::string zoneId, std::string zoneName);
	//母包角色等级升级信息接口
	static void roleLevelUpZTGame(std::string roleId, std::string roleName, std::string zoneId, std::string zoneName, int level);
	//母包是否需要切换账号按钮接口
	static bool isHasSwitchAccountZTGame();
	//母包切换账号操作接口
	static void switchAccountZTGame();
	//母包是否需要用户中心按钮接口
	static bool isHasCenterZTGame();
	//母包进入用户中心操作
	static void enterCenterZTGame();
	//母包是否需要调用第三方退出框接口
	static bool isHasQuitDialog();
	//母包弹出第三方退出弹出确认框接口
	static void quitZTGame();
	//母包开启日志输出接口
	static void enableDebugMode();
	//母包获取渠道id
	static int getPlatform();
	//母包更新服务器id
	static void setZoneId(std::string zoneId);
	//母包是否已经登录
	static bool isLogined();
    
    //-----------------------------    AdTracking     ---------------------------------------------//
    static void onLogin(std::string account);
    static void onRegister(std::string account);

   //webView
	static void createWebView(Node *pNode,std::string sUrl);


	//分享
	static void share(const char *title, const char *content, const char *imagePath,const char *description,const char *url);

};
#endif  //__HELP_FUNC_H__