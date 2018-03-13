Class {
	#name : #SoRegisterAllocationTest,
	#superclass : #TestCase,
	#category : #ScorchingVMTests
}

{ #category : #'tests - stress' }
SoRegisterAllocationTest >> testRegisterAllocationStress1 [
	| t1 t2 t3 |
	t1 := 1.
	t2 := 2.
	t3 := 3.
	self 
		assert: { t1 == t2 . t2 == t3 . t3 == t1 . t3 == t2 . t1 == t2 . t2 == t3 . t3 == t1 }
		equals: #(false false false false false false false)
]

{ #category : #'tests - stress' }
SoRegisterAllocationTest >> testRegisterAllocationStress2 [
	| t1 t2 t3 |
	t1 := 1.
	t2 := 1.
	t3 := 1.
	self 
		assert: { t1 == t2 . t2 == t3 . t3 == t1 . t3 == t2 . t1 == t2 . t2 == t3 . t3 == t1 }
		equals: #(true true true true true true true)
]
