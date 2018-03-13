"
Ensure that a compile time assumption is valid at runtime, else trigger the deoptimization routine.

This node is a macro. It is expanded at bytecode generation time to a jumpIfNotInstanceOf.

expression <Object> value that may trap 
behaviors <Array of Behaviors> expected types.
"
Class {
	#name : #SoTrapIfNotInstanceOf,
	#superclass : #SoAbsBodyInstruction,
	#instVars : [
		'expression',
		'behaviors',
		'deoptInfo'
	],
	#category : #'Scorching-Nodes-Body Instructions'
}

{ #category : #'graph edition' }
SoTrapIfNotInstanceOf >> basicReplaceSubNode: node by: anotherNode [
	<generated>
	expression := anotherNode.
	anotherNode addUse: self
]

{ #category : #accessing }
SoTrapIfNotInstanceOf >> behaviors [
	<generated>
	^ behaviors
]

{ #category : #accessing }
SoTrapIfNotInstanceOf >> behaviors: aValue [
	<generated>
	behaviors := aValue
]

{ #category : #testing }
SoTrapIfNotInstanceOf >> canLocallySpecifyType [
	^ true
]

{ #category : #accessing }
SoTrapIfNotInstanceOf >> deoptInfo [
	<generated>
	^ deoptInfo
]

{ #category : #accessing }
SoTrapIfNotInstanceOf >> deoptInfo: aValue [
	<generated>
	aValue ifNotNil: [aValue sunkObjects do: [ :sunkObj | sunkObj node: self ] ].
	deoptInfo := aValue
]

{ #category : #accessing }
SoTrapIfNotInstanceOf >> expression [
	<generated>
	^ expression
]

{ #category : #accessing }
SoTrapIfNotInstanceOf >> expression: aValue [
	<generated>
	expression := aValue.
	expression  addUse: self
]

{ #category : #testing }
SoTrapIfNotInstanceOf >> isFalseTrap [
	^ behaviors size = 1 and: [ behaviors anyOne == False]
]

{ #category : #testing }
SoTrapIfNotInstanceOf >> isTrapIfNotInstanceOf [
	^ true
]

{ #category : #traversing }
SoTrapIfNotInstanceOf >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseTrapIfNotInstanceOf: self
]

{ #category : #testing }
SoTrapIfNotInstanceOf >> isTrueTrap [
	^ behaviors size = 1 and: [ behaviors anyOne == True]
]

{ #category : #type }
SoTrapIfNotInstanceOf >> maybeSpecifyType: typeFound for: send [
	(self strictlyDominates: send) ifTrue: [ 
		^ typeFound intersection: (SoKnownType forArray: behaviors) ].
	^ typeFound
]

{ #category : #testing }
SoTrapIfNotInstanceOf >> maybeWorthSplitting [
	^ true
]

{ #category : #comparing }
SoTrapIfNotInstanceOf >> sameExprAs: op [
	op class = self class ifFalse: [ ^ false ].
	op expression = expression ifFalse: [ ^ false ].
	(behaviors includesAll: op behaviors) ifFalse: [ ^ false ].
	^ op behaviors includesAll: behaviors
]

{ #category : #testing }
SoTrapIfNotInstanceOf >> specifyTypeOfExpressionAt: instr [
	^ self strictlyDominates: instr
]

{ #category : #accessing }
SoTrapIfNotInstanceOf >> splitSubNode [
	^ expression
]

{ #category : #'graph edition' }
SoTrapIfNotInstanceOf >> subNodes [
	<generated>
	^ {expression}
]
