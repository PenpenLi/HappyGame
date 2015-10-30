/****************************************************************************
*	Copyright (c) 2014, zhongying.game
*	All rights reserved.
*****************************************************************************
*	filename:	HelpFunc.cpp
*  author:		ye.tao
*	e-mail:		553681974@qq.com
*	created:	2014/09/22
*	descript:   全局函数库
****************************************************************************/
#include "HelpFunc.h"
#include "cocostudio/CocoStudio.h"
#include "xnet_server.h"
#include "VisibleRect.h"
#include "DebugHelper.h"
#include "ensRippleNode.h"
#include "ensNormalMappedNode.h"

#if(CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#include "platform/android/jni/JniHelper.h"
#include <jni.h>
#include "Vibrate.h"
#include "DuduVoice.h"
#include "SDKHelper.h"
#include "TalkingDataHelper.h"
#include "C2DXShareSDK.h"
#include "ui/CocosGUI.h"
using namespace cn::sharesdk;
using namespace cocos2d::experimental::ui;

#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
#include "VibrateHelper.h"
#include "DuduVoiceHelper.h"
#include "SDKHelper.h"
#include "TalkingDataHelper.h"
#include "C2DXShareSDK.h"
using namespace cn::sharesdk;
#include "ui/CocosGUI.h"
using namespace cocos2d::experimental::ui;
#endif

std::string HelpFunc::gXorCoding(std::string str_in)
{
	static char key[] = "11gamezytyljfyxhylyjsyyqxjxcztm";
    std::string str_out;
	str_out.resize(str_in.size());
	for (int i = 0; i < str_in.size(); i++)
	{
		str_out[i] = (char) (str_in[i] ^ key[i % strlen(key)] | 0x10);
	}
	return str_out;
}

int HelpFunc::gTimeToFrames( double time )
{
	return (int)(time / Director::sharedDirector()->getAnimationInterval());
}

double HelpFunc::gFramesToTime( int frames )
{
	return frames * Director::sharedDirector()->getAnimationInterval();
}

void HelpFunc::gCreateFileWithContent( std::string fileName, std::string content )
{
	auto  path =FileUtils::getInstance()->getWritablePath();
	log("%s", path.c_str());
	path.append(fileName);

	FILE* file = fopen(path.c_str(), "wb");
	if (file)
	{
		fputs(content.c_str(), file);
		fclose(file);
	}
	return;
}

int HelpFunc::gGetRandNumber( int nRange )
{
	//获取系统时间
	struct timeval now;	//timeval是个结构体，里边有俩个变量，一个是以秒为单位的，一个是以微妙为单位的 
	gettimeofday(&now, NULL);

	//初始化随机种子
	unsigned rand_seed = (unsigned)(now.tv_sec*1000 + now.tv_usec/1000);    //都转化为毫秒 
	srand(rand_seed);

	if(nRange != 0)
	{
		int random = rand() % nRange;
		return random;
	}
	return 0;
}

int HelpFunc::gGetRandNumberBetween( int nBegin,int nEnd )
{
	nEnd++;
	int nRange = nEnd - nBegin;
	return (nBegin+HelpFunc::gGetRandNumber(nRange));
}

std::string HelpFunc::gNumToStr( int nNum )
{
	std::string strDes;
	strDes.clear();
	char data[30] = {'\0'};
	sprintf(data, "%d", nNum);
	strDes = data;
	return strDes;
}

std::string HelpFunc::gTimeToStr( float fTime )
{
	std::string strDes = "";
	strDes.clear();
	float nNewTime = fTime + 0.99f;
	int nNum = (long long)fTime%3600;

	if((long long)fTime/3600/24 != 0) // 从天记起（不显示分钟和秒数）
	{
		strDes += HelpFunc::gNumToStr((long long)fTime/3600/24) +"天 ";  // 天
		if((long long)fTime/3600%24 != 0)
		{
			strDes += HelpFunc::gNumToStr((long long)fTime/3600%24) +"时";  // 小时
		}	
	}
	else if((long long)fTime/3600 != 0) // 从小时记起
	{
		strDes += HelpFunc::gNumToStr((long long)fTime/3600) +"时 ";  // 小时
		if(nNum/60 != 0)
		{
			strDes += HelpFunc::gNumToStr(nNum/60) +"分";  // 分钟
		}
		if ((long long)fTime%60 != 0)
		{
			strDes += HelpFunc::gNumToStr(nNum%60) +"秒";  //秒
		}
		
	}
	else if(nNum/60 != 0) // 从分钟记起
	{
		strDes += HelpFunc::gNumToStr(nNum/60) +"分 ";  // 分钟
		if(nNum%60 != 0)
		{
			strDes += HelpFunc::gNumToStr(nNum%60) +"秒";  // 秒
		}
	}
	else if(nNum%60 != 0) // 从秒记起
	{
		strDes += HelpFunc::gNumToStr(nNum%60) +"秒";  // 秒
	}
	else if (fTime  == 0)
	{
		strDes = "0秒";
	}
	else if (fTime  != 0)
	{
		strDes = "1秒";
	}
	
	return strDes;
}

std::string HelpFunc::gGetMinuteStr( float fTime )
{
	std::string str = "";
	// 分 格式："00"
	if(HelpFunc::gNumToStr(((int)fTime)/60).size() == 1)
	{
		str = "0" + HelpFunc::gNumToStr(((int)fTime)/60);
	}
	else
	{
		str = HelpFunc::gNumToStr(((int)fTime)/60);
	}
	return str;
}

std::string HelpFunc::gGetSecondStr( float fTime )
{
	std::string str = "";
	// 秒 格式："00"
	if(HelpFunc::gNumToStr(((int)fTime)%60).size() == 1)
	{
		str = "0" + HelpFunc::gNumToStr(((int)fTime)%60);
	}
	else
	{
		str = HelpFunc::gNumToStr(((int)fTime)%60);
	}
	return str;
}

void HelpFunc::gShowRectLogInfo( CCRect rect )
{
	log("rect x = %f, y = %f, w = %f, h = %f", rect.origin.x, rect.origin.y, rect.size.width, rect.size.height);
}

long long HelpFunc::getSystemMSTime()
{
	//获取系统时间
	struct timeval now;	//timeval是个结构体，里边有俩个变量，一个是以秒为单位的，一个是以微妙为单位的 
	gettimeofday(&now, NULL);
	//初始化随机种子
	long long time = now.tv_sec*1000 + now.tv_usec/1000;    //都转化为毫秒 

	return time;
}

long long HelpFunc::getSystemSTime()
{
	//获取系统时间
	struct timeval now;	//timeval是个结构体，里边有俩个变量，一个是以秒为单位的，一个是以【微妙】为单位的 
	gettimeofday(&now, NULL);
	//初始化随机种子
	long long time = now.tv_sec + now.tv_usec/1000/1000;    //都转化为秒 

	return time;
}

long long HelpFunc::getSystemMTime()
{
	//获取系统时间
	struct timeval now;	//timeval是个结构体，里边有俩个变量，一个是以秒为单位的，一个是以【微妙】为单位的 
	gettimeofday(&now, NULL);
	//初始化随机种子
	long long time = now.tv_sec/60 + now.tv_usec/1000/1000/60;    //都转化为毫秒 

	return time;
}

float HelpFunc::gAngleAnalyseForQuad(float startX, float startY, float endX, float endY)
{
	float PI = 3.1415926f;
	float dis = sqrtf((startX - endX)*(startX - endX) + (startY - endY)*(startY - endY));
	float disX = fabs(endX - startX);
	float disY = fabs(endY - startY);

	if (startY < endY)  // 1,2象限
	{
		if(startX <= endX) //1象限
		{	
			float cosValue = disX / dis; 
			return acos(cosValue)*180/PI;
		}
		else  //2象限
		{
			float cosValue = - disX / dis; 
			return acos(cosValue)*180/PI;
		}
	}
	else  // 3,4象限
	{
		if(startX <= endX) //4象限
		{	
			float cosValue = disX / dis; 
			return (270 + asin(cosValue)*180/PI);
		}
		else  //3象限
		{
			float cosValue = - disX / dis; 
			return ( 270 + asin(cosValue)*180/PI);
		}
	}
	return -1;   //没有结果
}

float HelpFunc::gAngleAnalyseForRotation(float startX, float startY, float endX, float endY)
{
	float PI = 3.1415926f;
	float dis = sqrtf((startX - endX)*(startX - endX) + (startY - endY)*(startY - endY));
	float disX = fabs(endX - startX);

	if(dis == 0) return -1;

	if (startY < endY)  // 1,2象限
	{
		if(startX <= endX) //1象限
		{	
			float cosValue = disX / dis; 
			return acos(cosValue)*180/PI;
		}
		else  //2象限
		{
			float cosValue = - disX / dis; 
			return acos(cosValue)*180/PI;
		}
	}
	else  // 3,4象限
	{
		if(startX <= endX) //4象限
		{	
			float cosValue = disX / dis; 
			return (270 + asin(cosValue)*180/PI);
		}
		else  //3象限
		{
			float cosValue = - disX / dis; 
			return ( 270 + asin(cosValue)*180/PI);
		}
	}
	return -1;   //没有结果
}

int HelpFunc::gDirectionAnalyse( float startX, float startY, float endX, float endY )
{
	float PI = 3.1415926f;
	float dis = sqrtf((startX - endX)*(startX - endX) + (startY - endY)*(startY - endY));
	float disX = fabs(endX - startX);
	float disY = fabs(endY - startY);

	float angleValue = -1;

	if (startY < endY)  // 1,2象限
	{
		if(startX <= endX) //1象限
		{	
			float cosValue = disX / dis; 
			angleValue = acos(cosValue)*180/PI;
		}
		else  //2象限
		{
			float cosValue = - disX / dis; 
			angleValue = acos(cosValue)*180/PI;
		}
	}
	else  // 3,4象限
	{
		if(startX <= endX) //4象限
		{	
			float cosValue = disX / dis; 
			angleValue = (270 + asin(cosValue)*180/PI);
		}
		else  //3象限
		{
			float cosValue = - disX / dis; 
			angleValue = (270 + asin(cosValue)*180/PI);
		}
	}

	int nRet = 0x00;

	if(angleValue <= 22.5f)
	{
		nRet = 0x08;  // 右
	}
	else if(angleValue <= 67.5f)
	{
		nRet = 0x40;   //右上
	}
	else if(angleValue <= 112.5f)
	{
		nRet = 0x01;   // 上
	}
	else if(angleValue <= 157.5f)
	{
		nRet = 0x10;   // 左上
	}
	else if(angleValue <= 202.5f)
	{
		nRet = 0x04;  // 左
	}
	else if(angleValue <= 247.5f)
	{
		nRet = 0x20;  // 左下
	}
	else if(angleValue <= 292.5f)
	{
		nRet = 0x02;   // 下
	}
	else if(angleValue <= 337.5f)
	{
		nRet = 0x80;  // 右下
	}
	else
	{
		nRet = 0x08;  // 右
	}
	return nRet;   //没有结果
}

int HelpFunc::gDirectionAnalyseByAngle( float angle )
{
	float fAngle = (int(angle) + 360) % 360;

	int nRet = 0x00;

	if(fAngle <= 22.5f)
	{
		nRet = 0x08;  // 右
	}
	else if(fAngle <= 67.5f)
	{
		nRet = 0x40;   //右上
	}
	else if(fAngle <= 112.5f)
	{
		nRet = 0x01;   // 上
	}
	else if(fAngle <= 157.5f)
	{
		nRet = 0x10;   // 左上
	}
	else if(fAngle <= 202.5f)
	{
		nRet = 0x04;  // 左
	}
	else if(fAngle <= 247.5f)
	{
		nRet = 0x20;  // 左下
	}
	else if(fAngle <= 292.5f)
	{
		nRet = 0x02;   // 下
	}
	else if(fAngle <= 337.5f)
	{
		nRet = 0x80;  // 右下
	}
	else
	{
		nRet = 0x08;  // 右
	}
	return nRet;   //没有结果
}

int HelpFunc::getCollidingDirections(Rect rect1, Rect rect2)
{
	// 方向定义
	int kNone           =       0x00;
	int kUp             =       0x01;
	int kDown           =       0x02;
	int kLeft           =       0x04;
	int kRight          =       0x08;
	int kLeftUp         =       0x10;
	int kLeftDown       =       0x20;
	int kRightUp        =       0x40;
	int kRightDown      =       0x80;

	int directions = 0;

	if (rect1.intersectsRect(rect2) == true)
	{
		if ( rect1.getMaxX() < rect2.getMaxX() )
		{
			directions |= kRight;
		}
		if ( rect1.getMinX() > rect2.getMinX() )
		{
			directions |= kLeft;
		}
		if ( rect1.getMaxY() < rect2.getMaxY() )
		{
			directions |= kUp;
		}
		if ( rect1.getMinY() > rect2.getMinY() )
		{
			directions |= kDown;
		}
		if ( (directions & kUp) == kUp )
		{
			if ( (directions & kLeft) == kLeft )
			{
				directions |= kLeftUp;
			}
			if ( (directions & kRight) == kRight )
			{
				directions |= kRightUp;
			}
		}
		if ( (directions & kDown) == kDown )
		{
			if ( (directions & kLeft) == kLeft )
			{
				directions |= kLeftDown;
			}
			if ( (directions & kRight) == kRight )
			{
				directions |= kRightDown;
			}
		}
		if ( ( rect1.getMinX() >= rect2.getMinX() && rect1.getMaxX() <= rect2.getMaxX() && rect1.getMinY() >= rect2.getMinY() && rect1.getMaxY() <= rect2.getMaxY() ) ||
			 ( rect2.getMinX() >= rect1.getMinX() && rect2.getMaxX() <= rect1.getMaxX() && rect2.getMinY() >= rect1.getMinY() && rect2.getMaxY() <= rect1.getMaxY() ) )
		{
			// 整个包含
			directions |= kUp;
			directions |= kDown;
			directions |= kLeft;
			directions |= kRight;
			directions |= kLeftUp;
			directions |= kLeftDown;
			directions |= kRightUp;
			directions |= kRightDown;
		}
	}
	return directions;
}

int HelpFunc::bitAnd( int p1, int p2 )
{
	return (p1 & p2);
}

int HelpFunc::bitOr( int p1, int p2 )
{
	return (p1 | p2);
}

void HelpFunc::print( std::string str )
{
	log("%s",str.c_str());
}

bool HelpFunc::isSocketConnect()
{
    bool isOpen = XSockServer::sharedSockServer()->isOpen();
	return isOpen;
}

void HelpFunc::showWaveEffectByShader( Sprite3D * sprite )
{
	sprite->getGLProgramState()->setUniformInt("nSkip",0);
	return;
}

void HelpFunc::hideWaveEffectByShader( Sprite3D * sprite )
{
	HelpFunc::removeWaveEffectByShader(sprite);
	return;
}

void HelpFunc::addWaveEffectByShader(Sprite3D * sprite, std::string sprite3DPvrName, std::string effectPvrName, Vec4 color)
{
	// 设置精灵贴图
	sprite->setTexture(sprite3DPvrName);

	// 将vsh与fsh装配成一个完整的Shader文件。
	auto glprogram = GLProgram::createWithFilenames("UVAnimation.vsh", "UVAnimation.fsh");
	//auto glprogram = GLProgram::createWithFilenames("ccShader_3D_PositionTex.vert", "ccShader_3D_ColorTex.frag");
	// 由Shader文件创建这个Shader
	auto glprogramstate = GLProgramState::getOrCreateWithGLProgram(glprogram);
	// 给精灵设置所用的Shader
	sprite->setGLProgramState(glprogramstate);

	//创建精灵所用的贴图。
	auto textrue1 = Director::getInstance()->getTextureCache()->getTextureForKey(sprite3DPvrName);
	//将贴图设置给Shader中的变量值u_texture1
	glprogramstate->setUniformTexture("u_texture1", textrue1);

	//创建波光特效贴图。
	auto textrue2 = Director::getInstance()->getTextureCache()->getTextureForKey(effectPvrName);
	//将贴图设置给Shader中的变量值u_lightTexture
	glprogramstate->setUniformTexture("u_lightTexture", textrue2);

	//注意，对于波光特效贴图，我们希望它在进行UV动画时能产生四方连续效果，必须设置它的纹理UV寻址方式为GL_REPEAT。
	Texture2D::TexParams		tRepeatParams;
	tRepeatParams.magFilter = GL_LINEAR_MIPMAP_LINEAR;
	tRepeatParams.minFilter = GL_LINEAR;
	tRepeatParams.wrapS = GL_REPEAT;
	tRepeatParams.wrapT = GL_REPEAT;
	textrue2->setTexParameters(tRepeatParams);

	//在这里，我们设置一个波光特效的颜色。
	//Vec4  tLightColor(1.0,1.0,1.0,1.0);
	glprogramstate->setUniformVec4("v_LightColor",color);

	// 设置为非跳过特效参数
	glprogramstate->setUniformInt("nSkip",0);

	//下面这一段，是为了将我们自定义的Shader与我们的模型顶点组织方式进行匹配。模型的顶点数据一般包括位置，法线，色彩，纹理，以及骨骼绑定信息。而Shader需要将内部相应的顶点属性通道与模型相应的顶点属性数据进行绑定才能正确显示出顶点。
	long offset = 0;
	auto attributeCount = sprite->getMesh()->getMeshVertexAttribCount();
	for (auto k = 0; k < attributeCount; k++) {
		auto meshattribute = sprite->getMesh()->getMeshVertexAttribute(k);
		glprogramstate->setVertexAttribPointer(s_attributeNames[meshattribute.vertexAttrib],
			meshattribute.size,
			meshattribute.type,
			GL_FALSE,
			sprite->getMesh()->getVertexSizeInBytes(),
			(GLvoid*)offset);
		offset += meshattribute.attribSizeBytes;
	}

	return;
}

void HelpFunc::removeWaveEffectByShader( Sprite3D * sprite )
{
	sprite->getGLProgramState()->setUniformInt("nSkip",1);
	return;
}

int HelpFunc::getRefCount( Ref *ref )
{
	return ref->getReferenceCount();
}

void HelpFunc::removeAllSprite3DData()
{
	//Sprite3DCache::getInstance()->removeAllSprite3DData();
	return;
}

void HelpFunc::removeAllTimelineActions()
{
	cocostudio::timeline::ActionTimelineCache::destroyInstance();
	CSLoader::getInstance()->purge();
}

void HelpFunc::playVibrator(int time)
{
	if(!_bVibratorEnabled)
	{
		return;
	}
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
    vibrateJNI(time);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    VibrateHelper::vibrate();
#endif
    
}

bool HelpFunc::_bVibratorEnabled = true;
void HelpFunc::setVibratorEnabled( bool enable )
{
	_bVibratorEnabled = enable;
}

void HelpFunc::onLogin(std::string account)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    TalkingDataHelper::onLogin(account.c_str());
#endif
}

void HelpFunc::onRegister(std::string account)
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
    TalkingDataHelper::onRegister(account.c_str());
#endif
}

void HelpFunc::vibrateWithPattern( ValueVector pattern, int repeat )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	long long ary[20]={0};
	//从地图管理器中拷贝地图属性信息
	int count = 0;
	for(ValueVector::iterator itr = pattern.begin(); itr != pattern.end(); itr++, count++) 
	{
		ary[count] = (long long)((*itr).asInt());
	}
	vibrateWithPatternJNI(ary, repeat);
#endif
}

void HelpFunc::cancelVibrate()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	cancelVibrateJNI();
#endif

}

void HelpFunc::initDuduVoice( int zid, int uid )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	initDuduVoiceJNI(zid, uid);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	DuduVoiceHelper::getInst()->initDuduVoice(zid,uid);
#endif
}

void HelpFunc::pressRecordVoice()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	pressRecordVoiceJNI();
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	DuduVoiceHelper::getInst()->pressRecordVoice();
#endif
}

void HelpFunc::releaseSendVoice()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	releaseSendVoiceJNI();
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	DuduVoiceHelper::getInst()->releaseSendVoice();
#endif
}

void HelpFunc::cancelSendVoice()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	cancelSendVoiceJNI();
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	DuduVoiceHelper::getInst()->cancelSendVoice();
#endif
}

void HelpFunc::playVoice( std::string id )
{
	if(id.empty()==true)
	{
		return;
	}
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	playVoiceJNI(id);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	DuduVoiceHelper::getInst()->playVoice(id);
#endif
}

void HelpFunc::setShortRecordTime( int time )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	setShortRecordTimeJNI(time);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	DuduVoiceHelper::getInst()->setShortRecordTime(time);
#endif
}

void HelpFunc::setLongRecordTime( int time )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	setLongRecordTimeJNI(time);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	DuduVoiceHelper::getInst()->setLongRecordTime(time);
#endif
}

void HelpFunc::setUserIDForBugly( std::string userID )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	setUserIDForBuglyJNI(userID);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	SDKHelper::setUserIDForBugly(userID);
#endif
}

void HelpFunc::setMaxTouchesNum( int num )
{
	EventTouch::MAX_TOUCHES = num;
}

bool HelpFunc::_bIsPlayingVideo = false;
void HelpFunc::setIsPlayingVideo( bool playing )
{
	_bIsPlayingVideo = playing;
}

bool HelpFunc::isPlayingVideo()
{
	return _bIsPlayingVideo;
}

bool HelpFunc::_bNeedToRestartVideo = false;
void HelpFunc::setNeedToRestartVideo( bool need )
{
	_bNeedToRestartVideo = need;
}

bool HelpFunc::isNeedToRestartVideo()
{
	return _bNeedToRestartVideo;
}

void HelpFunc::loginZTGame( std::string zoneId, std::string zoneName, bool isAutoLogin )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	loginZTGameJNI(zoneId,zoneName,isAutoLogin);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	SDKHelper::loginZTGame();
#endif
}

void HelpFunc::payZTGame( std::string moneyName, std::string productName, std::string productId, int amount, int exchangedRatio, bool isMonthCard, std::string extraInfo )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	payZTGameJNI(moneyName, productName, productId, amount, exchangedRatio, isMonthCard, extraInfo);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	SDKHelper::payZTGame(productName, productId, amount, exchangedRatio, extraInfo);
#endif
}

void HelpFunc::loginOKZTGame( std::string roleId, std::string roleName, std::string roleLevel, std::string zoneId, std::string zoneName )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	loginOKZTGameJNI(roleId, roleName, roleLevel, zoneId, zoneName );
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

#endif
}

void HelpFunc::createRoleZTGame( std::string roleId, std::string roleName, std::string roleLevel, std::string zoneId, std::string zoneName )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	createRoleZTGameJNI(roleId, roleName, roleLevel, zoneId, zoneName);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

#endif
}

void HelpFunc::roleLevelUpZTGame( std::string roleId, std::string roleName, std::string zoneId, std::string zoneName, int level )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	roleLevelUpZTGameJNI(roleId, roleName, zoneId, zoneName, level);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

#endif
}

bool HelpFunc::isHasSwitchAccountZTGame()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	return isHasSwitchAccountZTGameJNI();
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	return SDKHelper::isHasSwitchAccountZTGame();
#endif
	return false;
}

void HelpFunc::switchAccountZTGame()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	switchAccountZTGameJNI();
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	SDKHelper::switchAccountZTGame();
#endif
}

bool HelpFunc::isHasCenterZTGame()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	return isHasCenterZTGameJNI();
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	return SDKHelper::isHasCenterZTGame();
#endif
	return false;
}

void HelpFunc::enterCenterZTGame()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	enterCenterZTGameJNI();
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	SDKHelper::enterCenterZTGame();
#endif
}

bool HelpFunc::isHasQuitDialog()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	return isHasQuitDialogJNI();
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

#endif
	return false;
}

void HelpFunc::quitZTGame()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	quitZTGameJNI();
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)

#endif
}

void HelpFunc::enableDebugMode()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	enableDebugModeJNI();
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	SDKHelper::enableDebugMode();
#endif
}

int HelpFunc::getPlatform()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	return getPlatformJNI();
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	return SDKHelper::getPlatformID();
#endif
	return -1;
}

void HelpFunc::setZoneId( std::string zoneId )
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	setZoneIdJNI(zoneId);
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	SDKHelper::setZoneId(zoneId);
#endif
}

bool HelpFunc::isLogined()
{
#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID)
	return isLoginedJNI();
#elif (CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
	return SDKHelper::isLogined();
#endif
	return false;
}

#if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
void authResultHandler(C2DXResponseState state, C2DXPlatType platType, __Dictionary *error)
{
    CCLOG("authResultHandler");
    switch (state) {
        case C2DXResponseStateSuccess:
            CCLOG("授权成功");
            break;
        case C2DXResponseStateFail:
            CCLOG("授权失败");
            break;
        default:
            CCLOG("授权取消");
            break;
    }
}

void getUserResultHandler(C2DXResponseState state, C2DXPlatType platType, __Dictionary *userInfo, __Dictionary *error, __Dictionary *db)
{
    CCLOG("getUserResultHandler");
    if (state == C2DXResponseStateSuccess)
    {
        //输出用户信息
        __Array *allKeys = db -> allKeys();
        allKeys->retain();
        for (int i = 0; i < allKeys -> count(); i++)
        {
            __String *key = (__String *)allKeys -> getObjectAtIndex(i);
            Ref *obj = db -> objectForKey(key -> getCString());
            
            CCLOG("key = %s", key -> getCString());
            if (dynamic_cast<__String *>(obj))
            {
                CCLOG("value = %s", dynamic_cast<__String *>(obj) -> getCString());
            }
            else if (dynamic_cast<__Integer *>(obj))
            {
                CCLOG("value = %d", dynamic_cast<__Integer *>(obj) -> getValue());
            }
            else if (dynamic_cast<__Double *>(obj))
            {
                CCLOG("value = %f", dynamic_cast<__Double *>(obj) -> getValue());
            }
        }
        allKeys->release();
    }
}

void shareResultHandler(C2DXResponseState state, C2DXPlatType platType, __Dictionary *shareInfo, __Dictionary *error)
{
    CCLOG("shareResultHandler");
    switch (state) {
        case C2DXResponseStateSuccess:
            CCLOG("分享成功");
            break;
        case C2DXResponseStateFail:
        {
            CCLOG("分享失败: %d : %s", ((__Integer *)error -> objectForKey("error_code")) -> getValue(), ((__String *)error -> objectForKey("error_msg")) -> getCString() );
            
        }
            break;
        default:
            CCLOG("分享取消");
            break;
    }
}

void followResultHandler(C2DXResponseState state, C2DXPlatType platType,  __Dictionary *error)
{
    CCLOG("shareResultHandler");
    switch (state) {
        case C2DXResponseStateSuccess:
            CCLOG("关注成功");
            break;
        case C2DXResponseStateFail:
            CCLOG("关注失败");
            break;
        default:
            CCLOG("关注取消");
            break;
    }

}
#endif

void HelpFunc::share(const char *title, const char *content, const char *imagePath,const char *description,const char *url)
{
//    //这两个根据需要，和平台进行调用
//    C2DXShareSDK::authorize(C2DXPlatTypeSinaWeibo, authResultHandler);      //用户授权
//    C2DXShareSDK::getUserInfo(C2DXPlatTypeSinaWeibo, getUserResultHandler); //获取授权用户信息
    #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
		__Dictionary *shareContent = __Dictionary::create();
		shareContent -> setObject(__String::create(title), "title");
		shareContent -> setObject(__String::create(content), "content");
	    shareContent -> setObject(__String::create(imagePath), "image");
		shareContent -> setObject(__String::create(description), "description");
		shareContent -> setObject(__String::create(url), "url");
		shareContent -> setObject(__String::createWithFormat("%d", C2DXContentTypeNews), "type");

		C2DXShareSDK::showShareMenu(NULL, shareContent, Vec2(100, 100), C2DXMenuArrowDirectionUp, shareResultHandler);

	#endif
}

void HelpFunc::createWebView(Node *pNode,std::string sUrl)
{
	  #if (CC_TARGET_PLATFORM == CC_PLATFORM_ANDROID || CC_TARGET_PLATFORM == CC_PLATFORM_IOS)
			WebView *webView = WebView::create();
			webView->setPosition(Vec2(0,0));
			webView->setContentSize(Size(VisibleRect::getVisibleSize().width*2/3,VisibleRect::getVisibleSize().height*2/3));
			webView->loadURL(sUrl.c_str());
			webView->setScalesPageToFit(false);
			webView->setOnShouldStartLoading([](WebView *sender, const std::string &url){
				sender->setVisible(false);
				return true;
			});
			webView->setOnDidFinishLoading([](WebView *sender, const std::string &url){
		        sender->setVisible(true);
			});
			webView->setOnDidFailLoading([](WebView *sender, const std::string &url){
        
			});
			pNode->addChild(webView);
	  #endif
}

Node* HelpFunc::createRippleNode(std::string spriteFrameName)
{
	auto m_rippleSprite = new ens::CrippleSprite();
	m_rippleSprite->autorelease();
	m_rippleSprite->init(spriteFrameName,8);
	m_rippleSprite->scheduleUpdate();
	return m_rippleSprite;
}

void HelpFunc::doRippleNodeTouch(Node * rippleNode, Point pos, float depth, float r)
{
	((ens::CrippleSprite*)rippleNode)->doTouch(pos, depth, r);
}

Node* HelpFunc::createLightNode( std::string spriteFileName )
{
	//lightNode
	auto lightNode = new ens::normalMapped::ClightSprite();
	lightNode->autorelease();
	lightNode->init(spriteFileName);
	lightNode->setZ(50);
	return lightNode;
}

Node* HelpFunc::createNormalMappedNode( Node* lightNode, std::string spriteFileName1, std::string spriteFileName2, std::string spriteLightFileName, int KBump )
{
	//normlMappedSprite
	auto normalMappedNode = new ens::CnormalMappedSprite();
	normalMappedNode->autorelease();
	normalMappedNode->init(spriteFileName1,spriteFileName2,spriteLightFileName);
	normalMappedNode->setLightSprite((ens::normalMapped::ClightSprite*)lightNode);
	normalMappedNode->setKBump(KBump);
	return normalMappedNode;
}
