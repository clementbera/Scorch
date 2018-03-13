"
Same as my superclass for BlockClosure. The main difference lies with number of copied variables and non local returns.

numCopied<Smi> number of copied values
"
Class {
	#name : #SoBlock,
	#superclass : #SoAbsCode,
	#instVars : [
		'numCopied'
	],
	#category : #'Scorching-Nodes'
}

{ #category : #backend }
SoBlock >> codeClass [
	^ CompiledBlock
	
]

{ #category : #backend }
SoBlock >> install: code [
	self error: 'unsupported'.
]

{ #category : #accessing }
SoBlock >> numCopied [
	<generated>
	^ numCopied
]

{ #category : #accessing }
SoBlock >> numCopied: aValue [
	<generated>
	numCopied := aValue
]

{ #category : #accessing }
SoBlock >> returnToSenderLevel [
	^ 0
]
