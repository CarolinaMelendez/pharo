"
I represent a sequence of refactorings that are executed one after the others.
I will fail on the first one that fails. 
"
Class {
	#name : #RBCompositeRefactoring,
	#superclass : #RBRefactoring,
	#instVars : [
		'refactorings'
	],
	#category : #'Refactoring-Core-Refactorings'
}

{ #category : #preconditions }
RBCompositeRefactoring >> applicabilityPreconditions [

	^ RBCondition true 
]

{ #category : #preconditions }
RBCompositeRefactoring >> breakingChangePreconditions [ 

	^ RBCondition true 
]

{ #category : #preconditions }
RBCompositeRefactoring >> generateChanges [
	
	self applicabilityPreconditions check ifFalse: [
		^ RBApplicabilityChecksFailedError signal:
			  self applicabilityPreconditions errorString ].
	self breakingChangePreconditions check ifFalse: [
		RBBreakingChangeChecksFailedWarning signal:
			self breakingChangePreconditions errorString ].

	self privateTransform.
	^ self changes
]

{ #category : #preconditions }
RBCompositeRefactoring >> preconditions [

	^ self applicabilityPreconditions & self breakingChangePreconditions 
]

{ #category : #transforming }
RBCompositeRefactoring >> privateTransform [

	refactorings do: [ :each | each generateChanges ]
]

{ #category : #accessing }
RBCompositeRefactoring >> refactorings [

	^ refactorings
]

{ #category : #accessing }
RBCompositeRefactoring >> refactorings: aCollection [

	refactorings := aCollection
]
