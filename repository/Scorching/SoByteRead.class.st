"
This instruction reads a byte at the given index. This is typically used for reads inside ByteArrays. The byte read is then converted to a smi (returned value is a smi).

The object is guaranteed to be a byte object. (Note: we could use this operation on Short/Word/DoubleWord Arrays if we assume endianness for some performance hacks).
"
Class {
	#name : #SoByteRead,
	#superclass : #SoAbsObjectRead,
	#category : #'Scorching-Nodes-Heap'
}

{ #category : #types }
SoByteRead >> basicTypeInformation [
	^ SoType smi
]

{ #category : #types }
SoByteRead >> hasRangeInformation [
	^ true
	
]

{ #category : #traversing }
SoByteRead >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseByteRead: self
]

{ #category : #primitive }
SoByteRead >> primitiveNumber [
	^ 2066
]

{ #category : #types }
SoByteRead >> rangeInformation [
	^ SoRange new
		minConstant: 0;
		maxConstant: 255;
		yourself
]
