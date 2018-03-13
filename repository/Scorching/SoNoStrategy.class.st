"
Fall-back - no typing strategy (for objects that we have no heuristics, non fixed, non variable, data, compiledCode, etc.)
"
Class {
	#name : #SoNoStrategy,
	#superclass : #SoTypingStrategy,
	#category : #'Scorching-Pass-Heap'
}

{ #category : #merging }
SoNoStrategy >> mergeWith: typingStrat [
	^ self
]

{ #category : #types }
SoNoStrategy >> typeRead: read [
]

{ #category : #types }
SoNoStrategy >> typeWrite: read [
]
