Extension { #name : #CompiledMethod }

{ #category : #'*Scorching' }
CompiledMethod >> hasNoRuntimeOptimizationsPragma [
	^ self pragmas anySatisfy: [ :pragma | pragma keyword = #noRuntimeOptimizations ] 
]
