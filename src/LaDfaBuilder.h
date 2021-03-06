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

#include "NodeMgr.h"
#include "CmdLine.h"

class LaDfaState;

//..............................................................................

enum LaDfaThreadMatchKind
{
	LaDfaThreadMatchKind_None,
	LaDfaThreadMatchKind_Token,
	LaDfaThreadMatchKind_AnyToken,
};

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

class LaDfaThread: public sl::ListLink
{
public:
	LaDfaThreadMatchKind m_match;
	LaDfaState* m_state;
	GrammarNode* m_resolver;
	size_t m_resolverPriority;
	Node* m_production;
	sl::Array<Node*> m_stack;

public:
	LaDfaThread();
};

//..............................................................................

enum LaDfaStateFlag
{
	LaDfaStateFlag_TokenMatch        = 1,
	LaDfaStateFlag_EpsilonProduction = 2,
};

// . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . . .

class LaDfaState: public sl::ListLink
{
public:
	size_t m_index;
	int m_flags;

	sl::List<LaDfaThread> m_activeThreadList;
	sl::List<LaDfaThread> m_resolverThreadList;
	sl::List<LaDfaThread> m_completeThreadList;
	sl::List<LaDfaThread> m_epsilonThreadList;

	LaDfaState* m_fromState;
	SymbolNode* m_token;
	sl::Array<LaDfaState*> m_transitionArray;
	LaDfaNode* m_dfaNode;

public:
	LaDfaState();

	bool
	isResolved()
	{
		return (m_dfaNode->m_flags & LaDfaNodeFlag_Resolved) != 0;
	}

	bool
	isAnyTokenIgnored()
	{
		return (m_flags & LaDfaStateFlag_TokenMatch) || (m_flags & LaDfaStateFlag_EpsilonProduction);
	}

	bool
	isEmpty()
	{
		return
			m_activeThreadList.isEmpty() &&
			m_resolverThreadList.isEmpty() &&
			m_completeThreadList.isEmpty() &&
			m_epsilonThreadList.isEmpty();
	}

	bool
	calcResolved();

	LaDfaThread*
	createThread(LaDfaThread* src = NULL);

	Node*
	getResolvedProduction();

	Node*
	getDefaultProduction();
};

//..............................................................................

class LaDfaBuilder
{
protected:
	sl::List<LaDfaState> m_stateList;
	NodeMgr* m_nodeMgr;
	sl::Array<Node*>* m_parseTable;
	size_t m_lookeaheadLimit;
	size_t m_lookeahead;
	size_t m_conflictDepthLimit;

public:
	LaDfaBuilder(
		NodeMgr* nodeMgr,
		sl::Array<Node*>* parseTable,
		size_t lookeaheadLimit,
		size_t conflictDepthLimit
		);

	Node*
	build(
		CmdLine* cmdLine,
		ConflictNode* conflict,
		size_t* lookahead = NULL
		); // returns DFA or immediate production

	void
	trace();

	size_t
	getLookahead()
	{
		return m_lookeahead;
	}

protected:
	LaDfaState*
	createState();

	bool
	transition(
		LaDfaState** resultState,
		LaDfaState* state,
		SymbolNode* token
		);

	bool
	processThread(
		LaDfaThread* thread,
		size_t depth
		);
};

//..............................................................................
