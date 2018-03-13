"
I represent a branch merge point.

Let's take this CFG:
    1
    /\
   /  \
  /   3
 /   /  \
2  4  5
 \   \  /
  \   6
   \  /
    \/
    7

BasicBlock 1 ends with a branch. As it has a single merge point (7), an instance of myself can be created. The mapping maps direct branch target to incoming basicBlock, in this case:

mapping = { 2 -> 2 . 3 -> 6 }

In basicBlock 7, we know that code leaving basicBlock 1 to the branch going to 2 arrives at 7 through 6.

2 and 3 (keys in mapping) are 1 successors.
2 and 6 (values in mapping) are 7 predecessors.

basicBlock <BasicBlock>
mapping <Dictionary of BasicBlock->BasicBlock>


"
Class {
	#name : #SoMergePoint,
	#superclass : #SoAbsMergePoint,
	#instVars : [
		'basicBlock',
		'mapping'
	],
	#category : #'Scorching-Pass-Flow'
}

{ #category : #accessing }
SoMergePoint >> basicBlock [
	<generated>
	^ basicBlock
]

{ #category : #accessing }
SoMergePoint >> basicBlock: aValue [
	<generated>
	basicBlock := aValue
]

{ #category : #testing }
SoMergePoint >> isMergePoint [
	^ true
]

{ #category : #accessing }
SoMergePoint >> mapping [
	<generated>
	^ mapping
]

{ #category : #accessing }
SoMergePoint >> mapping: aValue [
	<generated>
	mapping := aValue
]
