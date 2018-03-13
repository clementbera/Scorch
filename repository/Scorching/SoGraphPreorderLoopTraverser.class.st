"
I traverse the graph in preorder and recursively retraverse loops when I reach their back jumps.

backjumpBasicBlocks <Set of BasicBlocks> basicBlocks with back jumps
"
Class {
	#name : #SoGraphPreorderLoopTraverser,
	#superclass : #SoGraphTraverser,
	#instVars : [
		'backjumpBasicBlocks'
	],
	#category : #'Scorching-Pass-FrontEnd'
}

{ #category : #accessing }
SoGraphPreorderLoopTraverser >> backjumpBasicBlocks [
	<generated>
	^ backjumpBasicBlocks
]

{ #category : #accessing }
SoGraphPreorderLoopTraverser >> backjumpBasicBlocks: aValue [
	<generated>
	backjumpBasicBlocks := aValue
]

{ #category : #initialization }
SoGraphPreorderLoopTraverser >> initialize [

	super initialize.

	backjumpBasicBlocks := Set new.
]

{ #category : #'recursive traversing' }
SoGraphPreorderLoopTraverser >> maybeReprocess: basicBlock [
	(backjumpBasicBlocks includes: basicBlock) ifTrue: [ ^ self ].
	backjumpBasicBlocks add: basicBlock.
	self traverseBasicBlocks: (basicBlock codeNode basicBlocks 
		copyFrom: basicBlock lastInstr targetBasicBlock postOrder 
		to: basicBlock postOrder)
]

{ #category : #'recursive traversing' }
SoGraphPreorderLoopTraverser >> traverseBasicBlocks: basicBlocks [
	basicBlocks do: [ :basicBlock |
		self traverseForwardBasicBlock: basicBlock.
		basicBlock lastInstr isBackjump ifTrue: [ 
			self maybeReprocess: basicBlock ] ].
]

{ #category : #'recursive traversing' }
SoGraphPreorderLoopTraverser >> traversePreorderCode: code [
	self traverseBasicBlocks: code basicBlocks
]
