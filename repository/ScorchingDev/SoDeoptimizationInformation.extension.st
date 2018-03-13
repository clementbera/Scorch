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

{ #category : #'*ScorchingDev' }
SoDeoptimizationInformation >> gtInspectorViewIn: composite [
	<gtInspectorPresentationOrder: 15> 
	composite tree  
		rootsExpanded;
		title: 'SunkObj'; "Instructions"
		children: [:each |
			each = self 
				ifTrue: [ self sunkObjects ]
				ifFalse: [ 
					each class = SoPointerSunkObjectState 
						ifTrue: [ each fixedFields , { '--'} , each variableFields ]
						ifFalse: [ #() ] ] ]
]
