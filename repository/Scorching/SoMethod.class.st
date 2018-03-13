"
Same as my superclass for Methods. Two specific cases, methods can be customised (install in multiple classes) and can have a non zero primitive.

primitive<Object> if we're optimizing the fall-back code of a primitive, contains the primitive information.
classToInstall <Behavior|nil> If the method needs to be customised, classToInstall is the class the customised method will be installed to.
"
Class {
	#name : #SoMethod,
	#superclass : #SoAbsCode,
	#instVars : [
		'primitive',
		'classToInstall'
	],
	#category : #'Scorching-Nodes'
}

{ #category : #accessing }
SoMethod >> classToInstall [
	^ classToInstall ifNil: [ classToInstall := compiledCode methodClass ]
]

{ #category : #accessing }
SoMethod >> classToInstall: anObject [
	classToInstall := anObject
]

{ #category : #backend }
SoMethod >> codeClass [
	^ CompiledMethod
]

{ #category : #backend }
SoMethod >> install: code [
	
	code metadata isCustomized: (self classToInstall ~= code methodClass).
	code methodClass: self classToInstall.

	code methodClass = WriteStream ifTrue: [ 
		^ self logInstallFailure: code msg: 'WriteStream opt crashes deoptimisation debugging' ].
	code selector = #scanFor: ifTrue: [ 
		^ self logInstallFailure: code msg: '#scanFor: opt crashes method discarding in deoptimisation' ].
	code methodClass = Context ifTrue: [ 
		^ self logInstallFailure: code msg: 'Context opt crashed the VM in the past (maybe it does not today)' ].

	self logInstall: code.
	self classToInstall basicAddSelector: code selector withMethod: code
]

{ #category : #backend }
SoMethod >> logInstall: code [
	
	Transcript << 'Installed ' << code printString << ' in ' << self classToInstall name.
	Transcript cr.
	
	FileStream stdout << 'Installed ' << code printString << ' in ' << self classToInstall name.
	FileStream stdout cr.
]

{ #category : #backend }
SoMethod >> logInstallFailure: code msg: msg [
	
	Transcript << 'Ignored install of ' << code printString << ' in ' << self classToInstall name << ' because ' << msg.
	Transcript cr.
	
	FileStream stdout << 'Ignored install of ' << code printString << ' in ' << self classToInstall name << ' because ' << msg.
	FileStream stdout cr.
]

{ #category : #accessing }
SoMethod >> numCopied [
	^ 0
]

{ #category : #accessing }
SoMethod >> primitive [
	<generated>
	^ primitive
]

{ #category : #accessing }
SoMethod >> primitive: aValue [
	<generated>
	primitive := aValue
]

{ #category : #accessing }
SoMethod >> returnToSenderLevel [
	^ 2
]
