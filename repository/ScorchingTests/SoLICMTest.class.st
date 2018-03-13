Class {
	#name : #SoLICMTest,
	#superclass : #SoAbsPassTest,
	#category : #'ScorchingTests-UnitTests'
}

{ #category : #tests }
SoLICMTest >> testSize [
	| optCode |
	optCode := self run: { SoLICM } on: #sizeLICM:.
	"dont know how to test better..."
	self assert:  (((optCode symbolic splitOn: String cr) at: 2) endsWith: 'numSlots').
]

{ #category : #tests }
SoLICMTest >> testUnforward [
	| optCode |
	optCode := self run: { SoLICM } on: #unforwardLICM:.
	"dont know how to test better..."
	self assert:  (((optCode symbolic splitOn: String cr) at: 2) endsWith: 'unforward').
]
