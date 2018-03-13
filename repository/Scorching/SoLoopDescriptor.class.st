"
I describe a loop. I work on the canonicalized control flow, so the loop body are always contiguous (range of postOrder numbers)

headBasicBlock <BascBlock> the basic block just before the loop. Best basic block if you want to hoist something out of the loop.
range <Range> range of the loop basicblock (postOrder numbers). loop body are contiguous.
"
Class {
	#name : #SoLoopDescriptor,
	#superclass : #SoGraphTraverser,
	#instVars : [
		'headBasicBlock',
		'range'
	],
	#category : #'Scorching-Pass-Data'
}

{ #category : #accessing }
SoLoopDescriptor >> headBasicBlock [
	<generated>
	^ headBasicBlock
]

{ #category : #accessing }
SoLoopDescriptor >> headBasicBlock: aValue [
	<generated>
	headBasicBlock := aValue
]

{ #category : #accessing }
SoLoopDescriptor >> lastHeadInstr [
	^ headBasicBlock lastInstr
]

{ #category : #accessing }
SoLoopDescriptor >> range [
	<generated>
	^ range
]

{ #category : #accessing }
SoLoopDescriptor >> range: aValue [
	<generated>
	range := aValue
]
