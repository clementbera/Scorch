"
I am triggered when the argument of a method or a block is assigned. This was possible at some point for blocks, but is right now forbidden by default by the Pharo compiler.

Optimizing methods with such code is disabled due to the numerous compilation warning/issues you may get. In theory, the optimizer could support optimizing methods with such code.
"
Class {
	#name : #SoArgumentAssigment,
	#superclass : #Error,
	#category : #'Scorching-Error'
}
