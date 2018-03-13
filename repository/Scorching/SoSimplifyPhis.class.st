"
I analyse phis and remove them if they don't make sense.

I can be use over a codeNode (slower, collect the phis and process them) or directly to a list of phis.

3 main cases lead to phi simplification:
- phi result is unused 
- phi has a single input 
- phi is redondant (itself and another input because of a loop)

Phi interleaves are removed by another pass.
"
Class {
	#name : #SoSimplifyPhis,
	#superclass : #Object,
	#instVars : [
		'workList'
	],
	#category : #'Scorching-Pass-Utils'
}

{ #category : #private }
SoSimplifyPhis >> addToWorkList: collection ifNotPhi: phi [
	"We check for the phi itself to avoid infinite loops in phi for loops"
	collection do: [ :elem |
		(elem isPhiInput and: [ elem phi ~~ phi ]) ifTrue: [
			workList add: elem phi ] ].
]

{ #category : #private }
SoSimplifyPhis >> check1InputPhi: phi [
	self addToWorkList: phi uses ifNotPhi: phi.
	phi removeAndReplaceUsesBy: phi inputs anyOne
]

{ #category : #private }
SoSimplifyPhis >> checkPhiFunction: phi [

	| inputsSize |
	phi uses isEmpty ifTrue: [ ^ self checkUnused: phi ].
	inputsSize := phi inputs size.
	inputsSize = 2 ifTrue: [ ^ self checkRedondantInput: phi ].
	inputsSize = 1 ifTrue: [ ^ self check1InputPhi: phi ]
]

{ #category : #private }
SoSimplifyPhis >> checkRedondantInput: phi [
	"Redondant phi in loops, the input is incoming from before the loop and the other input is itself."
	(phi inputs anySatisfy: [ :input | input == phi ]) ifFalse: [ ^ self ].
	self addToWorkList: phi uses ifNotPhi: phi.
	phi inputs
		detect: [ :input | input ~~ phi ]
		ifFound: [ :remaingInput | phi removeAndReplaceUsesBy: remaingInput ]
		ifNone: nil
]

{ #category : #private }
SoSimplifyPhis >> checkUnused: phi [
	"Phi is unused. We remove it and reprocess the inputs."
	self addToWorkList: phi inputs ifNotPhi: phi.
	phi removeInstr
]

{ #category : #initialization }
SoSimplifyPhis >> initialize [

	super initialize.

	workList := OrderedCollection new.
]

{ #category : #public }
SoSimplifyPhis >> runOn: codeNode [
	codeNode basicBlocks do: [ :basicBlock |
		basicBlock phisDo: [ :phi | workList add: phi ] ].
	self simplifyPhis.
]

{ #category : #private }
SoSimplifyPhis >> simplifyPhis [
	| phi |
	[ workList isEmpty ] whileFalse: [
		phi := workList removeFirst.
		(workList includes: phi) ifFalse: [self checkPhiFunction: phi] ].
]

{ #category : #public }
SoSimplifyPhis >> simplifyPhis: phis [
	workList := phis.
	self simplifyPhis
]

{ #category : #accessing }
SoSimplifyPhis >> workList [
	<generated>
	^ workList
]

{ #category : #accessing }
SoSimplifyPhis >> workList: aValue [
	<generated>
	workList := aValue
]
