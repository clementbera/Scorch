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
	self expandSubNodesSizeFrom: descr in: sub.
	self expandSubNodesDoFrom: descr in: sub.
	self expandSubNodesAnySatisfyFrom: descr in: sub.
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
SoNodesWithDefMacroExpander >> expandSubNodesAnySatisfyFrom: descr in: sub [
	| stream |
	stream := '' writeStream.
	self headerWithPattern: 'subNodesAnySatisfy: aBlock
	"profiling"' on: stream.
	descr 
		pairsDo: [ :instVarName :type |
			(self macroExpanderFromSymbol: type)
				expandSubNodesAnySatisfy: instVarName 
				last:  (descr at: descr size - 1) == instVarName
				on: stream.
			stream nextPut: $. . 
			stream cr. 
			stream tab ].
	sub 
		compile: (self patchArrayConcat: stream contents)
		classified: #'graph edition'
]

{ #category : #'macro expansion' }
SoNodesWithDefMacroExpander >> expandSubNodesDoFrom: descr in: sub [
	| stream |
	stream := '' writeStream.
	self headerWithPattern: 'subNodesDo: aBlock
	"profiling"' on: stream.
	descr 
		pairsDo: [ :instVarName :type |
			(self macroExpanderFromSymbol: type) expandSubNodesDo: instVarName on: stream.
			instVarName = (descr at: descr size - 1)
				ifFalse: [ 
					stream nextPut: $. . 
					stream cr. 
					stream tab ] ].
	sub 
		compile: (self patchArrayConcat: stream contents)
		classified: #'graph edition'
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
	sub 
		compile: (self patchArrayConcat: stream contents)
		classified: #'graph edition'
]

{ #category : #'macro expansion' }
SoNodesWithDefMacroExpander >> expandSubNodesSizeFrom: descr in: sub [
	| stream |
	stream := '' writeStream.
	self headerWithPattern: 'subNodesSize' on: stream.
	stream << '^ '.
	descr 
		pairsDo: [ :instVarName :type |
			(self macroExpanderFromSymbol: type) expandSubNodesSize: instVarName on: stream.
			instVarName = (descr at: descr size - 1)
				ifFalse: [ stream << ' + ' ] ].
	sub 
		compile: (self patchArrayConcat: stream contents)
		classified: #'graph edition'
]

{ #category : #utils }
SoNodesWithDefMacroExpander >> headerWithPattern: pattern on: stream [
	stream << pattern.
	self maybeAddPragma: stream.
	stream cr; tab.
]

{ #category : #utils }
SoNodesWithDefMacroExpander >> patchArrayConcat: string [
	| str |
	"
	{object} , {index} , {expression}
	=> {object . index . expression}
	"
	str := self replace: '} , {' with: ' . ' in: string.
	"..."
	str := self replace: '1 + 1' with: '2' in: str.
	^ self replace: '2 + 1' with: '3' in: str.
]

{ #category : #utils }
SoNodesWithDefMacroExpander >> replace: pattern with: pattern2 in: string [
	"
	{object} , {index} , {expression}
	=> {object . index . expression}
	"
	| newString split |
	split := string splitOn: pattern.
	split size = 1 ifTrue: [ ^ string ].
	newString := '' writeStream.
	split 
		do: [ :each | newString << each ]
		separatedBy: [ newString << pattern2 ].
	^ newString contents
]
