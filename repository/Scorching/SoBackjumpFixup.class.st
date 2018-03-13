"
A fixup is a control flow merge point in the bytecode.

I am the target of at least one back jump.

If there is a single back jump jumping at this location, yetToMerge is less or equal to 1 and backJumpBasicBlock is always nil.
If there are multiple back jumps, then the backjumps are merged into one for loop canonicalisation. backJumpbasicBlock becomes the merge point before the backjump.

backJumpBasicBlock <BasicBlock> single basicBlock holding the backjump. It is separated from the rest as there may be multiple backjump to the same pc.
yetToMerge <Smi> number of backjump yet to merge. Once the last one is merged, the backJump basic block can be added to the control flow.
"
Class {
	#name : #SoBackjumpFixup,
	#superclass : #SoJumpFixup,
	#instVars : [
		'yetToMerge',
		'backJumpBasicBlock'
	],
	#category : #'Scorching-Decompiler'
}

{ #category : #'yet to merge' }
SoBackjumpFixup >> additionalBackjump [
	yetToMerge := yetToMerge + 1.
]

{ #category : #accessing }
SoBackjumpFixup >> backJumpBasicBlock [
	<generated>
	^ backJumpBasicBlock
]

{ #category : #accessing }
SoBackjumpFixup >> backJumpBasicBlock: aValue [
	<generated>
	backJumpBasicBlock := aValue
]

{ #category : #'yet to merge' }
SoBackjumpFixup >> backjumpFixedUp [
	yetToMerge := yetToMerge - 1
]

{ #category : #accessing }
SoBackjumpFixup >> ensureBackJumpBasicBlock [
	backJumpBasicBlock ifNil: [ backJumpBasicBlock := SoBasicBlock new ]
]

{ #category : #initialization }
SoBackjumpFixup >> initialize [

	super initialize.

	yetToMerge := 1.
]

{ #category : #decompilation }
SoBackjumpFixup >> reachedFrom: decompiler [
	decompiler reachBackjumpFixup: self
]

{ #category : #accessing }
SoBackjumpFixup >> yetToMerge [
	<generated>
	^ yetToMerge
]

{ #category : #accessing }
SoBackjumpFixup >> yetToMerge: aValue [
	<generated>
	yetToMerge := aValue
]
