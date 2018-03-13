"
I am the facade to Scorch, a framework aiming to improve the virtual machine performance by speculatively optimizing frequently used code at runtime. 

I have documented public APIs class-side that should be the *only* APIs used from the outside of this package. Any call on other APIs is not guaranteed to produce the same result in future release, and may be removed, renamed or altered.

The framework includes three main components:
- The runtime optimizer: it speculates on types based on previous runs on the portion of code to optimise and generate an optimised version of the code annotated with deoptimisation meta-information. Through the facade's API, the optimizer is called on an execution stack: it analyses it to find the best code to optimise. The optimizer is the main and most complex component of the framework (most classes and methods belongs to this part).
- The deoptimizer: it can recreate the non optimised stack from the context executing an optimised version of code, this is used for debugging and when a speculation made by the runtime optimiser happens to be incorrect.
- The dependency manager: it knows when a selector is installed what optimised code to discard to ensure the system remains correct, as if nothing was never optimised.
"
Class {
	#name : #Scorch,
	#superclass : #Object,
	#category : #'Scorching-FrontEnd'
}

{ #category : #'closure interface' }
Scorch class >> actualOuterContext: closure [
	^ self actualOuterContext: closure process: Processor activeProcess
]

{ #category : #'closure interface' }
Scorch class >> actualOuterContext: closure process: process [
	"
	In the current optimizer scheme, closure may refer to an optimized outerContext. This has several implications:
	- the outer context can be optimized, hence the program has issue debugging.
	- the outer context may be a deoptimized optimized context, hence the program has issue performing non local returns or debugging.
	This method answers the non optimized version of the outer context of the closure, potentially requiring the deoptimization of multiple frames.
	The process where the deoptimization matters.
	"
	^ SoDeoptimizer new actualOuterContext: closure process: process
]

{ #category : #'context interface' }
Scorch class >> deoptimizeContext: optimizedContext [ 
	<noRuntimeOptimizations>
	"
	The optimized context passed as input is stopped on a deoptimization 
	point and needs to be recovered. The context is deoptimized and 
	exception is resumed in the deoptimized stack.
	
	All methods from VM interface to this method should have the 
	<noRuntimeOptimizations> pragma to avoid recursive deoptimization.
	
	If the context passed is *not* at the bottom of the stack, you need to 
	manually set the context having the optimized context as sender to
	the context returned by this method. 
	"
	^ SoDeoptimizer new deoptimizeContext: optimizedContext
]

{ #category : #dependencies }
Scorch class >> flushSelector: selector [
	"
	When a method is installed, this method should be called to remove all the assumptions made by the optimizer for this selector. This may require the deoptimization of multiple frames.
	"
	SoDependencyMap default flushSelector: selector
]

{ #category : #'context interface' }
Scorch class >> isDeoptimizedContext: context [
	^ SoDeoptimizer new isDeoptimizedContext: context
]

{ #category : #'context interface' }
Scorch class >> optimizeContext: context [ 
	"
	Takes as input a non-optimized context which is at the bottom of the stack.
	Based on profiling information and the current stack, looks for the best
	method or block to optimize, generates an optimized version and 
	install it. Then just returns to resume execution.
	"
	^ SoOptimizer new optimizeContext: context
]
