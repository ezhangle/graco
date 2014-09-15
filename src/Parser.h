// This file is part of AXL (R) Library
// Tibbo Technology Inc (C) 2004-2013. All rights reserved
// Author: Vladimir Gladkov

#pragma once

#include "Lexer.h"
#include "Module.h"
#include "CmdLine.h"

//.............................................................................

class CParser: protected CLexer
{
protected:
	class CProductionSpecifiers
	{
	public:
		CClass* m_pClass;
		int m_SymbolFlags;

	public:
		CProductionSpecifiers ()
		{
			Reset ();
		}

		void Reset ()
		{
			m_pClass = NULL;
			m_SymbolFlags = 0;
		}
	};

protected:
	rtl::CString m_Dir;
	CModule* m_pModule;
	const TCmdLine* m_pCmdLine;
	CProductionSpecifiers m_DefaultProductionSpecifiers;

public:
	CParser ()
	{
		m_pModule = NULL;
		m_pCmdLine = NULL;
	}

	bool
	Parse (
		CModule* pModule,
		const TCmdLine* pCmdLine,
		const rtl::CString& FilePath,
		const char* pSource,
		size_t Length = -1
		);

	bool
	ParseFile (
		CModule* pModule,
		TCmdLine* pCmdLine,
		const rtl::CString& FilePath
		);

protected:
	// grammar

	bool
	Program ();

	bool
	LookaheadStatement ();

	bool
	ImportStatement ();

	bool
	DeclarationStatement ();

	bool
	ProductionSpecifiers (CProductionSpecifiers* pSpecifiers);

	bool
	ClassStatement ();

	bool
	UsingStatement ();

	bool
	DefineStatement ();

	bool
	Production (const CProductionSpecifiers* pSpecifiers);

	CClass*
	ClassSpecifier ();

	CGrammarNode*
	Alternative ();

	CGrammarNode*
	Sequence ();

	CGrammarNode*
	Quantifier ();

	CGrammarNode*
	Primary ();

	CSymbolNode*
	Resolver ();

	CBeaconNode*
	Beacon ();

	bool
	UserCode (
		int OpenBracket,
		rtl::CString* pString,
		lex::CSrcPos* pSrcPos
		);

	bool
	UserCode (
		int OpenBracket,
		rtl::CString* pString,
		lex::CLineCol* pLineCol
		);

	bool
	CustomizeSymbol (CSymbolNode* pNode);

	bool
	ProcessLocalList (CSymbolNode* pNode);

	bool
	ProcessFormalArgList (CSymbolNode* pNode);

	bool
	ProcessActualArgList (
		CArgumentNode* pNode,
		const rtl::CString& String
		);

	bool
	ProcessSymbolEventHandler (
		CSymbolNode* pNode,
		rtl::CString* pString
		);

	void
	SetGrammarNodeSrcPos (
		CGrammarNode* pNode,
		const lex::CLineCol& LineCol
		);

	void
	SetGrammarNodeSrcPos (CGrammarNode* pNode)
	{
		SetGrammarNodeSrcPos (pNode, m_LastTokenPos);
	}
};

//.............................................................................