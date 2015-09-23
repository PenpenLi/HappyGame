/****************************************************************************
*	Copyright (c) 2013, changyuan.game
*	All rights reserved.
*****************************************************************************
*	filename:	AStarHelper.cpp
*  author:		ye.tao
*	e-mail:		yetao@11game.com
*	created:	2013/10/29
*	descript:   A*寻路助手
****************************************************************************/
#include "AStarHelper.h"
#include "math.h"

AStarHelper* AStarHelper::_pInst = nullptr;

AStarHelper* AStarHelper::getInst()
{
	if(_pInst == nullptr)
	{
		_pInst = new AStarHelper();
	}
	return _pInst;
}

void AStarHelper::clearCache()
{
	strNode.clear();
	pOpenList.clear();
	pCloseList.clear();
	_mapAttri.clear();
	_quequeResult.clear();

}


ValueVector AStarHelper::ComputeAStar(CCPoint startPosIndex, CCPoint endPosIndex)
{
	int result = InitPath(startPosIndex, endPosIndex);
	if( result == 1) //正常
	{
		ProcPath();
		AnalysePath();
	}
	else if(result == -1) //起点就是障碍物
	{
		log("A* Start pos is barrier!");
		
	}
	else if(result == -2) //起点和终点重合
	{
		log("A* Start pos and end pos are the same!");
	}
	else if(result == -3) //终点就是障碍物
	{
		log("A* End pos is barrier!");
	}
	return _quequeResult;
}


int AStarHelper::InitPath(CCPoint startPosIndex, CCPoint endPosIndex)  //初始化  第一轮
{
	_quequeResult.clear();  //清空上一次的计算结果

	//初始化数据
	pOpenList.clear();
	pCloseList.clear();

	nNodePointer = 0;
	nOpenListPointer = 0;
	nCloseListPointer = 0;

	if(startPosIndex.y == _sMapSize.height)
	{
		startPosIndex.y = _sMapSize.height - 1;
	}
	else if(startPosIndex.y == -1)
	{
		startPosIndex.y = 0;
	}

	if(startPosIndex.x == _sMapSize.width)
	{
		startPosIndex.x = _sMapSize.width - 1;
	}
	else if(startPosIndex.x == -1)
	{
		startPosIndex.x = 0;
	}

	if(endPosIndex.y == _sMapSize.height)
	{
		endPosIndex.y = _sMapSize.height - 1;
	}
	else if(endPosIndex.y == -1)
	{
		endPosIndex.y = 0;
	}

	if(endPosIndex.x == _sMapSize.width)
	{
		endPosIndex.x = _sMapSize.width - 1;
	}
	else if(endPosIndex.x == -1)
	{
		endPosIndex.x = 0;
	}

	//初始化-------------起始点
	strNode[START_NODE_ARRY_INDEX].nRow = startPosIndex.y;
	strNode[START_NODE_ARRY_INDEX].nCol = startPosIndex.x;
	strNode[START_NODE_ARRY_INDEX].pFather = &strNode[START_NODE_ARRY_INDEX];
	strNode[START_NODE_ARRY_INDEX].G = 0;
	strNode[START_NODE_ARRY_INDEX].H = 0;
	strNode[START_NODE_ARRY_INDEX].F = 0;

	if(_mapAttri[strNode[START_NODE_ARRY_INDEX].nRow][strNode[START_NODE_ARRY_INDEX].nCol] == BARRIER) //如果起点就是障碍物，则直接返回，A*失败
	{
		return -1;
	}

	//将起始点加入close list
	pCloseList.push_back(&strNode[START_NODE_ARRY_INDEX]);
	nCloseListPointer++;

	//初始化-------------终点
	strNode[END_NODE_ARRY_INDEX].nRow = endPosIndex.y;
	strNode[END_NODE_ARRY_INDEX].nCol = endPosIndex.x;
	strNode[END_NODE_ARRY_INDEX].pFather = NULL;
	strNode[END_NODE_ARRY_INDEX].G = 0;
	strNode[END_NODE_ARRY_INDEX].H = 0;
	strNode[END_NODE_ARRY_INDEX].F = 0;

	nNodePointer = NORMAL_NODE_ARRY_INDEX;  //普通结点（除了起始点和终点）从索引值2开始

	if(strNode[START_NODE_ARRY_INDEX].nRow == strNode[END_NODE_ARRY_INDEX].nRow &&
	   strNode[START_NODE_ARRY_INDEX].nCol == strNode[END_NODE_ARRY_INDEX].nCol)  //起点和终点重合的情况
	{
		return -2; //返回，不做处理,A*失败
	}

	if(_mapAttri[strNode[END_NODE_ARRY_INDEX].nRow][strNode[END_NODE_ARRY_INDEX].nCol] == BARRIER) //如果终点就是障碍物，则直接返回，A*失败
	{
		return -3;
	}

	return 1;
}


void AStarHelper::InitMapAttris(ValueVector tiledAttris)
{
	_sMapSize = CCSize((tiledAttris.begin()->asValueVector()).size(), tiledAttris.size());  // x是总列数  y是总行数

	_mapAttri.resize(_sMapSize.height);
	for(int row = 0; row < _sMapSize.height; row++)
	{
		_mapAttri[row].resize(_sMapSize.width);
	}

	//从地图管理器中拷贝地图属性信息
	int rowCount = 0;
	for(ValueVector::iterator itrRow = tiledAttris.begin(); itrRow != tiledAttris.end(); itrRow++, rowCount++) 
	{
		int colCount = 0;
		ValueVector cols = (*itrRow).asValueVector();
		for(ValueVector::iterator itr = cols.begin(); itr != cols.end(); itr++, colCount++) 
		{
			AStarNode  cnode;
			strNode.push_back(cnode);  

			TiledAttriType attriType = (TiledAttriType)((*itr).asInt());
			if(attriType == eTiledAttriFree)
			{
				_mapAttri[rowCount][colCount] = 0;
			}
			else
			{
				_mapAttri[rowCount][colCount] = 1;
			}
		}
	}

}


void AStarHelper::ProcPath()
{
	AStarNode *pCurNode = pCloseList[nCloseListPointer-1];  //当前结点
	do 
	{
		//先遍历一下8个邻接结点是否为有效结点
		bool bNodeInvalid[8] = {false};  //分别代表：左上，上，右上，右，右下，下，左下，左  各个方位的节点是否有效（障碍物，边缘位置，在closelist中的结点都是无效结点）

		////////////筛选 边缘情况///////////////////////
		if(pCurNode->nRow == 0)  //第0行
		{
			bNodeInvalid[NODE_LEFT_UP] = true;
			bNodeInvalid[NODE_UP] = true;
			bNodeInvalid[NODE_RIGHT_UP] = true;
		}
		else if(pCurNode->nRow == _sMapSize.height - 1)   //最后一行
		{
			bNodeInvalid[NODE_LEFT_DOWN] = true;
			bNodeInvalid[NODE_DOWN] = true;
			bNodeInvalid[NODE_RIGHT_DOWN] = true;
		}
		if(pCurNode->nCol == 0)  //第0列
		{
			bNodeInvalid[NODE_LEFT_UP] = true;
			bNodeInvalid[NODE_LEFT] = true;
			bNodeInvalid[NODE_LEFT_DOWN] = true;
		}
		else if(pCurNode->nCol == _sMapSize.width - 1)   //最后一列
		{
			bNodeInvalid[NODE_RIGHT_UP] = true;
			bNodeInvalid[NODE_RIGHT] = true;
			bNodeInvalid[NODE_RIGHT_DOWN] = true;
		}
		////////////////////筛选 closelist中的成员/////////////////////////////////
		for(int i=0;i<nCloseListPointer;i++)
		{
			//左上  判定
			if(bNodeInvalid[NODE_LEFT_UP] == false)
			{
				if(pCloseList[i]->nRow == pCurNode->nRow - 1 && pCloseList[i]->nCol == pCurNode->nCol - 1)
				{
					bNodeInvalid[NODE_LEFT_UP] = true;
				}
			}
			//上  判定
			if(bNodeInvalid[NODE_UP] == false)
			{
				if(pCloseList[i]->nRow == pCurNode->nRow - 1 && pCloseList[i]->nCol == pCurNode->nCol)
				{
					bNodeInvalid[NODE_UP] = true;
				}
			}
			//右上  判定
			if(bNodeInvalid[NODE_RIGHT_UP] == false)
			{
				if(pCloseList[i]->nRow == pCurNode->nRow - 1 && pCloseList[i]->nCol == pCurNode->nCol + 1)
				{
					bNodeInvalid[NODE_RIGHT_UP] = true;
				}
			}
			//右  判定
			if(bNodeInvalid[NODE_RIGHT] == false)
			{
				if(pCloseList[i]->nRow == pCurNode->nRow && pCloseList[i]->nCol == pCurNode->nCol + 1)
				{
					bNodeInvalid[NODE_RIGHT] = true;
				}
			}
			//右下  判定
			if(bNodeInvalid[NODE_RIGHT_DOWN] == false)
			{
				if(pCloseList[i]->nRow == pCurNode->nRow + 1 && pCloseList[i]->nCol == pCurNode->nCol + 1)
				{
					bNodeInvalid[NODE_RIGHT_DOWN] = true;
				}
			}
			//下  判定
			if(bNodeInvalid[NODE_DOWN] == false)
			{
				if(pCloseList[i]->nRow == pCurNode->nRow + 1 && pCloseList[i]->nCol == pCurNode->nCol)
				{
					bNodeInvalid[NODE_DOWN] = true;
				}
			}
			//左下  判定
			if(bNodeInvalid[NODE_LEFT_DOWN] == false)
			{
				if(pCloseList[i]->nRow == pCurNode->nRow + 1 && pCloseList[i]->nCol == pCurNode->nCol - 1)
				{
					bNodeInvalid[NODE_LEFT_DOWN] = true;
				}
			}
			//左  判定
			if(bNodeInvalid[NODE_LEFT] == false)
			{
				if(pCloseList[i]->nRow == pCurNode->nRow && pCloseList[i]->nCol == pCurNode->nCol - 1)
				{
					bNodeInvalid[NODE_LEFT] = true;
				}
			}
		}
		////////////////////筛选 障碍物/////////////////////////////////
		//左上
		if(bNodeInvalid[NODE_LEFT_UP] == false)
		{
			if( _mapAttri[pCurNode->nRow - 1][pCurNode->nCol - 1] == BARRIER) //如果是障碍物，则设为无效的图块
			{
				bNodeInvalid[NODE_LEFT_UP] = true;
			}
		}
		//上  
		if(bNodeInvalid[NODE_UP] == false)
		{
			if( _mapAttri[pCurNode->nRow - 1][pCurNode->nCol] == BARRIER)
			{
				bNodeInvalid[NODE_UP] = true;
			}
		}
		//右上  
		if(bNodeInvalid[NODE_RIGHT_UP] == false)
		{
			if( _mapAttri[pCurNode->nRow - 1][pCurNode->nCol + 1] == BARRIER)
			{
				bNodeInvalid[NODE_RIGHT_UP] = true;
			}
		}
		//右  
		if(bNodeInvalid[NODE_RIGHT] == false)
		{
			if( _mapAttri[pCurNode->nRow][pCurNode->nCol + 1] == BARRIER)
			{
				bNodeInvalid[NODE_RIGHT] = true;
			}
		}
		//右下  
		if(bNodeInvalid[NODE_RIGHT_DOWN] == false)
		{
			if( _mapAttri[pCurNode->nRow + 1][pCurNode->nCol + 1] == BARRIER)
			{
				bNodeInvalid[NODE_RIGHT_DOWN] = true;
			}
		}
		//下  
		if(bNodeInvalid[NODE_DOWN] == false)
		{
			if(_mapAttri[pCurNode->nRow + 1][pCurNode->nCol] == BARRIER)
			{
				bNodeInvalid[NODE_DOWN] = true;
			}
		}
		//左下  
		if(bNodeInvalid[NODE_LEFT_DOWN] == false)
		{
			if( _mapAttri[pCurNode->nRow + 1][pCurNode->nCol - 1] == BARRIER)
			{
				bNodeInvalid[NODE_LEFT_DOWN] = true;
			}
		}
		//左  
		if(bNodeInvalid[NODE_LEFT] == false)
		{
			if( _mapAttri[pCurNode->nRow][pCurNode->nCol - 1] == BARRIER)
			{
				bNodeInvalid[NODE_LEFT] = true;
			}
		}

		//再遍历一下openlist中是否有8个邻接结点中的结点
		bool bNodeExistInOpenlist[8] = {false};  //分别代表：左上，上，右上，右，右下，下，左下，左  各个方位的节点在openlist中是否已经存在
		int         nNodeExistIndexInOpenlist[8] = {-1,-1,-1,-1,-1,-1,-1,-1};  //分别代表：左上，上，右上，右，右下，下，左下，左  各个方位的节点如果在openlist中已经存在，则存储其在openlist中得数组下标
		for(int i=0;i<nOpenListPointer;i++)
		{
			//左上  判定
			if(bNodeInvalid[NODE_LEFT_UP] == false)
			{
				if(pOpenList[i]->nRow == pCurNode->nRow - 1 && pOpenList[i]->nCol == pCurNode->nCol - 1)
				{
					bNodeExistInOpenlist[NODE_LEFT_UP] = true;
					nNodeExistIndexInOpenlist[NODE_LEFT_UP] = i;
				}
			}
			//上  判定
			if(bNodeInvalid[NODE_UP] == false)
			{
				if(pOpenList[i]->nRow == pCurNode->nRow - 1 && pOpenList[i]->nCol == pCurNode->nCol)
				{
					bNodeExistInOpenlist[NODE_UP] = true;
					nNodeExistIndexInOpenlist[NODE_UP] = i;
				}
			}
			//右上  判定
			if(bNodeInvalid[NODE_RIGHT_UP] == false)
			{
				if(pOpenList[i]->nRow == pCurNode->nRow - 1 && pOpenList[i]->nCol == pCurNode->nCol + 1)
				{
					bNodeExistInOpenlist[NODE_RIGHT_UP] = true;
					nNodeExistIndexInOpenlist[NODE_RIGHT_UP] = i;
				}
			}
			//右  判定
			if(bNodeInvalid[NODE_RIGHT] == false)
			{
				if(pOpenList[i]->nRow == pCurNode->nRow && pOpenList[i]->nCol == pCurNode->nCol + 1)
				{
					bNodeExistInOpenlist[NODE_RIGHT] = true;
					nNodeExistIndexInOpenlist[NODE_RIGHT] = i;
				}
			}
			//右下  判定
			if(bNodeInvalid[NODE_RIGHT_DOWN] == false)
			{
				if(pOpenList[i]->nRow == pCurNode->nRow + 1 && pOpenList[i]->nCol == pCurNode->nCol + 1)
				{
					bNodeExistInOpenlist[NODE_RIGHT_DOWN] = true;
					nNodeExistIndexInOpenlist[NODE_RIGHT_DOWN] = i;
				}
			}
			//下  判定
			if(bNodeInvalid[NODE_DOWN] == false)
			{
				if(pOpenList[i]->nRow == pCurNode->nRow + 1 && pOpenList[i]->nCol == pCurNode->nCol)
				{
					bNodeExistInOpenlist[NODE_DOWN] = true;
					nNodeExistIndexInOpenlist[NODE_DOWN] = i;
				}
			}
			//左下  判定
			if(bNodeInvalid[NODE_LEFT_DOWN] == false)
			{
				if(pOpenList[i]->nRow == pCurNode->nRow + 1 && pOpenList[i]->nCol == pCurNode->nCol - 1)
				{
					bNodeExistInOpenlist[NODE_LEFT_DOWN] = true;
					nNodeExistIndexInOpenlist[NODE_LEFT_DOWN] = i;
				}
			}
			//左  判定
			if(bNodeInvalid[NODE_LEFT] == false)
			{
				if(pOpenList[i]->nRow == pCurNode->nRow && pOpenList[i]->nCol == pCurNode->nCol - 1)
				{
					bNodeExistInOpenlist[NODE_LEFT] = true;
					nNodeExistIndexInOpenlist[NODE_LEFT] = i;
				}
			}
		}

		//如果openlist中没有这8个邻接结点中的某几个时，则初始化该结点，并加入openlist
		//左上结点
		if(bNodeInvalid[NODE_LEFT_UP] == false && bNodeExistInOpenlist[NODE_LEFT_UP] == false)
		{
			strNode[nNodePointer].nRow = pCurNode->nRow - 1;
			strNode[nNodePointer].nCol = pCurNode->nCol - 1;
			strNode[nNodePointer].pFather = pCurNode;
			strNode[nNodePointer].G = pCurNode->G+14;
			strNode[nNodePointer].H = 10*(abs(strNode[nNodePointer].nRow - strNode[END_NODE_ARRY_INDEX].nRow) + abs(strNode[nNodePointer].nCol - strNode[END_NODE_ARRY_INDEX].nCol));
			strNode[nNodePointer].F = strNode[nNodePointer].G + strNode[nNodePointer].H;
			pOpenList.push_back(&strNode[nNodePointer]);
			nOpenListPointer++;
			nNodePointer++;
		}
		//上结点
		if(bNodeInvalid[NODE_UP] == false && bNodeExistInOpenlist[NODE_UP] == false)
		{
			strNode[nNodePointer].nRow = pCurNode->nRow - 1;
			strNode[nNodePointer].nCol = pCurNode->nCol;
			strNode[nNodePointer].pFather = pCurNode;
			strNode[nNodePointer].G = pCurNode->G+10;
			strNode[nNodePointer].H = 10*(abs(strNode[nNodePointer].nRow - strNode[END_NODE_ARRY_INDEX].nRow) + abs(strNode[nNodePointer].nCol - strNode[END_NODE_ARRY_INDEX].nCol));
			strNode[nNodePointer].F = strNode[nNodePointer].G + strNode[nNodePointer].H;
			pOpenList.push_back(&strNode[nNodePointer]);
			nOpenListPointer++;
			nNodePointer++;
		}
		//右上结点
		if(bNodeInvalid[NODE_RIGHT_UP] == false && bNodeExistInOpenlist[NODE_RIGHT_UP] == false)
		{
			strNode[nNodePointer].nRow = pCurNode->nRow - 1;
			strNode[nNodePointer].nCol = pCurNode->nCol + 1;
			strNode[nNodePointer].pFather = pCurNode;
			strNode[nNodePointer].G = pCurNode->G+14;
			strNode[nNodePointer].H = 10*(abs(strNode[nNodePointer].nRow - strNode[END_NODE_ARRY_INDEX].nRow) + abs(strNode[nNodePointer].nCol - strNode[END_NODE_ARRY_INDEX].nCol));
			strNode[nNodePointer].F = strNode[nNodePointer].G + strNode[nNodePointer].H;
			pOpenList.push_back(&strNode[nNodePointer]);
			nOpenListPointer++;
			nNodePointer++;
		}
		//右结点
		if(bNodeInvalid[NODE_RIGHT] == false && bNodeExistInOpenlist[NODE_RIGHT] == false)
		{
			strNode[nNodePointer].nRow = pCurNode->nRow;
			strNode[nNodePointer].nCol = pCurNode->nCol + 1;
			strNode[nNodePointer].pFather = pCurNode;
			strNode[nNodePointer].G = pCurNode->G+10;
			strNode[nNodePointer].H = 10*(abs(strNode[nNodePointer].nRow - strNode[END_NODE_ARRY_INDEX].nRow) + abs(strNode[nNodePointer].nCol - strNode[END_NODE_ARRY_INDEX].nCol));
			strNode[nNodePointer].F = strNode[nNodePointer].G + strNode[nNodePointer].H;
			pOpenList.push_back(&strNode[nNodePointer]);
			nOpenListPointer++;
			nNodePointer++;
		}
		//右下结点
		if(bNodeInvalid[NODE_RIGHT_DOWN] == false && bNodeExistInOpenlist[NODE_RIGHT_DOWN] == false)
		{
			strNode[nNodePointer].nRow = pCurNode->nRow+1;
			strNode[nNodePointer].nCol = pCurNode->nCol + 1;
			strNode[nNodePointer].pFather = pCurNode;
			strNode[nNodePointer].G = pCurNode->G+14;
			strNode[nNodePointer].H = 10*(abs(strNode[nNodePointer].nRow - strNode[END_NODE_ARRY_INDEX].nRow) + abs(strNode[nNodePointer].nCol - strNode[END_NODE_ARRY_INDEX].nCol));
			strNode[nNodePointer].F = strNode[nNodePointer].G + strNode[nNodePointer].H;
			pOpenList.push_back(&strNode[nNodePointer]);
			nOpenListPointer++;
			nNodePointer++;
		}
		//下结点
		if(bNodeInvalid[NODE_DOWN] == false && bNodeExistInOpenlist[NODE_DOWN] == false)
		{
			strNode[nNodePointer].nRow = pCurNode->nRow+1;
			strNode[nNodePointer].nCol = pCurNode->nCol;
			strNode[nNodePointer].pFather = pCurNode;
			strNode[nNodePointer].G = pCurNode->G+10;
			strNode[nNodePointer].H = 10*(abs(strNode[nNodePointer].nRow - strNode[END_NODE_ARRY_INDEX].nRow) + abs(strNode[nNodePointer].nCol - strNode[END_NODE_ARRY_INDEX].nCol));
			strNode[nNodePointer].F = strNode[nNodePointer].G + strNode[nNodePointer].H;
			pOpenList.push_back(&strNode[nNodePointer]);
			nOpenListPointer++;
			nNodePointer++;
		}
		//左下结点
		if(bNodeInvalid[NODE_LEFT_DOWN] == false && bNodeExistInOpenlist[NODE_LEFT_DOWN] == false)
		{
			strNode[nNodePointer].nRow = pCurNode->nRow + 1;
			strNode[nNodePointer].nCol = pCurNode->nCol - 1;
			strNode[nNodePointer].pFather = pCurNode;
			strNode[nNodePointer].G = pCurNode->G+14;
			strNode[nNodePointer].H = 10*(abs(strNode[nNodePointer].nRow - strNode[END_NODE_ARRY_INDEX].nRow) + abs(strNode[nNodePointer].nCol - strNode[END_NODE_ARRY_INDEX].nCol));
			strNode[nNodePointer].F = strNode[nNodePointer].G + strNode[nNodePointer].H;
			pOpenList.push_back(&strNode[nNodePointer]);
			nOpenListPointer++;
			nNodePointer++;
		}
		//左结点
		if(bNodeInvalid[NODE_LEFT] == false && bNodeExistInOpenlist[NODE_LEFT] == false)
		{
			strNode[nNodePointer].nRow = pCurNode->nRow;
			strNode[nNodePointer].nCol = pCurNode->nCol - 1;
			strNode[nNodePointer].pFather = pCurNode;
			strNode[nNodePointer].G = pCurNode->G+10;
			strNode[nNodePointer].H = 10*(abs(strNode[nNodePointer].nRow - strNode[END_NODE_ARRY_INDEX].nRow) + abs(strNode[nNodePointer].nCol - strNode[END_NODE_ARRY_INDEX].nCol));
			strNode[nNodePointer].F = strNode[nNodePointer].G + strNode[nNodePointer].H;
			pOpenList.push_back(&strNode[nNodePointer]);
			nOpenListPointer++;
			nNodePointer++;
		}

		//对于之前已经在openlist中的结点，则要判断一下是否存在最优路径(比较G的值)
		//左上  判定
		if(bNodeExistInOpenlist[NODE_LEFT_UP])
		{
			if(pCurNode->G + 20 < pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT_UP]]->G)  //有最优路径
			{
				//修改openlist中的这个结点相关信息
				pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT_UP]]->pFather = pCurNode;
				pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT_UP]]->G = pCurNode->G+14;
				pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT_UP]]->H = 10*(abs(pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT_UP]]->nRow - strNode[END_NODE_ARRY_INDEX].nRow) + abs(pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT_UP]]->nCol - strNode[END_NODE_ARRY_INDEX].nCol));
				pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT_UP]]->F = pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT_UP]]->G + pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT_UP]]->H;
			}
		}
		//上  判定
		if(bNodeExistInOpenlist[NODE_UP])
		{
			if(pCurNode->G + 10 < pOpenList[nNodeExistIndexInOpenlist[NODE_UP]]->G)  //有最优路径
			{
				//修改openlist中的这个结点相关信息
				pOpenList[nNodeExistIndexInOpenlist[NODE_UP]]->pFather = pCurNode;
				pOpenList[nNodeExistIndexInOpenlist[NODE_UP]]->G = pCurNode->G+10;
				pOpenList[nNodeExistIndexInOpenlist[NODE_UP]]->H = 10*(abs(pOpenList[nNodeExistIndexInOpenlist[NODE_UP]]->nRow - strNode[END_NODE_ARRY_INDEX].nRow) + abs(pOpenList[nNodeExistIndexInOpenlist[NODE_UP]]->nCol - strNode[END_NODE_ARRY_INDEX].nCol));
				pOpenList[nNodeExistIndexInOpenlist[NODE_UP]]->F = pOpenList[nNodeExistIndexInOpenlist[NODE_UP]]->G + pOpenList[nNodeExistIndexInOpenlist[NODE_UP]]->H;
			}
		}
		//右上  判定
		if(bNodeExistInOpenlist[NODE_RIGHT_UP])
		{
			if(pCurNode->G + 20 < pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT_UP]]->G)  //有最优路径
			{
				//修改openlist中的这个结点相关信息
				pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT_UP]]->pFather = pCurNode;
				pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT_UP]]->G = pCurNode->G+14;
				pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT_UP]]->H = 10*(abs(pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT_UP]]->nRow - strNode[END_NODE_ARRY_INDEX].nRow) + abs(pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT_UP]]->nCol - strNode[END_NODE_ARRY_INDEX].nCol));
				pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT_UP]]->F = pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT_UP]]->G + pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT_UP]]->H;
			}
		}
		//右  判定
		if(bNodeExistInOpenlist[NODE_RIGHT])
		{
			if(pCurNode->G + 10 < pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT]]->G)  //有最优路径
			{
				//修改openlist中的这个结点相关信息
				pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT]]->pFather = pCurNode;
				pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT]]->G = pCurNode->G+10;
				pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT]]->H = 10*(abs(pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT]]->nRow - strNode[END_NODE_ARRY_INDEX].nRow) + abs(pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT]]->nCol - strNode[END_NODE_ARRY_INDEX].nCol));
				pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT]]->F = pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT]]->G + pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT]]->H;
			}
		}
		//右下  判定
		if(bNodeExistInOpenlist[NODE_RIGHT_DOWN])
		{
			if(pCurNode->G + 20 < pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT_DOWN]]->G)  //有最优路径
			{
				//修改openlist中的这个结点相关信息
				pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT_DOWN]]->pFather = pCurNode;
				pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT_DOWN]]->G = pCurNode->G+14;
				pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT_DOWN]]->H = 10*(abs(pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT_DOWN]]->nRow - strNode[END_NODE_ARRY_INDEX].nRow) + abs(pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT_DOWN]]->nCol - strNode[END_NODE_ARRY_INDEX].nCol));
				pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT_DOWN]]->F = pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT_DOWN]]->G + pOpenList[nNodeExistIndexInOpenlist[NODE_RIGHT_DOWN]]->H;
			}
		}
		//下  判定
		if(bNodeExistInOpenlist[NODE_DOWN])
		{
			if(pCurNode->G + 10 < pOpenList[nNodeExistIndexInOpenlist[NODE_DOWN]]->G)  //有最优路径
			{
				//修改openlist中的这个结点相关信息
				pOpenList[nNodeExistIndexInOpenlist[NODE_DOWN]]->pFather = pCurNode;
				pOpenList[nNodeExistIndexInOpenlist[NODE_DOWN]]->G = pCurNode->G+10;
				pOpenList[nNodeExistIndexInOpenlist[NODE_DOWN]]->H = 10*(abs(pOpenList[nNodeExistIndexInOpenlist[NODE_DOWN]]->nRow - strNode[END_NODE_ARRY_INDEX].nRow) + abs(pOpenList[nNodeExistIndexInOpenlist[NODE_DOWN]]->nCol - strNode[END_NODE_ARRY_INDEX].nCol));
				pOpenList[nNodeExistIndexInOpenlist[NODE_DOWN]]->F = pOpenList[nNodeExistIndexInOpenlist[NODE_DOWN]]->G + pOpenList[nNodeExistIndexInOpenlist[NODE_DOWN]]->H;
			}
		}
		//左下  判定
		if(bNodeExistInOpenlist[NODE_LEFT_DOWN])
		{
			if(pCurNode->G + 20 < pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT_DOWN]]->G)  //有最优路径
			{
				//修改openlist中的这个结点相关信息
				pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT_DOWN]]->pFather = pCurNode;
				pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT_DOWN]]->G = pCurNode->G+14;
				pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT_DOWN]]->H = 10*(abs(pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT_DOWN]]->nRow - strNode[END_NODE_ARRY_INDEX].nRow) + abs(pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT_DOWN]]->nCol - strNode[END_NODE_ARRY_INDEX].nCol));
				pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT_DOWN]]->F = pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT_DOWN]]->G + pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT_DOWN]]->H;
			}
		}
		//左  判定
		if(bNodeExistInOpenlist[NODE_LEFT])
		{
			if(pCurNode->G + 10 < pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT]]->G)  //有最优路径
			{
				//修改openlist中的这个结点相关信息
				pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT]]->pFather = pCurNode;
				pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT]]->G = pCurNode->G+10;
				pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT]]->H = 10*(abs(pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT]]->nRow - strNode[END_NODE_ARRY_INDEX].nRow) + abs(pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT]]->nCol - strNode[END_NODE_ARRY_INDEX].nCol));
				pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT]]->F = pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT]]->G + pOpenList[nNodeExistIndexInOpenlist[NODE_LEFT]]->H;
			}
		}

		//遍历openlist中F值最小的结点
		AStarNode *pMinNode = pOpenList[0]; //在openlist中最小F值的结点
		std::vector<AStarNode *>::iterator itrMin;
		for(std::vector<AStarNode *>::iterator itr = pOpenList.begin();itr != pOpenList.end(); ++itr)
		{
			if(pMinNode->F >= (*itr)->F)
			{
				pMinNode = (*itr);
				itrMin = itr;
			}
		}
		//并将F值最小的结点从openlist中删掉
		pOpenList.erase(itrMin);
		nOpenListPointer--;
		//将在openlist中删掉的F最小的结点加入到closelist中
		pCloseList.push_back(pMinNode);
		nCloseListPointer++;
		pCurNode = pMinNode;
	}while(pCloseList[nCloseListPointer - 1]->nRow != strNode[END_NODE_ARRY_INDEX].nRow  || pCloseList[nCloseListPointer - 1]->nCol  != strNode[END_NODE_ARRY_INDEX].nCol);
}

void AStarHelper::AnalysePath()
{
	AStarNode *pCurNode = pCloseList[nCloseListPointer - 1];  //获取终点（stone的位置结点） 
	std::vector<WalkDirection> nTempMoveCmdQueue;
	//下面先在closelist中获取回去的路
	while(pCurNode != pCloseList[0])  //pCloseList[0]为起始结点
	{
		if(pCurNode->pFather->nRow < pCurNode->nRow) //左上、上、右上
		{
			if(pCurNode->pFather->nCol < pCurNode->nCol)  //左上
			{
				if( _mapAttri[pCurNode->pFather->nRow+1][pCurNode->pFather->nCol] == BARRIER && _mapAttri[pCurNode->pFather->nRow][pCurNode->pFather->nCol + 1] != BARRIER)//只有左边有障碍
				{
					nTempMoveCmdQueue.push_back(eWalkUp);
					nTempMoveCmdQueue.push_back(eWalkLeft);
				}
				else if( _mapAttri[pCurNode->pFather->nRow][pCurNode->pFather->nCol+1] == BARRIER && _mapAttri[pCurNode->pFather->nRow+1][pCurNode->pFather->nCol] != BARRIER)//只有上边有障碍
				{
					nTempMoveCmdQueue.push_back(eWalkLeft);
					nTempMoveCmdQueue.push_back(eWalkUp);
				}
				else
				{
					nTempMoveCmdQueue.push_back(eWalkLeftUp);
				}
			}
			else if(pCurNode->pFather->nCol == pCurNode->nCol)  //上
			{
				nTempMoveCmdQueue.push_back(eWalkUp);
			}
			else if(pCurNode->pFather->nCol > pCurNode->nCol)  //右上
			{
				if( _mapAttri[pCurNode->pFather->nRow+1][pCurNode->pFather->nCol] == BARRIER && _mapAttri[pCurNode->pFather->nRow][pCurNode->pFather->nCol-1] != BARRIER)  //只有右边有障碍
				{
					nTempMoveCmdQueue.push_back(eWalkUp);
					nTempMoveCmdQueue.push_back(eWalkRight);
				}
				else if( _mapAttri[pCurNode->pFather->nRow][pCurNode->pFather->nCol-1] == BARRIER && _mapAttri[pCurNode->pFather->nRow+1][pCurNode->pFather->nCol] != BARRIER)  //只有上边有障碍物
				{
					nTempMoveCmdQueue.push_back(eWalkRight);
					nTempMoveCmdQueue.push_back(eWalkUp);
				}
				else
				{
					nTempMoveCmdQueue.push_back(eWalkRightUp);
				}
			}
		}
		else if(pCurNode->pFather->nRow == pCurNode->nRow)  //左、右
		{
			if(pCurNode->pFather->nCol < pCurNode->nCol)  //左
			{
				nTempMoveCmdQueue.push_back(eWalkLeft);
			}
			else if(pCurNode->pFather->nCol > pCurNode->nCol)  //右
			{
				nTempMoveCmdQueue.push_back(eWalkRight);
			}
		}
		else if(pCurNode->pFather->nRow > pCurNode->nRow)  //左下、下、右下
		{
			if(pCurNode->pFather->nCol < pCurNode->nCol)  //左下
			{
				if( _mapAttri[pCurNode->pFather->nRow-1][pCurNode->pFather->nCol] == BARRIER && _mapAttri[pCurNode->pFather->nRow][pCurNode->pFather->nCol+1] != BARRIER )
				{
					nTempMoveCmdQueue.push_back(eWalkDown);
					nTempMoveCmdQueue.push_back(eWalkLeft);
				}
				else if( _mapAttri[pCurNode->pFather->nRow][pCurNode->pFather->nCol+1] == BARRIER && _mapAttri[pCurNode->pFather->nRow-1][pCurNode->pFather->nCol] != BARRIER)
				{
					nTempMoveCmdQueue.push_back(eWalkLeft);
					nTempMoveCmdQueue.push_back(eWalkDown);
				}
				else
				{
					nTempMoveCmdQueue.push_back(eWalkLeftDown);
				}
			}
			else if(pCurNode->pFather->nCol == pCurNode->nCol)  //下
			{
				nTempMoveCmdQueue.push_back(eWalkDown);
			}
			else if(pCurNode->pFather->nCol > pCurNode->nCol)  //右下
			{
				if( _mapAttri[pCurNode->pFather->nRow][pCurNode->pFather->nCol-1] == BARRIER && _mapAttri[pCurNode->pFather->nRow-1][pCurNode->pFather->nCol] != BARRIER)
				{
					nTempMoveCmdQueue.push_back(eWalkRight);
					nTempMoveCmdQueue.push_back(eWalkDown);
				}
				else if(_mapAttri[pCurNode->pFather->nRow-1][pCurNode->pFather->nCol] == BARRIER && _mapAttri[pCurNode->pFather->nRow][pCurNode->pFather->nCol-1] != BARRIER)
				{
					nTempMoveCmdQueue.push_back(eWalkDown);
					nTempMoveCmdQueue.push_back(eWalkRight);
				}
				else
				{
					nTempMoveCmdQueue.push_back(eWalkRightDown);
				}
			}
		}
		pCurNode = pCurNode->pFather;
	}

	////然后在已经得到回溯路径的基础上，倒置数组得到来时的路径
	for(unsigned int i=0;i < nTempMoveCmdQueue.size();i++)
	{
		if(nTempMoveCmdQueue[nTempMoveCmdQueue.size() -1 - i] == eWalkUp)
		{
			_quequeResult.push_back(Value(eWalkDown));
		}
		else if(nTempMoveCmdQueue[nTempMoveCmdQueue.size() -1 - i] == eWalkDown)
		{
			_quequeResult.push_back(Value(eWalkUp));
		}
		else if(nTempMoveCmdQueue[nTempMoveCmdQueue.size() -1 - i] == eWalkLeft)
		{
			_quequeResult.push_back(Value(eWalkRight));
		}
		else if(nTempMoveCmdQueue[nTempMoveCmdQueue.size() -1 - i] == eWalkRight)
		{
			_quequeResult.push_back(Value(eWalkLeft));
		}
		else if(nTempMoveCmdQueue[nTempMoveCmdQueue.size() -1 - i] == eWalkLeftUp)
		{
			_quequeResult.push_back(Value(eWalkRightDown));
		}
		else if(nTempMoveCmdQueue[nTempMoveCmdQueue.size() -1 - i] == eWalkRightUp)
		{
			_quequeResult.push_back(Value(eWalkLeftDown));
		}
		else if(nTempMoveCmdQueue[nTempMoveCmdQueue.size() -1 - i] == eWalkLeftDown)
		{
			_quequeResult.push_back(Value(eWalkRightUp));
		}
		else if(nTempMoveCmdQueue[nTempMoveCmdQueue.size() -1 - i] == eWalkRightDown)
		{
			_quequeResult.push_back(Value(eWalkLeftUp));
		}
	}
}
