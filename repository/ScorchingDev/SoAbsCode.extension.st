Extension { #name : #SoAbsCode }

{ #category : #'*ScorchingDev' }
SoAbsCode >> debugSchedulingChildren [
	^ basicBlocks
]

{ #category : #'*ScorchingDev' }
SoAbsCode >> gtInspectorSchedulingIn: composite [
	<gtInspectorPresentationOrder: 8>  
	^ composite tree
		rootsExpanded;
		children: [ :each | each debugSchedulingChildren ];
		title: 'Scheduling'.		
]

{ #category : #'*ScorchingDev' }
SoAbsCode >> printOn: s [
	s 
		<< self class name
		 << '(' 
		<< compiledCode printString 
		<< ')'
]

{ #category : #'*ScorchingDev' }
SoAbsCode >> validateGraphSanity [
	SoValidator new
		options: #( graphSanity );
		codeNode: self;
		validateGraphSanity 
]
