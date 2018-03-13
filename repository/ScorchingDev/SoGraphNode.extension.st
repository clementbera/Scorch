Extension { #name : #SoGraphNode }

{ #category : #'*ScorchingDev' }
SoGraphNode >> colors [
	^ { Color blue . Color red . Color green . Color brown . Color orange . Color black . Color yellow . Color pink . Color tan . Color lightGreen . Color lightBlue . Color lightRed . Color lightBrown . Color magenta . Color cyan . Color gray  }
]

{ #category : #'*ScorchingDev' }
SoGraphNode >> realColor [
	^ self colors at: (color ifNil: [ ^ nil ])
]
