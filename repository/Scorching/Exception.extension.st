Extension { #name : #Exception }

{ #category : #'*Scorching' }
Exception >> signal [
	"Ask ContextHandlers in the sender chain to handle this signal.  The default is to execute and return my defaultAction."
	<scorchSignal>
	signalContext := thisContext contextTag.
	signaler ifNil: [ signaler := self receiver ].
	^ signalContext nextHandlerContext handleSignal: self
]
