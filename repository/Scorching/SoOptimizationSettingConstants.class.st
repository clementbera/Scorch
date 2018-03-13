"
I hold constants relative to the optimisation passes the optimiser will perform.
"
Class {
	#name : #SoOptimizationSettingConstants,
	#superclass : #SharedPool,
	#classVars : [
		'ActiveO',
		'InitialInliningPhase',
		'InitialOptPhase',
		'LateInliningPhase',
		'LateOptPhase',
		'NoInitialInliningPhase',
		'NoInitialOptPhase',
		'NoLateInliningPhase',
		'NoLateOptPhase',
		'NoOpt',
		'NoUniqueLoopPhase',
		'UniqueLoopPhase'
	],
	#category : #'Scorching-Constants'
}

{ #category : #initialize }
SoOptimizationSettingConstants class >> initialize [
	"We can mess up ordering here, but we need to remember:
	- Inlining requires deadBranchElim and tempVectSinking afterwards to be efficient. 
	  Overall, inlining is the phase taking most of the time, so don't abuse it too much.
	- DeadFlow elimination is efficient at the end only and if multiple optimisations have 
	  been performed (especially GVN).
	- ABCD is worth it after and before commonLoopOpt. Before commonLoopOp, it 
	  is better to run LICM afterwards to hoist the traps it generates out of the loop.
	  After commonLoopOpt, ABCD unchecks things in peeled and unrolled loop, so GVN 
	  is important to get good result by removing common sub expressions.
	- LICM has to be performed before commonLoopOpt to work correctly, and commonLoopOpt 
	 is more efficient after LICM. LICM and commonLoopOpt can be run only once..
	
	Currently ordering is split this way because it gets decent results and it is easy to debug part of 
	the optimisations. I think in the future we should switch to an optimisation planner that defines an
	optimisation planning by finding fixed points for each optimisations given the constraints."
	
	InitialInliningPhase := { SoCallGraphInliner . SoDeadBranchElimination .  SoTempVectorSinker }.
	InitialOptPhase := { SoABCD . SoBranchSplitter . SoGVN . SoRemoveRedondantRead . SoGVN . SoRemoveRedondantRead . SoABCD }.
	UniqueLoopPhase := { SoLICM ". SoCommonLoopOpt ". SoGVN }.
	LateInliningPhase := { SoLateCallGraphInliner . SoDeadBranchElimination . SoTempVectorSinker }.
	LateOptPhase := { SoBranchSplitter . SoGVN . SoRemoveRedondantRead . SoABCD . SoBranchSplitter . SoGVN . SoRemoveRedondantRead . SoDeadFlowElimination . SoGVN }.
	
	NoInitialInliningPhase := InitialOptPhase , UniqueLoopPhase ,  LateInliningPhase , LateOptPhase.
	NoInitialOptPhase := InitialInliningPhase , UniqueLoopPhase ,  LateInliningPhase , LateOptPhase.
	NoUniqueLoopPhase := InitialInliningPhase , InitialOptPhase ,  LateInliningPhase , LateOptPhase.
	NoLateInliningPhase := InitialInliningPhase , InitialOptPhase , UniqueLoopPhase , LateOptPhase.
	NoLateOptPhase := InitialInliningPhase , InitialOptPhase , UniqueLoopPhase ,  LateInliningPhase.
	NoOpt := #().
	
	ActiveO := InitialInliningPhase , InitialOptPhase , UniqueLoopPhase ,  LateInliningPhase , LateOptPhase.
]
