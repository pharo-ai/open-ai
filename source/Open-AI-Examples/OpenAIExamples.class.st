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
OpenAIExamples >> answersExampleFileReference [

	^ self examplesDirectory / 'answers-example.jsonl'
]

{ #category : #'private - accessing' }
OpenAIExamples >> answersFileId [

	^ self idForFileNamed: self answersExampleFileReference intendedFor: 'answers'
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
OpenAIExamples >> classificationsExampleFileReference [

	^ self examplesDirectory / 'classifications-example.jsonl'
]

{ #category : #'private - accessing' }
OpenAIExamples >> classificationsFileId [

	^ self idForFileNamed: self classificationsExampleFileReference intendedFor: 'classifications'
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

{ #category : #'private - processing' }
OpenAIExamples >> convertToLinuxLineEndings: aString [

	^ ( aString copyReplaceAll: String crlf with: String lf ) copyReplaceAll: String cr with: String lf
]

{ #category : #'private - processing' }
OpenAIExamples >> createAnswersExampleFile [

	self
		write: '{"text": "France is in Europe", "metadata": "country with french people"}
{"text": "Canada is in America", "metadata": "country with canadian people"}
{"text": "Japan is in Asia", "metadata": "country with japanese people"}'
		to: self answersExampleFileReference
]

{ #category : #'private - processing' }
OpenAIExamples >> createClassificationsExampleFile [

	self
		write:
			'{"text": "good film, but very glum.", "label": "Positive", "metadata": {"source":"example.com"}}
{"text": "i sympathize with the plight of these families, but the movie doesn''t do a very good job conveying the issue at hand.", "label": "Negative", "metadata": {"source":"example.com"}}'
		to: self classificationsExampleFileReference
]

{ #category : #'private - processing' }
OpenAIExamples >> createExamplesDirectory [

	self examplesDirectory createDirectory
]

{ #category : #'private - processing' }
OpenAIExamples >> createFileThatWillBeDeleted [

	self
		write: '{"prompt": "<prompt text>", "completion": "<ideal generated text>"}'
		to: self fileThatWillBeDeletedReference
]

{ #category : #'private - processing' }
OpenAIExamples >> createFineTuneExampleFile [

	self
		write: '{"prompt": "<prompt text>", "completion": "<ideal generated text>"}'
		to: self fineTuneExampleFileReference
]

{ #category : #'private - processing' }
OpenAIExamples >> createSearchExampleFile [

	self
		write: '{"text": "a cat is happy", "metadata": "a type of feline"}
{"text": "a dog is hungry", "metadata": "a type of canine"}
{"text": "a car is loud", "metadata": "a type of vehicle"}
{"text": "a building is tall", "metadata": "a type of location"}
{"text": "a vehicle is fast", "metadata": "a type of transport"}
{"text": "a person is smart", "metadata": "a type of sentient being"}'
		to: self searchExampleFileReference
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

	id := self idForFileNamed: self fileThatWillBeDeletedReference intendedFor: 'fine-tune'.
	^ self filesAPIClient removeFileIdentifiedBy: id
]

{ #category : #'private - accessing' }
OpenAIExamples >> examplesDirectory [

	^ 'open-ai' asFileReference
]

{ #category : #'private - accessing' }
OpenAIExamples >> fileThatWillBeDeletedReference [

	^ self examplesDirectory / 'file-that-will-be-deleted.jsonl'
]

{ #category : #accessing }
OpenAIExamples >> files [

	| apiClient files |

	apiClient := self filesAPIClient.
	files := apiClient listFiles.
	^ files data
		  ifEmpty: [ 
			  Array with: ( apiClient
					    idForProcessed: self fineTuneExampleFileReference
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
OpenAIExamples >> fineTuneExampleFileReference [

	^ self examplesDirectory / 'fine-tune-example.jsonl'
]

{ #category : #processing }
OpenAIExamples >> generateExampleFiles [

	self createExamplesDirectory.
	self createAnswersExampleFile.
	self createClassificationsExampleFile.
	self createFileThatWillBeDeleted.
	self createFineTuneExampleFile.
	self createSearchExampleFile
]

{ #category : #'private - accessing' }
OpenAIExamples >> idForFileNamed: aFileReference intendedFor: aPurpose [

	| fileName filesAPIClient files |

	fileName := aFileReference basename.
	filesAPIClient := self filesAPIClient.
	files := filesAPIClient listFiles.

	^ files data
		  detect: [ :file | file filename = fileName ]
		  ifFound: [ :file | file id ]
		  ifNone: [ 
		  filesAPIClient idForProcessed: aFileReference intendedFor: aPurpose waiting: 20 seconds ]
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
OpenAIExamples >> searchExampleFileReference [

	^ self examplesDirectory / 'search-example.jsonl'
]

{ #category : #'private - accessing' }
OpenAIExamples >> searchFileId [

	^ self idForFileNamed: self searchExampleFileReference intendedFor: 'search'
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

{ #category : #'private - processing' }
OpenAIExamples >> write: aString to: aFileReference [

	aFileReference writeStreamDo: [ :stream | 
		stream nextPutAll: ( self convertToLinuxLineEndings: aString ) ]
]
