Extension { #name : #OpalEncoderForSistaV1 }

{ #category : #'*Scorching' }
OpalEncoderForSistaV1 >> genBranchIfInstanceOf: literalIndex distance: distance [
	self genBranchIfInstanceOf: literalIndex distance: distance orNot: false
]

{ #category : #'*Scorching' }
OpalEncoderForSistaV1 >> genBranchIfInstanceOf: literalIndex distance: distance orNot: orNot [
	"254		11111110	kkkkkkkk	jjjjjjjj		branch If Not Instance Of Behavior/Array Of Behavior kkkkkkkk (+ Extend A * 256, where Extend A >= 0) distance jjjjjjjj (+ Extend B * 256, where Extend B >= 0)"
							
	| extendedIndex extendedDistance |
	(literalIndex < 0 or: [literalIndex > 65535]) ifTrue:
		[^self outOfRangeError: 'index' index: literalIndex range: 0 to: 65536].
	(distance < 1 or: [distance > 32767]) ifTrue: 
		[^self outOfRangeError: 'distance' index: distance range: 0 to: 32767].
	(extendedIndex := literalIndex) > 255 ifTrue:
		[self genUnsignedSingleExtendA: extendedIndex // 256.
		 extendedIndex := extendedIndex \\ 256].
	(orNot not or: [(extendedDistance := distance) > 255]) ifTrue:
		[self genUnsignedSingleExtendB: (distance bitShift: -8) + (orNot not asBit  * 128).
		extendedDistance := distance bitAnd: 255].
	
	stream
		nextPut: 254;
		nextPut: extendedIndex;
		nextPut: extendedDistance
]

{ #category : #'*Scorching' }
OpalEncoderForSistaV1 >> genBranchIfNotInstanceOf: literalIndex distance: distance [
	self genBranchIfInstanceOf: literalIndex distance: distance orNot: true
]

{ #category : #'*Scorching' }
OpalEncoderForSistaV1 >> genEnsureAllocatableSlots: int [
	stream
		nextPut: 236;
		nextPut: int
]

{ #category : #'*Scorching' }
OpalEncoderForSistaV1 >> genStoreFlagExtensionIgnoreStoreCheck: ignoreStoreCheck maybeContext: maybeContext ignoreReadOnlyCheck: ignoreReadOnlyCheck [
	"ignoreStoreCheck: 
	Can be applied to the long form of store and store pop of literal variable, remote inst var, remote temp, receiver inst var.
	If present, the VM does not generate the GC store check. 
	The main reasons the compiler can ignore the store check are one of these two:
	- the mutated object is always young
	- the object stored is immediate
	Currently the store check is for the remembered table, but we may have it for tri color marking later. So the compiler cannot really remove the store check if the object stored is old.

	maybeContext:
	Can be used only with remote instance variable stores and receiver variable stores. If marked, the object can be a context and hence needs specific VM code. Receiver inst var have a separate encoding, temp vectors and literal variable can't be contexts
	
	ignoreReadOnlyCheck:
	no read-only check will be performed by the VM. Normally each store has a read-only check.
	"
	self genUnsignedSingleExtendB: ignoreStoreCheck asBit + (maybeContext asBit << 1) + (ignoreReadOnlyCheck asBit << 2)
]

{ #category : #'*Scorching' }
OpalEncoderForSistaV1 class >> isReturnByte: byte [
	^ byte between: 88 and: 94
]

{ #category : #'*Scorching' }
OpalEncoderForSistaV1 class >> returnSelfByte [
	^ 88
]
