"
I set correctly the dominators to the basicBlocks. This algorithm was ported from a C implementation. This algorithm is simple therefore it is slow for large CFG. For large CFG one would need to implement the Lengauer-Tarjan algorithm. However, as the size of the CFG is usually limited, it's usually good enough.

This is on purpose rewriting using optimized constructs (to:do:) instead of do:, because 20% of the time (of the whole optimizer) was spent in SequencableCollection>>#do: and this algo is performance critical. The variables are declared outside of loops because it avoids the push nil at each iteration.

2 passes:
 - pass 1 (computeDominators): calculs all the dominators of each basicblock
 - pass 2 (computeImmediateDominators): calculs the immediate dominator out of the dominators found n pass 1

Assumes that the given basic blocks are in pre order traversal for efficiency, though it works in any case.

	dominators	<Collection of Collection of basicBlocks> at the depthFirstOrder of each basic block a collection of its dominators is stored.
"
Class {
	#name : #SoFindDominators,
	#superclass : #SoAbstractDominators,
	#instVars : [
		'dominators'
	],
	#category : #'Scorching-Pass-Utils'
}

{ #category : #private }
SoFindDominators >> computeDominators: blocks [
	
	| change tmpSet block prevs |
	change := true.
	dominators := Array new: blocks size.
	dominators at: 1 put: blocks first asOrderedCollection.
	2 to: blocks size do: [ :i |
		dominators at: (blocks at: i) tempData put: (OrderedCollection withAll: blocks) ].
	
	"set allows faster intersection: and allows to write add: instead of union: in our case"
	tmpSet := blocks asSet.
	[change] whileTrue: [ 
		change := false.
		2 to: blocks size do: [ :i |
			block := blocks at: i.
			tmpSet := tmpSet copy. 
			prevs := block predecessors.
			1 to: prevs size do: [ :j |
				tmpSet := tmpSet intersection: (dominators at: (prevs at: j) tempData) ].
			tmpSet add: block.
			tmpSet = (dominators at: block tempData) ifFalse: [ 
				change := true.
				dominators at: block tempData put: tmpSet ].
		]
	 ].
]

{ #category : #private }
SoFindDominators >> computeImmediateDominators: blocks [

	| toRemove iterator theDom |
	
	1 to: blocks size do: [ :i |
		iterator := dominators at: i.
		iterator remove: (blocks at: i).
		dominators at: i put: iterator asOrderedCollection  ].
	
	toRemove := OrderedCollection new.
	
	2 to: blocks size do: [ :j |
		toRemove reset.
		iterator := dominators at: (blocks at: j) tempData.
		1 to: iterator size do: [ :s |
			1 to: iterator size do: [ :t |
				t == s ifFalse: [
					theDom := iterator at: t.
					((dominators at: (iterator at: s) tempData) includes: theDom) 
						ifTrue: [ toRemove add: theDom ] ] ] ].
		1 to: toRemove size do: [ :v |
			iterator remove: (toRemove at: v) ifAbsent: nil ] ].
	
	2 to: blocks size do: [ :k |
		iterator := blocks at: k.
		iterator dominator: (dominators at: iterator tempData) first ]
	
]

{ #category : #accessing }
SoFindDominators >> dominators [
	<generated>
	^ dominators
]

{ #category : #accessing }
SoFindDominators >> dominators: aValue [
	<generated>
	dominators := aValue
]

{ #category : #public }
SoFindDominators >> findDominators: basicBlocks [
	self setBasicBlocksNumbers: basicBlocks.
	self computeDominators: basicBlocks.
	self computeImmediateDominators: basicBlocks.
	
]

{ #category : #private }
SoFindDominators >> setBasicBlocksNumbers: basicBlocks [
	1 to: basicBlocks size do: [ :i |
		(basicBlocks at: i) tempData: i ]
]
