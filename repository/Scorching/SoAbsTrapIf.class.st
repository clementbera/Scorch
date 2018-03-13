"
Ensure that a compile time assumption is valid at runtime, else trigger the deoptimization routine.

This node is a macro. It is expanded at bytecode generation time.

expression <ScorchNode> value that may trap 
deoptInfo <DeoptimizationInformation> 
"
Class {
	#name : #SoAbsTrapIf,
	#superclass : #SoAbsBodyInstruction,
	#instVars : [
		'expression',
		'deoptInfo'
	],
	#category : #'Scorching-Nodes-Body Instructions'
}

{ #category : #'graph edition' }
SoAbsTrapIf >> basicReplaceSubNode: node by: anotherNode [
	<generated>
	expression := anotherNode.
	anotherNode addUse: self
]

{ #category : #accessing }
SoAbsTrapIf >> deoptInfo [
	<generated>
	^ deoptInfo
]

{ #category : #accessing }
SoAbsTrapIf >> deoptInfo: aValue [
	<generated>
	aValue ifNotNil: [aValue instruction: self].
	deoptInfo := aValue
]

{ #category : #accessing }
SoAbsTrapIf >> expression [
	<generated>
	^ expression
]

{ #category : #accessing }
SoAbsTrapIf >> expression: aValue [
	<generated>
	expression := aValue.
	expression  addUse: self
]

{ #category : #testing }
SoAbsTrapIf >> hasBreakingDeoptPoint [
	^ false
]

{ #category : #testing }
SoAbsTrapIf >> isTrapIf [
	 ^ true
]

{ #category : #'graph edition' }
SoAbsTrapIf >> subNodes [
	<generated>
	^ {expression}
]

{ #category : #'graph edition' }
SoAbsTrapIf >> subNodesAnySatisfy: aBlock [
	"profiling"
	<generated>
	^aBlock value: expression.
	
]

{ #category : #'graph edition' }
SoAbsTrapIf >> subNodesDo: aBlock [
	"profiling"
	<generated>
	aBlock value: expression
]

{ #category : #'graph edition' }
SoAbsTrapIf >> subNodesSize [
	<generated>
	^ 1
]
