Class {
	#name : #OpenAIExamples,
	#superclass : #Object,
	#category : #'Open-AI-Examples'
}

{ #category : #accessing }
OpenAIExamples >> answers [

	^ OpenAITasks new answer: 'where is France?'
		  against: #( 'France is in Europe' 'Canada is in America' 'Japan is in Asia' )
		  given: ( Array with: #( 'how long is this car' '2 meters' ) )
		  within: 'this car is 2 meters long'
]

{ #category : #accessing }
OpenAIExamples >> answersFromFile [

	| id |

	id := self idForFileNamed: 'inputs/answers-example.jsonl' intendedFor: 'answers'.

	^ OpenAITasks new answer: 'where is France?'
		  returningUpTo: 5
		  from: id
		  given: ( Array with: #( 'how long is this car' '2 meters' ) )
		  within: 'this car is 2 meters long'
]

{ #category : #accessing }
OpenAIExamples >> classifications [

	^ OpenAITasks new classify: 'the weather is great'
		  asOneOf: #( 'happy' 'sad' )
		  given: ( Array with: #( 'the grass is green' 'happy' )
				    with: #( 'el cielo está lindo' 'happy' )
				    with: #( 'the soil is rotten' 'sad' ) )
]

{ #category : #accessing }
OpenAIExamples >> classificationsFromFile [

	| id |

	id := self idForFileNamed: 'inputs/classification-example.jsonl' intendedFor: 'classifications'.

	^ OpenAITasks new classify: 'movie is very good'
		  asOneOf: #( 'Positive' 'Negative' )
		  lookingForBest: 2
		  examplesIn: id
]

{ #category : #accessing }
OpenAIExamples >> classificationsFromFileWithoutLabels [

	| id |

	id := self idForFileNamed: 'inputs/classification-example.jsonl' intendedFor: 'classifications'.

	^ OpenAITasks new classify: 'movie is very good' lookingForBest: 2 examplesIn: id
]

{ #category : #accessing }
OpenAIExamples >> completions [

	^ OpenAITasks new complete: 'This is the day'
]

{ #category : #accessing }
OpenAIExamples >> deleteAllFiles [

	"ONLY FOR CLEANUP PURPOSES
	| files |
	files := OpenAITasks new listFiles.
	files data collect: [ :file | OpenAITasks new removeFileIdentifiedBy: file id ]
	"

	
]

{ #category : #accessing }
OpenAIExamples >> downloadAndRemoveFile [

	| id |

	id := self idForFileNamed: 'inputs/file-that-will-be-deleted.jsonl' intendedFor: 'fine-tune'
	 "All attempts at downloading give the same 400 error:
	Not allowed to download files of purpose: <THE PURPOSE SENT>
	contents := OpenAITasks new retrieveContentsUnder: id.".
	^ OpenAITasks new removeFileIdentifiedBy: id
]

{ #category : #accessing }
OpenAIExamples >> files [

	| files |

	files := OpenAITasks new listFiles.
	^ files data
		  ifEmpty: [ 
			  OpenAITasks new
				  upload: 'inputs/answers-example.jsonl' asFileReference intendedFor: 'answers';
				  upload: 'inputs/classification-example.jsonl' asFileReference intendedFor: 'classifications';
				  upload: 'inputs/fine-tune-example.jsonl' asFileReference intendedFor: 'fine-tune';
				  upload: 'inputs/search-example.jsonl' asFileReference intendedFor: 'search'
			  ]
		  ifNotEmpty: [ files ]
]

{ #category : #'private - accessing' }
OpenAIExamples >> idForFileNamed: aName intendedFor: aPurpose [

	| fileName files tasks |

	fileName := aName asFileReference basename.
	tasks := OpenAITasks new.
	files := tasks listFiles.
	^ files data
		  detect: [ :file | file filename = fileName ]
		  ifFound: [ :file | file id ]
		  ifNone: [ tasks idForProcessed: aName asFileReference intendedFor: aPurpose waiting: 4 seconds ]
]

{ #category : #accessing }
OpenAIExamples >> search [

	^ OpenAITasks new search: 'bulldog' against: #( cat dog car building vehicle person )
]

{ #category : #accessing }
OpenAIExamples >> searchFromFile [

	| id |

	id := self idForFileNamed: 'inputs/search-example.jsonl' intendedFor: 'search'.

	^ OpenAITasks new
		  search: 'the dog feels happy in a building where some person lives'
		  returningUpTo: 5
		  from: id
		  includeMetadata: false
]
