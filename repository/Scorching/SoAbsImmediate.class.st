"
My subclasses instances are  values that cannot change during the optimized method context lifetime. They are not SSA. In the representation, we consider they can be accessed without any overhead.

The instructions do not generate any bytecode and are not scheduled. When another instruction use this instruction, the correct reference to this instruction is generated.
"
Class {
	#name : #SoAbsImmediate,
	#superclass : #SoAbsNode,
	#category : #'Scorching-Nodes'
}

{ #category : #compatibility }
SoAbsImmediate >> addUse: use [
	
]

{ #category : #compatibility }
SoAbsImmediate >> backend [
	^ SoSpill new
]

{ #category : #compatibility }
SoAbsImmediate >> backend: backend [

]

{ #category : #type }
SoAbsImmediate >> basicTypeInformation [
	^ SoUnknownType default
]

{ #category : #compatibility }
SoAbsImmediate >> dominates: instr [
	^ true
]

{ #category : #testing }
SoAbsImmediate >> isImmediate [
	^ true
]

{ #category : #testing }
SoAbsImmediate >> isSpilled [
	^ true
]

{ #category : #compatibility }
SoAbsImmediate >> removeUse: use [
	
]

{ #category : #compatibility }
SoAbsImmediate >> strictlyDominates: instr [
	^ true
]

{ #category : #compatibility }
SoAbsImmediate >> uses [
	^ #()
]
