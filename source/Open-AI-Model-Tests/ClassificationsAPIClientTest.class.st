Class {
	#name : #ClassificationsAPIClientTest,
	#superclass : #APIClientTest,
	#category : #'Open-AI-Model-Tests'
}

{ #category : #private }
ClassificationsAPIClientTest >> happyResponseFromExamples [

	^ self jsonOkResponseWith: '{
   "completion":"cmpl-58uFrJfYP4xe5v5Tykp97LK0g7GAZ",
   "label":"Happy",
   "model":"ada",
   "object":"classification",
   "search_model":"ada",
   "selected_examples":[
      {
         "document":2,
         "label":"Sad",
         "text":"the soil is rotten"
      },
      {
         "document":0,
         "label":"Happy",
         "text":"the grass is green"
      },
      {
         "document":1,
         "label":"Happy",
         "text":"el cielo está lindo"
      }
   ]
}'
]

{ #category : #private }
ClassificationsAPIClientTest >> happyResponseFromFile [

	^ self jsonOkResponseWith: '{
   "completion":"cmpl-58yd1Undy8qAMx2iMQWCa9fuTrf0e",
   "file":"fileID",
   "label":"Positive",
   "model":"ada",
   "object":"classification",
   "search_model":"ada:2020-05-03",
   "selected_examples":[
      {
         "document":1,
         "label":"Positive",
         "object":"search_result",
         "score":214.54,
         "text":"good film, but very glum."
      },
      {
         "document":0,
         "label":"Negative",
         "object":"search_result",
         "score":147.785,
         "text":"i sympathize with the plight of these families, but the movie doesn''t do a very good job conveying the issue at hand."
      }
   ]
}'
]

{ #category : #private }
ClassificationsAPIClientTest >> restfulAPIClient [

	^ RESTfulAPIClient
		  buildingHttpClientWith: [ self httpClient ]
		  cachingIn: ExpiringCache onLocalMemory
]

{ #category : #tests }
ClassificationsAPIClientTest >> testChangeEngineTo [

	| client entityContentsJSON |

	client := ClassificationsAPIClient
		          accessingAPIsWith: self restfulAPIClient
		          authenticatedWith: '1234'.
	client changeEngineTo: 'davinci'.
	self httpClient
		whenSend: #entity:
		evaluate: [ :entityReceived | 
		entityContentsJSON := NeoJSONObject fromString: entityReceived contents ].
	self configureHttpClientToRespondWith: self happyResponseFromFile.
	client classify: 'movie is very good' lookingForExamplesIn: 'fileID'.

	self
		assert: entityContentsJSON query equals: 'movie is very good';
		assert: entityContentsJSON file equals: 'fileID';
		assert: ( entityContentsJSON at: #search_model ) equals: 'ada';
		assert: entityContentsJSON model equals: 'davinci';
		assert: entityContentsJSON keys size equals: 4
]

{ #category : #tests }
ClassificationsAPIClientTest >> testChangeSearchEngineTo [

	| client entityContentsJSON |

	client := ClassificationsAPIClient
		          accessingAPIsWith: self restfulAPIClient
		          authenticatedWith: '1234'.
	client changeSearchEngineTo: 'davinci'.
	self httpClient
		whenSend: #entity:
		evaluate: [ :entityReceived | 
		entityContentsJSON := NeoJSONObject fromString: entityReceived contents ].
	self configureHttpClientToRespondWith: self happyResponseFromFile.
	client classify: 'movie is very good' lookingForExamplesIn: 'fileID'.

	self
		assert: entityContentsJSON query equals: 'movie is very good';
		assert: entityContentsJSON file equals: 'fileID';
		assert: ( entityContentsJSON at: #search_model ) equals: 'davinci';
		assert: entityContentsJSON model equals: 'ada';
		assert: entityContentsJSON keys size equals: 4
]

{ #category : #tests }
ClassificationsAPIClientTest >> testClassifyGiven [

	| client answerJSON |

	client := ClassificationsAPIClient
		          accessingAPIsWith: self restfulAPIClient
		          authenticatedWith: '1234'.
	self configureHttpClientToRespondWith: self happyResponseFromExamples.

	answerJSON := client classify: 'the weather is great' given: ( Array
			                with: #( 'the grass is green' 'happy' )
			                with: #( 'el cielo está lindo' 'happy' )
			                with: #( 'the soil is rotten' 'sad' ) ).

	self
		assert: answerJSON label equals: 'Happy';
		assert: ( answerJSON model beginsWith: 'ada' );
		assert: ( ( answerJSON at: #search_model ) beginsWith: 'ada' );
		assert: answerJSON object equals: 'classification';
		assert: ( answerJSON at: #selected_examples ) size equals: 3
]

{ #category : #tests }
ClassificationsAPIClientTest >> testClassifyLookingForExamplesIn [

	| client answerJSON |

	client := ClassificationsAPIClient
		          accessingAPIsWith: self restfulAPIClient
		          authenticatedWith: '1234'.
	self configureHttpClientToRespondWith: self happyResponseFromFile.

	answerJSON := client classify: 'movie is very good' lookingForExamplesIn: 'fileID'.

	self
		assert: answerJSON label equals: 'Positive';
		assert: ( answerJSON model beginsWith: 'ada' );
		assert: ( ( answerJSON at: #search_model ) beginsWith: 'ada' );
		assert: answerJSON object equals: 'classification';
		assert: ( answerJSON at: #selected_examples ) size equals: 2
]

{ #category : #tests }
ClassificationsAPIClientTest >> testDefaultEntityWhenUsingExamples [

	| client entityContentsJSON |

	client := ClassificationsAPIClient
		          accessingAPIsWith: self restfulAPIClient
		          authenticatedWith: '1234'.
	self httpClient
		whenSend: #entity:
		evaluate: [ :entityReceived | 
		entityContentsJSON := NeoJSONObject fromString: entityReceived contents ].
	self configureHttpClientToRespondWith: self happyResponseFromExamples.
	client classify: 'the weather is great' given: ( Array
			  with: #( 'the grass is green' 'happy' )
			  with: #( 'el cielo está lindo' 'happy' )
			  with: #( 'the soil is rotten' 'sad' ) ).

	self
		assert: entityContentsJSON query equals: 'the weather is great';
		assert: entityContentsJSON examples equals: ( Array
				  with: #( 'the grass is green' 'happy' )
				  with: #( 'el cielo está lindo' 'happy' )
				  with: #( 'the soil is rotten' 'sad' ) );
		assert: ( entityContentsJSON at: #search_model ) equals: 'ada';
		assert: entityContentsJSON model equals: 'ada';
		assert: entityContentsJSON keys size equals: 4
]

{ #category : #tests }
ClassificationsAPIClientTest >> testDefaultEntityWhenUsingFile [

	| client entityContentsJSON |

	client := ClassificationsAPIClient
		          accessingAPIsWith: self restfulAPIClient
		          authenticatedWith: '1234'.
	self httpClient
		whenSend: #entity:
		evaluate: [ :entityReceived | 
		entityContentsJSON := NeoJSONObject fromString: entityReceived contents ].
	self configureHttpClientToRespondWith: self happyResponseFromFile.
	client classify: 'movie is very good' lookingForExamplesIn: 'fileID'.

	self
		assert: entityContentsJSON query equals: 'movie is very good';
		assert: entityContentsJSON file equals: 'fileID';
		assert: ( entityContentsJSON at: #search_model ) equals: 'ada';
		assert: entityContentsJSON model equals: 'ada';
		assert: entityContentsJSON keys size equals: 4
]

{ #category : #tests }
ClassificationsAPIClientTest >> testDefaultUrl [

	| client url |

	client := ClassificationsAPIClient
		          accessingAPIsWith: self restfulAPIClient
		          authenticatedWith: '1234'.
	self httpClient whenSend: #url: evaluate: [ :urlReceived | url := urlReceived ].
	self configureHttpClientToRespondWith: self happyResponseFromExamples.

	client classify: 'the weather is great' given: ( Array
			  with: #( 'the grass is green' 'happy' )
			  with: #( 'el cielo está lindo' 'happy' )
			  with: #( 'the soil is rotten' 'sad' ) ).

	self assert: url equals: 'https://api.openai.com/v1/classifications' asUrl
]

{ #category : #tests }
ClassificationsAPIClientTest >> testFromExamplesMatchBest [

	| client entityContentsJSON |

	client := ClassificationsAPIClient
		          accessingAPIsWith: self restfulAPIClient
		          authenticatedWith: '1234'.
	client fromExamplesMatchBest: 2.
	self httpClient
		whenSend: #entity:
		evaluate: [ :entityReceived | 
		entityContentsJSON := NeoJSONObject fromString: entityReceived contents ].
	self configureHttpClientToRespondWith: self happyResponseFromFile.
	client classify: 'movie is very good' lookingForExamplesIn: 'fileID'.

	self
		assert: entityContentsJSON query equals: 'movie is very good';
		assert: entityContentsJSON file equals: 'fileID';
		assert: ( entityContentsJSON at: #search_model ) equals: 'ada';
		assert: entityContentsJSON model equals: 'ada';
		assert: ( entityContentsJSON at: #max_examples ) equals: 2;
		assert: entityContentsJSON keys size equals: 5
]

{ #category : #tests }
ClassificationsAPIClientTest >> testIncludeMetadata [

	| client entityContentsJSON |

	client := ClassificationsAPIClient
		          accessingAPIsWith: self restfulAPIClient
		          authenticatedWith: '1234'.
	client includeMetadata.
	self httpClient
		whenSend: #entity:
		evaluate: [ :entityReceived | 
		entityContentsJSON := NeoJSONObject fromString: entityReceived contents ].
	self configureHttpClientToRespondWith: self happyResponseFromFile.
	client classify: 'movie is very good' lookingForExamplesIn: 'fileID'.

	self
		assert: entityContentsJSON query equals: 'movie is very good';
		assert: entityContentsJSON file equals: 'fileID';
		assert: ( entityContentsJSON at: #search_model ) equals: 'ada';
		assert: entityContentsJSON model equals: 'ada';
		assert: ( entityContentsJSON at: #return_metadata );
		assert: entityContentsJSON keys size equals: 5
]

{ #category : #tests }
ClassificationsAPIClientTest >> testLabelAsOneOf [

	| client entityContentsJSON |

	client := ClassificationsAPIClient
		          accessingAPIsWith: self restfulAPIClient
		          authenticatedWith: '1234'.
	client labelAsOneOf: #( 'Positive' 'Negative' ).
	self httpClient
		whenSend: #entity:
		evaluate: [ :entityReceived | 
		entityContentsJSON := NeoJSONObject fromString: entityReceived contents ].
	self configureHttpClientToRespondWith: self happyResponseFromFile.
	client classify: 'movie is very good' lookingForExamplesIn: 'fileID'.

	self
		assert: entityContentsJSON query equals: 'movie is very good';
		assert: entityContentsJSON file equals: 'fileID';
		assert: ( entityContentsJSON at: #search_model ) equals: 'ada';
		assert: entityContentsJSON model equals: 'ada';
		assert: entityContentsJSON labels equals: #( 'Positive' 'Negative' );
		assert: entityContentsJSON keys size equals: 5
]

{ #category : #tests }
ClassificationsAPIClientTest >> testRaisingTemperatureTo [

	| client entityContentsJSON |

	client := ClassificationsAPIClient
		          accessingAPIsWith: self restfulAPIClient
		          authenticatedWith: '1234'.
	client raisingTemperatureTo: 0.9.
	self httpClient
		whenSend: #entity:
		evaluate: [ :entityReceived | 
		entityContentsJSON := NeoJSONObject fromString: entityReceived contents ].
	self configureHttpClientToRespondWith: self happyResponseFromFile.
	client classify: 'movie is very good' lookingForExamplesIn: 'fileID'.

	self
		assert: entityContentsJSON query equals: 'movie is very good';
		assert: entityContentsJSON file equals: 'fileID';
		assert: ( entityContentsJSON at: #search_model ) equals: 'ada';
		assert: entityContentsJSON model equals: 'ada';
		assert: entityContentsJSON temperature equals: 0.9;
		assert: entityContentsJSON keys size equals: 5
]
