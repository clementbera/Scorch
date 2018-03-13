"
Common superclass of optimisation passes tests with utilities.
"
Class {
	#name : #SoAbsPassTest,
	#superclass : #TestCase,
	#category : #'ScorchingTests-UnitTests'
}

{ #category : #helper }
SoAbsPassTest >> codeNodeFrom: method [
	| codeNode |
	codeNode := SoMethodDecompiler decompile: method.
	{ SoReorderBasicBlocks . SoFindDominators . SoSimplifyPhis } do: [ :each | each new runOn: codeNode ].
	^ codeNode
]

{ #category : #exec }
SoAbsPassTest >> exec: method [
	^ self exec: method withArgs: #()
	
]

{ #category : #exec }
SoAbsPassTest >> exec: method withArgs: args [
	^ SoGuineaPig new withArgs: args executeMethod: method
	
]

{ #category : #helper }
SoAbsPassTest >> methodFromCodeNode: codeNode [
	{ SoReorderBasicBlocks . SoExpandAndReduce . SoSpillAnalysis . SoLivenessAnalysis . SoTempIndexAllocator } do: [ :each | each new runOn: codeNode ].
	^ codeNode generateBytecodes
]

{ #category : #helper }
SoAbsPassTest >> run: passes on: selector [
	| codeNode |
	codeNode := self codeNodeFrom: SoGuineaPig >> selector.
	passes do: [ :each | each new runOn: codeNode ].
	^ self methodFromCodeNode: codeNode
]

{ #category : #initialization }
SoAbsPassTest >> setUp [
	SoGuineaPig intrinsifyIfNeeded.
]
