/****************************************************************************
*	Copyright (c) 2014, zhongying.game
*	All rights reserved.
*****************************************************************************
*	filename:	Stick.h
*  author:		ye.tao
*	e-mail:		553681974@qq.com
*	created:	2014/09/28
*	descript:   控件：虚拟摇杆
****************************************************************************/
#ifndef __STICK_H__
#define __STICK_H__

#include "cocos2d.h"
USING_NS_CC;

class Stick : public Node
{
public:
	static Stick * createWithFrameName(std::string strBottomFrameName, std::string strStickFrameName);
	Stick();
	virtual ~Stick();

	virtual bool init(std::string strBottomFrameName, std::string strStickFrameName);

	// 获取触摸监听器
	//EventListenerTouchOneByOne * getTouchListener();

	// 设置回调函数
	//void setStickPositionChangeHandler(std::function<void(const int direction, const float angle)> handler);

	// 循环处理
	bool needUpdate();

	// 设置 / 获取是否正在工作
	void setIsWorking(bool isWorking);
	bool getIsWorking();

	// 获取当前摇杆的角度
	float getAngle();

	// 获取当前摇杆决定的方向
	int getDirection();

	// 隐藏掉摇杆
	void hide();

	void hideOver();

	bool onTouchBegan(Point pos);
	void onTouchMoved(Point pos);
	void onTouchEnded(Point pos);
	//void onTouchCancelled(Touch*, Event*);

	void handleTouchChange(Point pos);

	Size getFrameSize();

	void setLocked(bool locked);
	void setStartPosition(Point pos);

private:
	Sprite* _stick;
	Sprite* _frame;
	//std::function<void(const int direction, const float angle)> _handler;
	bool _isWorking;
	//EventListenerTouchOneByOne* _touchEventListener;
	float _fAngle;
	int _nDirection;

	bool _bIsLocked;		// 摇杆是否已经锁定
	Point _posStartPos;		// 摇杆其实位置

};

#endif // __STICK_H__

