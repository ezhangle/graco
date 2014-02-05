// This file is part of AXL (R) Library
// Tibbo Technology Inc (C) 2004-2013. All rights reserved
// Author: Vladimir Gladkov

#pragma once

#include "llkc_NodeMgr.h"
#include "llkc_DefineMgr.h"
#include "llkc_ClassMgr.h"
#include "llkc_Config.h"

//.............................................................................

class CModule
{	
	friend class CParser;

protected:
	rtl::CArrayT <CNode*> m_ParseTable;
	size_t m_LookaheadLimit;
	size_t m_Lookahead;
	CClassMgr m_ClassMgr;
	CDefineMgr m_DefineMgr;
	CNodeMgr m_NodeMgr;

public:
	rtl::CBoxListT <rtl::CString> m_ImportList;

public:
	CModule ();

	void
	Clear ();

	bool
	Build (CConfig* pConfig);

	void
	Export (lua::CLuaState* pLuaState);

	void
	Trace ();

protected:
	void
	ExportDefines (lua::CLuaState* pLuaState);

	void
	ExportClassTable (lua::CLuaState* pLuaState);

	void
	ExportParseTable (lua::CLuaState* pLuaState);
};

//.............................................................................
