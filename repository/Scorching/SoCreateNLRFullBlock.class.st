"
Same as superclass but I have a NLR.

The fake constant is passed in a phi to mark where the NLRs should return to.

nlrPhi <SoPhi> phi to return to if one inlines this NLR
"
Class {
	#name : #SoCreateNLRFullBlock,
	#superclass : #SoCreateContextFullBlock,
	#instVars : [
		'nlrPhi',
		'fakeConstant',
		'fakeBasicBlock'
	],
	#category : #'Scorching-Nodes-Body Instructions'
}

{ #category : #accessing }
SoCreateNLRFullBlock >> fakeBasicBlock [
	<generated>
	^ fakeBasicBlock
]

{ #category : #accessing }
SoCreateNLRFullBlock >> fakeBasicBlock: aValue [
	<generated>
	fakeBasicBlock := aValue
]

{ #category : #accessing }
SoCreateNLRFullBlock >> fakeConstant [
	<generated>
	^ fakeConstant
]

{ #category : #accessing }
SoCreateNLRFullBlock >> fakeConstant: aValue [
	<generated>
	fakeConstant := aValue
]

{ #category : #testing }
SoCreateNLRFullBlock >> hasNLR [
	^ true
]

{ #category : #initialization }
SoCreateNLRFullBlock >> initialize [

	super initialize.

	fakeConstant := SoConstant constant: 'fakeNLRVal'.
	fakeBasicBlock := SoBasicBlock new.
	fakeBasicBlock lastInstr: (SoJumpAhead from: fakeBasicBlock to: fakeBasicBlock).
	fakeBasicBlock firstInstr: fakeBasicBlock lastInstr.
]

{ #category : #traversing }
SoCreateNLRFullBlock >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseCreateNLRFullBlock: self
]

{ #category : #accessing }
SoCreateNLRFullBlock >> nlrPhi [
	<generated>
	^ nlrPhi
]

{ #category : #accessing }
SoCreateNLRFullBlock >> nlrPhi: aValue [
	<generated>
	nlrPhi := aValue
]
