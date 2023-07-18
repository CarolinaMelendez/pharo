Class {
	#name : #DTCoverageCollector,
	#superclass : #CoverageCollector,
	#category : #'Coverage-Base'
}

{ #category : #'as yet unclassified' }
DTCoverageCollector >> allNodesCovered: aMethod [
	|coveredMethod |
	coveredMethod := true.
   aMethod ast nodesDo: [ :node | node isSequence 
	                              ifTrue: [ node hasBeenExecuted 
						                       ifFalse: [ ^ false. ]] ].
	^ coveredMethod
]

{ #category : #basic }
DTCoverageCollector >> basicCollectResult [

	"Collect the results but does not reset the annotations."

	| res |
	res := DTCoverageResult new.
	res collector: self.
	res methods: (methods select: [ :m | m ast hasBeenExecuted ]).
	res nodes: IdentitySet new.
	nodes do: [ :node | 
			node hasBeenExecuted ifTrue: [ res nodes add: node ] ].

	res coveredMethods: (methods select: [ :meth | meth ast hasBeenExecuted and: [ self allNodesCovered: meth ] ]).
	res partiallyCoveredMethods: (methods select: [ :meth | meth ast hasBeenExecuted and: [ (self allNodesCovered: meth) not ] ]).
	res uncoveredMethods: (methods reject: [ :meth | meth ast hasBeenExecuted ]).
	res assignCoverageProperty.
	^ res
]

{ #category : #'as yet unclassified' }
DTCoverageCollector >> collectResult [

	"Collect the results.
	This also remaps the methods and  NOT resets the annotations."

	| res |
	self remapMethods.
	res := self basicCollectResult.
	"self reset."
	^ res
]
