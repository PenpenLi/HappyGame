﻿// 2012-04-08
// smart_ptr.h
// guosh
// 移植boost智能指针，使用接口一致

#ifndef _XCORE_SMART_PTR_H_
#define _XCORE_SMART_PTR_H_

#include <memory>       // for std::auto_ptr
#include <iostream>     // for std::ostream
#include <cstddef>      // for std::ptrdiff_t
#include <algorithm>    // for std::swap
#include <functional>   // for std::less
#include <assert.h>

#if defined(_MSC_VER) || defined(WIN32) || defined(_WIN32)
#include <WinSock2.h>
#endif

namespace xcore
{

template<typename T> class scoped_ptr;
template<typename T> class scoped_array;
template<typename T> class shared_ptr;
template<typename T> class shared_array;
template<typename T> class weak_ptr;
template<typename T> class enable_shared_from_this;

namespace detail
{

class weak_count;
class shared_count;

struct static_cast_tag {};
struct const_cast_tag {};
struct dynamic_cast_tag {};
struct polymorphic_cast_tag {};

///////////////////////////////////////////////////////////////////////////////
template<typename T>
inline void checked_delete(T* x)
{
	// intentionally complex - simplification causes regressions
	typedef char type_must_be_complete[ sizeof(T) ? 1 : -1 ];
	(void) sizeof(type_must_be_complete);
	delete x;
}

template<typename T>
inline void checked_array_delete(T* x)
{
	typedef char type_must_be_complete[ sizeof(T) ? 1 : -1 ];
	(void) sizeof(type_must_be_complete);
	delete [] x;
}

template<class T>
struct checked_deleter
{
	typedef void result_type;
	typedef T* argument_type;

	void operator()(T* x) const
	{
		xcore::detail::checked_delete(x);
	}
};

template<class T>
struct checked_array_deleter
{
	typedef void result_type;
	typedef T* argument_type;

	void operator()(T* x) const
	{
		checked_array_delete(x);
	}
};

///////////////////////////////////////////////////////////////////////////////
// class smart_counted_base
///////////////////////////////////////////////////////////////////////////////
class smart_counted_base
{
private:
	volatile int m_use_count;
	volatile int m_weak_count;

	smart_counted_base(smart_counted_base&);
	smart_counted_base& operator=(const smart_counted_base&);

protected:
	virtual ~smart_counted_base()
	{
		// empty
	}

public:
	smart_counted_base()
		: m_use_count(1)
		, m_weak_count(1)
	{
		// empty
	}

	virtual void dispose() = 0;

	void add_ref_copy()
	{
		// ++m_use_count;
		#if defined(_MSC_VER) || defined(WIN32) || defined(_WIN32)
			InterlockedIncrement((volatile LONG*)&m_use_count);
		#else
			__sync_add_and_fetch(&m_use_count, 1);
		#endif//
	}

	bool add_ref_lock()
	{
		//return (m_use_count.test_zero_inc() != 0);
		#if defined(_MSC_VER) || defined(WIN32) || defined(_WIN32)
		for (; ;)
		{
			LONG tmp = InterlockedCompareExchange((volatile LONG*)&m_use_count, 0, 0);
			if (tmp <= 0) return (tmp != 0);
			if (InterlockedCompareExchange((volatile LONG*)&m_use_count, tmp + 1, tmp) == tmp) return ((tmp + 1) != 0);
		}
		#else
		for (; ;)
		{
			int tmp = __sync_val_compare_and_swap((volatile int*)&m_use_count, 0, 0);
			if (tmp <= 0) return (tmp != 0);
			if (__sync_val_compare_and_swap(&m_use_count, tmp, tmp + 1) == tmp) return ((tmp + 1) != 0);
		}
		#endif//
	}

	void release()
	{
		//if (--m_use_count == 0)
		#if defined(_MSC_VER) || defined(WIN32) || defined(_WIN32)
		if (0 == InterlockedDecrement((volatile LONG*)&m_use_count))
		#else
		if (0 == __sync_sub_and_fetch(&m_use_count, 1))
		#endif//
		{
			dispose();
			weak_release();
		}
	}

	void weak_add_ref()
	{
		//++m_weak_count;
		#if defined(_MSC_VER) || defined(WIN32) || defined(_WIN32)
		InterlockedIncrement((volatile LONG*)&m_weak_count);
		#else
		__sync_add_and_fetch(&m_weak_count, 1);
		#endif//
	}

	void weak_release()
	{
		//if (--m_weak_count == 0)
		#if defined(_MSC_VER) || defined(WIN32) || defined(_WIN32)
		if (0 == InterlockedDecrement((volatile LONG*)&m_weak_count))
		#else
		if (0 == __sync_sub_and_fetch(&m_weak_count, 1))
		#endif//
		{
			delete this;
		}
	}

	long use_count() const
	{
		//return m_use_count.get_value();
		#if defined(_MSC_VER) || defined(WIN32) || defined(_WIN32)
		return InterlockedCompareExchange((volatile LONG*)&m_use_count, 0, 0);
		#else
		return __sync_val_compare_and_swap((volatile int*)&m_use_count, 0, 0);
		#endif//
	}
};

///////////////////////////////////////////////////////////////////////////////
// class smart_counted_base_impl
///////////////////////////////////////////////////////////////////////////////
template<typename T, typename D = checked_deleter<T> >
class smart_counted_base_impl : public smart_counted_base
{
private:
	T* m_ptr;
	D  m_deleter;

	typedef smart_counted_base_impl<T, D> this_type;

	smart_counted_base_impl(const smart_counted_base_impl&);
	smart_counted_base_impl& operator= (const smart_counted_base_impl&);

public:
	smart_counted_base_impl(T* p, D d = checked_deleter<T>())
		: smart_counted_base()
		, m_ptr(p)
		, m_deleter(d)
	{
		// empty
	}

	virtual void dispose()
	{
		if (m_ptr)
		{
			m_deleter(m_ptr);
			m_ptr = NULL;
		}
	}

	void* operator new(std::size_t)
	{
		return std::allocator<this_type>().allocate(1, static_cast<this_type*>(0));
	}

	void operator delete(void* p)
	{
		std::allocator<this_type>().deallocate(static_cast<this_type*>(p), 1);
	}
};

///////////////////////////////////////////////////////////////////////////////
// class shared_count
///////////////////////////////////////////////////////////////////////////////
class shared_count
{
private:
	smart_counted_base* m_pi;

	friend class weak_count;

public:
	shared_count()
		: m_pi(NULL)
	{
		// empty
	}

	template<typename Y>
	explicit shared_count(Y* p)
	{
		m_pi = new smart_counted_base_impl<Y>(p);
		assert(m_pi);
	}

	template<typename T, typename D>
	shared_count(T* p, D d)
	{
		m_pi = new smart_counted_base_impl<T, D>(p, d);
		assert(m_pi);
	}

	template<typename Y>
	explicit shared_count(std::auto_ptr<Y>& r)
	{
		m_pi = new smart_counted_base_impl<Y>(r.get());
		assert(m_pi);
		r.release();
	}

	~shared_count()
	{
		if (m_pi) m_pi->release();
	}

	shared_count(const shared_count& r)
		: m_pi(r.m_pi)
	{
		if (m_pi) m_pi->add_ref_copy();
	}

	explicit shared_count(const weak_count& r);

	shared_count& operator= (const shared_count& r)
	{
		smart_counted_base* tmp = r.m_pi;

		if (tmp != m_pi)
		{
			if (tmp) tmp->add_ref_copy();
			if (m_pi) m_pi->release();
			m_pi = tmp;
		}
		return *this;
	}

	void swap(shared_count& r)
	{
		smart_counted_base* tmp = r.m_pi;
		r.m_pi = m_pi;
		m_pi = tmp;
	}

	long use_count() const
	{
		return m_pi ? m_pi->use_count() : 0;
	}

	bool unique() const
	{
		return use_count() == 1;
	}

	bool empty() const
	{
		return m_pi == NULL;
	}

	friend inline bool operator== (const shared_count& a, const shared_count& b)
	{
		return a.m_pi == b.m_pi;
	}

	friend inline bool operator< (const shared_count& a, const shared_count& b)
	{
		return std::less<smart_counted_base*>()(a.m_pi, b.m_pi);
	}
};

///////////////////////////////////////////////////////////////////////////////
// class weak_count
///////////////////////////////////////////////////////////////////////////////
class weak_count
{
private:
	smart_counted_base* m_pi;

	friend class shared_count;

public:
	weak_count()
		: m_pi(NULL)
	{
		// empty
	}

	weak_count(const shared_count& r)
		: m_pi(r.m_pi)
	{
		if (m_pi) m_pi->weak_add_ref();
	}

	weak_count(const weak_count& r)
		: m_pi(r.m_pi)
	{
		if (m_pi) m_pi->weak_add_ref();
	}

	~weak_count()
	{
		if (m_pi) m_pi->weak_release();
	}

	weak_count& operator= (const shared_count& r)
	{
		smart_counted_base* tmp = r.m_pi;

		if (tmp != m_pi)
		{
			if (tmp) tmp->weak_add_ref();
			if (m_pi) m_pi->weak_release();
			m_pi = tmp;
		}
		return *this;
	}

	weak_count& operator= (const weak_count&  r)
	{
		smart_counted_base* tmp = r.m_pi;

		if (tmp != m_pi)
		{
			if (tmp) tmp->weak_add_ref();
			if (m_pi) m_pi->weak_release();
			m_pi = tmp;
		}
		return *this;
	}

	void swap(weak_count& r)
	{
		smart_counted_base* tmp = r.m_pi;
		r.m_pi = m_pi;
		m_pi = tmp;
	}

	long use_count() const
	{
		return m_pi ? m_pi->use_count() : 0;
	}

	bool empty() const
	{
		return m_pi == NULL;
	}

	friend inline bool operator== (const weak_count& a, const weak_count& b)
	{
		return a.m_pi == b.m_pi;
	}

	friend inline bool operator< (const weak_count& a, const weak_count& b)
	{
		return std::less<smart_counted_base*>()(a.m_pi, b.m_pi);
	}
};

inline shared_count::shared_count(const weak_count& r)
	: m_pi(r.m_pi)
{
	if (m_pi && !m_pi->add_ref_lock())
	{
		m_pi = NULL;
	}
}

}// namespace detail



///////////////////////////////////////////////////////////////////////////////
// class scoped_ptr
///////////////////////////////////////////////////////////////////////////////
template<typename T>
class scoped_ptr
{
private:
	T* m_ptr;

	typedef T element_type;
	typedef scoped_ptr<T> this_type;

	scoped_ptr(const scoped_ptr&);
	scoped_ptr& operator=(const scoped_ptr&);
	void operator==(const scoped_ptr&) const;
	void operator!=(const scoped_ptr&) const;

public:
	explicit scoped_ptr(T* p = NULL)
		: m_ptr(p)
	{
		// empty
	}

	explicit scoped_ptr(std::auto_ptr<T>& p)
		: m_ptr(p.release())
	{
		// empty
	}

	~scoped_ptr()
	{
		detail::checked_delete(m_ptr);
	}

	void reset(T* p = NULL)
	{
		assert(p == NULL || p != m_ptr);   // catch self-reset errors
		this_type(p).swap(*this);
	}

	T& operator*() const
	{
		assert(m_ptr != NULL);
		return *m_ptr;
	}

	T* operator->() const
	{
		assert(m_ptr != NULL);
		return m_ptr;
	}

	T* get() const
	{
		return m_ptr;
	}

	void swap(scoped_ptr& b)
	{
		T* tmp = b.m_ptr;
		b.m_ptr = m_ptr;
		m_ptr = tmp;
	}
};

template<class T>
inline void swap(scoped_ptr<T>& a, scoped_ptr<T>& b)
{
	a.swap(b);
}


///////////////////////////////////////////////////////////////////////////////
// class scoped_array
///////////////////////////////////////////////////////////////////////////////
template<typename T>
class scoped_array
{
private:
	T* m_ptr;

	typedef T element_type;
	typedef scoped_array<T> this_type;

	scoped_array(const scoped_array&);
	scoped_array& operator= (const scoped_array&);
	void operator==(const scoped_array&) const;
	void operator!=(const scoped_array&) const;

public:
	explicit scoped_array(T* p = NULL)
		: m_ptr(p)
	{
		// empty
	}

	~scoped_array()
	{
		detail::checked_array_delete(m_ptr);
	}

	void reset(T* p = NULL)
	{
		assert(p == NULL || p != m_ptr); // catch self-reset errors
		this_type(p).swap(*this);
	}

	T& operator[](std::ptrdiff_t i) const
	{
		assert(m_ptr != NULL);
		assert(i >= 0);
		return m_ptr[i];
	}

	T* get() const
	{
		return m_ptr;
	}

	void swap(scoped_array& b)  // never throws
	{
		T* tmp = b.m_ptr;
		b.m_ptr = m_ptr;
		m_ptr = tmp;
	}
};

template<class T>
inline void swap(scoped_array<T>& a, scoped_array<T>& b)
{
	a.swap(b);
}


///////////////////////////////////////////////////////////////////////////////
// class enable_shared_from_this
///////////////////////////////////////////////////////////////////////////////
template<class T>
class enable_shared_from_this
{
protected:
	enable_shared_from_this()
	{
	}

	enable_shared_from_this(enable_shared_from_this const&)
	{
	}

	enable_shared_from_this& operator=(enable_shared_from_this const&)
	{
		return *this;
	}

	~enable_shared_from_this()
	{
	}

public:

	shared_ptr<T> shared_from_this()
	{
		shared_ptr<T> p(weak_this_);
		assert(p.get() == this);
		return p;
	}

	shared_ptr<T const> shared_from_this() const
	{
		shared_ptr<T const> p(weak_this_);
		assert(p.get() == this);
		return p;
	}

public: // actually private, but avoids compiler template friendship issues

	// Note: invoked automatically by shared_ptr; do not call
	template<class X, class Y> void _internal_accept_owner(shared_ptr<X> const* ppx, Y* py) const
	{
		if (weak_this_.expired())
		{
			weak_this_ = shared_ptr<T>(*ppx, py);
		}
	}

private:
	mutable weak_ptr<T> weak_this_;
};

// enable_shared_from_this support
template< class X, class Y, class T >
inline void sp_enable_shared_from_this(shared_ptr<X> const* ppx, Y const* py, enable_shared_from_this< T > const* pe)
{
	if (pe != 0)
	{
		pe->_internal_accept_owner(ppx, const_cast< Y* >(py));
	}
}

inline void sp_enable_shared_from_this(...)
{
}

///////////////////////////////////////////////////////////////////////////////
// class shared_ptr
///////////////////////////////////////////////////////////////////////////////
template<typename T>
class shared_ptr
{
private:
	T* m_ptr;  // contained pointer
	detail::shared_count m_count; // reference pointer

	typedef T element_type;
	typedef T value_type;
	typedef detail::checked_deleter<T> deleter;
	typedef shared_ptr<T> this_type;

	template<typename Y> friend class shared_ptr;
	template<typename Y> friend class weak_ptr;

public:
	shared_ptr()
		: m_ptr(NULL)
		, m_count()
	{
		// empty
	}

	template<typename Y>
	explicit shared_ptr(Y* p) // Y must be complete
		: m_ptr(p)
		, m_count(p, deleter())
	{
		sp_enable_shared_from_this(this, p, p);
	}

	template<typename Y, typename D>
	explicit shared_ptr(Y* p, D d)
		: m_ptr(p)
		, m_count(p, d)
	{
		sp_enable_shared_from_this(this, p, p);
	}

	shared_ptr(const shared_ptr& r)
		: m_ptr(r.m_ptr)
		, m_count(r.m_count)
	{
		// empty
	}

	template<typename Y>
	shared_ptr(const shared_ptr<Y>& r)
		: m_ptr(r.m_ptr)
		, m_count(r.m_count)
	{
		// empty
	}

	template<typename Y>
	explicit shared_ptr(const weak_ptr<Y>& r)
		: m_ptr(NULL)
		, m_count(r.m_count)
	{
		if (!m_count.empty())
		{
			m_ptr = r.m_ptr;
		}
	}


	template<typename Y>
	explicit shared_ptr(const std::auto_ptr<Y>& r)
		: m_ptr(r.get())
		, m_count(r)
	{
		// empty
	}

	// aliasing
	template< class Y >
	shared_ptr(shared_ptr<Y> const& r, T* p): m_ptr(p), m_count(r.m_count)         // never throws
	{
	}

	template<class Y>
	shared_ptr(const shared_ptr<Y>& r, detail::static_cast_tag)
		: m_ptr(static_cast<element_type*>(r.m_ptr))
		, m_count(r.m_count)
	{
		// empty
	}

	template<class Y>
	shared_ptr(const shared_ptr<Y>& r, detail::const_cast_tag)
		: m_ptr(const_cast<element_type*>(r.m_ptr))
		, m_count(r.m_count)
	{
		// empty
	}

	template<class Y>
	shared_ptr(const shared_ptr<Y>& r, detail::dynamic_cast_tag)
		: m_ptr(dynamic_cast<element_type*>(r.m_ptr))
		, m_count(r.m_count)
	{
		if (m_ptr == NULL) // need to allocate new counter -- the cast failed
		{
			m_count = detail::shared_count();
		}
	}

	template<class Y>
	shared_ptr(const shared_ptr<Y>& r, detail::polymorphic_cast_tag)
		: m_ptr(dynamic_cast<element_type*>(r.m_ptr))
		, m_count(r.m_count)
	{
		if (m_ptr == NULL)
		{
			throw (std::bad_cast());
		}
	}

	shared_ptr& operator= (const shared_ptr& r)
	{
		shared_ptr(r).swap(*this);
		return *this;
	}

	template<typename Y>
	shared_ptr& operator= (const shared_ptr<Y>& r)
	{
		this_type(r).swap(*this);
		return *this;
	}

	template<typename Y>
	shared_ptr& operator= (const std::auto_ptr<Y>& r)
	{
		this_type(r).swap(*this);
		return *this;
	}

	void reset()
	{
		this_type().swap(*this);
	}

	template<typename Y>
	void reset(Y* p = NULL)
	{
		assert(p == NULL || p != m_ptr);
		shared_ptr(p).swap(*this);
	}

	template<typename Y, typename D>
	void reset(Y* p, D d)
	{
		assert(p == NULL || p != m_ptr);
		this_type(p, d).swap(*this);
	}

	T& operator* () const
	{
		assert(m_ptr != NULL);
		return *m_ptr;
	}

	T* operator-> () const
	{
		assert(m_ptr != NULL);
		return m_ptr;
	}

	T* get() const
	{
		return m_ptr;
	}

	bool unique() const
	{
		return m_count.unique();
	}

	long use_count() const
	{
		return m_count.use_count();
	}

	void swap(shared_ptr<T>& r)
	{
		std::swap(m_ptr, r.m_ptr);
		m_count.swap(r.m_count);
	}

	template<typename Y>
	bool owner_before(const shared_ptr<Y>& r) const
	{
		return m_count < r.m_count;
	}

	template<typename Y>
	bool owner_before(const weak_ptr<Y>& r) const
	{
		return m_count < r.m_count;
	}
};

template<typename T, typename U>
bool operator== (const shared_ptr<T>& a, const shared_ptr<U>& b)
{
	return a.get() == b.get();
}

template<typename T, typename U>
bool operator!= (const shared_ptr<T>& a, const shared_ptr<U>& b)
{
	return a.get() != b.get();
}

template<typename T, typename U>
bool operator< (const shared_ptr<T>& a, const shared_ptr<U>& b)
{
	return a.owner_before(b);
}

template<typename T>
inline void swap(shared_ptr<T>& a, shared_ptr<T>& b)
{
	return a.swap(b);
}

template<typename Y>
std::ostream& operator<< (std::ostream& os, const shared_ptr<Y>& p)
{
	os << p.get();
	return os;
}

template<class T, class U>
shared_ptr<T> static_pointer_cast(shared_ptr<U> const& r)
{
	return shared_ptr<T>(r, detail::static_cast_tag());
}

template<class T, class U>
shared_ptr<T> const_pointer_cast(shared_ptr<U> const& r)
{
	return shared_ptr<T>(r, detail::const_cast_tag());
}

template<class T, class U>
shared_ptr<T> dynamic_pointer_cast(shared_ptr<U> const& r)
{
	return shared_ptr<T>(r, detail::dynamic_cast_tag());
}

///////////////////////////////////////////////////////////////////////////////
// class weak_ptr
///////////////////////////////////////////////////////////////////////////////
template<typename T>
class weak_ptr
{
private:
	T* m_ptr;  // contained pointer
	detail::weak_count  m_count;  // reference counter

	typedef T element_type;
	typedef weak_ptr<T> this_type;

	template<typename Y> friend class weak_ptr;
	template<typename Y> friend class shared_ptr;

public:
	weak_ptr()
		: m_ptr(NULL)
		, m_count()
	{
		// empty
	}

	weak_ptr(const weak_ptr& r)
		: m_ptr(r.m_ptr)
		, m_count(r.m_count)
	{
		// empty
	}

	template<typename Y>
	weak_ptr(const weak_ptr<Y>& r)
		: m_ptr(r.lock().get())
		, m_count(r.m_count)
	{
		// empty
	}

	template<typename Y>
	weak_ptr(const shared_ptr<Y>& r)
		: m_ptr(r.m_ptr)
		, m_count(r.m_count)
	{
		// empty
	}

	weak_ptr& operator= (const weak_ptr& r)
	{
		m_ptr = r.m_ptr;
		m_count = r.m_count;
		return *this;
	}

	template<typename Y>
	weak_ptr& operator= (const weak_ptr<Y>& r)
	{
		m_ptr = r.lock().get();
		m_count = r.m_count;
		return *this;
	}

	template<typename Y>
	weak_ptr& operator= (const shared_ptr<Y>& r)
	{
		m_ptr = r.m_ptr;
		m_count = r.m_count;
		return *this;
	}

	shared_ptr<T> lock() const
	{
		return shared_ptr<element_type>(*this);
	}

	long use_count() const
	{
		return m_count.use_count();
	}

	bool expired() const
	{
		return m_count.use_count() == 0;
	}

	void reset()
	{
		this_type().swap(*this);
	}

	void swap(this_type& r)
	{
		std::swap(m_ptr, r.m_ptr);
		m_count.swap(r.m_count);
	}

	template<typename Y>
	bool owner_before(const weak_ptr<Y>& r) const
	{
		return m_count < r.m_count;
	}

	template<typename Y>
	bool owner_before(const shared_ptr<Y>& r) const
	{
		return m_count < r.m_count;
	}
};

template<typename T, typename U>
inline bool operator< (const weak_ptr<T>& a, const weak_ptr<U>& b)
{
	return a.owner_before(b);
}

template<typename T>
inline void swap(weak_ptr<T>& a, weak_ptr<T>& b)
{
	a.swap(b);
}

///////////////////////////////////////////////////////////////////////////////
// class shared_array
///////////////////////////////////////////////////////////////////////////////
template<typename T>
class shared_array
{
private:
	T* m_ptr;  // contained pointer
	detail::shared_count m_count; // reference counter

	typedef T element_type;
	typedef shared_array<T> this_type;
	typedef detail::checked_array_deleter<T> deleter;

public:
	explicit shared_array(T* p = NULL)
		: m_ptr(p)
		, m_count(p, deleter())
	{
		// empty
	}

	template<typename D>
	shared_array(T* p, D d)
		: m_ptr(p)
		, m_count(p, d)
	{
		// empty
	}

	shared_array(const shared_array& r)
		: m_ptr(r.m_ptr)
		, m_count(r.m_count)
	{
		// empty
	}

	shared_array& operator=(const shared_array& r)
	{
		this_type(r).swap(*this);
		return *this;
	}

	void reset(T* p = NULL)
	{
		assert(p == NULL || p != m_ptr);
		this_type(p).swap(*this);
	}

	template<typename D>
	void reset(T* p, D d)
	{
		assert(p == NULL || p != m_ptr);
		this_type(p, d).swap(*this);
	}

	T& operator[](std::ptrdiff_t i) const
	{
		assert(m_ptr != NULL);
		assert(i >= 0);
		return m_ptr[i];
	}

	T* get() const
	{
		return m_ptr;
	}

	bool unique() const
	{
		return m_count.unique();
	}

	long use_count() const
	{
		return m_count.use_count();
	}

	void swap(shared_array<T>& r)
	{
		std::swap(m_ptr, r.m_ptr);
		m_count.swap(r.m_count);
	}
};

template<typename T>
inline bool operator== (const shared_array<T>& a, const shared_array<T>& b)
{
	return a.get() == b.get();
}

template<typename T>
inline bool operator!= (const shared_array<T>& a, const shared_array<T>& b)
{
	return a.get() != b.get();
}

template<typename T>
inline bool operator< (const shared_array<T>& a, const shared_array<T>& b)
{
	return std::less<T*>()(a.get(), b.get());
}

template<typename T>
inline void swap(shared_array<T>& a, shared_array<T>& b)
{
	return a.swap(b);
}

}//namespace xcore

using namespace xcore;

#endif//_XCORE_SMART_PTR_H_
