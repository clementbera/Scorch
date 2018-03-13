"
Returns from a block or method.  Unlike Smalltalk, Return can choose to the context it wants return among the stack in addition to the sender and homeContext's sender.

For methods, as homeContext == thisContext, numLevels 0 is equivalent to numLevels 2.  We chose to always have method return with numLevels 2 as it is more convenient for code generation.

	returnedValue <Instruction> 
	numLevels	<Integer>	the number of block levels to break out of

NumLevels -- Context to returnTo 
0				thisContext sender ( == blockReturn, classic block return)
1				homeContext
2				homeContext sender ( == returnTop, classic non local return)
3				homeContext sender sender
...				...

Note: regular smalltalk code only triggers numLevels 0 and 2. numLevel 1 happens when you inline a method with non local return in one of its caller but you don't inline the block with the non local return. numLevel 3 and + may be used later if we decide to divide an optimized method into several methods.
"
Class {
	#name : #SoReturn,
	#superclass : #SoAbsCFGInstruction,
	#instVars : [
		'returnedValue',
		'numLevels'
	],
	#category : #'Scorching-Nodes-CFG Instructions'
}

{ #category : #'graph edition' }
SoReturn >> basicReplaceSubNode: node by: anotherNode [
	<generated>
	returnedValue := anotherNode.
	anotherNode addUse: self
]

{ #category : #testing }
SoReturn >> isReturn [
	^ true
]

{ #category : #traversing }
SoReturn >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseReturn: self
]

{ #category : #accessing }
SoReturn >> numLevels [
	<generated>
	^ numLevels
]

{ #category : #accessing }
SoReturn >> numLevels: aValue [
	<generated>
	numLevels := aValue
]

{ #category : #accessing }
SoReturn >> returnedValue [
	<generated>
	^ returnedValue
]

{ #category : #accessing }
SoReturn >> returnedValue: aValue [
	<generated>
	returnedValue := aValue.
	returnedValue  addUse: self
]

{ #category : #'graph edition' }
SoReturn >> subNodes [
	<generated>
	^ {returnedValue}
]
