Class {
	#name : #PEDRawDataFileExtractorScript,
	#superclass : #Object,
	#category : #'PharoEvolutionDataset-Script'
}

{ #category : #accessing }
PEDRawDataFileExtractorScript class >> script [
"This is the script to be used in order to extract data from a Pharo image of any version and write it into a text file with a specific format."
|outputFile separatorChar separateBlock|
outputFile := FileLocator documents / 'p.data'.
separatorChar := $!.
separateBlock := [ :stream |
	stream nextPut: Character lf.
	80 timesRepeat: [ stream nextPut: separatorChar ].
	stream nextPut: Character lf. ].
outputFile writeStreamDo: [ :s |
	Smalltalk allClassesAndTraits do: [ :c |
		"Instance-side"
		s
			nextPutAll: c printString;
			nextPut: separatorChar;
			nextPutAll: c superclass printString;
			nextPut: separatorChar;
			nextPutAll: c instVarNames printString;
			nextPut: separatorChar;
			nextPutAll: c classVarNames printString;
			nextPut: separatorChar;
			nextPutAll: c category.
		separateBlock value: s.
		c methods size > 0
			ifTrue: [
				c methods 
					do: [ :m | 
						s
							nextPutAll: m protocol; nextPut: Character lf;
							nextPutAll: m sourceCode ]
					separatedBy: [ separateBlock value: s ] ].
		separateBlock value: s.
		"Class-side"
		s
			nextPutAll: c class printString;
			nextPut: separatorChar;
			nextPutAll: c class superclass printString;
			nextPut: separatorChar;
			nextPutAll: c class instVarNames printString;
			nextPut: separatorChar;
			nextPutAll: c class classVarNames printString;
			nextPut: separatorChar;
			nextPutAll: c category.
		separateBlock value: s.
		c class methods size > 0
			ifTrue: [
				c class methods 
					do: [ :m | 
						s
							nextPutAll: m protocol; nextPut: Character lf;
							nextPutAll: m sourceCode ]
					separatedBy: [ separateBlock value: s ] ] ] 
	separatedBy: [ separateBlock value: s ] ].
]
