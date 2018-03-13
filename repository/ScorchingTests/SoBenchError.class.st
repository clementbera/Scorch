"
Triggered when an error occured while the validator was benchmarking new versions of methods versus old ones.

This could happen if the validator has:
- not compared the two versions of the two methods before (rerun the validator with #comparison option)
- not compared the *jitted* version  of the two methods before (rerun the validator with #jitComparsion option)

Alternatively, it can imply that the optimized method behavior is non deterministic, and that even if #jitComparison validation passes, bench option run the methods many more time and end up with the bug.
"
Class {
	#name : #SoBenchError,
	#superclass : #SoValidationFailure,
	#category : #'ScorchingTests-Validation'
}
