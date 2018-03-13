"
I analyse object accesses in the heap, keeping tracks of live object accesses/test in between interrupt points (liveSet) and method-wide escapes (escapes), to (each opt is annotated with escape or liveSet if they use them, else pure):
1) remove redondant read-writes in between interrupt points (liveSet)
2) remove store checks
	2A value to store is immediate (pure)
	2B value to store is a read from the same object (liveSet)
	2C value to store is already stored in the same object (live Set)
	2D object is young (recent instantiation, young guard) (liveSet)
	2E object is possibleRoot (liveSet)
3) remove read-only checks
	3A object is writable 
		(recent instantiation, read-only guard/trap) (liveSet)
	3B object is instantiated and has not escaped yet (escape)
	3C <for now> Multi read-write objects have their write 
		changed to trapIfReadonly + no check write (pure)
4) partially type object fields until they escape
	5A Array like objects are typed with ArrayStrategy (escape)
	5B Fixed objects are typed with FixedStrategy (escape)
5) find method-wide escapes
	If foldable, fold the allocation (allInstantiations)
6) Allocation quickening
	If relevant, I mark instantiation as not requiring to 
		initialize the object they instantiate (allInstantiations)

In practice in operate in multiple steps:
- first I walk the graph, performing 1 to 4.
- second I perform 5
- third  I perform 6

liveSet <OrderedCollection of ObjectAccess/Test> live since last interrupt point
escapes <Dictionary of (instantiation -> typeStrategy)> instantiations that have not escaped so far and the typing strategy we're doing
allInstantiations <OrderedCollection of Instantiation> for step 6.

----
IMPROVEMENTS POSSIBLE
-> partial alloc folding (see allocationFolding)
"
Class {
	#name : #SoEscapeOptimisation,
	#superclass : #SoEscapingLoopAnalysis,
	#instVars : [
		'allInstantiations'
	],
	#category : #'Scorching-Pass-Heap'
}

{ #category : #accessing }
SoEscapeOptimisation >> allInstantiations [
	<generated>
	^ allInstantiations
]

{ #category : #accessing }
SoEscapeOptimisation >> allInstantiations: aValue [
	<generated>
	allInstantiations := aValue
]

{ #category : #'private - allocation' }
SoEscapeOptimisation >> allocationFolding [
	"Improvement: we note that due to exception, it is possible that 
	 the value is used exclusively in a branch ending with a trap. Since we've 
	 got a single return point, the object can also be used only in a branch returning.
	 In those 2 cases we should be able to partially fold. 
	 Based on the values of escapes at the end of each trapping / return basicBlock, it is possible 
	 to know if the instantiation escapes or not up until the return / trap point. Allocation can be postponed
	 up until the common dominator of the trapping / return branches, it could even be duplicated if there is no
	 overlap.
	 We could also go in the direction of generic partial folding (if the object is used only in an uncommon branch)
	 but that's more complicated"
	allInstantiations copy do: [ :alloc |
		(self canFold: alloc) ifTrue: [ 
			allInstantiations remove: alloc.
			SoAllocationFolder new fold: alloc ] ]
]

{ #category : #'private - allocation' }
SoEscapeOptimisation >> allocationQuickening [
	"Answers true if we need to reprocess the graph. This is the case for array typing strategies"
	| needsReprocessing |
	needsReprocessing := false.
	allInstantiations do: [ :alloc |
		(self quickenAllocation: alloc) ifTrue: [ needsReprocessing := true ] ].
	^ needsReprocessing
]

{ #category : #private }
SoEscapeOptimisation >> basicRemoveStoreCheck: write [
	write storeCheck ifFalse: [ ^ self ].
	"Case 1: value to store is immediate"
	(write expression typeInformationAt: write) requiresStoreCheck ifFalse: [ write storeCheck: false ].
]

{ #category : #'private - allocation' }
SoEscapeOptimisation >> canFold: alloc [
	^ alloc isPointers "We could remove that but does not really make sense"
			and: [ alloc hasExactSize 
			and: [ alloc behavior instSpec <= 2
			and: [ alloc instSize <= MaxAllocationFoldingSize 
			and: [ self onlyConstantAccess: alloc ] ] ] ]
]

{ #category : #'private - escape' }
SoEscapeOptimisation >> escapeSimplifyRead: read [
	escapes 
		at: read object
		ifPresent: [ :typeStrat | 
			typeStrat typeRead: read ].
	^ false
]

{ #category : #'private - escape' }
SoEscapeOptimisation >> escapeSimplifyReadOnlyBranch: rob [
	escapes 
		at: rob expression
		ifPresent: [ :typeStrat | 
			self replaceAlwaysFalseBasicBlock: rob. ^ true ].
	^ false
]

{ #category : #'private - escape' }
SoEscapeOptimisation >> escapeSimplifyTrapIfReadOnly: rot [
	escapes 
		at: rot expression
		ifPresent: [ :typeStrat | 
			rot removeInstr. ^ true ].
	^ false
]

{ #category : #'private - escape' }
SoEscapeOptimisation >> escapeSimplifyWrite: write [
	escapes 
		at: write object
		ifPresent: [ :typeStrat | 
			write hasDeoptInfo 
				ifTrue: [ (self removeImmCheck: write) ifTrue: [ ^ true ] ]. 
			typeStrat typeWrite: write ].
	^ false
]

{ #category : #'private - updating' }
SoEscapeOptimisation >> escapesOfBasicBlock: bb [
	^ bb tempData second
]

{ #category : #'private - allocation' }
SoEscapeOptimisation >> finishQuickenAllocation: alloc with: fixedIndexes [
	fixedIndexes size = 0 ifTrue: [ ^ false ].
	alloc instSize - fixedIndexes size > MaxAllocationInitializationUnroll ifTrue: [ ^ false ].
	alloc needsInit: false.
	1 to: alloc instSize do: [ :i |
		(fixedIndexes includes: i)
			ifFalse: [(alloc initWriteAt: i) insertBefore: alloc nextInstr] ].
	^ alloc behavior instSpec = 2
]

{ #category : #private }
SoEscapeOptimisation >> hardRemovalOfReadOnlyCheck: write [
	"To remove if we want one day to optimise read-only objects.
	 If the object is written twice, anywhere in the graph, transforms read-only write 
	 to trapIfReadOnly then write."
	write object uses do: [ :use |
		(use ~= write 	
			and: [ (use isWrite and: [ use object = write object ])
			or: [ use isRead and: [ use index = write index ] ] ]) ifTrue: [ 
				write transformToReadOnlyTrapAndStore.
				write prevInstr isTraversedBy: self.
				write prevInstr nextInstr isTraversedBy: self.
				^ true ] ].
	^ false
]

{ #category : #'private - live set' }
SoEscapeOptimisation >> liveSetSimplifyPossibleRoot: pr [
	liveSet do: [ :live |
		live access = pr access
			ifTrue: [
				(live isNew or: [live isPossibleRoot])
					ifTrue: [ pr removeInstr. ^ true ].
				(live isYoungBranch and: [ live trueBasicBlock dominatesInstr: pr ])
					ifTrue: [ pr removeInstr. ^ true ] ] ].
	^ false
]

{ #category : #'private - live set' }
SoEscapeOptimisation >> liveSetSimplifyRead: read [ 
	liveSet do: [ :live |
		(live isObjectAccess
			and: [ live object = read object 
			and: [ live index = read index ] ])
			ifTrue: [
				live isRead 
					ifTrue: [ read removeAndReplaceUsesBy: live ]
					ifFalse: [ read removeAndReplaceUsesBy: live expression ].
				^ true ] ].
	^ false
]

{ #category : #'private - live set' }
SoEscapeOptimisation >> liveSetSimplifyReadOnlyBranch: rob [
	liveSet do: [ :live |
		live access = rob access
			ifTrue: [
				(live isNew or: [live isTrapIfReadOnly])
					ifTrue: [ self replaceAlwaysFalseBasicBlock: rob. ^ true ].
				(live isReadOnlyBranch and: [ live falseBasicBlock dominatesInstr: rob ])
					ifTrue: [ self replaceAlwaysFalseBasicBlock: rob. ^ true ].
				(live isReadOnlyBranch and: [ live trueBasicBlock dominatesInstr: rob ])
					ifTrue: [ self replaceAlwaysTrueBasicBlock: rob. ^ true ] ] ].
	^ false
]

{ #category : #'private - live set' }
SoEscapeOptimisation >> liveSetSimplifyTrapIfReadOnly: rot [
	liveSet do: [ :live |
		live access = rot access
			ifTrue: [
				(live isNew or: [live isTrapIfReadOnly])
					ifTrue: [ rot removeInstr. ^ true ].
				(live isReadOnlyBranch and: [ live falseBasicBlock dominatesInstr: rot ])
					ifTrue: [ rot removeInstr. ^ true ] ] ].
	^ false
]

{ #category : #'private - live set' }
SoEscapeOptimisation >> liveSetSimplifyWrite: write [ 
	| dispatcher |
	dispatcher := SoWriteDispatcher new
		write: write;
		escapeOptimiser: self;
		yourself.
	"can remove another live write..."
	liveSet copy do: [ :live |
		live access = write access
			ifTrue: [ (dispatcher traverseInstruction: live) ifTrue: [ ^true ] ] ].
	^ false
	
]

{ #category : #'private - live set' }
SoEscapeOptimisation >> liveSetSimplifyWrite: write thanksToInstantiation: inst [ 
	write storeCheck: false.
	^ self removeImmCheck: write
]

{ #category : #'private - live set' }
SoEscapeOptimisation >> liveSetSimplifyWrite: write thanksToPossibleRoot: pr [ 
	write storeCheck: false.
	^ false
]

{ #category : #'private - live set' }
SoEscapeOptimisation >> liveSetSimplifyWrite: write thanksToRead: read [ 
	write expression = read ifTrue: [ write storeCheck: false ].
	read index = write index ifTrue: [ liveSet remove: read ].
	^ false
]

{ #category : #'private - live set' }
SoEscapeOptimisation >> liveSetSimplifyWrite: write thanksToReadOnlyBranch: rob [ 
	(rob falseBasicBlock dominatesInstr: write) ifFalse: [ ^ false ].
	^ self removeImmCheck: write
]

{ #category : #'private - live set' }
SoEscapeOptimisation >> liveSetSimplifyWrite: write thanksToTrapIfReadOnly: rot [ 
	^ self removeImmCheck: write
]

{ #category : #'private - live set' }
SoEscapeOptimisation >> liveSetSimplifyWrite: write thanksToWrite: write2 [ 
	| originalSC |
	originalSC := write storeCheck.
	write expression = write2 expression ifTrue: [ write storeCheck: false ].
	write2 index = write index ifFalse: [ ^ false ].
	liveSet remove: write2.
	"The write may be in a branch so write2 cannot be removed. We could deal
	 with this if the pass was postOrdered, but postOrder have bad interactions
	 with immChecks ...."
	write2 basicBlock = write basicBlock ifFalse: [ ^ false ].
	write2 removeInstr.
	write storeCheck: originalSC.
	^ false
]

{ #category : #'private - live set' }
SoEscapeOptimisation >> liveSetSimplifyWrite: write thanksToYoungBranch: yb [ 
	(yb trueBasicBlock dominatesInstr: write) ifFalse: [ ^ false ].
	write storeCheck: false.
	^ false
]

{ #category : #'private - live set' }
SoEscapeOptimisation >> liveSetSimplifyYoungBranch: yb [
	liveSet do: [ :live |
		live access = yb access
			ifTrue: [
				"Not sure with possible root"
				live isNew
					ifTrue: [ self replaceAlwaysTrueBasicBlock: yb. ^ true ].
				(live isYoungBranch and: [ live trueBasicBlock dominatesInstr: yb ])
					ifTrue: [ self replaceAlwaysTrueBasicBlock: yb. ^ true ].
				(live isYoungBranch and: [ live falseBasicBlock dominatesInstr: yb ])
					ifTrue: [ self replaceAlwaysFalseBasicBlock: yb. ^ true ] ] ].
	^ false
]

{ #category : #'private - allocation' }
SoEscapeOptimisation >> onlyConstantAccess: alloc [
	^ alloc uses allSatisfy: [ :use |
		use isSunkObject or: [ 
			use isObjectAccess 
				and: [ use index isConstant
				and: [ use object = alloc 
				and: [ use isRead or: [ use expression ~= alloc ] ] ] ] ] ]
]

{ #category : #'private - allocation' }
SoEscapeOptimisation >> quickenAllocation: alloc [
	"we could deal with the CFG if we move that to a separated class... No bench where useful right now."
	| instr fixedIndexes |
	alloc needsInit ifFalse: [ ^ false ].
	instr := alloc.
	fixedIndexes := Set new.
	[ instr := instr nextInstr.
	 (instr isWrite 
		and: [ instr object = alloc
		and: [instr index isConstant ] ]) ifTrue: [ fixedIndexes add: instr index constant ].
	(instr hasDeoptInfo or: [ instr isCFGInstr ]) ifTrue: [ ^ self finishQuickenAllocation: alloc with: fixedIndexes ].
	true ] whileTrue
]

{ #category : #'private - allocation' }
SoEscapeOptimisation >> quickenAndRemoveEscape: escape [
	escapes removeKey: escape.
	escape needsInit ifFalse: [ ^ self ].
	self quickenAllocation: escape
]

{ #category : #private }
SoEscapeOptimisation >> removeImmCheck: write [
	| newInstr |
	newInstr := write asInstrWithoutChecks.
	newInstr ~~ write ifTrue: [ 
		write replaceBy: newInstr.
		newInstr storeCheck: write storeCheck.
		self traverseInstruction: newInstr.
		^ true ].
	^ false
]

{ #category : #private }
SoEscapeOptimisation >> removeReadOnlyBranch: rob [
	"the expression is ALWAYS writable.
	 We cannot deal with control flow manipulation right now. 
	 We set the branch as a branch solved by dead branch elimination."
	rob replaceBy: (SoInstanceOfBranch new
		expression: (SoConstant new);
		basicBlock: rob basicBlock;
		behaviors: { UndefinedObject };
		trueBasicBlock: rob falseBasicBlock;
		falseBasicBlock: rob trueBasicBlock;
		yourself)
]

{ #category : #private }
SoEscapeOptimisation >> removeYoungBranch: yb [
	"the expresssion is ALWAYS young.
	 We cannot deal with control flow manipulation right now. 
	 We set the branch as a branch solved by dead branch elimination."
	yb replaceBy: (SoInstanceOfBranch new
		expression: (SoConstant new);
		basicBlock: yb basicBlock;
		behaviors: { UndefinedObject };
		trueBasicBlock: yb trueBasicBlock;
		falseBasicBlock: yb falseBasicBlock;
		yourself)
]

{ #category : #private }
SoEscapeOptimisation >> replaceAlwaysFalseBasicBlock: branch [
	"Always falseBasicBlock reached.
	 We cannot deal with control flow manipulation right now. 
	 We set the branch as a branch solved by dead branch elimination.
	 Branch expression below always true."
	branch replaceBy: (SoInstanceOfBranch new
		expression: SoConstant new;
		basicBlock: branch basicBlock;
		behaviors: { UndefinedObject };
		trueBasicBlock: branch falseBasicBlock;
		falseBasicBlock: branch trueBasicBlock;
		yourself)
]

{ #category : #private }
SoEscapeOptimisation >> replaceAlwaysTrueBasicBlock: branch [
	"Always trueBasicBlock reached.
	 We cannot deal with control flow manipulation right now. 
	 We set the branch as a branch solved by dead branch elimination.
	 Branch expression below always true."
	branch replaceBy: (SoInstanceOfBranch new
		expression: SoConstant new;
		basicBlock: branch basicBlock;
		behaviors: { UndefinedObject };
		trueBasicBlock: branch trueBasicBlock;
		falseBasicBlock: branch falseBasicBlock;
		yourself)
]

{ #category : #public }
SoEscapeOptimisation >> runOn: codeNode [
	["We do preorder due to read-only check wirtes that block too many things"
	allInstantiations := OrderedCollection new.
	self traversePreorderCode: codeNode.
	self allocationFolding.
	self allocationQuickening] whileTrue
]

{ #category : #traversing }
SoEscapeOptimisation >> traverseInstantiation: alloc [
	allInstantiations add: alloc.
	liveSet add: alloc.
	escapes at: alloc put: (self typeStrategyFor: alloc)
	
]

{ #category : #traversing }
SoEscapeOptimisation >> traverseObjectRead: read [
	(self liveSetSimplifyRead: read) ifTrue: [ ^ true ].
	self escapeSimplifyRead: read.
	liveSet add: read
]

{ #category : #traversing }
SoEscapeOptimisation >> traverseObjectWrite: write [
	(self liveSetSimplifyWrite: write) ifTrue: [ ^ self ].
	(self escapeSimplifyWrite: write) ifTrue: [ ^ self ].
	self basicRemoveStoreCheck: write.
	write hasDeoptInfo ifFalse: [ 
		self checkEscape: write expression.
		^ liveSet add: write ].
	(self hardRemovalOfReadOnlyCheck: write) ifTrue: [ ^self ].
	self breakingDeoptPointAt: write.
]

{ #category : #traversing }
SoEscapeOptimisation >> traversePossibleRoot: pr [
	(self liveSetSimplifyPossibleRoot: pr) ifTrue: [ ^ self ].
	liveSet add: pr
]

{ #category : #traversing }
SoEscapeOptimisation >> traverseReadOnlyBranch: rob [
	(self liveSetSimplifyReadOnlyBranch: rob) ifTrue: [ ^ self ].
	(self escapeSimplifyReadOnlyBranch: rob) ifTrue: [ ^ self ].
	liveSet add: rob
]

{ #category : #traversing }
SoEscapeOptimisation >> traverseTrapIfReadOnly: rot [
	(self liveSetSimplifyTrapIfReadOnly: rot) ifTrue: [ ^ self ].
	(self escapeSimplifyTrapIfReadOnly: rot) ifTrue: [ ^ self ].
	liveSet add: rot
]

{ #category : #traversing }
SoEscapeOptimisation >> traverseYoungBranch: yb [
	(self liveSetSimplifyYoungBranch: yb) ifTrue: [ ^ self ].
	liveSet add: yb
]

{ #category : #'private - updating' }
SoEscapeOptimisation >> typeStrategyFor: alloc [
	alloc behavior instSpec <= 1 ifTrue: [ ^ SoFixedStrategy for: alloc ].
	(alloc behavior instSpec = 2 
		and: [alloc needsInit not]) ifTrue: [ ^ SoArrayStrategy new ].
	^ SoNoStrategy new 
]
