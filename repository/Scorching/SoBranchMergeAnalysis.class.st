"
I analyse a branch and figure out the merge points, i.e., the point where the two branches merge again. 

In a standard diamond, there is only one merge point. In this case I answer an instance of MergePoint with annotations used by other passes. In more advanced cases, there can be multiple merge points, in this case I answer a ComplexMergePoint. Lastly there may be no merge point, which is almost exclusively for loops (returns are canonicalized, but returns to different locations (i.e., NLR vs return), in which case we may find no merge point).

"
Class {
	#name : #SoBranchMergeAnalysis,
	#superclass : #SoGraphTraverser,
	#category : #'Scorching-Pass-Flow'
}

{ #category : #private }
SoBranchMergeAnalysis >> branchSuccessors: branch [
	^ (branch flatCollect: [ :bb | bb successors ]) asSet removeAllFoundIn: branch; yourself
]

{ #category : #public }
SoBranchMergeAnalysis >> mergePointFor: branch [
	| trueBranch falseBranch maybeMergeFalse maybeMergeTrue mergePoints mergePoint |
	trueBranch := self dominatedPath: branch trueBasicBlock.
	falseBranch := self dominatedPath: branch falseBasicBlock.
	maybeMergeTrue := self branchSuccessors: trueBranch.
	maybeMergeFalse := self branchSuccessors: falseBranch.
	mergePoints := maybeMergeTrue intersection: maybeMergeFalse.
	mergePoints size > 1 ifTrue: [ ^ SoComplexMergePoint new ]. 
	mergePoints size < 1 ifTrue: [ ^ SoNoMergePoint new ]. "loop"
	"Temporary workaround to avoid the case where merge points can reach each other, return splitting would help."
	maybeMergeTrue size > 1 ifTrue: [ ^ SoComplexMergePoint new ].
	maybeMergeFalse size > 1 ifTrue: [ ^ SoComplexMergePoint new ].
	mergePoint := mergePoints anyOne .
	^ SoMergePoint new 	
		basicBlock: mergePoint;
		mapping: { 
			branch trueBasicBlock -> (mergePoint predecessors copyWithoutAll: falseBranch) .
			branch falseBasicBlock -> (mergePoint predecessors copyWithoutAll: trueBranch) } asDictionary;
		yourself
]
