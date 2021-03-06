//..............................................................................
//
//  This file is part of the Graco toolkit.
//
//  Graco is distributed under the MIT license.
//  For details see accompanying license.txt file,
//  the public copy of which is also available at:
//  http://tibbo.com/downloads/archive/graco/license.txt
//
//..............................................................................

#pragma once

#define _LLK_NODE_H

#include "llk_Ast.h"

namespace llk {

//..............................................................................

enum NodeKind
{
	NodeKind_Undefined = 0,
	NodeKind_Token,
	NodeKind_Symbol,
	NodeKind_Sequence,
	NodeKind_Action,
	NodeKind_Argument,
	NodeKind_LaDfa,

	NodeKind__Count,
};

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

inline
const char*
getNodeKindString(NodeKind nodeKind)
{
	static const char* stringTable[NodeKind__Count] =
	{
		"undefined-node-kind", // NodeKind_Undefined
		"token-node",          // NodeKind_Token,
		"symbol-node",         // NodeKind_Symbol,
		"sequence-node",       // NodeKind_Sequence,
		"action-node",         // NodeKind_Action,
		"argument-node",       // NodeKind_Argument,
		"lookahead-dfa-node",  // NodeKind_LaDfa,
	};

	return nodeKind >= 0 && nodeKind < NodeKind__Count ?
		stringTable[nodeKind] :
		stringTable[NodeKind_Undefined];
}

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

enum NodeFlag
{
	NodeFlag_Locator = 0x01, // used to locate AST / token from actions (applies to token & symbol nodes)
	NodeFlag_Matched = 0x02, // applies to token & symbol & argument nodes
};

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

class Node: public axl::sl::ListLink
{
public:
	NodeKind m_kind;
	uint_t m_flags;
	size_t m_index;

public:
	Node()
	{
		m_kind = NodeKind_Undefined;
		m_flags = 0;
		m_index = -1;
	}

	virtual
	~Node()
	{
	}

	const char*
	getNodeKindString()
	{
		return llk::getNodeKindString(m_kind);
	}
};

//..............................................................................

template <class Token_0>
class TokenNode: public Node
{
public:
	typedef Token_0 Token;

public:
	Token m_token;

public:
	TokenNode()
	{
		m_kind = NodeKind_Token;
	}
};

//..............................................................................

enum SymbolNodeFlag
{
	SymbolNodeFlag_Stacked = 0x0010,
	SymbolNodeFlag_Named   = 0x0020,
	SymbolNodeFlag_Pragma  = 0x0040,
	SymbolNodeFlag_HasEnter  = 0x0100,
	SymbolNodeFlag_HasLeave  = 0x0200,
	SymbolNodeFlag_KeepAst   = 0x0400,
};

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

template <class AstNode_0>
class SymbolNode: public Node
{
public:
	typedef AstNode_0 AstNode;

public:
	AstNode* m_astNode;

	axl::sl::List<Node> m_locatorList;
	axl::sl::Array<Node*> m_locatorArray;

public:
	SymbolNode()
	{
		m_kind = NodeKind_Symbol;
		m_astNode = NULL;
	}

	virtual
	~SymbolNode()
	{
		if (m_astNode && !(m_flags & SymbolNodeFlag_KeepAst))
			AXL_MEM_DELETE(m_astNode);
	}
};

//..............................................................................

enum LaDfaNodeFlag
{
	LaDfaNodeFlag_PreResolver        = 0x0010,
	LaDfaNodeFlag_HasChainedResolver = 0x0020,
};

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

template <class Token_0>
class LaDfaNode: public Node
{
public:
	typedef Token_0 Token;

public:
	size_t m_resolverThenIndex;
	size_t m_resolverElseIndex;

	axl::sl::BoxIterator<Token> m_reparseLaDfaTokenCursor;
	axl::sl::BoxIterator<Token> m_reparseResolverTokenCursor;

public:
	LaDfaNode()
	{
		m_kind = NodeKind_LaDfa;
		m_resolverThenIndex = -1;
		m_resolverElseIndex = -1;
	}
};

//..............................................................................

} // namespace llk
