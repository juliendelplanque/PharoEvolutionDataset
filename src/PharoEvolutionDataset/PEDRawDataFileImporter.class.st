Class {
	#name : #PEDRawDataFileImporter,
	#superclass : #Object,
	#instVars : [
		'databaseConnection',
		'dataFile',
		'lastClassInsertedId'
	],
	#category : #'PharoEvolutionDataset-Importer'
}

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
	self databaseConnection execute: self insertClassQuery value: splitted first value: splitted fourth.
	lastClassInsertedId := self databaseConnection lastInsertedId.
	((self class compiler evaluate: splitted second) ifNil: [ #() ]) do: [ :instvarName |
		self databaseConnection execute: self insertInstanceVariableQuery value: splitted first value: lastClassInsertedId ].
	((self class compiler evaluate: splitted third)  ifNil: [ #() ]) do: [ :instvarName |
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
				crCount := lineBag occurrencesOf: self newLineSeparator.
				stream position: lastPosition.
				(exclamationMarksCount = 3 and: [ crCount = 0 ])
					ifTrue: [ self importClassDataFromStream: stream ]
					ifFalse: [ 
						(exclamationMarksCount = 80 and: [ crCount = 0 ])
							ifTrue: [ self skipSeparatorsLineFromStream: stream ]
							ifFalse: [ self importMethodDataFromStream: stream ] ] ] ]
]

{ #category : #importing }
PEDRawDataFileImporter >> importMethodDataFromStream: stream [
	| methodCode |
	methodCode := stream upTo: self newLineSeparator.
	self databaseConnection execute: self insertMethodQuery value: methodCode value: lastClassInsertedId.
]

{ #category : #queries }
PEDRawDataFileImporter >> insertClassQuery [
	^ 'INSERT INTO class(name, category, pharo_version_id) VALUES (?, ?, ?);'
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
	^ 'INSERT INTO method(source_code, class_id) VALUES (?, ?);'
]

{ #category : #'instance creation' }
PEDRawDataFileImporter >> newLineSeparator [
	^ Character lf
]

{ #category : #importing }
PEDRawDataFileImporter >> separatorsLineSize [
	^ 81
]

{ #category : #importing }
PEDRawDataFileImporter >> skipSeparatorsLineFromStream: stream [
	stream skip: self separatorsLineSize
]
