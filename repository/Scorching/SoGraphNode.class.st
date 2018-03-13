"
I am used for graph coloring. I represent a node in the graph knowing its relationship and ready to be colored.

I hold an id to map the algo to concrete cases. relations and savedRelations hold the dependencies of the node with other nodes, this is duplicated to improve the algorithm performance (1 field is mutable, the other set at the beginning of the algo and do not change). color is the color set by the algo.

	id <Object> information to map this node to a concrete application.
	relations <Collection of LiliGraphNode> nodes connected with this node.
	savedRelations <Collection of LiliGraphNode> duplication of relations. The algo destroy the relations, therefore savedRelations allows to restore the relations when needed.
	color <SmallInteger> color set by the graphColoring algo
	
"
Class {
	#name : #SoGraphNode,
	#superclass : #Object,
	#instVars : [
		'color',
		'id',
		'relations',
		'savedRelations'
	],
	#category : #'Scorching-Backend-Analysis'
}

{ #category : #'instance creation' }
SoGraphNode class >> id: id [ 
	^ self new id: id
]

{ #category : #initialize }
SoGraphNode >> addRelation: node [
	relations add: node.
	node relations add: self.
	
]

{ #category : #accessing }
SoGraphNode >> color [
	<generated>
	^ color
]

{ #category : #accessing }
SoGraphNode >> color: aValue [
	<generated>
	color := aValue
]

{ #category : #accessing }
SoGraphNode >> id [
	<generated>
	^ id
]

{ #category : #accessing }
SoGraphNode >> id: anObject [
	id := anObject
]

{ #category : #initialize }
SoGraphNode >> initialize [

	super initialize.

	relations := OrderedCollection new.
]

{ #category : #printing }
SoGraphNode >> printOn: stream [
	stream <<  id printString << '[' << color asString << ']'
]

{ #category : #accessing }
SoGraphNode >> relations [
	<generated>
	^ relations
]

{ #category : #accessing }
SoGraphNode >> relations: aValue [
	<generated>
	relations := aValue
]

{ #category : #accessing }
SoGraphNode >> removeFromGraph [
	relations do: [ :each | 
		each removeRelation: self ]
]

{ #category : #accessing }
SoGraphNode >> removeRelation: aNode [
	relations remove: aNode
]

{ #category : #accessing }
SoGraphNode >> restoreRelations [
	relations := savedRelations copy.
]

{ #category : #accessing }
SoGraphNode >> saveRelations [
	savedRelations := relations copy.
]

{ #category : #accessing }
SoGraphNode >> savedRelations [
	<generated>
	^ savedRelations
]

{ #category : #accessing }
SoGraphNode >> savedRelations: aValue [
	<generated>
	savedRelations := aValue
]
