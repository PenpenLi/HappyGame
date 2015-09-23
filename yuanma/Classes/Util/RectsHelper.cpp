/****************************************************************************
*	Copyright (c) 2015, zhongying.game
*	All rights reserved.
*****************************************************************************
*	filename:	RectsHelper.cpp
*  author:		ye.tao
*	e-mail:		553681974@qq.com
*	created:	2015/1/21
*	descript:   矩形管理器
****************************************************************************/
#include "RectsHelper.h"
#include "HelpFunc.h"

RectsHelper* RectsHelper::_pInst = nullptr;

RectsHelper* RectsHelper::getInst()
{
	if(_pInst == nullptr)
	{
		_pInst = new RectsHelper();
	}
	return _pInst;
}

void RectsHelper::clearCache(int mapAreaRowNum, int mapAreaColNum)
{
	_vvBottomsRects.clear();
	_vvBodysRects.clear();
	_vvUndefsRects.clear();

	nMapAreaRowNum = mapAreaRowNum;
	nMapAreaColNum = mapAreaColNum;

	for(int num=0;num<nMapAreaRowNum*nMapAreaColNum;num++)
	{
		std::vector<Rect> temp;
		_vvBottomsRects.push_back(temp);
		_vvBodysRects.push_back(temp);
		_vvUndefsRects.push_back(temp);
	}

}

void RectsHelper::insertBottomRect( int nAreaIndex, Rect bottom )
{
	_vvBottomsRects[nAreaIndex-1].push_back(bottom);
}

void RectsHelper::insertBodyRect( int nAreaIndex, Rect body )
{
	_vvBodysRects[nAreaIndex-1].push_back(body);
}

void RectsHelper::insertUndefRect( int nAreaIndex, Rect undef )
{
	_vvUndefsRects[nAreaIndex-1].push_back(undef);
}

int RectsHelper::isCollidingBottomOnBottomsInArea( int nAreaIndex, Rect bottom, bool bAtBottomDirection /*= false*/, int bottomDirection /*= -1*/ )
{
	int collisionDirections = 0;
	if(nAreaIndex <= _vvBottomsRects.size())
	{
		std::vector<Rect> &bottoms = _vvBottomsRects[nAreaIndex-1];  // 获取该区域内的所有bottom矩形
		for(std::vector<Rect>::iterator itr = bottoms.begin(); itr != bottoms.end(); itr++)
		{
			collisionDirections = HelpFunc::getCollidingDirections(bottom, (*itr));
			if (collisionDirections != 0)   // 说明存在direction方向的碰撞
			{
				if (bAtBottomDirection)  // 在自身方向上发生碰撞
				{
					if ((collisionDirections & bottomDirection) == bottomDirection)
					{
						break;
					}
				}
				else
				{
					break;
				}
			}
		}
	}
	else
	{
		collisionDirections = -1;
	}

	return collisionDirections;
}

int RectsHelper::isCollidingBottomOnBodysInArea( int nAreaIndex, Rect bottom, bool bAtBottomDirection /*= false*/, int bottomDirection /*= -1*/ )
{
	int collisionDirections = 0;
	if(nAreaIndex <= _vvBodysRects.size())
	{
		std::vector<Rect> &bodys = _vvBodysRects[nAreaIndex-1];  // 获取该区域内的所有bottom矩形
		for(std::vector<Rect>::iterator itr = bodys.begin(); itr != bodys.end(); itr++)
		{
			collisionDirections = HelpFunc::getCollidingDirections(bottom, (*itr));
			if (collisionDirections != 0)   // 说明存在direction方向的碰撞
			{
				if (bAtBottomDirection)  // 在自身方向上发生碰撞
				{
					if ((collisionDirections & bottomDirection) == bottomDirection)
					{
						break;
					}
				}
				else
				{
					break;
				}
			}
		}
	}
	else
	{
		collisionDirections = -1;
	}

	return collisionDirections;
}

void RectsHelper::removeRect( int nAreaIndex, int type, int rectIndex )
{
	nAreaIndex--;
	rectIndex--;
	//  1：Bottom   2：Body   3：Undef
	if(type == 1)
	{
		_vvBottomsRects[nAreaIndex].erase(_vvBottomsRects[nAreaIndex].begin() + rectIndex);
	}
	else if(type == 2)
	{
		_vvBodysRects[nAreaIndex].erase(_vvBodysRects[nAreaIndex].begin() + rectIndex);
	}
	else if(type == 3)
	{
		_vvUndefsRects[nAreaIndex].erase(_vvUndefsRects[nAreaIndex].begin() + rectIndex);
	}

}
