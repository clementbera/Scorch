"
Specific version for test /debugging.
"
Class {
	#name : #SoOptimizerDebugTest,
	#superclass : #SoOptimizer,
	#instVars : [
		'block'
	],
	#category : #'ScorchingTests-Validation'
}

{ #category : #accessing }
SoOptimizerDebugTest >> block [
	^ block
]

{ #category : #accessing }
SoOptimizerDebugTest >> block: anObject [
	block := anObject
]

{ #category : #'private - opt' }
SoOptimizerDebugTest >> run: optClass [
	block value: optClass value: [ super run: optClass ]
]
