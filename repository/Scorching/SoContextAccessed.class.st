"
I am sent when trying to optimize a method that access a context. Currently, the optimizer does not optimize methods accessing contexts to avoid issues but it could theorically do so. 
"
Class {
	#name : #SoContextAccessed,
	#superclass : #Error,
	#category : #'Scorching-Error'
}
