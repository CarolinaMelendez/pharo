Class {
	#name : #DTTestCoverageLeafNode,
	#superclass : #DTTestLeafNode,
	#category : #'DrTests-TestCoverage'
}

{ #category : #accessing }
DTTestCoverageLeafNode >> drTestsName [
   "Maybe here we can avoid show if the statementCoverage is 100 or 0"
   | statementCoverage |
	statementCoverage:= self content ast propertyAt: #statementCoverage ifAbsent: '--' .
	^ self content selector , '   (', statementCoverage , ')' .
]
