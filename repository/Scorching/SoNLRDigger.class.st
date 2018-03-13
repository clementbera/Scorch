"
Specific version for NLR digging : inlines only sends with NLR.
"
Class {
	#name : #SoNLRDigger,
	#superclass : #SoInliner,
	#category : #'Scorching-Pass-Inlining'
}

{ #category : #inlining }
SoNLRDigger >> inline: send [
	(send subNodesAnySatisfy: [ :s | s isBlockClosure ]) ifTrue: [ ^ super inline: send ].
	^ #()
]
