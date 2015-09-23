/****************************************************************************
*	Copyright (c) 2015, zhongying.game
*	All rights reserved.
*****************************************************************************
*	filename:	TriggersHelper.cpp
*  author:		ye.tao
*	e-mail:		553681974@qq.com
*	created:	2015/1/29
*	descript:   触发器管理器
****************************************************************************/
#include "TriggersHelper.h"
#include "HelpFunc.h"

TriggersHelper* TriggersHelper::_pInst = nullptr;

TriggersHelper* TriggersHelper::getInst()
{
	if(_pInst == nullptr)
	{
		_pInst = new TriggersHelper();
	}
	return _pInst;
}

void TriggersHelper::clearCache(int mapAreaRowNum, int mapAreaColNum)
{
	_vvTriggerRects.clear();

	nMapAreaRowNum = mapAreaRowNum;
	nMapAreaColNum = mapAreaColNum;

	for(int num=0;num<nMapAreaRowNum*nMapAreaColNum;num++)
	{
		std::vector<Rect> temp;
		_vvTriggerRects.push_back(temp);
	}

}

void TriggersHelper::insertTriggerRect( int nAreaIndex, Rect rect )
{
	_vvTriggerRects[nAreaIndex-1].push_back(rect);
}

int TriggersHelper::isCollidingBottomOnTriggerRectInArea( int nAreaIndex, Rect bottom )
{
	int index = 0;
	int count = 1;  // 根据lua计数，从1开始
	std::vector<Rect> &rects = _vvTriggerRects[nAreaIndex-1];  // 获取该区域内的所有bottom矩形
	for(std::vector<Rect>::iterator itr = rects.begin(); itr != rects.end(); itr++,count++)
	{
		int collisionDirections = HelpFunc::getCollidingDirections(bottom, (*itr));
		if (collisionDirections != 0)   // 说明存在direction方向的碰撞
		{
			index = count;
			break;
		}
	}
	return index;
}

void TriggersHelper::removeTriggerRect(int nAreaIndex, int rectIndex)
{
	nAreaIndex--;
	rectIndex--;
	_vvTriggerRects[nAreaIndex].erase(_vvTriggerRects[nAreaIndex].begin() + rectIndex);
}
