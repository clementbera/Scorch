"
I transform basicBlocks with only phi and branch by duplicating the branch in predecessors if and only if the branch can be resolved or transformed by the JIT to smi comparison then jump.


"
Class {
	#name : #SoBranchSplitter,
	#superclass : #SoGraphTraverser,
	#instVars : [
		'merges'
	],
	#pools : [
		'SoMagicConstants'
	],
	#category : #'Scorching-Pass-Flow'
}

{ #category : #'private - phi remapping' }
SoBranchSplitter >> addMergePointEntryIn: phiToBBMap phi: phi mergePoint: mergePoint [
	"If we reach here, the phi is used after the branch merge. 
	 We need to merge the phi so we can later remap uses to it"
	| newPhi |
	newPhi := SoPhi new.
	mergePoint basicBlock addFirstInstruction: newPhi.
	phiToBBMap keysAndValuesDo: [ :dominatingBB :branchPhi |
		(mergePoint mapping at: dominatingBB) do: [ :bbInput | 
			newPhi addInput: branchPhi basicBlock: bbInput ] ].
	self 
		assert: mergePoint basicBlock predecessors size = newPhi basicBlockReferences size
		description: 'Attempt to add a phi at merge point with incorrect merge point'.
	phiToBBMap at: mergePoint basicBlock put: newPhi.
]

{ #category : #'private - phi remapping' }
SoBranchSplitter >> addPhiIn: basicBlock from: phi [
	| newPhi |
	newPhi := basicBlock addFirstInstruction: SoPhi new.
	basicBlock predecessors do: [ :each |
		each ~= phi basicBlock ifTrue: [
			newPhi addInput: (phi inputForBasicBlock: each predecessors anyOne) basicBlock: each ] ].
	^ newPhi
	
]

{ #category : #testing }
SoBranchSplitter >> canSplitBranch: instr mergePoint: mergePoint [
	"In this specific case it's too difficult to correctly remap the phi entries.
	 We could implement that later if it looks critical.
	The problem happens when the branch to split has a complex merge point (multiple merge basic block). Then, If the phi duplicated have uses after the merge point, we need to remap all the phi inputs correctly, creating new phis at each merge points."
	^ (mergePoint isComplex and: [ instr basicBlock firstInstr isPhi ]) not
	
]

{ #category : #'private - split' }
SoBranchSplitter >> copyBranchAndSplitEdge: branch [
	branch basicBlock predecessors do: [ :basicBlock | 
		self newFlowInstructionsFrom: basicBlock usingBranch: branch ].
]

{ #category : #'private - phi remapping' }
SoBranchSplitter >> createAndUpdatePhi: phi branch: branch mergePoint: mergePoint [
	"We create a map to know for each phi use what value can be used instead."
	| map |
	map := Dictionary new.
	"In each branch the uses are remapped to a new phi in the branch"
	self createPhisFor: phi inBranch: branch mapInto: map.
	"After the merge point the uses are remapped to a new phi at merge point"
	self createPhiFor: phi atMergePoint: mergePoint mapInto: map.
	"Each branch predecessor has a copied branch which needs to be updated with the phi input"
	self mapPhiPredecessors: phi into: map.
	self 
		assert: map size >= 4
		description: 'branch splitter map is messed up: ' , map size printString.
	"Map is ready. We can remap the uses."
	self remapPhiUses: phi usingMap: map
]

{ #category : #'private - phi remapping' }
SoBranchSplitter >> createAndUpdatePhis: branch mergePoint: mergePoint [
	branch basicBlock phisDo: [ :phi |
		self createAndUpdatePhi: phi branch: branch mergePoint: mergePoint ].
]

{ #category : #'private - phi remapping' }
SoBranchSplitter >> createPhiFor: phi atMergePoint: mergePoint mapInto: map [
	mergePoint isMergePoint ifFalse: [ ^ self ].
	(phi uses anySatisfy: [ :use | use isDominatedByBasicBlock: mergePoint basicBlock ]) ifFalse: [ ^ self ].
	"We create this phi only if needed not to try to modify strange control flow, risking errors"
	self addMergePointEntryIn: map phi: phi mergePoint: mergePoint
]

{ #category : #'private - phi remapping' }
SoBranchSplitter >> createPhisFor: phi inBranch: branch mapInto: map [
	self createPhisFor: phi inBranchBasicBlock: branch trueBasicBlock mapInto: map.
	self createPhisFor: phi inBranchBasicBlock: branch falseBasicBlock mapInto: map.
]

{ #category : #'private - phi remapping' }
SoBranchSplitter >> createPhisFor: phi inBranchBasicBlock: basicBlock mapInto: map [
	| newPhi  |
	newPhi := self addPhiIn: basicBlock from: phi.
	map at: basicBlock put: newPhi.
]

{ #category : #testing }
SoBranchSplitter >> instrAndTypes: branch [
	| instrAndTypes split |
	split := branch expression.
	instrAndTypes := Dictionary new.
	"collect types of branch expression in each branch."
	(split isPhi and: [ split basicBlock == branch basicBlock ]) 
		ifTrue: [ 
			split inputsAndBasicBlocksDo: [ :input :basicBlock |
				instrAndTypes at: input put: (input typeInformationAt: basicBlock lastInstr) ] ]
		ifFalse: [ 
			branch basicBlock predecessors do: [ :basicBlock |
				instrAndTypes at: split put: (split typeInformationAt: basicBlock lastInstr) ] ].
	^ instrAndTypes 
]

{ #category : #'private - phi remapping' }
SoBranchSplitter >> mapPhiPredecessors: phi into: map [
	phi inputsAndBasicBlocksDo: [ :in :basicBlock |
		map at: basicBlock put: in ].
]

{ #category : #'private - send' }
SoBranchSplitter >> maybeWorthSplittingSend: send [
	true ifTrue: [ ^ false ]. "Triggers too many deopt when enabled, I need to understand why..."
	send receiver isPhi ifFalse: [ ^ false ].
	send receiver basicBlock = send basicBlock ifFalse: [ ^ false ].
	(send canBeInlined and: [ send methodToInline primitive = 0 ]) 
		ifTrue: [ "No need to duplicate the code in this case" ^ false ].
	send receiver inputsAndBasicBlocksDo: [ :in :bb |
		(in typeInformationAt: bb lastInstr) hasOneType ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #'private - split' }
SoBranchSplitter >> newBasicBlockTo: target dominatedBy: basicBlock justAfter: boolean [
	| newBB jump |
	newBB := SoBasicBlock new.
	jump := SoJumpAhead from: newBB to: target.
	boolean 
		ifTrue: [ basicBlock codeNode addBasicBlock: newBB after: basicBlock]
		ifFalse: [ basicBlock codeNode addBasicBlock: newBB before: target].
	^ newBB
		dominator: basicBlock;
		firstInstr: jump;
		lastInstr: jump;
		yourself
]

{ #category : #'private - split' }
SoBranchSplitter >> newFlowInstructionsFrom: basicBlock usingBranch: branch [
	| trueSucc falseSucc newBranch |
	"I needs to be just after the branch to be generated correctly, the other is
	 far away just in case we are in a loop (not to integrate code in loop body)"
	trueSucc := self 
		newBasicBlockTo: branch trueBasicBlock 
		dominatedBy: basicBlock 
		justAfter: (branch trueBasicBlock bbNumber < branch falseBasicBlock bbNumber).
	falseSucc := self 
		newBasicBlockTo: branch falseBasicBlock 
		dominatedBy: basicBlock
		justAfter: (branch falseBasicBlock bbNumber < branch trueBasicBlock bbNumber).
	newBranch := branch copy.
	basicBlock lastInstr prevInstrNextInstr: newBranch.
	basicBlock lastInstr: newBranch.
	newBranch basicTrueBasicBlock: trueSucc.
	newBranch basicFalseBasicBlock: falseSucc.
]

{ #category : #initialization }
SoBranchSplitter >> nonLoopMerges: codeNode [
	"collect merge but no bj merge."
	^ codeNode basicBlocks select: [ :each | 
			each predecessors size > 1 and: [ 
				each predecessors noneSatisfy: [ :pred | 
					pred lastInstr isBackjump ] ] ]
]

{ #category : #'private - split' }
SoBranchSplitter >> patchDominatorFrom: basicBlock to: uniquePredecessor [
	basicBlock codeNode basicBlocks do: [ :each |
		each dominator = basicBlock ifTrue: 
			[ each dominator: uniquePredecessor ] ]
]

{ #category : #'private - phi remapping' }
SoBranchSplitter >> remapPhiUses: phi usingMap: map [
	phi uses do: [ :use |
		self remapUse: use ofPhi: phi usingMap: map ]
]

{ #category : #'private - phi remapping' }
SoBranchSplitter >> remapUse: use ofPhi: phi usingMap: map [
	map keysAndValuesDo: [ :dominatingBasicBlock :phiToRemap |
		(use isDominatedByBasicBlock: dominatingBasicBlock) ifTrue: [ 
			^ use basicReplaceSubNode: phi by: phiToRemap ] ].
	"If we reach here the phi is not remapped, it means it is the original branch
	 (either the branch expression of the branch deopt info)."
	self 
		assert: use basicBlock = phi basicBlock
		description: 'branch splitter phi uses remapping has some oddities'.
	
]

{ #category : #'private - split' }
SoBranchSplitter >> removeBasicBlock: bb [

	bb instructionsDo: [ :instr | instr removeInstr ].
	bb lastInstr successors do: [ :succ | succ removePredecessor: bb ].
	bb codeNode basicBlocks remove: bb.
]

{ #category : #'private - split' }
SoBranchSplitter >> removeDeadBranches: branch [
	SoDeadBranchElimination new processBranches: (branch basicBlock predecessors collect: [ :each | each lastInstr ])
]

{ #category : #public }
SoBranchSplitter >> runOn: codeNode [
	merges := self nonLoopMerges: codeNode.
	[ merges isEmpty ] whileFalse: [ self splitMergeBasicBlock: merges removeLast ]
]

{ #category : #'private - split' }
SoBranchSplitter >> shouldRemapUse: use phi: phi dominatedBy: basicBlock [
	^ use isDominatedByBasicBlock: basicBlock
]

{ #category : #testing }
SoBranchSplitter >> shouldSplitBooleanBranch: instr mergePoint: mergePoint [
	| instrAndTypes |
	"Hard constraint first. Is it possible to split ?"
	(self canSplitBranch: instr mergePoint: mergePoint) ifFalse: [ ^ false ].
	
	"Heuristic second. Should we split ?"
	instrAndTypes := self instrAndTypes: instr.
	instrAndTypes keysAndValuesDo: [ :instrInBB :type |
		"This may lead the JIT to generate quicker branches"
		instrInBB isSmiCompOp ifTrue: [ ^ true ].
		instrInBB class == SoPointerEqualsOp ifTrue: [ ^ true ].
		instrInBB isPhi ifTrue: [ ^ true ].
		"One branch will be removed at the end of the process."
		(type isOnlyType: True) ifTrue: [ ^ true ].
		(type isOnlyType: False) ifTrue: [ ^ true ] ].

	^ false
]

{ #category : #testing }
SoBranchSplitter >> shouldSplitTypeBranch: instr mergePoint: mergePoint [
	| instrAndTypes |
	"too complex and uncommon."
	instr behaviors size > 1 ifTrue: [ ^ false ].
	
	"Hard constraints first. Is it possible to split ?"
	(self canSplitBranch: instr mergePoint: mergePoint) ifFalse: [ ^ false ].
	
	"Heuristic second. Should we split ?"
	instrAndTypes := self instrAndTypes: instr.
	instrAndTypes keysAndValuesDo: [ :instrInBB :type |
		"One branch will be removed in the end."
		instrInBB isPhi ifTrue: [ ^ true ].
		type isKnownType ifTrue: [ 
			(instr behaviors includesAll: type behaviors)
				ifTrue: [ ^ true ].
			(instr behaviors includesAny: type behaviors)
				ifFalse: [ ^ true ] ] ].
	
	^ false
]

{ #category : #'private - split' }
SoBranchSplitter >> splitBranch: branch mergePoint: mergePoint [
	self copyBranchAndSplitEdge: branch.
	self createAndUpdatePhis: branch mergePoint: mergePoint.
	self removeBasicBlock: branch basicBlock.
	self patchDominatorFrom: branch basicBlock to: branch basicBlock dominator. 
	self removeDeadBranches: branch.
]

{ #category : #private }
SoBranchSplitter >> splitMergeBasicBlock: basicBlock [
	"Ensure only phis and branch"
	basicBlock instructionsDo: [ :instr |
		instr isPhi ifFalse: [ 
			^ (instr isBranch or: [ instr isSend ])
				ifTrue: [ instr isTraversedBy: self ]
			 	ifFalse: [ self ] ] ].
]

{ #category : #'private - send' }
SoBranchSplitter >> splitPhisOf: basicBlock onCopy: copy [
	basicBlock phisDo: [ :phi |
		| input |
		input := phi inputForBasicBlock: copy basicBlock.
		copy subNodes do: [ :sub |
			sub = phi ifTrue: [ copy replaceSubNode: phi by: input ] ].
		copy deoptInfo sunkObjects do: [ :sunk | 
			sunk subNodes do: [ :sub |
				sub == phi ifTrue: [ sunk replaceSubNode: phi receiver by: input ] ] ] ]
]

{ #category : #'private - send' }
SoBranchSplitter >> splitSend: send [
	| newPhi map |
	map := Dictionary new.
	send basicBlock predecessors do: [ :bb |
		| copy |
		copy := send copy.
		copy insertBefore: bb lastInstr.
		self splitPhisOf: send basicBlock onCopy: copy.
		map at: bb put: copy ].
	send basicBlock addFirstInstruction: (newPhi := SoPhi new).
	map keysAndValuesDo: [ :bb :copyOfSend |
		newPhi addInput: copyOfSend basicBlock: bb ].
	send removeAndReplaceUsesBy: newPhi.
	
	"Maxi hack because no fixed points for optimisations leads to complete non sense.
	 Basically remove this once optimisations are properly ordered."
	SoSimplifyPhis new simplifyPhis: (OrderedCollection with: send receiver with: newPhi).
	SoLateCallGraphInliner new inlineQuietlySends: map values.
	
]

{ #category : #traversing }
SoBranchSplitter >> traverseBooleanBranch: branch [
	| mergePoint |
	mergePoint := SoBranchMergeAnalysis new mergePointFor: branch.
	(self shouldSplitBooleanBranch: branch mergePoint: mergePoint) ifFalse: [ ^ self ].
	self splitBranch: branch mergePoint: mergePoint.
	branch codeNode maintainPostOrder.
]

{ #category : #traversing }
SoBranchSplitter >> traverseBranchIfNotInstanceOf: branch [
	| mergePoint |
	mergePoint := SoBranchMergeAnalysis new mergePointFor: branch.
	(self shouldSplitTypeBranch: branch mergePoint: mergePoint) ifFalse: [ ^ self ].
	self splitBranch: branch mergePoint: mergePoint.
	branch codeNode maintainPostOrder.
]

{ #category : #traversing }
SoBranchSplitter >> traverseSend: send [
	(self maybeWorthSplittingSend: send) ifFalse: [ ^ self ].
	self splitSend: send.
	"reprocess the merge"
	merges addLast: send basicBlock
]
