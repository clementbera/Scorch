"
empty node, represent the last instruction before a loop body (back jump target). Typically used to holds deoptimization information to hoist code out of loops later.
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
	aValue ifNotNil: [aValue sunkObjects do: [ :sunkObj | sunkObj node: self ] ].
	deoptInfo := aValue
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
