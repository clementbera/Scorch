"
Unit test for phi input accessing.
"
Class {
	#name : #SoPhiTest,
	#superclass : #TestCase,
	#instVars : [
		'bb1',
		'bb2',
		'phi'
	],
	#category : #'ScorchingTests-UnitTests'
}

{ #category : #initialization }
SoPhiTest >> setUp [
	bb1 := SoBasicBlock new.
	bb2 := SoBasicBlock new.
	phi := SoPhi new
		addInput: (SoConstant constant: 1) 
		basicBlock: bb1;
		addInput: (SoConstant constant: 2) 
		basicBlock: bb2;
		yourself
]

{ #category : #tests }
SoPhiTest >> testAddInput [
	| bb3 inputs bbRefs correctRefs |
	phi
		addInput: (SoConstant constant: 3)
		basicBlock: (bb3 := SoBasicBlock new).
	inputs := phi inputs collect: #constant.
	self assert: (inputs includesAll: #(1 2 3)).
	self assert: (#(1 2 3) includesAll: inputs).
	bbRefs := phi basicBlockReferences.
	correctRefs := {bb1 . bb2 . bb3}.
	self assert: (bbRefs includesAll: correctRefs).
	self assert: (correctRefs includesAll: bbRefs).
]

{ #category : #tests }
SoPhiTest >> testBasicBlockReferences [
	| bbRefs correctRefs |
	bbRefs := phi basicBlockReferences.
	correctRefs := {bb1 . bb2}.
	self assert: (bbRefs includesAll: correctRefs).
	self assert: (correctRefs includesAll: bbRefs).
]

{ #category : #tests }
SoPhiTest >> testBasicBlocksForInput [
	| bb_1 bb_2 |
	bb_1 := phi basicBlocksForInput: (SoConstant constant: 1).
	self assert: bb_1 size = 1.
	self assert: bb_1 first == bb1.
	bb_2 := phi basicBlocksForInput: (SoConstant constant: 2).
	self assert: bb_2 size = 1.
	self assert: bb_2 first == bb2.
]

{ #category : #tests }
SoPhiTest >> testInputForBasicBlock [
	| in1 in2 |
	in1 := phi inputForBasicBlock: bb1.
	self assert: in1 = (SoConstant constant: 1).
	in2 := phi inputForBasicBlock: bb2.
	self assert: in2 = (SoConstant constant: 2).
]

{ #category : #tests }
SoPhiTest >> testInputs [
	| inputs |
	inputs := phi inputs collect: #constant.
	self assert: (inputs includesAll: #(1 2)).
	self assert: (#(1 2) includesAll: inputs).
]

{ #category : #tests }
SoPhiTest >> testReplaceBasicBlockWith [
	| bb3 inputs bbRefs correctRefs |
	phi replaceBasicBlock: bb2 with: (bb3 := SoBasicBlock new). 
	inputs := phi inputs collect: #constant.
	self assert: (inputs includesAll: #(1 2)).
	self assert: (#(1 2) includesAll: inputs).
	bbRefs := phi basicBlockReferences.
	correctRefs := {bb1 . bb3}.
	self assert: (bbRefs includesAll: correctRefs).
	self assert: (correctRefs includesAll: bbRefs).
]
