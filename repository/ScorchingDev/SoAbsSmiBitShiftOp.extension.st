Extension { #name : #SoAbsSmiBitShiftOp }

{ #category : #'*ScorchingDev' }
SoAbsSmiBitShiftOp class >> script [
	
	| ranges |
	ranges := { ( -7 to: -3) . ( -4 to: 5) . (3 to: 7) }.
	ranges do: [ :r1 |
	ranges do: [ :r2 |
		| a b c d |
		(r1 printString , ' bitShift: ' , r2 printString) logCr.
		a := r1 first tryPrimitive: 17 withArgs:  {r2 first}.
		b := r1 last tryPrimitive: 17 withArgs:  {r2 first}.
		c := r1 first tryPrimitive: 17 withArgs:  {r2 last}.
		d := r1 last tryPrimitive: 17 withArgs:  {r2 last}.
		{ a . b . c . d } logCr.
		"('Result: ' , 
			({ a . b . c . d } select: #isInteger) min printString, 
			' to ',
			({ a . b . c . d } select: #isInteger) max printString) logCr."
		 ] ]
]
