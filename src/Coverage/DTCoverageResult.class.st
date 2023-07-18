Class {
	#name : #DTCoverageResult,
	#superclass : #CoverageResult,
	#instVars : [
		'coveredMethods',
		'partiallyCoveredMethods',
		'uncoveredMethods'
	],
	#category : #'Coverage-Base'
}

{ #category : #accessing }
DTCoverageResult >> assignCoverage: aPorcentage toMethod: aMethod [
   aMethod ast propertyAt: #statementCoverage put: (aPorcentage asString, '%')
]

{ #category : #'as yet unclassified' }
DTCoverageResult >> assignCoverageProperty [
   coveredMethods do: [ :method | self assignCoverage: 100 toMethod: method ].
	uncoveredMethods do: [ :method | self assignCoverage: 0 toMethod: method ].
	partiallyCoveredMethods do: [ :method |  self assignCoverage: (self calculateStatementCoverageOfMethod: method) toMethod: method ]



]

{ #category : #accessing }
DTCoverageResult >> calculateStatementCoverageOfMethod: aMethod [
"taking in account only RBSequenceNode"
	| coverage nroStatement nroStatementExecuted |
	nroStatement := 0.
	nroStatementExecuted := 0 .
	aMethod ast nodesDo: [ :node |  node isSequence 
		                            ifTrue:[ nroStatement:= nroStatement + 1. 
			                                  node hasBeenExecuted  ifTrue:[ nroStatementExecuted:= nroStatementExecuted + 1 ]]].
	
	coverage :=  (nroStatementExecuted / nroStatement) * 100 printShowingDecimalPlaces: 2.
   
	^ coverage
]

{ #category : #accessing }
DTCoverageResult >> coveredMethods [
	^ coveredMethods
]

{ #category : #accessing }
DTCoverageResult >> coveredMethods: anObject [

	coveredMethods := anObject
]

{ #category : #accessing }
DTCoverageResult >> partiallyCoveredMethods [
	^ partiallyCoveredMethods
]

{ #category : #accessing }
DTCoverageResult >> partiallyCoveredMethods: anObject [

	partiallyCoveredMethods := anObject
]

{ #category : #accessing }
DTCoverageResult >> uncoveredMethods [
	^ uncoveredMethods
]

{ #category : #accessing }
DTCoverageResult >> uncoveredMethods: anObject [

	uncoveredMethods := anObject
]
