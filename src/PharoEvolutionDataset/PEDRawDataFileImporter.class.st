Class {
	#name : #PEDRawDataFileImporter,
	#superclass : #Object,
	#instVars : [
		'databaseConnection',
		'dataFile',
		'lastClassInsertedId',
		'pharoVersionId'
	],
	#category : #'PharoEvolutionDataset-Importer'
}

{ #category : #importing }
PEDRawDataFileImporter class >> import: aRawDataFileReference pharoVersion: versionString in: connection [
	connection execute: 'INSERT INTO pharo_version(version) VALUES (?);' value: versionString.

	PEDRawDataFileImporter new
		pharoVersionId: connection lastInsertedId;
		dataFile: aRawDataFileReference;
		databaseConnection: connection;
		importInDatabase.
]

{ #category : #accessing }
PEDRawDataFileImporter >> dataFile [
	^ dataFile
]

{ #category : #accessing }
PEDRawDataFileImporter >> dataFile: anObject [
	dataFile := anObject
]

{ #category : #'instance creation' }
PEDRawDataFileImporter >> dataSeparator [
	^ $!
]

{ #category : #accessing }
PEDRawDataFileImporter >> databaseConnection [
	^ databaseConnection
]

{ #category : #accessing }
PEDRawDataFileImporter >> databaseConnection: anObject [
	databaseConnection := anObject
]

{ #category : #importing }
PEDRawDataFileImporter >> importClassDataFromStream: stream [
	| line splitted |
	line := stream upTo: self newLineSeparator.
	splitted := line splitOn: self dataSeparator.
	self databaseConnection execute: self insertClassQuery value: splitted first value: splitted second value: splitted fifth value: self pharoVersionId.
	lastClassInsertedId := self databaseConnection lastInsertedId.
	((self class compiler evaluate: splitted third) ifNil: [ #() ]) do: [ :instvarName |
		self databaseConnection execute: self insertInstanceVariableQuery value: splitted first value: lastClassInsertedId ].
	((self class compiler evaluate: splitted fourth) ifNil: [ #() ]) do: [ :instvarName |
		self databaseConnection execute: self insertClassVariableQuery value: splitted first value: lastClassInsertedId ]
]

{ #category : #importing }
PEDRawDataFileImporter >> importInDatabase [
	self databaseConnection ensureOpen.
	self dataFile readStreamDo: [ :s |
		|stream|
		stream :=  ZnPositionableReadStream on: s.
		stream sizeBuffer: 10e6.
		[ stream atEnd ]
			whileFalse: [ 
				|lastPosition lineBag exclamationMarksCount crCount|
				lastPosition := stream position.
				lineBag := (stream upTo: self newLineSeparator) asBag.
				exclamationMarksCount := lineBag occurrencesOf: self dataSeparator.
				crCount := lineBag occurrencesOf: Character cr.
				stream position: lastPosition.
				(exclamationMarksCount = 4 and: [ crCount = 0 ])
					ifTrue: [ self importClassDataFromStream: stream ]
					ifFalse: [ 
						(exclamationMarksCount = 80 and: [ crCount = 0 ])
							ifTrue: [ self skipSeparatorsLineFromStream: stream ]
							ifFalse: [ self importMethodDataFromStream: stream ] ] ] ]
]

{ #category : #importing }
PEDRawDataFileImporter >> importMethodDataFromStream: stream [
	| methodProtocol methodCode |
	methodProtocol := stream upTo: self newLineSeparator.
	methodProtocol = '' ifTrue: [ ^ self ].
	methodCode := stream upTo: self newLineSeparator.
	[ stream peek = self dataSeparator or: [ stream atEnd ] ]
		whileFalse: [ methodCode := methodCode , (stream upTo: self newLineSeparator) ].
	self databaseConnection execute: self insertMethodQuery value: methodCode value: methodProtocol value: lastClassInsertedId.
]

{ #category : #queries }
PEDRawDataFileImporter >> insertClassQuery [
	^ 'INSERT INTO class(name, super, category, pharo_version_id) VALUES (?, ?, ?, ?);'
]

{ #category : #queries }
PEDRawDataFileImporter >> insertClassVariableQuery [
	^ 'INSERT INTO class_variable(name, class_id) VALUES (?, ?);'
]

{ #category : #queries }
PEDRawDataFileImporter >> insertInstanceVariableQuery [
	^ 'INSERT INTO instance_variable(name, class_id) VALUES (?, ?);'
]

{ #category : #queries }
PEDRawDataFileImporter >> insertMethodQuery [
	^ 'INSERT INTO method(source_code, protocol, class_id) VALUES (?, ?, ?);'
]

{ #category : #'instance creation' }
PEDRawDataFileImporter >> newLineSeparator [
	^ Character lf
]

{ #category : #accessing }
PEDRawDataFileImporter >> pharoVersionId [
	^ pharoVersionId
]

{ #category : #accessing }
PEDRawDataFileImporter >> pharoVersionId: anObject [
	pharoVersionId := anObject
]

{ #category : #importing }
PEDRawDataFileImporter >> separatorsLineSize [
	^ 81
]

{ #category : #importing }
PEDRawDataFileImporter >> skipSeparatorsLineFromStream: stream [
	stream skip: self separatorsLineSize
]
