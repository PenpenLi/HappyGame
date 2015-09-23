/****************************************************************************
*	Copyright (c) 2014, zhongying.game
*	All rights reserved.
*****************************************************************************
*	filename:	Stick.cpp
*  author:		ye.tao
*	e-mail:		553681974@qq.com
*	created:	2014/09/28
*	descript:   控件：虚拟摇杆
****************************************************************************/
#include "Stick.h"
#include "VisibleRect.h"
#include "HelpFunc.h"
Stick::Stick()
{
	_nDirection = -1;
	_fAngle = -1;
	_bIsLocked = false;
	_posStartPos = ccp(0,0);
}

Stick::~Stick()
{

}

Stick * Stick::createWithFrameName( std::string strBottomFrameName, std::string strStickFrameName )
{
	Stick *pRet = new Stick();
	if (pRet && pRet->init(strBottomFrameName, strStickFrameName))
	{ 
		pRet->autorelease();
		return pRet;
	} 
	else
	{ 
		delete pRet; 
		pRet = NULL; 
		return NULL;
	}
}

bool Stick::init(std::string strBottomFrameName, std::string strStickFrameName)
{
	if (!Node::init())
		return false;

	_frame = Sprite::createWithSpriteFrameName(strBottomFrameName);
	addChild(_frame);

	_stick = Sprite::createWithSpriteFrameName(strStickFrameName);
	_stick->setPosition(_frame->getContentSize().width / 2, _frame->getContentSize().height / 2);
	_frame->addChild(_stick);

	//_touchEventListener = EventListenerTouchOneByOne::create();
	//_touchEventListener->onTouchBegan = CC_CALLBACK_2(Stick::onTouchBegan, this);
	//_touchEventListener->onTouchMoved = CC_CALLBACK_2(Stick::onTouchMoved, this);
	//_touchEventListener->onTouchEnded = CC_CALLBACK_2(Stick::onTouchEnded, this);
	//_touchEventListener->onTouchCancelled = CC_CALLBACK_2(Stick::onTouchCancelled, this);
	//_touchEventListener->setSwallowTouches(true);

	//Director::getInstance()->getEventDispatcher()->addEventListenerWithSceneGraphPriority(_touchEventListener, this);
	if(_bIsLocked == false)
	{
		_frame->setOpacity(0);
		_stick->setOpacity(0);
	}
	else
	{
		_frame->setOpacity(128);
		_stick->setOpacity(128);
	}

	_isWorking = false;

	return true;
}

//EventListenerTouchOneByOne * Stick::getTouchListener()
//{
//	return _touchEventListener;
//}

//void Stick::setStickPositionChangeHandler(std::function<void(const int direction, const float angle)> handler)
//{
//	_handler = handler;
//}

bool Stick::onTouchBegan(Point pos)
{
	if(_isWorking) return false;

	if(_bIsLocked == false)
	{
		if ( pos.x <= VisibleRect::width()/2 )
		{
			_stick->stopAllActions();
			_stick->runAction(FadeIn::create(0.1f));
			_frame->stopAllActions();
			_frame->runAction(FadeIn::create(0.1f));

			if( pos.x - _frame->getContentSize().width/2 <= 0 )  // 考虑边界情况
			{
				_frame->setPositionX(_frame->getContentSize().width/2);
				_stick->setPositionX(pos.x);
			}
			else  // 正常情况
			{
				_frame->setPositionX(pos.x);
			}

			if(pos.y - _frame->getContentSize().height/2 <= 0)  // 考虑边界情况
			{
				_frame->setPositionY(_frame->getContentSize().height/2);
				_stick->setPositionY(pos.y);
			}
			else if(pos.y + _frame->getContentSize().height/2 >= VisibleRect::height())  // 考虑边界情况
			{
				_frame->setPositionY(VisibleRect::height() - _frame->getContentSize().height/2);
				_stick->setPositionY(pos.y);
			}
			else   // 正常情况
			{
				_frame->setPositionY(pos.y);
			}

			handleTouchChange(pos);
			return true;
		}
	}
	else
	{
		Rect rect = CCRectMake(_frame->getPositionX() - _frame->getContentSize().width/2, _frame->getPositionY() - _frame->getContentSize().height/2, _frame->getContentSize().width, _frame->getContentSize().height);
		if ( rect.containsPoint(pos) )
		{
			_stick->stopAllActions();
			_stick->runAction(FadeTo::create(0.1f,255));
			_frame->stopAllActions();
			_frame->runAction(FadeTo::create(0.1f,255));

			handleTouchChange(pos);
			return true;
		}	
	}

	return false;
}

void Stick::onTouchMoved(Point pos)
{
	handleTouchChange(pos);

	if(_bIsLocked == false)
	{
		auto bigR = _frame->getContentSize().width / 2;
		auto distance = _frame->getPosition().getDistance(pos);
		if (distance > bigR)
		{
			auto posFrame = _frame->getPosition();
			if(posFrame.x + 30 <= pos.x)
			{
				_frame->setPositionX(posFrame.x + (distance - bigR));
				if(_frame->getPositionX() + bigR >= VisibleRect::width())
				{
					_frame->setPositionX(VisibleRect::width() - bigR);
				}
			}
			else if(posFrame.x - 30 >= pos.x)
			{
				_frame->setPositionX(posFrame.x - (distance - bigR));
				if(_frame->getPositionX() - bigR <= 0)
				{
					_frame->setPositionX(bigR);
				}
			}

			if(posFrame.y + 30 <= pos.y)
			{
				_frame->setPositionY(posFrame.y + (distance - bigR));
				if(_frame->getPositionY() + bigR >= VisibleRect::height())
				{
					_frame->setPositionY(VisibleRect::height() - bigR);
				}
			}
			else if(posFrame.y - 30 >= pos.y)
			{
				_frame->setPositionY(posFrame.y - (distance - bigR));
				if(_frame->getPositionY() - bigR <= 0)
				{
					_frame->setPositionY(bigR);
				}
			}
		}
	}

}

void Stick::onTouchEnded(Point pos)
{
	hide();
}

//void Stick::onTouchCancelled(Touch* touch, Event* event)
//{
//	onTouchEnded(touch, event);
//}

void Stick::handleTouchChange(Point pos)
{
	static Vec2 origin = Vec2(_frame->getContentSize().width / 2, _frame->getContentSize().height / 2);
	static float bigR = _frame->getContentSize().width / 2;
	static float smallR = _stick->getContentSize().width / 2;

	Vec2 hit = this->_frame->convertToNodeSpaceAR(pos);

	if (hit.getDistance(Vec2::ZERO) + smallR > bigR)
	{
		float x = (bigR - smallR) / sqrt(1 + hit.y * hit.y / hit.x / hit.x);
		float y = abs(hit.y / hit.x * x);

		if (hit.x > 0)
		{
			if (hit.y > 0)
			{
				hit.x = x;
				hit.y = y;
			}
			else
			{
				hit.x = x;
				hit.y = -y;
			}
		}
		else
		{
			if (hit.y > 0)
			{
				hit.x = -x;
				hit.y = y;
			}
			else
			{
				hit.x = -x;
				hit.y = -y;
			}
		}
	}

	_stick->setPosition(hit + origin);

	//if (!_handler._Empty())
	{
		float fAngle = HelpFunc::gAngleAnalyseForRotation(_frame->getContentSize().width/2, _frame->getContentSize().height/2, _stick->getPositionX(), _stick->getPositionY());
		if(fAngle != -1)
		{
			int nDirection = HelpFunc::gDirectionAnalyse(_frame->getContentSize().width/2, _frame->getContentSize().height/2, _stick->getPositionX(), _stick->getPositionY());
			//_handler(nDirection, fAngle);
			_nDirection = nDirection;
			_fAngle = fAngle;
		}
	}

}

void Stick::setIsWorking( bool isWorking )
{
	_isWorking = isWorking;
}

bool Stick::getIsWorking()
{
	return _isWorking;
}

float Stick::getAngle()
{
	return _fAngle;
}

int Stick::getDirection()
{
	return _nDirection;
}

void Stick::hide()
{
	static Vec2 origin = Vec2(_frame->getContentSize().width / 2, _frame->getContentSize().height / 2);

	if(_bIsLocked == false)
	{
		_stick->stopAllActions();
		_stick->runAction(Spawn::create(MoveTo::create(0.1f, origin), FadeOut::create(0.1f), nullptr));

		_frame->stopAllActions();
		_frame->runAction(FadeOut::create(0.1f));
		_frame->runAction(Sequence::create(DelayTime::create(0.1),CallFunc::create(CC_CALLBACK_0(Stick::hideOver,this)),nullptr));

	}
	else
	{
		_stick->stopAllActions();
		_stick->runAction(Spawn::create(MoveTo::create(0.1f, origin), FadeTo::create(0.1f,128), nullptr));

		_frame->stopAllActions();
		_frame->runAction(FadeTo::create(0.1f,128));
	}

	_fAngle = -1;
	_nDirection = -1;
}

void Stick::hideOver()
{
	_frame->setPosition(_posStartPos);
}

bool Stick::needUpdate()
{
	if(_fAngle == -1 && _nDirection == -1)
	{
		return false;
	}
	return true;
}

cocos2d::Size Stick::getFrameSize()
{
	return _frame->getContentSize();
}

void Stick::setLocked( bool locked )
{
	_bIsLocked = locked;
	if(_bIsLocked == false)
	{
		_frame->setOpacity(0);
		_stick->setOpacity(0);
	}
	else
	{
		_frame->setOpacity(128);
		_stick->setOpacity(128);
	}
	_frame->setPosition(_posStartPos);

}

void Stick::setStartPosition( Point pos )
{
	_posStartPos = pos;
	_frame->setPosition(_posStartPos);
}
