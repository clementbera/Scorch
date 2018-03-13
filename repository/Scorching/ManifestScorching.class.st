"
I store metadata for this package. These meta data are used by other tools such as the SmalllintManifestChecker and the critics Browser
"
Class {
	#name : #ManifestScorching,
	#superclass : #PackageManifest,
	#category : #Scorching
}

{ #category : #'code-critics' }
ManifestScorching class >> ruleRBUsesAddRuleV1FalsePositive [
	^ #(#(#(#RGMethodDefinition #(#SoEscapeOptimisation #traverseObjectWrite: #false)) #'2018-01-13T19:59:03.503709+01:00') )
]
