"
Happens when the optimizing compiler has generated an optimized method, but that Cog's JIT has not succeeded in compiling the compiled method to machine code.

It could be a problem with stack depth, usually related to the optimizing compiler IR to bytecode backend, or a control flow problem (control flow unsupported by the JIT).
"
Class {
	#name : #SoJITComparisonError,
	#superclass : #SoValidationFailure,
	#category : #'ScorchingTests-Validation'
}
