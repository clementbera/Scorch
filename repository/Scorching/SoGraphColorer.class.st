"
I am an implementation of the Briggs-Chaitin graph coloring algorithm. The algorithm colors each node of a graph such as there can't be 2 nodes with a relationship having the same color.

WARNING: this has been rewritten for performance to get the optimiser under the threshold, only the 2 methods increasing the number of colors are critical (colorize is ok).

Summary of the algo in pseudo-code:
While G cannot be R-colored
    While graph G has a node N with degree less than R
        Remove N and its associated edges from G and push N on a stack S
    End While 
    If the entire graph has been removed then the graph is R-colorable 
        While stack S contains a node N
            Add N to graph G and assign it a color from the R colors
        End While
    Else graph G cannot be colored with R colors
        Simplify the graph G by choosing an object to spill and remove its node N from G
        (spill nodes are chosen based on object’s number of definitions and references)
End While

success <Boolean> true once the algorithm has found a number of colors which is high enough to color all the nodes.


"
Class {
	#name : #SoGraphColorer,
	#superclass : #Object,
	#instVars : [
		'success'
	],
	#category : #'Scorching-Backend-Analysis'
}

{ #category : #analysis }
SoGraphColorer class >> analyse [
	"Answers a collection of arrays with { number of nodes in the graph . maximum number of constraints between the nodes . number of color needed }"
	| nodes record |
	record := OrderedCollection new.
	1 to: 50 do: [ :numberOfNodes |
		1 to: numberOfNodes do: [ :numberOfConstraints |
			nodes := SoGraphColorer exampleNodes: numberOfNodes relations: numberOfConstraints.
			record add: { numberOfNodes . numberOfConstraints . nodes max: [ :node | node color ] } ] ].
	^ record
]

{ #category : #analysis }
SoGraphColorer class >> exampleNodes: numNodes relations: numRelations [
	| nodes |
	nodes := (1 to: numNodes) collect: [ :i | SoGraphNode id: i ].
	1 to: nodes size do: [ :i |
		| nodeI |
		nodeI := nodes at: i.
		1 to: numRelations do: [ :k | 
			| relation |
			relation := nodes atRandom.
			(relation == nodeI or: [ nodeI relations includes: relation ]) ifFalse: [ nodeI addRelation: relation ] ] ].
	^ self new color: nodes asOrderedCollection
]

{ #category : #public }
SoGraphColorer >> color: nodeCollection minColor: min maxColor: max [
	"Attempt to color with the minimum number of color (min). 
	  On failure, attempt to color with 1 more color, again and 
	  again, until it reaches the max number of colors (max)."
	success := false.
	self saveRelations: nodeCollection.
	min to: max do: [ :numColor |
		self restoreRelations: nodeCollection.
		self 
			color: nodeCollection asSet
			with: numColor.
		success ifTrue: [ ^ numColor ] ].
	SoNotEnoughTemps signal: 'running out of temps...'.
]

{ #category : #private }
SoGraphColorer >> color: nodeCollection with: numColor [
	| stack change |
	stack := OrderedCollection new.
	change := true.
	[change] whileTrue: [ 
		change := false.
		nodeCollection 
			detect: [ :e | e relations size < numColor ]
			ifFound: [ :node |
				change := true.
				nodeCollection remove: node.
				stack add: node.
				node removeFromGraph ]
			ifNone: nil
		 ].
	nodeCollection ifEmpty: [ self colorize: stack  with: numColor].
]

{ #category : #private }
SoGraphColorer >> colorize: stack with: numColors [
	| coloris |
	success := true.
	coloris := 1 to: numColors.
	self restoreRelations: stack.
	[stack isEmpty] whileFalse: [ 
		| elem forbiddenColors |
		elem := stack removeLast.
		forbiddenColors := (elem relations collect: [ :rel | rel color ]) asSet.
		"There might be a nil in forbiddenColors for uninitialized colors"
		elem color: (coloris detect: [ :e | (forbiddenColors includes: e) not ]).
	 ].

]

{ #category : #private }
SoGraphColorer >> restoreRelations: nodeCollection [
	nodeCollection do: [ :e |
		e restoreRelations ]
]

{ #category : #private }
SoGraphColorer >> saveRelations: nodeCollection [
	nodeCollection do: [ :e | 
		e saveRelations ]
]

{ #category : #accessing }
SoGraphColorer >> success [
	<generated>
	^ success
]

{ #category : #accessing }
SoGraphColorer >> success: aValue [
	<generated>
	success := aValue
]
