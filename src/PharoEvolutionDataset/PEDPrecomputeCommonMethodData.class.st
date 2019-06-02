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
	self connection execute: 'ALTER TABLE method ADD COLUMN ast_dump TEXT;'.
]

{ #category : #adding }
PEDPrecomputeCommonMethodData >> addPrecomputedData [
	| cursor |
	cursor := connection execute: 'SELECT id, source_code FROM method;'.
	[ cursor hasNext ]
		whileTrue: [ |currentRow ast|
			currentRow := cursor next.
			ast := [ RBParser parseMethod: (currentRow atColumnNamed: 'source_code') ] on: SyntaxErrorNotification do: [ nil ].
			connection execute: 'UPDATE method SET selector = ?, ast_dump = ? WHERE id = ?;' value: (ast ifNotNil: #selector) value: (ast ifNotNil: #dump) value: (currentRow atColumnNamed: 'id') ]
]

{ #category : #accessing }
PEDPrecomputeCommonMethodData >> connection [
	^ connection
]

{ #category : #accessing }
PEDPrecomputeCommonMethodData >> connection: anObject [
	connection := anObject
]

{ #category : #precomputing }
PEDPrecomputeCommonMethodData >> precompute [
	self addNewColumnsToMethodTable.
	self addPrecomputedData
]
