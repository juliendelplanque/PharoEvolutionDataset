Class {
	#name : #PEDPrecomputeCommonMethodData,
	#superclass : #Object,
	#instVars : [
		'connection'
	],
	#category : #'PharoEvolutionDataset-DataEnhancer'
}

{ #category : #'instance creation' }
PEDPrecomputeCommonMethodData class >> on: connection [
	^ self new
		connection: connection;
		yourself
]

{ #category : #'instance creation' }
PEDPrecomputeCommonMethodData class >> precomputeOn: connection [
	^ (self on: connection)
		precompute;
		yourself
]

{ #category : #'schema modification' }
PEDPrecomputeCommonMethodData >> addNewColumnsToMethodTable [
	self connection execute: 'ALTER TABLE method ADD COLUMN selector TEXT;'.
	self connection execute: 'ALTER TABLE method ADD COLUMN loc INTEGER;'.
]

{ #category : #adding }
PEDPrecomputeCommonMethodData >> addPrecomputedData [
	| cursor |
	cursor := connection execute: 'SELECT id, source_code FROM method;'.
	[ cursor hasNext ]
		whileTrue: [ |currentRow ast lines|
			currentRow := cursor next.
			ast := [ RBParser parseMethod: (currentRow atColumnNamed: 'source_code') ] on: SyntaxErrorNotification do: [ nil ].
			lines := self linesOfCodeIn: (currentRow atColumnNamed: 'source_code').
			connection execute: 'UPDATE method SET selector = ?, loc = ? WHERE id = ?;' value: (ast ifNotNil: #selector) value: lines value: (currentRow atColumnNamed: 'id') ]
]

{ #category : #accessing }
PEDPrecomputeCommonMethodData >> connection [
	^ connection
]

{ #category : #accessing }
PEDPrecomputeCommonMethodData >> connection: anObject [
	connection := anObject
]

{ #category : #metrics }
PEDPrecomputeCommonMethodData >> linesOfCodeIn: sourceCode [
	| lines |
	lines := 0.
	sourceCode lineIndicesDo: [:start :endWithoutDelimiters :end |
		endWithoutDelimiters > start ifTrue: [lines := lines+1] ].
	^ lines
]

{ #category : #precomputing }
PEDPrecomputeCommonMethodData >> precompute [
	self addNewColumnsToMethodTable.
	self addPrecomputedData
]
