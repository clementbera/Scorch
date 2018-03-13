"
I am the common superclass of the scanner used in the decompilation process. If not overriden, every instruction is interpreted by my instances as doing nothing.
"
Class {
	#name : #SoAbstractScanner,
	#superclass : #SoInstructionStream,
	#category : #'Scorching-Decompiler'
}

{ #category : #opcodes }
SoAbstractScanner >> blockReturnConstant: value [ 
	<script>
	"Return Constant From Block bytecode."
]

{ #category : #opcodes }
SoAbstractScanner >> blockReturnTop [
	<script>
	"Return Top Of Stack bytecode."


]

{ #category : #opcodes }
SoAbstractScanner >> callPrimitive: prim [
	<script>
]

{ #category : #opcodes }
SoAbstractScanner >> directedSuperSend: selector numArgs: numArgs [
	<script>
	"Send Message Above Specific Class With Selector, selector, bytecode.
	 Start the lookup above the class that is the value of the association on
	 top of stack. The arguments  of the message are found in the top numArgs
	 stack locations beneath the association, and the receiver just below them."
]

{ #category : #opcodes }
SoAbstractScanner >> doDup [
	<script>
	"Duplicate Top Of Stack bytecode."


]

{ #category : #opcodes }
SoAbstractScanner >> doNop [
	<script>

	"do nothing"
]

{ #category : #opcodes }
SoAbstractScanner >> doPop [
	<script>
	"Remove Top Of Stack bytecode."

]

{ #category : #stackp }
SoAbstractScanner >> drop: n [
	"ignored in scanner"
]

{ #category : #opcodes }
SoAbstractScanner >> jump: offset [
	<script>
	"Unconditional Jump bytecode."


]

{ #category : #opcodes }
SoAbstractScanner >> jump: offset if: condition [ 
	<script>
	"Conditional Jump bytecode."


]

{ #category : #opcodes }
SoAbstractScanner >> methodReturnConstant: value [ 
	<script>
	"Return Constant bytecode."

]

{ #category : #opcodes }
SoAbstractScanner >> methodReturnReceiver [
	<script>
	"Return Self bytecode."

]

{ #category : #opcodes }
SoAbstractScanner >> methodReturnTop [
	<script>
	"Return Top Of Stack bytecode."

]

{ #category : #opcodes }
SoAbstractScanner >> popIntoLiteralVariable: anAssociation [ 
	<script>
	"Remove Top Of Stack And Store Into Literal Variable bytecode."

]

{ #category : #opcodes }
SoAbstractScanner >> popIntoReceiverVariable: offset [ 
	<script>
	"Remove Top Of Stack And Store Into Instance Variable bytecode."

]

{ #category : #opcodes }
SoAbstractScanner >> popIntoRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [
	<script>
	"Remove Top Of Stack And Store Into Offset of Temp Vector bytecode."
]

{ #category : #opcodes }
SoAbstractScanner >> popIntoTemporaryVariable: offset [ 
	<script>
	"Remove Top Of Stack And Store Into Temporary Variable bytecode."

]

{ #category : #opcodes }
SoAbstractScanner >> pushActiveContext [
	<script>
	"Push Active Context On Top Of Its Own Stack bytecode."

]

{ #category : #opcodes }
SoAbstractScanner >> pushActiveProcess [
	<script>
	"Push Active Process On Top Of Its Own Stack bytecode."
	
]

{ #category : #opcodes }
SoAbstractScanner >> pushClosureCopyNumCopiedValues: numCopied numArgs: numArgs blockSize: blockSize [
	<script>
	"Push Closure bytecode."

]

{ #category : #opcodes }
SoAbstractScanner >> pushClosureTemps: numTemps [
	<script>
	"push on stack nil numTemps times for the closure temps"
]

{ #category : #opcodes }
SoAbstractScanner >> pushConsArrayWithElements: numElements [
	<script>
	"Push Cons Array of size numElements popping numElements items from the stack into the array bytecode."

]

{ #category : #opcodes }
SoAbstractScanner >> pushConstant: value [
	<script>
	"Push Constant, value, on Top Of Stack bytecode."

]

{ #category : #opcodes }
SoAbstractScanner >> pushFullClosure: compiledBlock numCopied: numCopied receiverOnStack: recOnStack ignoreOuterContext: ignoreOuterContext [
]

{ #category : #opcodes }
SoAbstractScanner >> pushLiteralVariable: anAssociation [
	<script>
	"Push Contents Of anAssociation On Top Of Stack bytecode."

]

{ #category : #opcodes }
SoAbstractScanner >> pushNewArrayOfSize: numElements [ 
	<script>
	"Push New Array of size numElements bytecode."

]

{ #category : #opcodes }
SoAbstractScanner >> pushReceiver [
	<script>
	"Push Active Context's Receiver on Top Of Stack bytecode."

]

{ #category : #opcodes }
SoAbstractScanner >> pushReceiverVariable: offset [
	<script>
	"Push Contents Of the Receiver's Instance Variable Whose Index 
	is the argument, offset, On Top Of Stack bytecode."

]

{ #category : #opcodes }
SoAbstractScanner >> pushRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [
	<script>
	"Push Contents at Offset in Temp Vector bytecode."
]

{ #category : #opcodes }
SoAbstractScanner >> pushTemporaryVariable: offset [
	<script>
	"Push Contents Of Temporary Variable Whose Index Is the 
	argument, offset, On Top Of Stack bytecode."

]

{ #category : #opcodes }
SoAbstractScanner >> send: selector super: supered numArgs: numberArguments [
	<script>
	"Send Message With Selector, selector, bytecode. The argument, 
	supered, indicates whether the receiver of the message is specified with 
	'super' in the source method. The arguments of the message are found in 
	the top numArguments locations on the stack and the receiver just 
	below them."

]

{ #category : #opcodes }
SoAbstractScanner >> storeIntoLiteralVariable: anAssociation [ 
	<script>
	"Store Top Of Stack Into Literal Variable Of Method bytecode."

]

{ #category : #opcodes }
SoAbstractScanner >> storeIntoReceiverVariable: offset [ 
	<script>
	"Store Top Of Stack Into Instance Variable Of Method bytecode."

]

{ #category : #opcodes }
SoAbstractScanner >> storeIntoRemoteTemp: remoteTempIndex inVectorAt: tempVectorIndex [
	<script>
	"Store Top Of Stack And Store Into Offset of Temp Vector bytecode."
]

{ #category : #opcodes }
SoAbstractScanner >> storeIntoTemporaryVariable: offset [ 
	<script>
	"Store Top Of Stack Into Temporary Variable Of Method bytecode."

]

{ #category : #opcodes }
SoAbstractScanner >> trap [
	<script>
	"send the class trap message to the current context."

]

{ #category : #opcodes }
SoAbstractScanner >> trapIfNotInstanceOf: behaviorOrArrayOfBehavior [ 
	<script>
	"If the top of stack is not an instance of either the argument, or, if the
	argument is an Array,
	any of the elements of the argument, send the class trap message
	to the current context."

]

{ #category : #opcodes }
SoAbstractScanner >> unusedBytecode [
	<script>
		"an unused bytecode is encountered"
]
