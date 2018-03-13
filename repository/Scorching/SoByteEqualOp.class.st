"
Specific operations comparing bytes between 2 objects. The operations takes 3 parameters, the objects to compare and the length to compare. This is done as a memComp. strcomp are transformed to this if they use a globally ordered set of characters (typically ASCII table). In the JIT, this is compiled to word comparison (it assumes the unused bytes in case of non aligned structures are zero-ed. Therefore, this *cannot* be used for a length inferior to the object's length, unless the length passed as parameter is aligned to a word.
"
Class {
	#name : #SoByteEqualOp,
	#superclass : #SoAbsUnsafeOp,
	#category : #'Scorching-Nodes-Op'
}

{ #category : #types }
SoByteEqualOp >> basicTypeInformation [
	^ SoType boolean
]

{ #category : #static }
SoByteEqualOp >> computeStatically [ 
	self flag: #TODO. "Could be better if we simulate both primitives instead."
	^ SoConstant constant: (ByteString 
		compare: receiver constant 
		with: self firstArg constant 
		collated: (ByteString classBindingOf: #AsciiOrder)) = 2
]

{ #category : #traversing }
SoByteEqualOp >> isTraversedBy: aTraverser [
	<generated>
	^ aTraverser traverseByteEqualOp: self
]

{ #category : #primitive }
SoByteEqualOp >> primitiveNumber [
	^ 3021
]
