Class {
	#name : #DTCoveragePluginPresenter,
	#superclass : #DTDefaultPluginPresenter,
	#instVars : [
		'sourceCodePanel',
		'coveredNodes',
		'uncoveredNodes',
		'yellowNodes'
	],
	#category : #'DrTests-Spec'
}

{ #category : #initialization }
DTCoveragePluginPresenter >> connectPresenters [

	super connectPresenters.

	self resultViewsDropList whenSelectedItemChangedDo: [
		:resultTreeViewOrNil |
		resultTreeViewOrNil ifNotNil: [
			resultsList roots:
				(resultTreeViewOrNil resultTreeFor: drTests pluginResult)
					subResults ] ].

   resultsList whenSelectionChangedDo: [ :selection |
												  (selection selectedItem isKindOf: DTTestLeafNode   "DTTestCoverageLeafNode" )
                                       ifTrue: [ selection selectedItem ifNotNil:[ :item | self updateSourceCodePanel: item content.] ] ] .

]

{ #category : #layout }
DTCoveragePluginPresenter >> defaultLayout [

	^ SpBoxLayout newTopToBottom
		add: (SpPanedLayout newLeftToRight
			add: (SpPanedLayout newLeftToRight
		  		add: packagesList;
				add: itemsList;
				yourself);
			add: (SpBoxLayout newTopToBottom
				spacing: 5;
				add: resultViewsDropList expand: false;
				add: resultLabel expand: false;
				add: resultsList;
				add: sourceCodePanel ;
				yourself);
		  yourself);
		add: startButton expand: false;
		yourself
]

{ #category : #initialization }
DTCoveragePluginPresenter >> defineColorCoverage: aMethod [
  aMethod ast nodesDo: [:node| node  isSequence 
	                    ifTrue:[ node hasBeenExecuted  
		                          ifTrue: [ coveredNodes add: node ]    
				                    ifFalse: [ uncoveredNodes add: node ]].
			
			                       node isMessage 
			               ifTrue:[ self defineColorMessageNode: node] ]

]

{ #category : #'as yet unclassified' }
DTCoveragePluginPresenter >> defineColorMessageNode: aRBMessageNode [
| blockNodes |
"handle arguments"
blockNodes := aRBMessageNode arguments select: [:element | element isKindOf: RBBlockNode].
blockNodes isNotEmpty ifTrue: [
(blockNodes allSatisfy: [:arg |  "self hasAllRBSequenceNodeExecuted:  " arg body hasBeenExecuted ])
    ifFalse: [  | nodeInterval nodeSubIntervals resultInterval|
	              nodeSubIntervals := OrderedCollection new .
	              nodeInterval := aRBMessageNode sourceInterval.
	              aRBMessageNode arguments do: [:node | nodeSubIntervals add:node sourceInterval   ].
	              resultInterval :=  self getSubIntervalsOf: nodeInterval from: nodeSubIntervals.
	              yellowNodes addAll: resultInterval ]].
]

{ #category : #'as yet unclassified' }
DTCoveragePluginPresenter >> getSubIntervalsOf: intervalNode from: subIntervalNodes [
| resultArray previousEnd |
" Example
intervalNode := 69 to: 378.
subIntervalNodes := {(92 to: 121). (132 to: 378)}."

resultArray := OrderedCollection new.
previousEnd := intervalNode first - 2.
subIntervalNodes do: [ :subInterval |
    | start end |
    start := subInterval first.
    end := subInterval last.

    (start - previousEnd) > 1 ifTrue: [
        resultArray add: (previousEnd + 1 to: start - 1).
    ].
    previousEnd := end.
].

(previousEnd < intervalNode last) ifTrue: [
    resultArray add: (previousEnd + 1 to: intervalNode last).
].

resultArray := resultArray asOrderedCollection.

^ resultArray
]

{ #category : #initialization }
DTCoveragePluginPresenter >> initializeResultsTreeAndLabel [

	resultLabel := self newLabel label: 'Results:'.
	resultsList := self newTree.
	resultsList
		display: [ :node |node drTestsName ]; "Coverage porcentage"
		displayColor: [ :node | node displayColor ];
		children: [ :node | node subResults ];
		contextMenu: [
			(self rootCommandsGroup / 'Results tools') beRoot asMenuPresenter ].

	resultsList outputActivationPort
		transmitDo: [
			(DTResultBrowseCommand forSpecContext: self) execute ].
	sourceCodePanel := self instantiate: SpCodePresenter.
]

{ #category : #initialization }
DTCoveragePluginPresenter >> updateSourceCodePanel: compiledMethod [
| statementCoverage |
yellowNodes := OrderedCollection new.
uncoveredNodes:= OrderedCollection new.
coveredNodes:= OrderedCollection new.

statementCoverage := compiledMethod ast propertyAt: #statementCoverage .
statementCoverage = '0%' 
ifTrue: [ uncoveredNodes add: compiledMethod ast   ]
ifFalse: [ statementCoverage = '100%'
	        ifTrue: [coveredNodes add: compiledMethod ast    ]
	        ifFalse: [ self defineColorCoverage: compiledMethod]  ] .

sourceCodePanel beForMethod: compiledMethod.
sourceCodePanel text: compiledMethod sourceCode.

uncoveredNodes do: [:node |
    sourceCodePanel addTextSegmentDecoration: (SpTextPresenterDecorator forHighlight
        interval: (node sourceInterval first to: node sourceInterval last + 1);
		  highlightColor: (Color r: 0.98 g: 0.71 b: 0.71)
    )
].
yellowNodes do: [:interval |
    sourceCodePanel addTextSegmentDecoration: (SpTextPresenterDecorator forHighlight
        interval: (interval + 1);
		  highlightColor: (Color r: 0.98 g: 0.95 b: 0.71)
    )
].

coveredNodes do: [:node |
    sourceCodePanel addTextSegmentDecoration: (SpTextPresenterDecorator forHighlight
        interval: (node sourceInterval first to: node sourceInterval last + 1);
		  highlightColor: (Color r: 0.74 g: 0.98 b: 0.71)
    )
].

^ sourceCodePanel yourself.

]
