"
I hold magic constants, i.e., magic numbers used to tune the optimizer. 

"
Class {
	#name : #SoMagicConstants,
	#superclass : #SharedPool,
	#classVars : [
		'AlwaysInlineSize',
		'ClosureInliningBonus',
		'ConstantInliningBonus',
		'DecayInliningMalus',
		'EscapeInliningBonus',
		'InitialInliningBonus',
		'LoopDepthInliningBonus',
		'MaxAllocationFoldingSize',
		'MaxAllocationInitializationUnroll',
		'MaxFullUnrollCount',
		'MaxHomeContextDistance',
		'MaxInliningDepth',
		'MaxInstSizeForInlinedAllocation',
		'MaxNoInterruptCount',
		'MaxRecursion',
		'MaxTrapTrips',
		'TimeBeforePostponing'
	],
	#category : #'Scorching-Constants'
}

{ #category : #initialize }
SoMagicConstants class >> initialize [
	"
	self initialize.
	"
	
	"--- Inlining Magic Numbers ---"
	
	"The higher the bonus is, the higher is the chance to inline. "
	"send has a constant operand"
	ConstantInliningBonus := 17.
	"send has a closure operand"
	ClosureInliningBonus := 70.
	"send is in loop / nested loops"
	LoopDepthInliningBonus := 8.
	"send has a potential fold allocation"
	EscapeInliningBonus := 35.
	
	"If the method to inline has more than this size, always inline it"
	AlwaysInlineSize := 9.
	
	"Inlining has InitialInliningBonus // 100 as extra bonus in size, minus the decay per inlined function"
	InitialInliningBonus := 5000.
	DecayInliningMalus := 33.
	
	"Max number of methods inlined in each other, else inlining fails. A big number here may create very slow dynamic deoptimization."
	MaxInliningDepth := 24.
	
	"In case of a recursive method, max number of time in which the method can be inlined in itself."
	MaxRecursion := 2.
	"Max distance between a block and its home, else block cannot be inlined, except if method in between were inlined..."
	MaxHomeContextDistance := 7. "has to be less than MaxInliningDepth"
	
	"--- Loop optimisations Magic Numbers ---"
	
	"Max number of iteration in the loop to fully unroll it"
	MaxFullUnrollCount := 16.
	
	"Max number of iteration in the loop to remove interrupt check"
	MaxNoInterruptCount := 9999. 
	
	"--- Other Magic Numbers ---"
	 
	"Maximum size of objects that can be allocated inlined without external calls"
	MaxInstSizeForInlinedAllocation := 1 << 16 - 1.
	
	"User-pause allowed for the optimizer"
	TimeBeforePostponing := 2 seconds.
	
	"Max number of times a trap trips before the method is discarded"
	MaxTrapTrips := 2.
	
	"max size of object to move from heap to stack allocation"
	MaxAllocationFoldingSize := 12.
	
	"Max size of fields to initialize to move from duff's device default init to
	 manual default value + initial values init"
	MaxAllocationInitializationUnroll := 8.
]
