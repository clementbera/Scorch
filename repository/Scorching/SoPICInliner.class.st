"
Called on a polymorphic send, I try to transform the send this way:

>> branchIfNotInstanceOf: X Y
	
>> X.1 send
	
>> Y.1 send
	
>> phi (X.1 Y.1)

And then inline the send in both branches with new type information.

I work only on 2 different receiver types.
"
Class {
	#name : #SoPICInliner,
	#superclass : #Object,
	#pools : [
		'SoMagicConstants'
	],
	#category : #'Scorching-Pass-Inlining'
}

{ #category : #'inlining PIC' }
SoPICInliner >> canAttemptPICInlining: send [
	"2 types, 2 methods right now."
	send deoptInfo depth < MaxInliningDepth ifFalse: [ ^ false ].
	send sendData mayBeInlinablePIC ifFalse: [ ^ false ].
	send sendData behaviorsAndMethods size ~= 2 ifTrue: [ ^ false ].
	^ send sendData behaviorsAndMethods values anySatisfy: [ :m | self canPICInline: m ]
]

{ #category : #'inlining PIC' }
SoPICInliner >> canPICInline: methodToInline [
	methodToInline isOptimized ifTrue: [ ^ false ].
	methodToInline allowRuntimeOptimizations ifFalse: [ ^ false ].
	^ methodToInline bytecodeSize <= AlwaysInlineSize
]

{ #category : #public }
SoPICInliner >> maybePICInlining: send [
	(self canAttemptPICInlining: send) ifTrue: [ self picInlining: send ]
]

{ #category : #'inlining PIC' }
SoPICInliner >> newBasicBlockJumpingTo: bb dominator: dom [
	| jmp newBB |
	newBB := SoBasicBlock new 
		dominator: dom;
		yourself.
	jmp := SoJumpAhead from: newBB to: bb.
	newBB
		firstInstr: jmp;
		lastInstr: jmp.
	dom codeNode addBasicBlock: newBB before: bb.
	^ newBB
]

{ #category : #'inlining PIC' }
SoPICInliner >> picInlining: send [
	| newSends |
	newSends := self picTransform: send.
	newSends do: [ :each | 
		each canBeInlined ifTrue: [ each basicInline ] ].
	
]

{ #category : #'inlining PIC' }
SoPICInliner >> picTransform: send [
	"Transforms:
	
	...
	send
	...
	
	to:
	
	...
	branchIfInstanceOf: X Y
	
	X.1 send
	
	Y.1 send
	
	phi (X.1 Y.1)
	..."
	
	| prevBB nextBB branch1 branch2 dup1 dup2 instBranch |
	dup1 := send copy.
	dup2 := send copy.
	prevBB := SoBasicBlockSplitter new splitBasicBlockAt: send.
	nextBB := prevBB successors first.
	branch2 := self newBasicBlockJumpingTo: nextBB dominator: prevBB.
	branch1 := self newBasicBlockJumpingTo: nextBB dominator: prevBB.
	branch1 addFirstInstruction: dup1.
	branch2 addFirstInstruction: dup2.
	nextBB predecessors remove: prevBB.
	instBranch := SoInstanceOfBranch new
		basicBlock: prevBB;
		behaviors: {send sendData behaviors first};
		expression: send receiver;
		trueBasicBlock: branch2;
		falseBasicBlock: branch1;
		yourself.
	dup1 sendData behaviorsAndMethods removeKey: send sendData behaviors first.
	dup2 sendData behaviorsAndMethods removeKey: send sendData behaviors second.
	prevBB lastInstr prevInstrNextInstr: instBranch.
	prevBB lastInstr: instBranch.
	send uses ifNotEmpty: [
		nextBB addFirstInstruction: (SoPhi new
			addInput: branch1 firstInstr basicBlock: branch1;
			addInput: branch2 firstInstr basicBlock: branch2;
			yourself).
		send replaceUsesBy: nextBB firstInstr ].
	^ { branch1 firstInstr . branch2 firstInstr  }
	
	
	
]
