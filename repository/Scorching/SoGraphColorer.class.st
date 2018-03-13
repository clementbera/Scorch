"
I color each node of a graph such as there can't be 2 nodes with a relationship having the same color. I find the minimal number of color in [ minColor ; maxColor ] to color the nodes (and then color them). I am an adaptation of the Briggs-Chaitin graph coloring algorithm. 

WARNING: This algorithm is one of the most critical for performance. It has been rewritten for performance to get the optimiser under the threshold.

Algorithm (G: Graph ; R: number of colors in [ minColor ; maxColor ])
1) Dichotomical search of the minimum R such as G is R-colorable
	While G has a node N with degree less than R
		Remove N and its associated edges from G and push N on a stack S
	If the entire graph has been removed then the graph is R-colorable 
2) Coloration of the graph
	While stack S contains a node N
		Add N to graph G and assign it a color from the R colors
	




"
Class {
	#name : #SoGraphColorer,
	#superclass : #Object,
	#instVars : [
		'lastSuccessfulStack'
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

{ #category : #private }
SoGraphColorer >> canColor: nodes with: numColor [
	| stack setOfNodes |
	self restoreRelations: nodes.
	setOfNodes := nodes asSet.
	stack := OrderedCollection new.
	[ self removeNodeIn: setOfNodes degreeLessThan: numColor intoStack: stack ] whileTrue.
	^ setOfNodes size = 0
		ifTrue: [ lastSuccessfulStack := stack. true ]
		ifFalse: [ false ].
]

{ #category : #public }
SoGraphColorer >> color: nodes minColor: minColor maxColor: maxColor [
	self saveRelations: nodes.
	(self canColor: nodes with: minColor) ifTrue: [ 
		self setColors: minColor.
		^ minColor ].
	(self canColor: nodes with: maxColor) ifFalse: [ 
		SoNotEnoughTemps signal: 'running out of temps...' ].
	^ self dichotomicSearchIn: nodes from: minColor to: maxColor

]

{ #category : #private }
SoGraphColorer >> dichotomicSearchIn: nodes from: minColor to: maxColor [
	"min is not successful, max is successful"
	| min max mid |
	min := minColor.
	max := maxColor.
	[ min + 1 = max ] whileFalse: [ 
		mid := max + min // 2.
		(self canColor: nodes with: mid) 
			ifTrue: [ max := mid ]
			ifFalse: [ min := mid ] ].
	self setColors: max.
	^ max
]

{ #category : #accessing }
SoGraphColorer >> lastSuccessfulStack [
	<generated>
	^ lastSuccessfulStack
]

{ #category : #accessing }
SoGraphColorer >> lastSuccessfulStack: aValue [
	<generated>
	lastSuccessfulStack := aValue
]

{ #category : #private }
SoGraphColorer >> removeNodeIn: nodeCollection degreeLessThan: numColor intoStack: stack [
	"Inlined version - profiling"
	nodeCollection do: [ :node | 
		node relations size < numColor ifTrue: [ 
			nodeCollection remove: node.
			stack add: node.
			node removeFromGraph. 
			^ true ] 
	].
	^ false
]

{ #category : #private }
SoGraphColorer >> restoreRelations: nodes [
	nodes do: [ :e | e restoreRelations ]
]

{ #category : #private }
SoGraphColorer >> saveRelations: nodes [
	nodes do: [ :e | e saveRelations ]
]

{ #category : #private }
SoGraphColorer >> setColors: numColors [
	| coloris |
	coloris := 1 to: numColors.
	self restoreRelations: lastSuccessfulStack.
	[lastSuccessfulStack isEmpty] whileFalse: [ 
		| elem forbiddenColors |
		elem := lastSuccessfulStack removeLast.
		forbiddenColors := (elem relations collect: [ :rel | rel color ]) asSet.
		"There might be a nil in forbiddenColors for uninitialized colors"
		elem color: (coloris detect: [ :e | (forbiddenColors includes: e) not ]).
	 ].

]
