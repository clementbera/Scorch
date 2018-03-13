"
I iterate in postorder over the graph, removing dead code (side-effect free unused code). I am a separate pass since I need to go backward.

TODO: would be nice to reprocess loops like liveness analysis
"
Class {
	#name : #SoDeadCodeElimination,
	#superclass : #SoGraphTraverser,
	#category : #'Scorching-Pass-Data'
}

{ #category : #public }
SoDeadCodeElimination >> runOn: codeNode [
	self traversePostorderCode: codeNode
]

{ #category : #traversing }
SoDeadCodeElimination >> traverseBodyInstruction: instr [
	instr hasEffect ifTrue: [ ^ self ].
	instr uses ifEmpty: [ ^ instr removeInstr ]
]

{ #category : #traversing }
SoDeadCodeElimination >> traverseCreateFullBlock: obj [ 
	| sunkClosure |
	(obj uses allSatisfy: [ :use | use isSunkObject ]) ifFalse: [ ^ super traverseCreateFullBlock: obj  ].
	obj removeInstr.
	obj uses size = 0 ifTrue: [ ^ self ].
	sunkClosure := obj asSunkClosure. "side-effect def-uses in sunkClosure"
	obj uses do: [ :sunkObject |
		sunkObject uses do: [ :deoptInfo |
			deoptInfo sunkObjects 
				detect: [ :so | so marker == sunkClosure marker ] 
				ifNone: [ deoptInfo addSunkObject: sunkClosure ] ].
		sunkObject basicReplaceSubNode: obj by: sunkClosure marker ].
]
