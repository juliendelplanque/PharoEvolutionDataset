Class {
	#name : #PEDRawDataFileExtractorScript,
	#superclass : #Object,
	#category : #PharoEvolutionDataset
}

{ #category : #accessing }
PEDRawDataFileExtractorScript class >> script [
"This is the script to be used in order to extract data from a Pharo image of any version and write it into a text file with a specific format."
|outputFile separatorChar separateBlock|
outputFile := FileLocator desktop / 'p7.data'.
separatorChar := $!.
separateBlock := [ :stream |
	stream nextPut: Character lf.
	80 timesRepeat: [ stream nextPut: separatorChar ].
	stream nextPut: Character lf. ].
outputFile writeStreamDo: [ :s |
	Smalltalk allClassesAndTraits do: [ :c |
		s
			nextPutAll: c name;
			nextPut: separatorChar;
			nextPutAll: c instanceVariables printString;
			nextPut: separatorChar;
			nextPutAll: (c classVariables collect: #key) printString;
			nextPut: separatorChar;
			nextPutAll: c category.
		separateBlock value: s.
		c methods do: [ :m |
			s nextPutAll: m sourceCode. ] 
		separatedBy: [ separateBlock value: s ].
		c class methods do: [ :m |
			s nextPutAll: m sourceCode. ] 
		separatedBy: [ separateBlock value: s ] ] 
	separatedBy: [ separateBlock value: s ] ].


]
