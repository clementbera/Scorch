"
I am the common superclass of deoptimisation related code. All my subclasses code cannot be deoptimized to avoid recursive dynamic deoptimization (hence avoid crashes). All the deoptimization code cannot use code external to my subclasses code for the same reason. I encode tips for the optimiser to know he can't deal with this code.
"
Class {
	#name : #SoAbsDeopt,
	#superclass : #Object,
	#category : #'Scorching-Deoptimization'
}

{ #category : #testing }
SoAbsDeopt class >> allowRuntimeOptimization [
	^ false
]
