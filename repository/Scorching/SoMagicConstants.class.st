"
I hold magic constants, i.e., magic numbers used to tune the optimizer. 

"
Class {
	#name : #SoMagicConstants,
	#superclass : #SharedPool,
	#classVars : [
		'AggressiveInliningCountThreshold',
		'AlwaysInlineSize',
		'ClosureInliningBonus',
		'ConstantInliningBonus',
		'DefaultContextDistance',
		'MaxCommonLoopBasicBlocks',
		'MaxFullUnrollCount',
		'MaxHomeContextDistance',
		'MaxInlineSize',
		'MaxInliningDepth',
		'MaxInstSizeForInlinedAllocation',
		'MaxObjectSizeToStackAllocation',
		'MaxRecursion',
		'MaxTrapTrips',
		'RelaxedInliningCountThreshold',
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
	
	"If a send uses a constant or a closure, the method has a higher chance to be inlined.
	 The higher the bonus is, the higher is the chance to inline. "
	ConstantInliningBonus := 17.
	ClosureInliningBonus := 70.
	
	"If less than a threshold has already been inlined, the inlining heuristics are more aggressive."
	AggressiveInliningCountThreshold := 12.
	RelaxedInliningCountThreshold := 25.
	
	"If the method to inline has more than this size (+bonus from csts/closures, 
	 -malus from InliningCount threshold) it won't be inlined."
	MaxInlineSize := 60.
	"If the method has less than this number of bytecode it will always be inlined."
	AlwaysInlineSize := 9.
	
	"Max number of methods inlined in each other, else inlining fails. A big number here may create very slow dynamic deoptimization."
	MaxInliningDepth := 10.
	"In case of a recursive method, max number of time in which the method can be inlined in itself."
	MaxRecursion := 1.
	"Max distance between a block and its home, else block cannot be inlined, except if method in between were inlined..."
	MaxHomeContextDistance := 7. "has to be less than MaxInliningDepth"
	
	"--- Loop optimisations Magic Numbers ---"
	
	"Max number of basicBlocks in a loop to perform peeling / unrolling"
	MaxCommonLoopBasicBlocks := 5. 
	
	"Max number of iteration in the loop to fully unroll it"
	MaxFullUnrollCount := 10.
	
	"--- Other Magic Numbers ---"
	
	"Maximum size of objects that can be allocated inlined without external calls"
	MaxInstSizeForInlinedAllocation := 64.
	
	"User-pause allowed for the optimizer"
	TimeBeforePostponing := 0.2 seconds.
	
	"Max number of times a trap trips before the method is discarded"
	MaxTrapTrips := 2.
	
	"max size of object to move from heap to stack allocation"
	MaxObjectSizeToStackAllocation := 17.
]
