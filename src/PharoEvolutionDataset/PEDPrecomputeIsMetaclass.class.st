Class {
	#name : #PEDPrecomputeIsMetaclass,
	#superclass : #PEDPrecomputer,
	#category : #'PharoEvolutionDataset-DataEnhancer'
}

{ #category : #adding }
PEDPrecomputeIsMetaclass >> addNewColumnsToMethodTable [
	self connection execute: 'ALTER TABLE class ADD COLUMN is_metaclass BOOLEAN;'.
]

{ #category : #adding }
PEDPrecomputeIsMetaclass >> addPrecomputedData [
	| cursor |
	cursor := connection execute: 'SELECT id, name FROM class;'.
	[ cursor hasNext ]
		whileTrue: [ |currentRow|
			currentRow := cursor next.
			connection execute: 'UPDATE class SET is_metaclass = ? WHERE id = ?;' value: ((currentRow atColumnNamed: 'name') endsWith: ' class') value: (currentRow atColumnNamed: 'id') ]
]
