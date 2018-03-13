"
A fixup is a control flow merge point in the bytecode.

I represent a point in the code that can't be reached. For example, the bytecode after a return can't be reached. It is created during decompilation and may be changed to a jump fixup if the decompiler decompiles later in the code a jump that jumps to the dead fixup location.
"
Class {
	#name : #SoDeadFixup,
	#superclass : #Object,
	#category : #'Scorching-Decompiler'
}

{ #category : #testing }
SoDeadFixup >> isDeadFixup [
	^ true
]

{ #category : #decompilation }
SoDeadFixup >> reachedFrom: decompiler [
	decompiler reachDeadFixup: self
]
