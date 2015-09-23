/****************************************************************************
*	Copyright (c) 2015, zhongying.game
*	All rights reserved.
*****************************************************************************
*	filename:	RectsHelper.h
*  author:		ye.tao
*	e-mail:		553681974@qq.com
*	created:	2015/1/21
*	descript:   矩形管理器
****************************************************************************/
#ifndef __RECTS_HELPER_H__
#define __RECTS_HELPER_H__

#include "cocos2d.h"
USING_NS_CC;

class RectsHelper
{
public:
	static RectsHelper* getInst();
	// 清空缓存
	void clearCache(int mapAreaRowNum, int mapAreaColNum);

	// 在指定区域插入bottom矩形
	void insertBottomRect(int nAreaIndex, Rect bottom);
	// 在指定区域插入body矩形
	void insertBodyRect(int nAreaIndex, Rect body);
	// 在指定区域插入undef矩形
	void insertUndefRect(int nAreaIndex, Rect undef);

	// 在指定区域移除矩形 参数1：地图区域index   参数2：类型  1：Bottom   2：Body   3：Undef  参数3：在对应矩形区域内的矩形index
	void removeRect(int nAreaIndex, int type, int rectIndex);


	// 指定bottom是否在指定区域Area内的bottoms上发生碰撞，返回值为碰撞集合
	int isCollidingBottomOnBottomsInArea( int nAreaIndex, Rect bottom, bool bAtBottomDirection = false, int bottomDirection = -1);
	// 指定bottom是否在指定区域Area内的bodys上发生碰撞，返回值为碰撞集合
	int isCollidingBottomOnBodysInArea( int nAreaIndex, Rect bottom, bool bAtBottomDirection = false, int bottomDirection = -1);

protected:
	static RectsHelper* _pInst;
	int nMapAreaRowNum;
	int nMapAreaColNum;
	std::vector< std::vector<Rect> > _vvBottomsRects;
	std::vector< std::vector<Rect> > _vvBodysRects;
	std::vector< std::vector<Rect> > _vvUndefsRects;
};

#endif  //__RECTS_HELPER_H__