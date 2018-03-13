Class {
	#name : #SoInlinerTest,
	#superclass : #SoAbsPassTest,
	#category : #'ScorchingTests-UnitTests'
}

{ #category : #tests }
SoInlinerTest >> testPrimInlining [
	| optCode selectors newSelectors |
	selectors := ((SoGuineaPig >> #primInIining) literals allButLast: 2) select: #isSymbol.
	optCode := self run: { SoInliner } on: #primInIining.
	newSelectors := (optCode literals allButLast: 2) select: #isSymbol.
	newSelectors do: [ :sel |
		self deny: (selectors includes: sel) ].
	self assert: (self exec: optCode) = SoGuineaPig new primInIining.
]
