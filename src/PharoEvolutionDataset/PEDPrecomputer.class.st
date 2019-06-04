Class {
	#name : #PEDPrecomputer,
	#superclass : #Object,
	#instVars : [
		'connection'
	],
	#category : #'PharoEvolutionDataset-DataEnhancer'
}

{ #category : #'instance creation' }
PEDPrecomputer class >> on: connection [
	^ self new
		connection: connection;
		yourself
]

{ #category : #'instance creation' }
PEDPrecomputer class >> precomputeOn: connection [
	^ (self on: connection)
		precompute;
		yourself
]

{ #category : #adding }
PEDPrecomputer >> addNewColumnsToMethodTable [
	self subclassResponsibility
]

{ #category : #adding }
PEDPrecomputer >> addPrecomputedData [
	self subclassResponsibility
]

{ #category : #accessing }
PEDPrecomputer >> connection [
	^ connection
]

{ #category : #accessing }
PEDPrecomputer >> connection: anObject [
	connection := anObject
]

{ #category : #precomputing }
PEDPrecomputer >> precompute [
	self addNewColumnsToMethodTable.
	self addPrecomputedData
]
