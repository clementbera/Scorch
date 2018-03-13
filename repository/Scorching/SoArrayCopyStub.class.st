"
Specific optimisation to improve the performance of array copies -- currently disabled due to the range analysis complexity.
"
Class {
	#name : #SoArrayCopyStub,
	#superclass : #SoStub,
	#category : #'Scorching-Pass-Stub'
}

{ #category : #modules }
SoArrayCopyStub >> maybeArrayCopy: send [
	((send receiver typeInformationAt: send) isOnlyType: Array) ifFalse: [ ^ self].
	(((send arguments at: 3) typeInformationAt: send) isOnlyType: Array) ifFalse: [ ^ self].
	"send replaceBy: (send asUnsafeOp: SoArrayCopyOp). "
	
]
