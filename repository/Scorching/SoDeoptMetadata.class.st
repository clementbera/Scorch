"
I am able to deoptimize a compiled code and remap block closure outerContext.

Instance Variables
	blockOuters:		<Dict of pc -> marker>
	deoptPoints:		<pc -> deoptPointc>
	trapTripped:		<Smi> number of time guard failed
	unoptimizedMethod:<CompiledMethod>
	isCustomized:		<Boolean> true if the method is installed in a class that do not have this method originally.
	debugInfo: 			<Object> anything related to debugging one wants to put there
"
Class {
	#name : #SoDeoptMetadata,
	#superclass : #SoAbsDeopt,
	#instVars : [
		'deoptPoints',
		'blockOuters',
		'unoptimizedMethod',
		'trapTripped',
		'isCustomized',
		'debugInfo'
	],
	#category : #'Scorching-Deoptimization'
}

{ #category : #accessing }
SoDeoptMetadata >> blockOuters [
	<generated>
	^ blockOuters
]

{ #category : #accessing }
SoDeoptMetadata >> blockOuters: aValue [
	<generated>
	blockOuters := aValue
]

{ #category : #accessing }
SoDeoptMetadata >> blockOutersAt: compiledBlock code: code [
	^ blockOuters at: compiledBlock
]

{ #category : #accessing }
SoDeoptMetadata >> debugFailingDeoptPoint: pc code: code [
	| col |
			FileStream stdout
				<< 'Should deopt at 0-based pc: ' 
				<< (self indexFromPC: pc code: code) printString 
				<< '(was '
				<< pc printString 
				<< ') but have only deopt info for '.
			col := OrderedCollection new.
			deoptPoints array pairsDo: [:k : v |
				col add: k].
			col := col select: #notNil.
			col sort.
			col do: [ :c | FileStream stdout << c printString << ' ' ].
			FileStream stdout cr.
			(code at: code initialPC) = 217 
				ifTrue: [ 
					FileStream stdout 
						<< 'DISCARDED'
						<< code metadata debugInfo ]
				ifFalse: [
					FileStream stdout << code symbolic printString].
			self debugTermination
	
]

{ #category : #accessing }
SoDeoptMetadata >> debugInfo [
	<generated>
	^ debugInfo
]

{ #category : #accessing }
SoDeoptMetadata >> debugInfo: aValue [
	<generated>
	debugInfo := aValue
]

{ #category : #accessing }
SoDeoptMetadata >> debugTermination [ 
	| proc |
	"StandardFileStream stdout 
	<< ' Deopt fail, no scope at: '
	<< debugPC printString
	<< ' available Keys: '
	<< (scopes keys select: [ :each | 
		each between: debugPC - 20 and: debugPC + 20 ]) printString
	<< ' sent from: '
	<< thisContext home sender method selector
	<<  (thisContext home sender at: 1) printString
	<< ' terminating process.'."
	FileStream stdout << 'HARD TERMINATION'.
	'HARD TERMINATION' logCr.
	proc := Processor activeProcess.
	[proc terminate] forkAt: proc priority + 1
]

{ #category : #accessing }
SoDeoptMetadata >> deoptPointAt: pc code: code [
	^ deoptPoints 
		at: (self indexFromPC: pc code: code) 
		ifAbsent: [ nil "self debugFailingDeoptPoint: pc code: code" ].
	
]

{ #category : #accessing }
SoDeoptMetadata >> deoptPoints [
	<generated>
	^ deoptPoints
]

{ #category : #accessing }
SoDeoptMetadata >> deoptPoints: aValue [
	<generated>
	deoptPoints := aValue
]

{ #category : #accessing }
SoDeoptMetadata >> increaseTrapTripped [
	trapTripped := trapTripped + 1
]

{ #category : #accessing }
SoDeoptMetadata >> indexFromPC: pc code: code [
	^ pc - (code numLiterals + 1 * Smalltalk wordSize)
]

{ #category : #initialization }
SoDeoptMetadata >> initialize [

	super initialize.

	blockOuters := SoDeoptDictionary new.
	deoptPoints := SoDeoptDictionary new.
	trapTripped := 0.
]

{ #category : #accessing }
SoDeoptMetadata >> isCustomized [
	<generated>
	^ isCustomized
]

{ #category : #accessing }
SoDeoptMetadata >> isCustomized: aValue [
	<generated>
	isCustomized := aValue
]

{ #category : #accessing }
SoDeoptMetadata >> trapTripped [
	<generated>
	^ trapTripped
]

{ #category : #accessing }
SoDeoptMetadata >> trapTripped: aValue [
	<generated>
	trapTripped := aValue
]

{ #category : #accessing }
SoDeoptMetadata >> unoptimizedMethod [
	<generated>
	^ unoptimizedMethod
]

{ #category : #accessing }
SoDeoptMetadata >> unoptimizedMethod: aValue [
	<generated>
	unoptimizedMethod := aValue
]
