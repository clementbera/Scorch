"
I describe a loop. I work on the canonicalized control flow, so the loop body are always contiguous (range of postOrder numbers)

headBasicBlock <BascBlock> the basic block just before the loop. Best basic block if you want to hoist something out of the loop.
range <Range> range of the loop basicblock (postOrder numbers). loop body are contiguous.
"
Class {
	#name : #SoLICMLoop,
	#superclass : #SoGraphTraverser,
	#instVars : [
		'headBasicBlock',
		'range'
	],
	#category : #'Scorching-Pass-Flow'
}

{ #category : #accessing }
SoLICMLoop >> headBasicBlock [
	<generated>
	^ headBasicBlock
]

{ #category : #accessing }
SoLICMLoop >> headBasicBlock: aValue [
	<generated>
	headBasicBlock := aValue
]

{ #category : #accessing }
SoLICMLoop >> lastHeadInstr [
	^ headBasicBlock lastInstr
]

{ #category : #accessing }
SoLICMLoop >> range [
	<generated>
	^ range
]

{ #category : #accessing }
SoLICMLoop >> range: aValue [
	<generated>
	range := aValue
]
