"
This instruction writes a byte at the given index. This is typically used for writes inside ByteArrays. The byte written is guaranteed to be a smi in the [0;255] range.

The object is guaranteed to be a byte object. (Note: we could use this operation on Short/Word/DoubleWord Arrays if we assume endianness for some performance hacks).
"
Class {
	#name : #SoByteWrite,
	#superclass : #SoAbsObjectWrite,
	#category : #'Scorching-Nodes-Heap'
}

{ #category : #traversing }
SoByteWrite >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseByteWrite: self
]

{ #category : #primitive }
SoByteWrite >> primitiveNumber [
	^ 3004
]
