"
I represent the creation of a full block closure *without* an outer context.

numArgs <Smi> 
compiledCode <CompiledCode> 
receiver <SoNode>

"
Class {
	#name : #SoCreateFullBlock,
	#superclass : #SoAbsBodyInstruction,
	#instVars : [
		'compiledCode',
		'receiver',
		'values'
	],
	#category : #'Scorching-Nodes-Body Instructions'
}

{ #category : #converting }
SoCreateFullBlock >> asSunkClosure [
	^ SoPointerSunkObjectState new
			theClass: FullBlockClosure;
			marker: SoSunkObjectMarker new;
			fixedFields: { 
				SoConstant new.
				SoConstant constant: compiledCode .
				SoConstant constant: self numArgs .
				receiver };
			variableFields: values copy;
			yourself 
]

{ #category : #'graph edition' }
SoCreateFullBlock >> basicReplaceSubNode: node by: anotherNode [
	<generated>
	receiver == node ifTrue: [ 
		receiver := anotherNode.
		^ anotherNode addUse: self ].
	values at: (values indexOf: node) put: anotherNode.
	anotherNode addUse: self.
]

{ #category : #type }
SoCreateFullBlock >> basicTypeInformation [
	^ SoKnownType for: (Smalltalk at: #FullBlockClosure)
]

{ #category : #testing }
SoCreateFullBlock >> cannotBeForwarded [
	^ true
]

{ #category : #accessing }
SoCreateFullBlock >> compiledCode [
	<generated>
	^ compiledCode
]

{ #category : #accessing }
SoCreateFullBlock >> compiledCode: aValue [
	<generated>
	compiledCode := aValue
]

{ #category : #testing }
SoCreateFullBlock >> hasEffect [
	^ false
]

{ #category : #testing }
SoCreateFullBlock >> hasNLR [
	^ false
]

{ #category : #testing }
SoCreateFullBlock >> isBlockClosure [
	^ true
]

{ #category : #traversing }
SoCreateFullBlock >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseCreateFullBlock: self
]

{ #category : #accessing }
SoCreateFullBlock >> nlrPhi [
	^ nil
]

{ #category : #accessing }
SoCreateFullBlock >> numArgs [
	^ compiledCode numArgs
]

{ #category : #accessing }
SoCreateFullBlock >> outerScopeMarker: marker [
	"ignored"
]

{ #category : #'graph edition' }
SoCreateFullBlock >> postCopy [
	<generated>
	values := values copy.
	super postCopy
]

{ #category : #accessing }
SoCreateFullBlock >> receiver [
	<generated>
	^ receiver
]

{ #category : #accessing }
SoCreateFullBlock >> receiver: aValue [
	<generated>
	receiver := aValue.
	receiver  addUse: self
]

{ #category : #'graph edition' }
SoCreateFullBlock >> subNodes [
	<generated>
	^ {receiver} , values
]

{ #category : #'graph edition' }
SoCreateFullBlock >> subNodesAnySatisfy: aBlock [
	"profiling"
	<generated>
	(aBlock value: receiver) ifTrue: [^true].
	^values anySatisfy: aBlock.
	
]

{ #category : #'graph edition' }
SoCreateFullBlock >> subNodesDo: aBlock [
	"profiling"
	<generated>
	aBlock value: receiver.
	values do: aBlock
]

{ #category : #'graph edition' }
SoCreateFullBlock >> subNodesSize [
	<generated>
	^ 1 + values size
]

{ #category : #accessing }
SoCreateFullBlock >> values [
	<generated>
	^ values
]

{ #category : #accessing }
SoCreateFullBlock >> values: aValue [
	<generated>
	values := aValue.
	values do: [  :each | each addUse: self ]
]
