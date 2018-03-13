Class {
	#name : #BaselineOfScorch,
	#superclass : #BaselineOf,
	#category : #BaselineOfScorch
}

{ #category : #baselines }
BaselineOfScorch >> baseline: spec [ 
	<baseline>
	spec for: #common do: [
		
	spec  
		description: 'Baseline for Scorch, a library for runtime optimizations';
		author: 'ClementBera';
		postLoadDoIt: #postload:package:.
	
	spec	
			package: 'Scorching';
			package: 'ScorchingDev' with: [ 
				spec requires: 'Scorching' ];
			package: 'ScorchingTests' with: [ 
				spec requires: #('Scorching') ];
			package: 'ScorchingVMTests' with: [ 
				spec requires: #('Scorching' 'ScorchingDev') ].
	].
]

{ #category : #actions }
BaselineOfScorch >> postload: loader package: packageSpec [
	(Smalltalk at: #SoScripts) openWorkspaces
]

{ #category : #baselines }
BaselineOfScorch >> project [
	
	| aProject |
	
	aProject := super project.
	aProject loadType: #atomic.
	^ aProject.
	
]
