"
ConfigurationOfSista loadBleedingEdge
"
Class {
	#name : #ConfigurationOfScorch,
	#superclass : #Object,
	#instVars : [
		'project'
	],
	#classVars : [
		'LastVersionLoad'
	],
	#category : #ConfigurationOfScorch
}

{ #category : #'development support' }
ConfigurationOfScorch class >> DevelopmentSupport [

"See the methods in the 'development support' category on the class-side of MetacelloBaseConfiguration. Decide what development support methods you would like to use and copy them the the class-side of your configuration."
	<apiDocumentation>

]

{ #category : #private }
ConfigurationOfScorch class >> baseConfigurationClassIfAbsent: aBlock [

	^Smalltalk
		at: #MetacelloBaseConfiguration
		ifAbsent: [ 
			self ensureMetacelloBaseConfiguration.
			Smalltalk at: #MetacelloBaseConfiguration ifAbsent: aBlock ].

]

{ #category : #private }
ConfigurationOfScorch class >> ensureMetacello [

	(self baseConfigurationClassIfAbsent: []) ensureMetacello
]

{ #category : #private }
ConfigurationOfScorch class >> ensureMetacelloBaseConfiguration [

	Smalltalk
		at: #MetacelloBaseConfiguration
		ifAbsent: [ 
			| repository version |
			repository := MCHttpRepository location: 'http://seaside.gemstone.com/ss/metacello' user: '' password: ''.
			repository
				versionReaderForFileNamed: 'Metacello-Base-DaleHenrichs.2.mcz'
				do: [ :reader | 
					version := reader version.
					version load.
					version workingCopy repositoryGroup addRepository: repository ] ]
]

{ #category : #'metacello tool support' }
ConfigurationOfScorch class >> isMetacelloConfig [
	"Answer true and the Metacello tools will operate on you"
	
	^true
]

{ #category : #loading }
ConfigurationOfScorch class >> load [
	"Load the #stable version defined for this platform. The #stable version is the version that is recommended to be used on this platform."

	"self load"

	<apiDocumentation>
	^(self project version: #stable) load
]

{ #category : #loading }
ConfigurationOfScorch class >> loadBleedingEdge [
	"Load the latest versions of the mcz files defined for this project. It is not likely that the #bleedingEdge has been tested."

	"self loadBleedingEdge"

	<apiDocumentation>
	^(self project version: #bleedingEdge) load
]

{ #category : #loading }
ConfigurationOfScorch class >> loadDevelopment [
	"Load the #development version defined for this platform. The #development version will change over time and is not expected to be stable."

	"self loadDevelopment"

	<apiDocumentation>
	^(self project version: #development) load
]

{ #category : #loading }
ConfigurationOfScorch class >> loadLatest [
	"Load the latest available version of the configuration"

	"self loadLatest"

	^self project lastVersion load
]

{ #category : #accessing }
ConfigurationOfScorch class >> project [

	^self new project
]

{ #category : #'development support' }
ConfigurationOfScorch class >> validate [
	"Check the configuration for Errors, Critical Warnings, and Warnings (see class comment for MetacelloMCVersionValidator for more information). 
	Errors identify specification issues that will result in unexpected behaviour when you load the configuration. 
	Critical Warnings identify specification issues that may result in unexpected behavior when you load the configuration.
	Warnings identify specification issues that are technically correct, but are worth take a look at."

	"self validate"

	<apiDocumentation>
	self ensureMetacello.
	^ ((Smalltalk at: #MetacelloToolBox) validateConfiguration: self debug: #() recurse: false) explore
]

{ #category : #baselines }
ConfigurationOfScorch >> baseline10: spec [ 
	<version: '1.0-baseline'>
	spec for: #common do: [
		
	spec  
		blessing: #baseline;
		repository: 'http://smalltalkhub.com/mc/ClementBera/Scorch/main';
		description: 'Baseline for Scorch, a library for runtime optimizations';
		author: 'ClementBera'.
	
	spec	
			package: 'Scorching';
			package: 'ScorchingDev' with: [ 
				spec requires: 'Scorching' ];
			package: 'ScorchingTests' with: [ 
				spec requires: #('Scorching' 'OpalCompiler-Core' 'Kernel') ];
			package: 'ScorchingVMTests' with: [ 
				spec requires: 'Scorching' ].
	spec
		repository: 'http://smalltalkhub.com/mc/ClementBera/FullBlockClosureOpalExtension/main';
		package: 'OpalCompiler-Core';
		package: 'Kernel'.
	
	]
]

{ #category : #baselines }
ConfigurationOfScorch >> baseline11: spec [ 
	<version: '1.1-baseline'>
	spec for: #common do: [
		
	spec  
		blessing: #baseline;
		repository: 'http://smalltalkhub.com/mc/ClementBera/Scorch/main';
		description: 'Baseline for Scorch, a library for runtime optimizations';
		author: 'ClementBera'.
	
	spec	
			package: 'Scorching';
			package: 'ScorchingDev' with: [ 
				spec requires: 'Scorching' ];
			package: 'ScorchingTests' with: [ 
				spec requires: #('Scorching') ];
			package: 'ScorchingVMTests' with: [ 
				spec requires: 'Scorching' ].
	]
]

{ #category : #baselines }
ConfigurationOfScorch >> baseline12: spec [ 
	<version: '1.2-baseline'>
	spec for: #common do: [
		
	spec  
		blessing: #baseline;
		repository: 'http://smalltalkhub.com/mc/ClementBera/Scorch/main';
		description: 'Baseline for Scorch, a library for runtime optimizations';
		author: 'ClementBera'.
	
	spec	
			package: 'Scorching';
			package: 'ScorchingDev' with: [ 
				spec requires: 'Scorching' ];
			package: 'ScorchingTests' with: [ 
				spec requires: #('Scorching') ];
			package: 'ScorchingVMTests' with: [ 
				spec requires: #('Scorching' 'ScorchingDev') ].
	]
]

{ #category : #baselines }
ConfigurationOfScorch >> baseline13: spec [ 
	<version: '1.3-baseline'>
	spec for: #common do: [
		
	spec  
		blessing: #baseline;
		repository: 'github://clementbera/Scorch:master/repository';
		description: 'Baseline for Scorch, a library for runtime optimizations';
		author: 'ClementBera'.
	
	spec	
			package: 'Scorching';
			package: 'ScorchingDev' with: [ 
				spec requires: 'Scorching' ];
			package: 'ScorchingTests' with: [ 
				spec requires: #('Scorching') ];
			package: 'ScorchingVMTests' with: [ 
				spec requires: #('Scorching' 'ScorchingDev') ].
	]
]

{ #category : #accessing }
ConfigurationOfScorch >> customProjectAttributes [
	 "Edit to return a collection of any custom attributes e.g. for conditional loading: Array with: #'Condition1' with: #'Condition2.
	For more information see: http://code.google.com/p/metacello/wiki/CustomProjectAttrributes"

	^ #().
]

{ #category : #accessing }
ConfigurationOfScorch >> project [

	^ project ifNil: [ | constructor |
		"Bootstrap Metacello if it is not already loaded"
		(self class baseConfigurationClassIfAbsent: []) ensureMetacello.
		"Construct Metacello project"
		project := MetacelloMCProject new projectAttributes: self customProjectAttributes. 
		constructor := (Smalltalk at: #MetacelloVersionConstructor) on: self project: project.
		project loadType: #linear. "change to #atomic if desired"
		project ]
]

{ #category : #baselines }
ConfigurationOfScorch >> stable: spec [
	<symbolicVersion: #'stable'>

	spec for: #'common' version: '1.0'.

]

{ #category : #baselines }
ConfigurationOfScorch >> version10: spec [ 
  <version: '1.0' imports: #('1.1-baseline' )>

	spec for: #'common' do: [
		spec blessing: #'stable'.
		spec description: 'version 1.0'.
		spec author: 'ClementBera'.
		spec timestamp: '19/7/2017 16:49'.
		spec 
			package: #'Scorching' with: 'Scorching-ClementBera.280';
			package: #'ScorchingDev' with: 'ScorchingDev-ClementBera.81';
			package: #'ScorchingTests' with: 'ScorchingTests-ClementBera.79';
			package: #'ScorchingVMTests' with: 'ScorchingVMTests-ClementBera.28'. ].
]
