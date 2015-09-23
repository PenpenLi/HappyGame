/****************************************************************************
*	Copyright (c) 2015, zhongying.game
*	All rights reserved.
*****************************************************************************
*	filename:	TriggersHelper.h
*  author:		ye.tao
*	e-mail:		553681974@qq.com
*	created:	2015/1/29
*	descript:   触发器管理器
****************************************************************************/
#ifndef __TRIGGERS_HELPER_H__
#define __TRIGGERS_HELPER_H__

#include "cocos2d.h"
USING_NS_CC;

class TriggersHelper
{
public:
	static TriggersHelper* getInst();
	// 清空缓存
	void clearCache(int mapAreaRowNum, int mapAreaColNum);

	// 在指定区域插入bottom矩形
	void insertTriggerRect(int nAreaIndex, Rect rect);

	// 在指定区域移除矩形 参数1：地图区域index  参数2：在对应矩形区域内的矩形index
	void removeTriggerRect(int nAreaIndex, int rectIndex);

	// 指定bottom是否在指定区域Area内的bottoms上发生碰撞，返回值为rect在当前区域内的index
	int isCollidingBottomOnTriggerRectInArea( int nAreaIndex, Rect bottom);


protected:
	static TriggersHelper* _pInst;
	int nMapAreaRowNum;
	int nMapAreaColNum;
	std::vector< std::vector<Rect> > _vvTriggerRects;
};

#endif  //__TRIGGERS_HELPER_H__