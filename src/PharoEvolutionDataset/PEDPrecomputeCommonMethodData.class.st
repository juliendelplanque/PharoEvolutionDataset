Class {
	#name : #PEDPrecomputeCommonMethodData,
	#superclass : #PEDPrecomputer,
	#category : #'PharoEvolutionDataset-DataEnhancer'
}

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

{ #category : #metrics }
PEDPrecomputeCommonMethodData >> linesOfCodeIn: sourceCode [
	| lines |
	lines := 0.
	sourceCode lineIndicesDo: [:start :endWithoutDelimiters :end |
		endWithoutDelimiters > start ifTrue: [lines := lines+1] ].
	^ lines
]
