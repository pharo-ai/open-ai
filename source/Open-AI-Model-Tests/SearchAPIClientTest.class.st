Class {
	#name : #SearchAPIClientTest,
	#superclass : #APIClientTest,
	#category : #'Open-AI-Model-Tests'
}

{ #category : #private }
SearchAPIClientTest >> dogResponseFromDocuments [

	^ self jsonOkResponseWith: '{
   "object":"list",
   "data":[
      {
         "object":"search_result",
         "document":0,
         "score":99.573
      },
      {
         "object":"search_result",
         "document":1,
         "score":166.614
      },
      {
         "object":"search_result",
         "document":2,
         "score":88.431
      },
      {
         "object":"search_result",
         "document":3,
         "score":51.822
      },
      {
         "object":"search_result",
         "document":4,
         "score":83.597
      },
      {
         "object":"search_result",
         "document":5,
         "score":70.199
      }
   ],
   "model":"ada:2020-05-03"
}'
]

{ #category : #private }
SearchAPIClientTest >> dogResponseFromFile [

	^ self jsonOkResponseWith: '{
   "object":"list",
   "data":[
      {
         "object":"search_result",
         "document":0,
         "score":78.533,
         "text":"a dog is hungry"
      },
      {
         "object":"search_result",
         "document":1,
         "score":72.794,
         "text":"a building is tall"
      },
      {
         "object":"search_result",
         "document":2,
         "score":98.424,
         "text":"a cat is happy"
      },
      {
         "object":"search_result",
         "document":3,
         "score":29.02,
         "text":"a person is smart"
      }
   ],
   "model":"ada:2020-05-03"
}'
]

{ #category : #private }
SearchAPIClientTest >> restfulAPIClient [

	^ RESTfulAPIClient
		  buildingHttpClientWith: [ self httpClient ]
		  cachingIn: ExpiringCache onLocalMemory
]

{ #category : #tests }
SearchAPIClientTest >> testChangeModelTo [

	| client url |

	client := SearchAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	client changeModelTo: 'davinci'.
	self httpClient whenSend: #url: evaluate: [ :urlReceived | url := urlReceived ].

	self configureHttpClientToRespondWith: self dogResponseFromDocuments.
	client search: 'bulldog' against: #( cat dog car building vehicle person ).

	self assert: url equals: 'https://api.openai.com/v1/engines/davinci/search' asUrl
]

{ #category : #tests }
SearchAPIClientTest >> testDefaultEntityWhenUsingDocuments [

	| client entityContentsJSON documents |

	client := SearchAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	self httpClient
		whenSend: #entity:
		evaluate: [ :entityReceived | 
		entityContentsJSON := NeoJSONObject fromString: entityReceived contents ].
	self configureHttpClientToRespondWith: self dogResponseFromDocuments.
	documents := #( cat dog car building vehicle person ).
	client search: 'bulldog' against: documents.

	self
		assert: entityContentsJSON query equals: 'bulldog';
		assert: entityContentsJSON documents equals: documents;
		assert: entityContentsJSON keys size equals: 2
]

{ #category : #tests }
SearchAPIClientTest >> testDefaultEntityWhenUsingFile [

	| client entityContentsJSON |

	client := SearchAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	self httpClient
		whenSend: #entity:
		evaluate: [ :entityReceived | 
		entityContentsJSON := NeoJSONObject fromString: entityReceived contents ].
	self configureHttpClientToRespondWith: self dogResponseFromFile.
	client search: 'the dog feels happy in a building where some person lives' in: 'fileID'.

	self
		assert: entityContentsJSON query
		equals: 'the dog feels happy in a building where some person lives';
		assert: entityContentsJSON file equals: 'fileID';
		assert: entityContentsJSON keys size equals: 2
]

{ #category : #tests }
SearchAPIClientTest >> testDefaultUrl [

	| client url |

	client := SearchAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	self httpClient whenSend: #url: evaluate: [ :urlReceived | url := urlReceived ].
	self configureHttpClientToRespondWith: self dogResponseFromDocuments.

	client search: 'bulldog' against: #( cat dog car building vehicle person ).

	self assert: url equals: 'https://api.openai.com/v1/engines/ada/search' asUrl
]

{ #category : #tests }
SearchAPIClientTest >> testIncludeMetadata [

	| client entityContentsJSON documents |

	client := SearchAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	client includeMetadata.
	self httpClient
		whenSend: #entity:
		evaluate: [ :entityReceived | 
		entityContentsJSON := NeoJSONObject fromString: entityReceived contents ].
	self configureHttpClientToRespondWith: self dogResponseFromDocuments.
	documents := #( cat dog car building vehicle person ).
	client search: 'bulldog' against: documents.

	self
		assert: entityContentsJSON query equals: 'bulldog';
		assert: entityContentsJSON documents equals: documents;
		assert: ( entityContentsJSON at: #return_metadata );
		assert: entityContentsJSON keys size equals: 3
]

{ #category : #tests }
SearchAPIClientTest >> testReturnUpTo [

	| client entityContentsJSON documents |

	client := SearchAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	client returnUpTo: 10.
	self httpClient
		whenSend: #entity:
		evaluate: [ :entityReceived | 
		entityContentsJSON := NeoJSONObject fromString: entityReceived contents ].
	self configureHttpClientToRespondWith: self dogResponseFromDocuments.
	documents := #( cat dog car building vehicle person ).
	client search: 'bulldog' against: documents.

	self
		assert: entityContentsJSON query equals: 'bulldog';
		assert: entityContentsJSON documents equals: documents;
		assert: ( entityContentsJSON at: #max_rerank ) equals: 10;
		assert: entityContentsJSON keys size equals: 3
]

{ #category : #tests }
SearchAPIClientTest >> testSearchAgainst [

	| client answerJSON documents |

	client := SearchAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	self configureHttpClientToRespondWith: self dogResponseFromDocuments.
	documents := #( cat dog car building vehicle person ).

	answerJSON := client search: 'bulldog' against: documents.

	self
		assert: ( answerJSON model beginsWith: 'ada' );
		assert: answerJSON object equals: 'list';
		assert: ( answerJSON at: #data ) size equals: documents size.
	( answerJSON at: #data ) doWithIndex: [ :item :index | 
		self
			assert: item object equals: 'search_result';
			assert: item document equals: index - 1;
			assert: item score strictlyPositive
		]
]

{ #category : #tests }
SearchAPIClientTest >> testSearchIn [

	| client answerJSON |

	client := SearchAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	self configureHttpClientToRespondWith: self dogResponseFromFile.

	answerJSON := client
		              search: 'the dog feels happy in a building where some person lives'
		              in: 'fileID'.

	self
		assert: ( answerJSON model beginsWith: 'ada' );
		assert: answerJSON object equals: 'list';
		assert: ( answerJSON at: #data ) size equals: 4.
	( answerJSON at: #data ) doWithIndex: [ :item :index | 
		self
			assert: item object equals: 'search_result';
			assert: item document equals: index - 1;
			assert: item score strictlyPositive;
			assert: item text notEmpty
		]
]
