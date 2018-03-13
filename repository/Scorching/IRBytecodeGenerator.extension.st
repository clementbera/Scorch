Extension { #name : #IRBytecodeGenerator }

{ #category : #'*Scorching' }
IRBytecodeGenerator >> compiledBlockWith: trailer [
	| lits header cb |
	lits := self literals allButLast "1 free only for compiledBlock".
	header := self spurBlockVMHeader: lits size.
	cb := trailer createMethod: self bytecodes size class: CompiledBlock header: header.
	(WriteStream with: cb)
		position: cb initialPC - 1;
		nextPutAll: self bytecodes.
	lits withIndexDo: [:obj :i | cb literalAt: i put: obj].
	cb needsFrameSize: self stackFrameSize.
	self updateLiterals: cb.
	^ cb
]

{ #category : #'*Scorching' }
IRBytecodeGenerator >> spurBlockVMHeader: literalsSize [
	^ (CompiledMethod headerFlagForEncoder: self encoderClass) +
		(self numArgs bitShift: 24) +
		( self numTemps bitShift: 18) +
		literalsSize
]

{ #category : #'*Scorching' }
IRBytecodeGenerator >> spurVMHeader: literalsSize [
	^ (self spurBlockVMHeader: literalsSize) + (self hasPrimitive asBit bitShift: 16)
]
