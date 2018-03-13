"
I am triggered when the compiled method / scorch graph tries to decompile or to compile a method with too many stack slots, including spilled stack slots. 

The VM supports at most (CompiledMethod fullFrameSize) slots in a stack frame.
"
Class {
	#name : #SoStackOverflow,
	#superclass : #Error,
	#category : #'Scorching-Error'
}
