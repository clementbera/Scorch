"
I look for nodes in the IR that defines #nodesWithDef, and then, generates the method #subNodes and #replaceSubNode:by:

Usage:
self expandNodesWithDefMacros 
"
Class {
	#name : #SoNodesWithDefMacroExpander,
	#superclass : #SoAbstractGenerator,
	#category : #'ScorchingDev-macros'
}

{ #category : #script }
SoNodesWithDefMacroExpander class >> expandNodesWithDefMacros [
	^ self new expandNodesWithDefMacros
]

{ #category : #'macro expansion' }
SoNodesWithDefMacroExpander >> expandMacro: descr in: sub [ 
	descr ifEmpty: [ ^ self ].	
	self expandSubNodesFrom: descr in: sub.
	self expandReplaceSubNodesFrom: descr in: sub.
	self expandPostCopyFrom: descr in: sub.
]

{ #category : #public }
SoNodesWithDefMacroExpander >> expandNodesWithDefMacros [
	SoAbsNode allSubclasses do: [ :sub |
		sub ~~ SoPointerSunkObjectState ifTrue: [ 
			sub class 
				compiledMethodAt: #nodesWithDef 
				ifPresent: [ :cm | 
					self 
						expandMacro: (self withArgs: #() executeMethod: cm) 
						in: sub ]
				ifAbsent: nil ] ]
]

{ #category : #'macro expansion' }
SoNodesWithDefMacroExpander >> expandPostCopyFrom: descr in: sub [
	| stream worth |
	stream := '' writeStream.
	self headerWithPattern: 'postCopy' on: stream.
	worth := false.
	descr 
		pairsDo: [ :instVarName :type |
			type = #array ifTrue: [ 
				worth := true.
				stream << instVarName << ' := ' << instVarName << ' copy.'. stream cr; tab. ] ].
	stream << 'super postCopy'.
	worth ifTrue: [sub compile: stream contents classified: #'graph edition'].
]

{ #category : #'macro expansion' }
SoNodesWithDefMacroExpander >> expandReplaceSubNodesFrom: descr in: sub [
	| stream |
	stream := '' writeStream.
	self headerWithPattern: 'basicReplaceSubNode: node by: anotherNode' on: stream.
	descr 
		pairsDo: [ :instVarName :type |	
			(self macroExpanderFromSymbol: type)
				expandReplaceSubNode: instVarName
				last: (descr at: descr size - 1) == instVarName
				on: stream ].
	sub compile: stream contents classified: #'graph edition'
]

{ #category : #'macro expansion' }
SoNodesWithDefMacroExpander >> expandSubNodesFrom: descr in: sub [
	| stream |
	stream := '' writeStream.
	self headerWithPattern: 'subNodes' on: stream.
	stream << '^ '.
	descr 
		pairsDo: [ :instVarName :type |
			(self macroExpanderFromSymbol: type) expandSubNodes: instVarName on: stream.
			instVarName = (descr at: descr size - 1)
				ifFalse: [ stream << ' , ' ] ].
	sub compile: stream contents classified: #'graph edition'
]

{ #category : #utils }
SoNodesWithDefMacroExpander >> headerWithPattern: pattern on: stream [
	stream << pattern.
	self maybeAddPragma: stream.
	stream cr; tab.
]
