"
A MCTraitDefinition represents a trait.
"
Class {
	#name : #MCTraitDefinition,
	#superclass : #MCClassDefinition,
	#category : #'Monticello-Modeling'
}

{ #category : #deprecated }
MCTraitDefinition class >> name: classNameString traitComposition: traitCompositionString category: categoryString instVarNames: ivarArray classInstVarNames: civarArray classTraitComposition: classTraitCompositionString comment: commentString commentStamp: commentStamp [
	"Do not use this method! This method will be deprecated once Tonel will not use it anymore."

	^ (self named: classNameString)
		  traitComposition: traitCompositionString;
		  category: categoryString;
		  instVarNames: ivarArray;
		  classInstVarNames: civarArray;
		  comment: commentString;
		  commentStamp: commentStamp;
		  classTraitComposition: classTraitCompositionString;
		  yourself
]

{ #category : #comparing }
MCTraitDefinition >> = aDefinition [

	self flag: #traits. "Ugly we harcoded the super superclass method.  We will have to refactor the definition hierarchy"

	^ (aDefinition isKindOf: MCDefinition) and: [
		  (self isRevisionOf: aDefinition) and: [
			  self traitCompositionString = aDefinition traitCompositionString and: [
				  self classTraitCompositionString = aDefinition classTraitCompositionString and: [
					  self category = aDefinition category and: [
						  self slotDefinitionString = aDefinition slotDefinitionString and: [
							  self classInstVarNames = aDefinition classInstVarNames and: [ comment = aDefinition comment ] ] ] ] ] ] ]
]

{ #category : #visiting }
MCTraitDefinition >> accept: aVisitor [
	^ aVisitor visitTraitDefinition: self

]

{ #category : #printing }
MCTraitDefinition >> classSlotDefinitionString [

	^ self needsSlotClassDefinition 
		ifTrue: [ self classInstanceVariables asString ]
		ifFalse: [ 
			String streamContents: [ :stream |
				stream nextPutAll: '{ '.
				self classInstanceVariables 
					do: [ :each | stream print: each name ]
					separatedBy: [ stream nextPutAll: ' . ' ].
				stream nextPutAll: ' }']]
]

{ #category : #installing }
MCTraitDefinition >> createClass [

	| trait |
	trait := self class classInstaller make: [ :aBuilder |
		         aBuilder
			         name: name;
			         traitComposition: (Smalltalk compiler evaluate: self traitCompositionString);
			         slots: self instanceVariables;
			         package: self category;
			         beTrait ].


	trait ifNotNil: [
		trait comment: comment stamp: commentStamp.
		self classInstanceVariables ifNotEmpty: [ :vars | trait classSide slots: vars ] ].
	^ trait
]

{ #category : #testing }
MCTraitDefinition >> hasClassInstanceVariables [
	^ false


]

{ #category : #comparing }
MCTraitDefinition >> hash [

	^ (name hash bitXor: traitComposition hash) bitXor: self category hash
]

{ #category : #printing }
MCTraitDefinition >> printClassDefinitionOn: stream [

	^ self printMetaDefinitionOn: stream
]

{ #category : #printing }
MCTraitDefinition >> printDefinitionOn: stream [
	stream nextPutAll: 'Trait named: #', self className;
		 cr;
		 tab;
		 nextPutAll: 'uses: ';
		 nextPutAll: self traitCompositionString;
		 cr.

	self instanceVariablesString isEmpty ifFalse: [
			stream 
				tab;
				nextPutAll: 'instanceVariableNames: ';
				nextPut: $';
		 		nextPutAll: self instanceVariablesString;
				nextPut: $';
				cr ].
		
	stream
		 tab;
		 nextPutAll: 'package: ';
		 store: self category asString

]

{ #category : #comparing }
MCTraitDefinition >> requirements [
	"Assuming that traits in a composition can be identified by
	testing for the first character beeing an uppercase character
	(and thus not a special character such as {, # etc.)"

	self hasTraitComposition
		ifFalse: [ ^ #() ].

	^ (((RBParser parseExpression: self traitCompositionString)
		allChildren select: [ :e | e isVariable ])
		collect: [ :e | e name ]
		as: Set) asArray
]

{ #category : #printing }
MCTraitDefinition >> slotDefinitionString [

	variables ifNil: [ ^ '{ }' ].

	^ self needsSlotClassDefinition 
		ifTrue: [ self instanceVariables asString ]
		ifFalse: [ 
			String streamContents: [ :stream |
				stream nextPutAll: '{ '.
				self instanceVariables 
					do: [ :each | stream print: each name ]
					separatedBy: [ stream nextPutAll: ' . ' ].
				stream nextPutAll: ' }']]
]
