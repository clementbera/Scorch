"
I map selectors to optimized code. I am used to discard optimized code when a selector is installed somewhere. 

selectorMap <selector -> collection of optimizedMethods> collection of optimized methods to flush when selector is installed. 
"
Class {
	#name : #SoDependencyMap,
	#superclass : #SoAbsDeopt,
	#instVars : [
		'selectorMap'
	],
	#classInstVars : [
		'default'
	],
	#category : #'Scorching-Deoptimization'
}

{ #category : #'instance creation' }
SoDependencyMap class >> default [
	^ default ifNil: [ default := self new ]
]

{ #category : #adding }
SoDependencyMap >> addDependency: selector optimizedCode: optimizedCode [
	"When a new method with the given selector will be installed, I will discard the given optimized code"
	self flag: #Recursion.
	selectorMap
		at: selector 
		ifPresent: [ :col | (col identityIncludes: optimizedCode) ifFalse: [ col add: optimizedCode ] ]
		ifAbsentPut: [ OrderedCollection with: optimizedCode ].
]

{ #category : #public }
SoDependencyMap >> debugFlushAll [
	"This method should be called only if you're discarding everything.
	 Flushes all the dependencies"
	
	self flag: #Recursion.
	selectorMap := Dictionary new
]

{ #category : #public }
SoDependencyMap >> discardAndUninstallOptimizedCode: code [
	"This code is discarded (typically too many traps have tripped in it), 
	  I need to remove it from the dependencies"
	self assert: code class == CompiledMethod.
	"Temporarily replaced code discard with voidCogVMState to avoid crashes..."
	code discard.
	"self flag: #TODO.
	code voidCogVMState."
	self uninstallMethod: code.
	self removeDependencies: code.
	
]

{ #category : #public }
SoDependencyMap >> flushSelector: selector [
	"A new method with the given selector is installed,  need to discard the optimized code relying on this selector"
	selectorMap
		at: selector
		ifPresent: [ :dependencies | 
			dependencies do: [ :m | self discardAndUninstallOptimizedCode: m ].
			selectorMap removeKey: selector ]
]

{ #category : #initialization }
SoDependencyMap >> initialize [

	super initialize.

	self flag: #Recursion.
	selectorMap := Dictionary new.
]

{ #category : #removing }
SoDependencyMap >> removeDependencies: code [
	| toRemove |
	self flag: #Recursion.
	toRemove := OrderedCollection new.
	selectorMap keysAndValuesDo: [ :selector :dependencies |
		dependencies remove: code ifAbsent: nil.
		dependencies ifEmpty: [ toRemove add: selector ] ].
	toRemove do: [ :sel | selectorMap removeKey: sel ifAbsent: nil ].
	
]

{ #category : #accessing }
SoDependencyMap >> selectorMap [
	<generated>
	^ selectorMap
]

{ #category : #accessing }
SoDependencyMap >> selectorMap: aValue [
	<generated>
	selectorMap := aValue
]

{ #category : #private }
SoDependencyMap >> uninstallMethod: code [
	self flag: #Recursion.
	code metadata isCustomized ifNil: [ ^ self "For testing purpose, this is nil" ].
	code metadata isCustomized ifTrue: [ ^ code methodClass basicRemoveSelector: code selector ].
	code methodClass 
		basicAddSelector: code selector 
		withMethod: code metadata unoptimizedMethod.
]
