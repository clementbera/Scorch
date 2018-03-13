"
I represent the receiver (thisContext receiver)
"
Class {
	#name : #SoDeoptReceiver,
	#superclass : #SoAbsDeoptNode,
	#category : #'Scorching-Deoptimization'
}

{ #category : #visiting }
SoDeoptReceiver >> accept: visitor [
	<script>
	^ visitor visitReceiver: self
]
