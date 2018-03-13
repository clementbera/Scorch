"
Empty node, represent the last instruction before a loop body (back jump target). Used to holds deoptimization information to hoist traps out of loops.
"
Class {
	#name : #SoLoopHead,
	#superclass : #SoAbsBodyInstruction,
	#instVars : [
		'deoptInfo'
	],
	#category : #'Scorching-Nodes-Body Instructions'
}

{ #category : #accessing }
SoLoopHead >> deoptInfo [
	<generated>
	^ deoptInfo
]

{ #category : #accessing }
SoLoopHead >> deoptInfo: aValue [
	<generated>
	aValue ifNotNil: [aValue instruction: self].
	deoptInfo := aValue
]

{ #category : #testing }
SoLoopHead >> hasBreakingDeoptPoint [
	^ false
]

{ #category : #testing }
SoLoopHead >> isLoopHead [
	^ true
]

{ #category : #traversing }
SoLoopHead >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseLoopHead: self
]
