Extension { #name : #SoAbsMessageInliner }

{ #category : #'*ScorchingDev' }
SoAbsMessageInliner class >> logInlining: send message: msg [
	send codeNode debugInfo add: (SoInliningLog new 
		message: send selector , ' ' , msg;
		stackOrNil: (send deoptInfo ifNotNil: [ :d | d asDebugStack ]);
		num: send codeNode debugInfo size;
		yourself) 
]
