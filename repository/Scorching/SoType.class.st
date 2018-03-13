"
I represent the type information of the returned value of an instruction (behavior-level).  

At the exception of the inlining phasis where types are speculated based on runtime type-feedback, type information is always inferred, from multiple sources such as constants or existing type checks. The type information is propagated on demand through other nodes such as phi using unions.
 
I am most commonly used only through the intersection: and union: methods.
"
Class {
	#name : #SoType,
	#superclass : #Object,
	#category : #'Scorching-Type'
}

{ #category : #'instance creation' }
SoType class >> boolean [
	^ SoKnownType forArray: { True . False }
]

{ #category : #'instance creation' }
SoType class >> smi [
	^ SoKnownType for: SmallInteger
]

{ #category : #testing }
SoType >> hasHint [
	^ false
]

{ #category : #testing }
SoType >> hasOneType [
	^ false
]

{ #category : #testing }
SoType >> hasReliableHint [
	^ false
]

{ #category : #operation }
SoType >> intersection: type [
	self subclassResponsibility 
]

{ #category : #testing }
SoType >> isKnownType [
	^ false
]

{ #category : #testing }
SoType >> isOnlyType: type [
	^ false
]

{ #category : #testing }
SoType >> isOnlyTypes: types [
	^ false
]

{ #category : #testing }
SoType >> requiresStoreCheck [
	"Answers if an instruction of this type stored into another object requires a store check"
	^ true
	
]

{ #category : #operation }
SoType >> union: type [
	self subclassResponsibility 
]
