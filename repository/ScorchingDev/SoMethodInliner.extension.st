Extension { #name : #SoMethodInliner }

{ #category : #'*ScorchingDev' }
SoMethodInliner >> inline: message [
	send := message.
	self canInline ifFalse: [ self class logInlining: send message: debugString. ^ #() ].
	self parseInlinedCode ifFalse: [ self class logInlining: send message: debugString. ^ #() ].
	self class logInlining: send message: debugString.
	self insertTrap.
	self splitBasicBlock.
	self patchReturn.
	^ self finishInlining
]
