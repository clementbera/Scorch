"
I hold all the constants related to special selectors. Special selectors are either triggered abnormally by the VM or executed abnormally, leading to different behavior and have to be handled specifically by the optimizer.
"
Class {
	#name : #SoSpecialSelectorConstants,
	#superclass : #SharedPool,
	#classVars : [
		'DNUSelector',
		'HintInlinedSmiSelectors',
		'InlinedSmiSelectors',
		'VMCallBackSelectors'
	],
	#category : #'Scorching-Constants'
}

{ #category : #initialize }
SoSpecialSelectorConstants class >> initialize [
	"#doesNotUnderstand:"
	DNUSelector := Smalltalk specialObjectsArray at: 21.
	
	"array of selectors that are in fact callbacks from the VM like DNUs."
	VMCallBackSelectors := {
		DNUSelector .
		Smalltalk specialObjectsArray at: 22 . "cannotReturn:" 
		Smalltalk specialObjectsArray at: 26 . "mustBeBoolean"
		Smalltalk specialObjectsArray at: 35 . "cannotInterpret:"
		Smalltalk specialObjectsArray at: 49 . "aboutToReturn:through:"
		Smalltalk specialObjectsArray at: 50 . "run:with:in:"
		Smalltalk specialObjectsArray at: 51 . "attemptToAssign:withIndex:"
		Smalltalk specialObjectsArray at: 54 . "invokeCallbackContext:"
		Smalltalk specialObjectsArray at: 58 . "unusedBytecode"
		Smalltalk specialObjectsArray at: 59 ifAbsent: [nil]. "conditionalBranchCounterTrippedOn:"
		Smalltalk specialObjectsArray at: 60 ifAbsent: [nil]. "trapTripped" 
	}.
	
	"selectors that are normally compiled to the bytecode as type-predicted send, and if so, may also also compiled to machine code with type prediction, losing type information for Smis."
	InlinedSmiSelectors := #(< <= > >=).
	HintInlinedSmiSelectors := #(+ - bitAnd: bitOr: = ~=)
]
