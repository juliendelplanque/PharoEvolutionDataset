Class {
	#name : #PEDDatabaseCreator,
	#superclass : #Object,
	#instVars : [
		'databaseConnection'
	],
	#category : #'PharoEvolutionDataset-Creator'
}

{ #category : #creating }
PEDDatabaseCreator class >> createOn: databaseConnection [
	^ (self on: databaseConnection) create
]

{ #category : #'instance creation' }
PEDDatabaseCreator class >> on: databaseConnection [
	^ self new
		databaseConnection: databaseConnection;
		yourself
]

{ #category : #creating }
PEDDatabaseCreator >> create [
	self databaseConnection ensureOpen.
	self
		createPharoVersionTable;
		createClassTable;
		createInstanceVariableTable;
		createClassVariableTable;
		createMethodTable
]

{ #category : #creating }
PEDDatabaseCreator >> createClassTable [
	self databaseConnection execute: 'CREATE TABLE class(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name TEXT NOT NULL,
	category TEXT NOT NULL,
	super REFERENCES class(id),
	pharo_version_id REFERENCES pharo_version(id)
);'.
]

{ #category : #creating }
PEDDatabaseCreator >> createClassVariableTable [
	self databaseConnection execute: 'CREATE TABLE class_variable(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name TEXT NOT NULL,
	class_id INTEGER REFERENCES class(id)
);'.
]

{ #category : #creating }
PEDDatabaseCreator >> createInstanceVariableTable [
	self databaseConnection execute: 'CREATE TABLE instance_variable(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	name TEXT NOT NULL,
	class_id INTEGER REFERENCES class(id)
);'.
]

{ #category : #creating }
PEDDatabaseCreator >> createMethodTable [
	self databaseConnection execute: 'CREATE TABLE method(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	source_code TEXT NOT NULL,
	class_id INTEGER REFERENCES class(id)
);'.
]

{ #category : #creating }
PEDDatabaseCreator >> createPharoVersionTable [
	self databaseConnection execute: 'CREATE TABLE pharo_version(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
	version TEXT NOT NULL
);'.
]

{ #category : #accessing }
PEDDatabaseCreator >> databaseConnection [
	^ databaseConnection
]

{ #category : #accessing }
PEDDatabaseCreator >> databaseConnection: anObject [
	databaseConnection := anObject
]
