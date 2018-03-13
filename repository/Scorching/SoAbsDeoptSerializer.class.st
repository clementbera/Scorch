"
pc -> deoptPoint = list of objects to reconstruct.

marker becomes index in the array.

Map:
pc1 in 4 bytes.
distance to pc2 in 4 bytes.
obj A 
	class (constant)
	fields to decode with variable size.

pc ->  
PointerObj  + marker, class, fixedFields, Varfields
ActiveClosure, Rcvr in 1 byte
Constant + index in 1,2,3,4 bytes.
Temp + index in 1 or 2 bytes.
otherObj ref + index in 1,2,3,4 bytes.
"
Class {
	#name : #SoAbsDeoptSerializer,
	#superclass : #Object,
	#category : #'Scorching-Deoptimization'
}

{ #category : #'as yet unclassified' }
SoAbsDeoptSerializer >> serialize [
]

{ #category : #private }
SoAbsDeoptSerializer >> serialize: dict [
]
