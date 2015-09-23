#ifndef _XNET_MESSAGE_H_
#define _XNET_MESSAGE_H_

#include "xcore_define.h"

class VirtualClass
{
public:
	virtual int visit() { return 0;}
};

namespace xnet {

///////////////////////////////////////////////////////////////////////////////
// class XVisitor
///////////////////////////////////////////////////////////////////////////////
template <typename FinalT>
class XVisitor
{
public:
	virtual ~XVisitor() {}
	virtual int visit(FinalT* visited) = 0;
};

///////////////////////////////////////////////////////////////////////////////
// class XMessage
///////////////////////////////////////////////////////////////////////////////
class XMessage
{
public:
	virtual ~XMessage() {}

	virtual const string& unique_key() = 0;
	virtual int accept(VirtualClass* visitor) = 0;
};

///////////////////////////////////////////////////////////////////////////////
template <typename T>
static int acceptMessageImpl(T* visited, VirtualClass* visitor)
{
	typedef XVisitor<T> VisitorType;
	typedef XVisitor<XMessage> VisitorBaseType;

	if (VisitorType* p = dynamic_cast<VisitorType*>(visitor))
	{
		return p->visit(visited);
	}
	else if (VisitorBaseType* pb = dynamic_cast<VisitorBaseType*>(visitor))
	{
		return pb->visit(visited);
	}

	assert(false);
	return -1;
}

#define DEFINE_MESSAGE_VISITABLE() \
	virtual int accept(VirtualClass* visitor) \
{ return acceptMessageImpl(this, visitor); }


///////////////////////////////////////////////////////////////////////////////
// class XMessageFactory
///////////////////////////////////////////////////////////////////////////////
template<typename BaseClassT = XMessage, typename ClassKeyT = int>
class XMessageFactory
{
public:
	typedef BaseClassT* (*Creator)();
	typedef map<ClassKeyT, Creator> CreatorMap;
	typedef typename map<ClassKeyT, Creator>::iterator CreatorIter;
	typedef typename map<ClassKeyT, Creator>::const_iterator ConstCreatorIter;

public:
	static XMessageFactory<BaseClassT, ClassKeyT>* instance()
	{
		static XMessageFactory<BaseClassT, ClassKeyT> instance_;
		return &instance_;
	}

	void register_creator(const ClassKeyT& key, Creator creator)
	{
		assert(m_creatorMap.find(key) == m_creatorMap.end() && "Message Key already register!");
		m_creatorMap[key] = creator;
	}

	BaseClassT* create(const ClassKeyT& key) const
	{
		ConstCreatorIter it = m_creatorMap.find(key);
		if (it != m_creatorMap.end())
			return (*(it->second))();

		return NULL;
	}

	const CreatorMap& creatormap() const { return m_creatorMap; }

protected:
	XMessageFactory() {}
	~XMessageFactory() {}
	XMessageFactory(const XMessageFactory&);
	XMessageFactory& operator=(const XMessageFactory&);
	CreatorMap m_creatorMap;
};


///////////////////////////////////////////////////////////////////////////////
// class XMessageCreatorRegister
///////////////////////////////////////////////////////////////////////////////
template <typename BaseClassT, typename ClassT, typename ClassKeyT = int>
class XMessageCreatorRegister
{
	static BaseClassT* create()
	{
		BaseClassT* msg = dynamic_cast<BaseClassT *>(new ClassT);
		assert(msg);
		return msg;
	}

public:
	XMessageCreatorRegister(const ClassKeyT& classID)
	{
		XMessageFactory<BaseClassT, ClassKeyT>::instance()->register_creator(classID, create);
	}
};

}//namespace xnet

using namespace xnet;

#endif//_XNET_MESSAGE_H_
