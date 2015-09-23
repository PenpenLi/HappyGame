/****************************************************************************
*	Copyright (c) 2013, changyuan.game
*	All rights reserved.
*****************************************************************************
*	filename:	AStarHelper.h
*  author:		ye.tao
*	e-mail:		yetao@11game.com
*	created:	2013/10/29
*	descript:   A*寻路助手
****************************************************************************/
#ifndef __ASTAR_HELPER_H__
#define	 __ASTAR_HELPER_H__

#include "cocos2d.h"
USING_NS_CC;

///////  A* 寻径算法相关   //////////
#define START_NODE_ARRY_INDEX					0   //默认数组第0个元素为起点结点
#define END_NODE_ARRY_INDEX						1   //默认数组第1个元素为终点结点
#define NORMAL_NODE_ARRY_INDEX					2   //默认数组从第2个元素起为普通结点
 
#define BARRIER                                 1    //障碍物在_mapAttri中的标号

//结点的方位（用作数组下标）
#define NODE_LEFT_UP					0
#define NODE_UP							1
#define NODE_RIGHT_UP				    2
#define NODE_RIGHT						3
#define NODE_RIGHT_DOWN					4
#define NODE_DOWN					    5
#define NODE_LEFT_DOWN					6
#define NODE_LEFT						7

typedef enum
{
	eTiledAttriFree							=					0x00000001,						// 自由空地（可利用）
	eTiledAttriBarrier						=					0x00000004,						// 障碍物（不可利用）

}TiledAttriType;

typedef struct node
{
	int F;
	int G;
	int H;
	int nRow;
	int nCol;
	struct node * pFather;
}AStarNode;

enum WalkDirection
{
	eWalkNone			=		0x00,
	eWalkUp				=		0x01,
	eWalkDown			=		0x02,
	eWalkLeft			=		0x04,
	eWalkRight			=		0x08,
	eWalkLeftUp			=		0x10,
	eWalkLeftDown		=		0x20,
	eWalkRightUp		=		0x40,
	eWalkRightDown		=		0x80
};

class AStarHelper
{
public:

	static AStarHelper* getInst();

	// 清空缓存
	void clearCache();
	
	// 初始化地图属性（传入横纵格子数）
	void InitMapAttris(ValueVector tiledAttris);

	// 返回路径  （ValueVector 的真实结构为 std::vector<WalkDirection>）
	ValueVector ComputeAStar(CCPoint startPosIndex, CCPoint endPosIndex);


protected:
	int InitPath(CCPoint startPosIndex, CCPoint endPosIndex);				// 初始化参数,返回值  1：正常  0：起点和终点重合   -1：起点是障碍物  
	void ProcPath();														// A*逻辑Proc 
	void AnalysePath();														// 回溯路径（往返）

protected:
	static AStarHelper* _pInst;

	//普通结点
	std::vector<AStarNode> strNode;
	int   nNodePointer;
	//open list
	std::vector<AStarNode *> pOpenList;
	int   nOpenListPointer;
	//close list
	std::vector<AStarNode *> pCloseList;
	int   nCloseListPointer;

	std::vector< std::vector<int> > _mapAttri;   //地图属性值分布（列、行）  0：可行  1：不可行
	CCSize _sMapSize;							 //横纵格子数

	ValueVector _quequeResult;  //最终A*结果  （ValueVector 的真实结构为 std::vector<WalkDirection>）

};

#endif  //__ASTAR_HELPER_H__
