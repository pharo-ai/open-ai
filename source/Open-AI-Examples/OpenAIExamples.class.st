Class {
	#name : #OpenAIExamples,
	#superclass : #Object,
	#category : #'Open-AI-Examples'
}

{ #category : #accessing }
OpenAIExamples >> answers [

	| response |

	response := self answersAPIClient
		            answer: 'where is France?'
		            against: #( 'France is in Europe' 'Canada is in America' 'Japan is in Asia' )
		            given: ( Array with: #( 'how long is this car' '2 meters' ) )
		            within: 'this car is 2 meters long'.

	^ self cleanDelimitersFrom: ( response at: 'answers' )
]

{ #category : #'private - accessing' }
OpenAIExamples >> answersAPIClient [

	| apiClient |

	apiClient := AnswersAPIClient
		             accessingAPIsWith: RESTfulAPIClient cachingOnLocalMemory
		             authenticatedWith: self apiKey.
	apiClient
		changeEngineTo: 'ada';
		changeSearchEngineTo: 'ada';
		stopAt: #( '\n' '<|endoftext|>' ).

	^ apiClient
]

{ #category : #'private - accessing' }
OpenAIExamples >> answersFileId [

	^ self idForFileNamed: 'open-ai/answers-example.jsonl' intendedFor: 'answers'
]

{ #category : #accessing }
OpenAIExamples >> answersFromFile [

	| id apiClient response |

	id := self answersFileId.

	apiClient := self answersAPIClient.
	apiClient returnUpTo: 5.

	response := apiClient
		            answer: 'where is France?'
		            querying: id
		            given: ( Array with: #( 'how long is this car' '2 meters' ) )
		            within: 'this car is 2 meters long'.

	^ self cleanDelimitersFrom: ( response at: 'answers' )
]

{ #category : #'private - accessing' }
OpenAIExamples >> apiKey [

	^ 'open-ai/apikey.secret' asFileReference contents
]

{ #category : #accessing }
OpenAIExamples >> classifications [

	| apiClient response |

	apiClient := self classificationsAPIClient.
	apiClient labelAsOneOf: #( 'happy' 'sad' ).
	
	response := apiClient classify: 'the weather is great' given: ( Array
			              with: #( 'the grass is green' 'happy' )
			              with: #( 'el cielo está lindo' 'happy' )
			              with: #( 'the soil is rotten' 'sad' ) ).
	^ response at: 'label'
]

{ #category : #'private - accessing' }
OpenAIExamples >> classificationsAPIClient [

	| apiClient |

	apiClient := ClassificationsAPIClient
		             accessingAPIsWith: RESTfulAPIClient cachingOnLocalMemory
		             authenticatedWith: self apiKey.
	apiClient
		changeEngineTo: 'ada';
		changeSearchEngineTo: 'ada'.

	^ apiClient
]

{ #category : #'private - accessing' }
OpenAIExamples >> classificationsFileId [

	^ self idForFileNamed: 'open-ai/classifications-example.jsonl' intendedFor: 'classifications'
]

{ #category : #accessing }
OpenAIExamples >> classificationsFromFile [

	| id apiClient response |

	id := self classificationsFileId.

	apiClient := self classificationsAPIClient.
	apiClient
		labelAsOneOf: #( 'Positive' 'Negative' );
		fromExamplesMatchBest: 2.

	response := apiClient classify: 'movie is very good' lookingForExamplesIn: id.
	^ response at: 'label'
]

{ #category : #accessing }
OpenAIExamples >> classificationsFromFileWithoutLabels [

	| id apiClient response |

	id := self classificationsFileId.

	apiClient := self classificationsAPIClient.
	apiClient fromExamplesMatchBest: 2.

	response := apiClient classify: 'movie is very good' lookingForExamplesIn: id.
	^ response at: 'label'
]

{ #category : #'private - accessing' }
OpenAIExamples >> cleanDelimitersFrom: anAnswerCollection [

	^ anAnswerCollection collect: [ :answer | ( answer substrings: '===' ) first trimBoth ]
]

{ #category : #accessing }
OpenAIExamples >> completions [

	| apiClient seedText response |

	apiClient := self completionsAPIClient.
	apiClient changeMaximumNumberOfTokensTo: 1.
	seedText := 'This is the day'.

	response := apiClient complete: seedText.

	^ '<1s><2s>' expandMacrosWith: seedText with: ( ( response at: 'choices' ) first at: 'text' )
]

{ #category : #'private - accessing' }
OpenAIExamples >> completionsAPIClient [

	| apiClient |

	apiClient := CompletionsAPIClient
		             accessingAPIsWith: RESTfulAPIClient cachingOnLocalMemory
		             authenticatedWith: self apiKey.
	apiClient changeEngineTo: 'ada'.

	^ apiClient
]

{ #category : #accessing }
OpenAIExamples >> deleteAllFiles [

	"Use with extreme caution!"

	| apiClient |

	apiClient := self filesAPIClient.
	^ apiClient listFiles data collect: [ :file | apiClient removeFileIdentifiedBy: file id ]
]

{ #category : #accessing }
OpenAIExamples >> downloadAndRemoveFile [

	"All attempts at downloading give the same 400 error:
	Not allowed to download files of purpose: <THE PURPOSE SENT>"

	| id |

	id := self idForFileNamed: 'open-ai/file-that-will-be-deleted.jsonl' intendedFor: 'fine-tune'.
	^ self filesAPIClient removeFileIdentifiedBy: id
]

{ #category : #accessing }
OpenAIExamples >> files [

	| apiClient files |

	apiClient := self filesAPIClient.
	files := apiClient listFiles.
	^ files data
		  ifEmpty: [ 
			  Array with: ( apiClient
					    idForProcessed: 'open-ai/fine-tune-example.jsonl' asFileReference
					    intendedFor: 'fine-tune'
					    waiting: 4 seconds )
			  ]
		  ifNotEmpty: [ files ]
]

{ #category : #'private - accessing' }
OpenAIExamples >> filesAPIClient [

	^ FilesAPIClient
		  accessingAPIsWith: RESTfulAPIClient cachingOnLocalMemory
		  authenticatedWith: self apiKey
]

{ #category : #'private - accessing' }
OpenAIExamples >> idForFileNamed: aName intendedFor: aPurpose [

	| fileName filesAPIClient files |

	fileName := aName asFileReference basename.
	filesAPIClient := self filesAPIClient.
	files := filesAPIClient listFiles.
	
	^ files data
		  detect: [ :file | file filename = fileName ]
		  ifFound: [ :file | file id ]
		  ifNone: [ 
		  filesAPIClient idForProcessed: aName asFileReference intendedFor: aPurpose waiting: 4 seconds ]
]

{ #category : #accessing }
OpenAIExamples >> search [

	| documents response |

	documents := #( cat dog car building vehicle person ).
	response := self searchAPIClient search: 'bulldog' against: documents.
	
	^ ( self sortByScoreDataIn: response ) collect: [ :result | 
		  documents at: ( result at: 'document' ) + 1 ]
]

{ #category : #'private - accessing' }
OpenAIExamples >> searchAPIClient [

	| apiClient |

	apiClient := SearchAPIClient
		             accessingAPIsWith: RESTfulAPIClient cachingOnLocalMemory
		             authenticatedWith: self apiKey.
	apiClient changeEngineTo: 'ada'.

	^ apiClient
]

{ #category : #'private - accessing' }
OpenAIExamples >> searchFileId [

	^ self idForFileNamed: 'open-ai/search-example.jsonl' intendedFor: 'search'
]

{ #category : #accessing }
OpenAIExamples >> searchFromFile [

	| id apiClient response |

	id := self searchFileId.

	apiClient := self searchAPIClient.
	apiClient returnUpTo: 5.

	response := apiClient search: 'the dog feels happy in a building where some person lives' in: id.
	^ ( self sortByScoreDataIn: response ) collect: [ :result | result text ]
]

{ #category : #'private - accessing' }
OpenAIExamples >> sortByScoreDataIn: response [

	^ ( response at: 'data' ) sorted: [ :a :b | ( a at: 'score' ) >= ( b at: 'score' ) ]
]
