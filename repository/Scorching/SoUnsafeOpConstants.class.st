"
I hold all the constants relative to unchecked primitives. The specifications for these unsafe operations are in the SistaV1 bytecode set class comment.
"
Class {
	#name : #SoUnsafeOpConstants,
	#superclass : #SharedPool,
	#classVars : [
		'UByteAt',
		'UByteAtPut',
		'UByteSize',
		'UCharacterAsInteger',
		'UClass',
		'UIdentityHash',
		'UPointerAt',
		'UPointerAtPut',
		'UPointerNew',
		'UPointerSize',
		'USmiAdd',
		'USmiBitAnd',
		'USmiBitOr',
		'USmiBitShiftLeft',
		'USmiBitShiftRight',
		'USmiBitXor',
		'USmiDiv',
		'USmiEqual',
		'USmiGreater',
		'USmiGreaterOrEqual',
		'USmiLess',
		'USmiLessOrEqual',
		'USmiMod',
		'USmiMod2',
		'USmiMul',
		'USmiNotEqual',
		'USmiQuo',
		'USmiSub',
		'UVarByteNew',
		'UVarPointerNew'
	],
	#category : #'Scorching-Constants'
}

{ #category : #initialize }
SoUnsafeOpConstants class >> initialize [
	UClass := 1000.
	UPointerSize := 1001.
	"UPointerSize := 1002. Same but with inst var"
	UByteSize := 1003.
	UPointerNew := 1011. 
	UIdentityHash := 1020.
	UCharacterAsInteger := 1030.
	
	USmiAdd := 2000.
	USmiSub := 2001.
	USmiMul := 2002.
	USmiDiv := 2003.
	USmiMod := 2004.
	USmiMod2 := 2005.
	USmiQuo := 2006.
	USmiBitAnd := 2016.
	USmiBitOr := 2017.
	USmiBitXor := 2018.
	USmiBitShiftLeft := 2019.
	USmiBitShiftRight := 2020.
	USmiGreater := 2032.
	USmiLess := 2033.
	USmiGreaterOrEqual := 2034.
	USmiLessOrEqual := 2035.
	USmiEqual := 2036.
	USmiNotEqual := 2037.
	
	UVarPointerNew := 2011.
	UVarByteNew := 2012.
	UPointerAt := 2064.
	UByteAt := 2065.
	
	UPointerAtPut := 3000.
	UByteAtPut := 3001.
]
