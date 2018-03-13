"
This error has happen if the optimization graph is insane ( for example an instruction refers to an unknown value or the control flow makes no sense) at some point during the optimisation process.

In general, this implies an optimization pass has transformed the graph in an insane state, so the pass needs to be checked.
"
Class {
	#name : #SoGraphInsane,
	#superclass : #SoValidationFailure,
	#category : #'ScorchingTests-Validation'
}
