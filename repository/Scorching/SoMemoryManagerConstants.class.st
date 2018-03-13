"
I hold constants relative to the memory representation of objects.

"
Class {
	#name : #SoMemoryManagerConstants,
	#superclass : #SharedPool,
	#classVars : [
		'ContextClass',
		'Forwarder',
		'MaxArraySize',
		'MaxByteArraySize',
		'MaxBytesToGuarantee',
		'NoStoreCheckTypes'
	],
	#category : #'Scorching-Constants'
}

{ #category : #initialize }
SoMemoryManagerConstants class >> initialize [

	"If a value of one of this type is stored into an object, the store does not require a store check"
	NoStoreCheckTypes := { True . False . UndefinedObject . SmallInteger . Character . SmallFloat64 }.
	"Used to abstract over MethodContext/Context"
	ContextClass := Context.
	"Approx. In my computer it's - 15. We just it to be far enough from maxVal."
	MaxArraySize := SmallInteger maxVal // 4 - 1. 
	"Approx. In my computer it's - 15. We could revert to -1 but it's very close o maxVal..."
	MaxByteArraySize := SmallInteger maxVal - 9.
	"Maximum number of bytes the optimized method can ask the VM to guarantee on Eden"
	MaxBytesToGuarantee := 8000.  
	"FakeForwarderClass, object of size more than 3 words with hash 8"
	Forwarder := 'forwarderClassShouldBeAtLeast3Words' 
		tryPrimitive: 161 withArgs: #(8);
		yourself.  
]
