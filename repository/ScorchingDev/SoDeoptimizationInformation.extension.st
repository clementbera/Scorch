Extension { #name : #SoDeoptimizationInformation }

{ #category : #'*ScorchingDev' }
SoDeoptimizationInformation >> asDebugStack [
	| stack ctxt |
	ctxt := self sunkObjects first.
	stack := OrderedCollection new.
	[ctxt isNil ] whileFalse: [
		stack add: (ctxt fixedFields at: 4) constant -> (ctxt fixedFields at: 2) instrPC. 
		ctxt := self sunkObjects detect: [ :sunk | sunk marker == ctxt fixedFields first ] ifNone: [ ] ].
	^ stack
]
