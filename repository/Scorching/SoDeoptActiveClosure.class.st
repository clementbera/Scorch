"
I represent the activeclosure (thisContext closureOrNil)
"
Class {
	#name : #SoDeoptActiveClosure,
	#superclass : #SoAbsDeoptNode,
	#category : #'Scorching-Deoptimization'
}

{ #category : #visiting }
SoDeoptActiveClosure >> accept: visitor [
	<script>
	^ visitor visitActiveClosure: self
]
