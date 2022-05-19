Class {
	#name : #OpenAITasks,
	#superclass : #Object,
	#category : #'Open-AI-Examples'
}

{ #category : #processing }
OpenAITasks >> answer: aQuestion against: aDocumentCollection given: exampleCollection within: anExampleContext [

	| apiClient response |

	apiClient := AnswersAPIClient authenticatedWith: self apiKey.
	apiClient
		changeEngineTo: 'ada';
		changeSearchEngineTo: 'ada';
		stopAt: #( '\n' '<|endoftext|>' ).
	response := apiClient answer: aQuestion
		            against: aDocumentCollection
		            given: exampleCollection
		            within: anExampleContext.
	^ response at: 'answers'
]

{ #category : #processing }
OpenAITasks >> answer: aQuestion returningUpTo: aNumber from: aFileId given: exampleCollection within: anExampleContext [

	| apiClient response |

	apiClient := AnswersAPIClient authenticatedWith: self apiKey.
	apiClient
		changeEngineTo: 'ada';
		changeSearchEngineTo: 'ada';
		stopAt: #( '\n' '<|endoftext|>' );
		returnUpTo: aNumber.
	response := apiClient answer: aQuestion
		            querying: aFileId
		            given: exampleCollection
		            within: anExampleContext.
	^ ( response at: 'answers' ) collect: [ :answer | ( answer substrings: '===' ) first trimBoth ]
]

{ #category : #'private - accessing' }
OpenAITasks >> apiKey [

	^ 'inputs/apikey.secret' asFileReference contents
]

{ #category : #processing }
OpenAITasks >> classify: aString asOneOf: labelCollection given: exampleCollection [

	| apiClient response |

	apiClient := ClassificationsAPIClient authenticatedWith: self apiKey.
	apiClient
		changeEngineTo: 'ada';
		changeSearchEngineTo: 'ada';
		labelAsOneOf: labelCollection.
	response := apiClient classify: aString given: exampleCollection.
	^ response at: 'label'
]

{ #category : #processing }
OpenAITasks >> classify: aString asOneOf: labelCollection lookingForBest: aNumber examplesIn: aFileId [

	| apiClient response |

	apiClient := ClassificationsAPIClient authenticatedWith: self apiKey.
	apiClient
		changeEngineTo: 'ada';
		changeSearchEngineTo: 'ada';
		labelAsOneOf: labelCollection;
		fromExamplesMatchBest: aNumber.
	response := apiClient classify: aString lookingForExamplesIn: aFileId.
	^ response at: 'label'
]

{ #category : #processing }
OpenAITasks >> classify: aString lookingForBest: aNumber examplesIn: aFileId [

	| apiClient response |

	apiClient := ClassificationsAPIClient authenticatedWith: self apiKey.
	apiClient
		changeEngineTo: 'ada';
		changeSearchEngineTo: 'ada';
		fromExamplesMatchBest: aNumber.
	response := apiClient classify: aString lookingForExamplesIn: aFileId.
	^ response at: 'label'
]

{ #category : #processing }
OpenAITasks >> complete: aString [

	| apiClient response |

	apiClient := CompletionsAPIClient authenticatedWith: self apiKey.
	apiClient
		changeEngineTo: 'ada';
		changeMaximumNumberOfTokensTo: 1.
	response := apiClient complete: aString.
	^ '<1s><2s>' expandMacrosWith: aString with: ( ( response at: 'choices' ) first at: 'text' )
]

{ #category : #'private - processing' }
OpenAITasks >> ensureJsonLinesTypeIsKnown [

	| extensionsMap |

	extensionsMap := ZnMimeType extensionsMap.
	extensionsMap at: 'jsonl' ifAbsentPut: [ ZnMimeType applicationOctetStream ]
]

{ #category : #processing }
OpenAITasks >> listFiles [

	| apiClient response |

	apiClient := FilesAPIClient authenticatedWith: self apiKey.
	response := apiClient listFiles.
	^ response
]

{ #category : #processing }
OpenAITasks >> removeFileIdentifiedBy: aFileId [

	| apiClient response |

	apiClient := FilesAPIClient authenticatedWith: self apiKey.
	response := apiClient removeFileIdentifiedBy: aFileId.
	^ response
]

{ #category : #processing }
OpenAITasks >> search: aQuery against: aDocumentCollection [

	| apiClient response sortedResults |

	apiClient := SearchAPIClient authenticatedWith: self apiKey.
	apiClient changeEngineTo: 'ada'.
	response := apiClient search: aQuery against: aDocumentCollection.
	sortedResults := ( response at: 'data' ) sorted: [ :a :b | ( a at: 'score' ) >= ( b at: 'score' ) ].
	^ sortedResults collect: [ :result | aDocumentCollection at: ( result at: 'document' ) + 1 ]
]

{ #category : #processing }
OpenAITasks >> search: aQuery returningUpTo: aNumber from: aFileId includeMetadata: aBoolean [

	| apiClient response sortedResults |

	apiClient := SearchAPIClient authenticatedWith: self apiKey.
	apiClient
		changeEngineTo: 'ada';
		returnUpTo: aNumber.
	aBoolean ifTrue: [ apiClient includeMetadata ].
	response := apiClient search: aQuery in: aFileId.
	sortedResults := ( response at: 'data' ) sorted: [ :a :b | ( a at: 'score' ) >= ( b at: 'score' ) ].
	^ sortedResults collect: [ :result | result text ]
]

{ #category : #processing }
OpenAITasks >> upload: aFile intendedFor: aPurpose [

	| apiClient response |

	self ensureJsonLinesTypeIsKnown.
	apiClient := FilesAPIClient authenticatedWith: self apiKey.
	response := apiClient upload: aFile intendedFor: aPurpose.
	^ response at: 'id'
]
