Class {
	#name : #AnswersAPIClientTest,
	#superclass : #APIClientTest,
	#category : #'Open-AI-Model-Tests'
}

{ #category : #private }
AnswersAPIClientTest >> europeFromDocumentsResponse [

	^ self jsonOkResponseWith: '{
   "answers":[
      "Europe"
   ],
   "completion":"cmpl-58c1t9411dzxRMzbyviK5tBMAYw3Z",
   "model":"ada:2020-05-03",
   "object":"answer",
   "search_model":"ada",
   "selected_documents":[
      {
         "document":0,
         "text":"France is in Europe "
      },
      {
         "document":2,
         "text":"Japan is in Asia "
      },
      {
         "document":1,
         "text":"Canada is in America "
      }
   ]
}'
]

{ #category : #private }
AnswersAPIClientTest >> europeFromFileResponse [

	^ self jsonOkResponseWith: '{
   "answers":[
      "in Europe\n===\nContext: this car is 2 meters long\n==="
   ],
   "completion":"cmpl-58q7uDHZX7tpJYrt0qS0viiGYKqUe",
   "file":"fileID",
   "model":"ada",
   "object":"answer",
   "search_model":"ada:2020-05-03",
   "selected_documents":[
      {
         "document":0,
         "object":"search_result",
         "score":232.386,
         "text":"France is in Europe"
      }
   ]
}'
]

{ #category : #private }
AnswersAPIClientTest >> restfulAPIClient [

	^ RESTfulAPIClient
		  buildingHttpClientWith: [ self httpClient ]
		  cachingIn: ExpiringCache onLocalMemory
]

{ #category : #tests }
AnswersAPIClientTest >> testAnswerAgainstGivenWithin [

	| client answerJSON |

	client := AnswersAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	self configureHttpClientToRespondWith: self europeFromDocumentsResponse.

	answerJSON := client
		              answer: 'where is France?'
		              against: #( 'France is in Europe' 'Canada is in America' 'Japan is in Asia' )
		              given: ( Array with: #( 'how long is this car' '2 meters' ) )
		              within: 'this car is 2 meters long'.

	self
		assert: answerJSON answers equals: ( Array with: 'Europe' );
		assert: ( answerJSON model beginsWith: 'ada' );
		assert: ( ( answerJSON at: #search_model ) beginsWith: 'ada' );
		assert: answerJSON object equals: 'answer';
		assert: ( answerJSON at: #selected_documents ) size equals: 3
]

{ #category : #tests }
AnswersAPIClientTest >> testAnswerQueryingGivenWithin [

	| client answerJSON |

	client := AnswersAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	self configureHttpClientToRespondWith: self europeFromFileResponse.

	answerJSON := client
		              answer: 'where is France?'
		              querying: 'fileID'
		              given: ( Array with: #( 'how long is this car' '2 meters' ) )
		              within: 'this car is 2 meters long'.

	self
		assert: ( answerJSON answers collect: [ :answer | ( answer substrings: '===' ) first trimBoth ] )
		equals: ( Array with: 'in Europe' );
		assert: answerJSON file equals: 'fileID';
		assert: ( answerJSON model beginsWith: 'ada' );
		assert: ( ( answerJSON at: #search_model ) beginsWith: 'ada' );
		assert: answerJSON object equals: 'answer';
		assert: ( answerJSON at: #selected_documents ) size equals: 1
]

{ #category : #tests }
AnswersAPIClientTest >> testChangeEngineTo [

	| client answerJSON entityContentsJSON |

	client := AnswersAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	client changeEngineTo: 'davinci'.
	self httpClient
		whenSend: #entity:
		evaluate: [ :entityReceived | 
		entityContentsJSON := NeoJSONObject fromString: entityReceived contents ].
	self configureHttpClientToRespondWith: self europeFromDocumentsResponse.

	answerJSON := client
		              answer: 'where is France?'
		              against: #( 'France is in Europe' 'Canada is in America' 'Japan is in Asia' )
		              given: ( Array with: #( 'how long is this car' '2 meters' ) )
		              within: 'this car is 2 meters long'.

	self
		assert: entityContentsJSON question equals: 'where is France?';
		assert: entityContentsJSON documents
		equals: #( 'France is in Europe' 'Canada is in America' 'Japan is in Asia' );
		assert: ( entityContentsJSON at: #search_model ) equals: 'ada';
		assert: entityContentsJSON model equals: 'davinci';
		assert: ( entityContentsJSON at: #examples_context ) equals: 'this car is 2 meters long';
		assert: entityContentsJSON examples
		equals: ( Array with: #( 'how long is this car' '2 meters' ) );
		assert: entityContentsJSON keys size equals: 6
]

{ #category : #tests }
AnswersAPIClientTest >> testChangeSearchEngineTo [

	| client answerJSON entityContentsJSON |

	client := AnswersAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	client changeSearchEngineTo: 'davinci'.
	self httpClient
		whenSend: #entity:
		evaluate: [ :entityReceived | 
		entityContentsJSON := NeoJSONObject fromString: entityReceived contents ].
	self configureHttpClientToRespondWith: self europeFromDocumentsResponse.

	answerJSON := client
		              answer: 'where is France?'
		              against: #( 'France is in Europe' 'Canada is in America' 'Japan is in Asia' )
		              given: ( Array with: #( 'how long is this car' '2 meters' ) )
		              within: 'this car is 2 meters long'.

	self
		assert: entityContentsJSON question equals: 'where is France?';
		assert: entityContentsJSON documents
		equals: #( 'France is in Europe' 'Canada is in America' 'Japan is in Asia' );
		assert: ( entityContentsJSON at: #search_model ) equals: 'davinci';
		assert: entityContentsJSON model equals: 'ada';
		assert: ( entityContentsJSON at: #examples_context ) equals: 'this car is 2 meters long';
		assert: entityContentsJSON examples
		equals: ( Array with: #( 'how long is this car' '2 meters' ) );
		assert: entityContentsJSON keys size equals: 6
]

{ #category : #tests }
AnswersAPIClientTest >> testDefaultEntityWhenUsingDocuments [

	| client answerJSON entityContentsJSON |

	client := AnswersAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	self httpClient
		whenSend: #entity:
		evaluate: [ :entityReceived | 
		entityContentsJSON := NeoJSONObject fromString: entityReceived contents ].
	self configureHttpClientToRespondWith: self europeFromDocumentsResponse.

	answerJSON := client
		              answer: 'where is France?'
		              against: #( 'France is in Europe' 'Canada is in America' 'Japan is in Asia' )
		              given: ( Array with: #( 'how long is this car' '2 meters' ) )
		              within: 'this car is 2 meters long'.

	self
		assert: entityContentsJSON question equals: 'where is France?';
		assert: entityContentsJSON documents
		equals: #( 'France is in Europe' 'Canada is in America' 'Japan is in Asia' );
		assert: ( entityContentsJSON at: #search_model ) equals: 'ada';
		assert: entityContentsJSON model equals: 'ada';
		assert: ( entityContentsJSON at: #examples_context ) equals: 'this car is 2 meters long';
		assert: entityContentsJSON examples
		equals: ( Array with: #( 'how long is this car' '2 meters' ) );
		assert: entityContentsJSON keys size equals: 6
]

{ #category : #tests }
AnswersAPIClientTest >> testDefaultEntityWhenUsingFile [

	| client answerJSON entityContentsJSON |

	client := AnswersAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	self httpClient
		whenSend: #entity:
		evaluate: [ :entityReceived | 
		entityContentsJSON := NeoJSONObject fromString: entityReceived contents ].
	self configureHttpClientToRespondWith: self europeFromFileResponse.

	answerJSON := client
		              answer: 'where is France?'
		              querying: 'fileID'
		              given: ( Array with: #( 'how long is this car' '2 meters' ) )
		              within: 'this car is 2 meters long'.

	self
		assert: entityContentsJSON question equals: 'where is France?';
		assert: entityContentsJSON file equals: 'fileID';
		assert: ( entityContentsJSON at: #search_model ) equals: 'ada';
		assert: entityContentsJSON model equals: 'ada';
		assert: ( entityContentsJSON at: #examples_context ) equals: 'this car is 2 meters long';
		assert: entityContentsJSON examples
		equals: ( Array with: #( 'how long is this car' '2 meters' ) );
		assert: entityContentsJSON keys size equals: 6
]

{ #category : #tests }
AnswersAPIClientTest >> testDefaultHeaders [

	| client headers |

	client := AnswersAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	headers := Dictionary new.
	self httpClient
		whenSend: #headerAt:put:
		evaluate: [ :header :value | headers at: header put: value ].
	self configureHttpClientToRespondWith: self europeFromDocumentsResponse.

	client
		answer: 'where is France?'
		against: #( 'France is in Europe' 'Canada is in America' 'Japan is in Asia' )
		given: ( Array with: #( 'how long is this car' '2 meters' ) )
		within: 'this car is 2 meters long'.

	self assert: ( headers at: 'Authorization' ) equals: 'Bearer 1234'
]

{ #category : #tests }
AnswersAPIClientTest >> testDefaultUrl [

	| client url |

	client := AnswersAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	self httpClient whenSend: #url: evaluate: [ :urlReceived | url := urlReceived ].
	self configureHttpClientToRespondWith: self europeFromDocumentsResponse.

	client
		answer: 'where is France?'
		against: #( 'France is in Europe' 'Canada is in America' 'Japan is in Asia' )
		given: ( Array with: #( 'how long is this car' '2 meters' ) )
		within: 'this car is 2 meters long'.

	self assert: url equals: 'https://api.openai.com/v1/answers' asUrl
]

{ #category : #tests }
AnswersAPIClientTest >> testIncludeMetadata [

	| client answerJSON entityContentsJSON |

	client := AnswersAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	client includeMetadata.
	self httpClient
		whenSend: #entity:
		evaluate: [ :entityReceived | 
		entityContentsJSON := NeoJSONObject fromString: entityReceived contents ].
	self configureHttpClientToRespondWith: self europeFromDocumentsResponse.

	answerJSON := client
		              answer: 'where is France?'
		              against: #( 'France is in Europe' 'Canada is in America' 'Japan is in Asia' )
		              given: ( Array with: #( 'how long is this car' '2 meters' ) )
		              within: 'this car is 2 meters long'.

	self
		assert: entityContentsJSON question equals: 'where is France?';
		assert: entityContentsJSON documents
		equals: #( 'France is in Europe' 'Canada is in America' 'Japan is in Asia' );
		assert: ( entityContentsJSON at: #search_model ) equals: 'ada';
		assert: entityContentsJSON model equals: 'ada';
		assert: ( entityContentsJSON at: #examples_context ) equals: 'this car is 2 meters long';
		assert: entityContentsJSON examples
		equals: ( Array with: #( 'how long is this car' '2 meters' ) );
		assert: ( entityContentsJSON at: #return_metadata );
		assert: entityContentsJSON keys size equals: 7
]

{ #category : #tests }
AnswersAPIClientTest >> testReturnUpTo [

	| client answerJSON entityContentsJSON |

	client := AnswersAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	client returnUpTo: 10.
	self httpClient
		whenSend: #entity:
		evaluate: [ :entityReceived | 
		entityContentsJSON := NeoJSONObject fromString: entityReceived contents ].
	self configureHttpClientToRespondWith: self europeFromDocumentsResponse.

	answerJSON := client
		              answer: 'where is France?'
		              against: #( 'France is in Europe' 'Canada is in America' 'Japan is in Asia' )
		              given: ( Array with: #( 'how long is this car' '2 meters' ) )
		              within: 'this car is 2 meters long'.

	self
		assert: entityContentsJSON question equals: 'where is France?';
		assert: entityContentsJSON documents
		equals: #( 'France is in Europe' 'Canada is in America' 'Japan is in Asia' );
		assert: ( entityContentsJSON at: #search_model ) equals: 'ada';
		assert: entityContentsJSON model equals: 'ada';
		assert: ( entityContentsJSON at: #examples_context ) equals: 'this car is 2 meters long';
		assert: entityContentsJSON examples
		equals: ( Array with: #( 'how long is this car' '2 meters' ) );
		assert: ( entityContentsJSON at: 'max_rerank' ) equals: 10;
		assert: entityContentsJSON keys size equals: 7
]

{ #category : #tests }
AnswersAPIClientTest >> testStopAt [

	| client answerJSON entityContentsJSON |

	client := AnswersAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	client stopAt: #( '\n' '<|endoftext|>' ).
	self httpClient
		whenSend: #entity:
		evaluate: [ :entityReceived | 
		entityContentsJSON := NeoJSONObject fromString: entityReceived contents ].
	self configureHttpClientToRespondWith: self europeFromDocumentsResponse.

	answerJSON := client
		              answer: 'where is France?'
		              against: #( 'France is in Europe' 'Canada is in America' 'Japan is in Asia' )
		              given: ( Array with: #( 'how long is this car' '2 meters' ) )
		              within: 'this car is 2 meters long'.

	self
		assert: entityContentsJSON question equals: 'where is France?';
		assert: entityContentsJSON documents
		equals: #( 'France is in Europe' 'Canada is in America' 'Japan is in Asia' );
		assert: ( entityContentsJSON at: #search_model ) equals: 'ada';
		assert: entityContentsJSON model equals: 'ada';
		assert: ( entityContentsJSON at: #examples_context ) equals: 'this car is 2 meters long';
		assert: entityContentsJSON examples
		equals: ( Array with: #( 'how long is this car' '2 meters' ) );
		assert: entityContentsJSON stop equals: #( '\n' '<|endoftext|>' );
		assert: entityContentsJSON keys size equals: 7
]
