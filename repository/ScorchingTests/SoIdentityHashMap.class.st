"
I am a typical implementation of a HashMap. I should be used for caching. I am efficient and compact in memory.

WARNING: nil is not a valid key.

API:
#cacheAt: key computedValue: aBlock 	
#flushCache

Instance creation:
#new: size accuracy: iteration

Instance Variables
	accuracy:		<Integer> number of times I will try to fetch the value for a given key before computing the value from the computedValueBlock
	mask:		<Integer> hashMask to fetch the cache entry

Implementation:
For a key, I checked the entry at the key hash bitAnd a mask based on my size. If there's an entry with the correct key, I give the value, if there's no entry, I write the value, if there's an incorrect entry, I retry fetching the cached value with a different mask a number of times fixed in accuracy IV. If the cache is full for a hash and misses, I flush the entries for the hash and write down the new value at first entry.
"
Class {
	#name : #SoIdentityHashMap,
	#superclass : #Object,
	#type : #variable,
	#instVars : [
		'accuracy',
		'mask'
	],
	#category : #'ScorchingTests-StaticTypes'
}

{ #category : #'instance creation' }
SoIdentityHashMap class >> new [
	^ self new: 1024 accuracy: 3
]

{ #category : #'instance creation' }
SoIdentityHashMap class >> new: size [ 
	^ self new: size accuracy: 2
]

{ #category : #'instance creation' }
SoIdentityHashMap class >> new: size accuracy: iteration [	
	^ (super new: size * 2) initializeWithAccuracy: iteration 
]

{ #category : #public }
SoIdentityHashMap >> cacheAt: key valueToCompute: aBlock [ 	
	| keyHash index cachedKey |
	
	"basicIdentityHash seems to be the most efficient."
	keyHash := key identityHash.
	
	"fetch the cached value or compute it and write it down if there's a correct entry or a free entry."
	0 to: accuracy - 1 do: [ :i |
		index := self indexFor: keyHash attempt: i.
		(cachedKey := self at: index - 1) == key ifTrue: [ ^ self at: index ].
		cachedKey ifNil: [ 
			self at: index - 1 put: key.
			^ self at: index put: aBlock value ] ].
	
	"cache full for the hash. Flush the hash entries but the first one"
	1 to: accuracy - 1 do: [ :i |
		index := self indexFor: keyHash attempt: i.
		self at: index - 1 put: nil ].
	
	"Compute and write down the value for the first hash entry"
	index := self indexFor: keyHash attempt: 0.
	self at: index - 1 put: key.
	^ self at: index put: aBlock value.
	
]

{ #category : #public }
SoIdentityHashMap >> flushCache [
	1 to: self size by: 2 do: [ :i |
		self at: i put: nil ].
]

{ #category : #private }
SoIdentityHashMap >> indexFor: hash attempt: i [
	"index of the cached entry for the key hash and the number of the attempt to fetch the cached value"
	^ 2 * (((hash bitAnd: mask  << i) >> i) + 1)
]

{ #category : #initialize }
SoIdentityHashMap >> initializeWithAccuracy: iteration [
	| size |
	size := self size.
	size > 0 ifFalse: [ self error: 'HashMap should have at least 1 value.' ].
	accuracy := iteration.
	mask := (1 << ((size / 2) highBit - 1) - 1).
	mask + 1 = (size / 2) ifFalse: [ self error: 'HashMap should have a power of 2 as size' ].
	
]
