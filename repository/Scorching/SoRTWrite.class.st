"
Specific write for remote temp (can't be immutable and so on).

expression <AbsInstruction> expression to store into.
ignoreStoreCheck <Boolean> Need of GC store check ?
"
Class {
	#name : #SoRTWrite,
	#superclass : #SoAccessStrategy,
	#instVars : [
		'expression',
		'ignoreStoreCheck'
	],
	#category : #'Scorching-Nodes-AccessStrategy'
}

{ #category : #accessing }
SoRTWrite >> expression [
	<generated>
	^ expression
]

{ #category : #accessing }
SoRTWrite >> expression: aValue [
	<generated>
	expression := aValue
]

{ #category : #accessing }
SoRTWrite >> ignoreStoreCheck [
	<generated>
	^ ignoreStoreCheck
]

{ #category : #accessing }
SoRTWrite >> ignoreStoreCheck: aValue [
	<generated>
	ignoreStoreCheck := aValue
]

{ #category : #initialization }
SoRTWrite >> initialize [

	super initialize.

	ignoreStoreCheck := false.
]

{ #category : #testing }
SoRTWrite >> isDefaultStore [
	^ ignoreStoreCheck not
]

{ #category : #testing }
SoRTWrite >> isWrite [
	^ true
]

{ #category : #accessing }
SoRTWrite >> subNodes [
	^ { expression }
]
