Extension { #name : #SoAbsBodyInstruction }

{ #category : #'*ScorchingDev' }
SoAbsBodyInstruction >> debugUses [
	^ uses
]

{ #category : #'*ScorchingDev' }
SoAbsBodyInstruction >> debugUsesNoDeopt [
	^ uses reject: [ :each | each isSunkObject ]
]

{ #category : #'*ScorchingDev' }
SoAbsBodyInstruction >> gtInspectorSchedulingIn: composite [
	<gtInspectorPresentationOrder: 11>  
	^ composite tree
		rootsExpanded;
		children: [ :each | each debugSchedulingChildren ];
		title: 'Sub'. "SubNodes"		
]

{ #category : #'*ScorchingDev' }
SoAbsBodyInstruction >> gtInspectorUsesIn: composite [
	<gtInspectorPresentationOrder: 15>  
	^ composite tree
		rootsExpanded;
		children: [ :each | each debugUses ];
		title: 'Uses'.		
]

{ #category : #'*ScorchingDev' }
SoAbsBodyInstruction >> gtInspectorUsesNoDeoptIn: composite [
	<gtInspectorPresentationOrder: 12>  
	^ composite tree
		rootsExpanded;
		children: [ :each | each debugUsesNoDeopt ];
		title: 'UsesND'. "UsesNoDeopt"		
]

{ #category : #'*ScorchingDev' }
SoAbsBodyInstruction class >> ignoreAccessorNames [
	^ #(nextInstr)
]

{ #category : #'*ScorchingDev' }
SoAbsBodyInstruction >> longPrintOn: s [
	SoPrettyPrinter new printDefUse: self on: s
]
