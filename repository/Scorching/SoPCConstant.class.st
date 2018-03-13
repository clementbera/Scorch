"
I am a specific representation of a constant. The problem here is that some nodes, such as sends, have a deoptimization record *after* they are performed in case of the debugger dynamic deoptimization, and *before* they are performed if they are changed to a trap. Hence the deopt metadata needs to pc and use onlyt one pc in the final metadata.

backjump -> before
inst store -> after
branch -> after
send -> after
inlined send / caller scope -> after
loopHead -> before
trap -> before

instrPC <Smi> pc in original method of the instruction (for example send pc)
nextPC <Smi> pc in original method right after the instruction (for example right after the send)
"
Class {
	#name : #SoPCConstant,
	#superclass : #SoAbsDeoptImmediate,
	#instVars : [
		'instrPC',
		'nextPC'
	],
	#category : #'Scorching-Nodes-Deopt'
}

{ #category : #converting }
SoPCConstant >> asDeopt [
	"Non bottom ctxt"
	^ SoDeoptConstant new
		constant: nextPC;
		yourself
]

{ #category : #fixing }
SoPCConstant >> fixPCConstantIn: sunkObj for: node at: position [
	sunkObj fixedFields 
		at: position 
		put: (SoConstant constant: (node isTraversedBy: self))
]

{ #category : #accessing }
SoPCConstant >> instrPC [
	<generated>
	^ instrPC
]

{ #category : #accessing }
SoPCConstant >> instrPC: aValue [
	<generated>
	instrPC := aValue
]

{ #category : #traversing }
SoPCConstant >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traversePCConstant: self
]

{ #category : #accessing }
SoPCConstant >> nextPC [
	<generated>
	^ nextPC
]

{ #category : #accessing }
SoPCConstant >> nextPC: aValue [
	<generated>
	nextPC := aValue
]

{ #category : #printing }
SoPCConstant >> shortPrintOn: s [
	super shortPrintOn: s.
	s << '[' << instrPC asString << ' -> ' << nextPC asString << ']'
]

{ #category : #traversing }
SoPCConstant >> traverseBackjump: bj [
	^ instrPC
]

{ #category : #traversing }
SoPCConstant >> traverseBooleanBranch: branch [
	^ nextPC
]

{ #category : #traversing }
SoPCConstant >> traverseContextInstVar: glob [
	^ nextPC
]

{ #category : #traversing }
SoPCConstant >> traverseGlobal: glob [
	^ nextPC
]

{ #category : #traversing }
SoPCConstant >> traverseImmediateTrap: send [
	^ instrPC
]

{ #category : #traversing }
SoPCConstant >> traverseInstVar: glob [
	^ nextPC
]

{ #category : #traversing }
SoPCConstant >> traverseMutableLiteral: glob [
	^ nextPC
]

{ #category : #traversing }
SoPCConstant >> traverseSend: send [
	^ nextPC
]
