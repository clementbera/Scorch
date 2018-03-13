"
Specific version for primitive with different deoptimisation information.

originalMethod <CompiledMethod> method to restore to at the beginning
"
Class {
	#name : #SoPrimitiveDecompiler,
	#superclass : #SoMethodDecompiler,
	#instVars : [
		'originalMethod'
	],
	#category : #'Scorching-Decompiler'
}

{ #category : #accessing }
SoPrimitiveDecompiler >> getClassToInstall [
	^ originalMethod methodClass
]

{ #category : #fixups }
SoPrimitiveDecompiler >> insertLoopHead [
	
]

{ #category : #accessing }
SoPrimitiveDecompiler >> originalMethod [
	<generated>
	^ originalMethod
]

{ #category : #accessing }
SoPrimitiveDecompiler >> originalMethod: aValue [
	<generated>
	originalMethod := aValue
]

{ #category : #'sunk objects' }
SoPrimitiveDecompiler >> recordSunkContext: node [
	self error: 'should not happen'
]

{ #category : #initialization }
SoPrimitiveDecompiler >> setUpWithInliner: inliner [
	originalMethod := inliner codeToInline.
	super setUpWithInliner: inliner
]
