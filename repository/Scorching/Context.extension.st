Extension { #name : #Context }

{ #category : #'*Scorching' }
Context >> aboutToReturn: result through: firstUnwindContext [ 
	"Called from VM when an unwindBlock is found between self and its home.
	 Return to home's sender, executing unwind blocks on the way."
	<noRuntimeOptimizations>
	"It could be that the outer is deoptimized and the NLR
	would fail whereas it should succeed."
	closureOrNil ifNotNil: [ 
		(Scorch isDeoptimizedContext: self home) ifTrue: [ 
				| ctxt |
				ctxt := self.
				[ ctxt outerContext == self home ] whileFalse: [ ctxt := ctxt outerContext ].
				Scorch actualOuterContext: ctxt closureOrNil.
				^ self return: result from: self methodReturnContext ] ].
	self methodReturnContext return: result through: firstUnwindContext
]

{ #category : #'*Scorching' }
Context >> callInlinedPrimitive: primNumber [
	"inlined primitive simulation.
	Inlined binary tree."

	| prim marker res |
	FileStream stdout << primNumber printString << '   '.
	prim := primNumber bitAnd: 1 << 15 - 1.
	marker := Object new.
	(res := self value: prim marker: marker) == marker 
		ifTrue: [self error: 'simulation not supported for' , prim printString]
		ifFalse: [ self push: res ]
	
]

{ #category : #'*Scorching' }
Context >> callPrimitive: primNumber [
	| res |
	primNumber >= (1 << 15) ifTrue: [ "inlined primitive, cannot fail" ^ self callInlinedPrimitive: primNumber ].  
	res := self doPrimitive: primNumber method: self method receiver: receiver args: self arguments.
	"regular primitive. Always at the beginning of methods."
	res = PrimitiveFailToken ifTrue: [ "keeps interpreting the method" ^ self ].
	self push: res.
	self methodReturnTop.
]

{ #category : #'*Scorching' }
Context >> cannotReturn: result [
	<noRuntimeOptimizations>
	closureOrNil ifNotNil: [ 
		"It could be that the NLR failed because the outerContext was deoptimized.
		In that case remap the outerContext to the deoptimized version and
		retry the NLR."
		(Scorch isDeoptimizedContext: self home) ifTrue: [ 
			| ctxt |
			ctxt := self.
			[ ctxt outerContext == self home ] whileFalse: [ ctxt := ctxt outerContext ].
			Scorch actualOuterContext: ctxt closureOrNil.
			^ self return: result from: self methodReturnContext ].
		^BlockCannotReturn result: result from: self home].
	Processor activeProcess 
		debug: thisContext 
		title: 'computation has been terminated'
]

{ #category : #'*Scorching' }
Context >> closureOrNil [
	^ closureOrNil 
]

{ #category : #'*Scorching' }
Context >> conditionalBranchCounterTrippedOn: boolean [
	"Triggered by the Sista JIT. Here you need to manage the adaptive recompilation. When this method is triggered #conditionalBranchCounterTrippedOn: is removed from the specialObjectsArray"
	
	[ Scorch optimizeContext: self ] ensure: [ 
		self skipBackBeforeJump.
		method resetCounters.
		Smalltalk vm parameterAt: 17 put: 0.5. "Move back the tide"
		Smalltalk specialObjectsArray at: 59 put: #conditionalBranchCounterTrippedOn: ].
	^ boolean 
]

{ #category : #'*Scorching' }
Context >> deoptimize [
	<noRuntimeOptimizations>
	^ Scorch deoptimizeContext: self
]

{ #category : #'*Scorching' }
Context >> method: x [
	method := x
]

{ #category : #'*Scorching' }
Context >> respondsToUnknownBytecode [
	"This method is triggered by the VM when the interpreter tries to execute an unknown bytecode"
	
	"Falls back on the in-image interpreter for byte code not implemented in the VM"
	^ self interpretNextInstructionFor: self
	

]

{ #category : #'*Scorching' }
Context >> trapTripped [
	"Triggered by the Sista JIT. Here you need to manage the dynamic deoptimization."
	<noRuntimeOptimizations>
	| deoptCtxt currentProcess |
	deoptCtxt := self deoptimize.
	currentProcess := Processor activeProcess.
	[ currentProcess suspendedContext: deoptCtxt ] fork.
	Processor yield.
	"Should not reach here already..."
	thisContext sender: deoptCtxt.
	thisContext jump.
	self error: 'should not be reached'.
]

{ #category : #'*Scorching' }
Context >> value: prim marker: marker [
	"inlined primitive simulation.
	Inlined binary tree."

	| rcvr arg1 arg2 |
	prim < 1000  
		ifTrue: [ 	
			rcvr := self pop.
			(prim between: 1 and: 3) ifTrue: [ ^ rcvr basicSize ] ]
		ifFalse: [ 
			arg1 := self pop.
			rcvr := self pop.
			prim < 2000 
			ifTrue: [ 
				prim = 1000 ifTrue: [ ^ rcvr + arg1 ].
				prim = 1036 ifTrue: [ ^ rcvr = arg1 ].
				prim = 1035 ifTrue: [ ^ rcvr <= arg1 ].
				prim = 1033 ifTrue: [ ^ rcvr < arg1 ].
				prim = 1037 ifTrue: [ ^ rcvr ~= arg1 ].
				(prim between: 1064 and: 1065) ifTrue: [ ^ rcvr basicAt: arg1 ] ]
			ifFalse: [ 
				arg2 := self pop.
				arg1 := self pop.
				rcvr := self pop.
				prim < 2002 
					ifTrue: [ ^ rcvr basicAt: arg2 put: arg2 ] ] ].
	^ marker
]
