Extension { #name : #RPackage }

{ #category : #'*Calypso-SystemQueries' }
RPackage class >> convertToCalypsoBrowserItem: aPackage [

	^ClyBrowserItem named: aPackage name with: aPackage
]

{ #category : #'*Calypso-SystemQueries' }
RPackage class >> decorateBrowserItem: aBrowserItem by: anEnvironmentPlugin [
	^ anEnvironmentPlugin
		decorateBrowserItem: aBrowserItem
		ofPackage: aBrowserItem actualObject
]

{ #category : #'*Calypso-SystemQueries' }
RPackage class >> defaultSortFunctionForCalypso [
	^ClySortByNameFunction ascending
]

{ #category : #'*Calypso-SystemQueries' }
RPackage >> definesOverridesOf: aMethod [

	(self definesOverridesOf: aMethod in: definedSelectors) ifTrue: [ ^ true ].
	(self definesOverridesOf: aMethod in: extensionSelectors) ifTrue: [ ^ true ].

	^ false
]

{ #category : #'*Calypso-SystemQueries' }
RPackage >> definesOverridesOf: aMethod in: classAndSelectors [

	| methodClass selector |
	methodClass := aMethod origin.
	selector := aMethod selector.

	classAndSelectors keysAndValuesDo: [ :class :selectors | ((selectors includes: selector) and: [ class inheritsFrom: methodClass ]) ifTrue: [ ^ true ] ].
	^ false
]

{ #category : #'*Calypso-SystemQueries' }
RPackage >> importClasses: classCollection [
	classCollection do: [ :each | self addClass: each ]
]

{ #category : #'*Calypso-SystemQueries' }
RPackage >> isAboutPackage: aPackage [

	^self == aPackage
]

{ #category : #'*Calypso-SystemQueries' }
RPackage class >> itemsSortOrderForCalypso [
	^10
]

{ #category : #'*Calypso-SystemQueries' }
RPackage class >> prepareClassGroupQueryFrom: aPackage in: aNavigationEnvironment [
	^ ClyAllClassGroupsQuery
		sortedFrom: (ClyPackageScope of: aPackage in: aNavigationEnvironment)
]

{ #category : #'*Calypso-SystemQueries' }
RPackage class >> prepareClassQueriesFrom: packages in: aNavigationEnvironment [
	^{
		ClyAllClassesQuery from: ClyPackageScope ofAll: packages in: aNavigationEnvironment.
		ClyAllClassesQuery from: ClyPackageExtensionScope ofAll: packages in: aNavigationEnvironment
	}
]

{ #category : #'*Calypso-SystemQueries' }
RPackage >> tagsForClasses [
	"Any class could be tagged for user purpose.
	Now we implement it on top of RPackageTag"

	^self classTags reject: [:each | each isRoot] thenCollect: [:each | each name]
]
