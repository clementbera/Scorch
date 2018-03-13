"
My instances are direct call to a given method. Sometimes the optimiser chose this over inlining (recursion, etc.)

methodToCall <CompiledCode>
loopDepth <Smi>
deoptInfo <DeoptimisationInformation>
"
Class {
	#name : #SoDirectCall,
	#superclass : #SoAbsCall,
	#instVars : [
		'methodToCall'
	],
	#category : #'Scorching-Nodes-Op'
}

{ #category : #traversing }
SoDirectCall >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseDirectCall: self
]

{ #category : #accessing }
SoDirectCall >> methodToCall [
	<generated>
	^ methodToCall
]

{ #category : #accessing }
SoDirectCall >> methodToCall: aValue [
	<generated>
	methodToCall := aValue
]
