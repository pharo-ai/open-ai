Class {
	#name : #ClassificationsAPIClientTest,
	#superclass : #APIClientTest,
	#category : #'Open-AI-Model-Tests'
}

{ #category : #private }
ClassificationsAPIClientTest >> happyFromExamplesResponse [

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
ClassificationsAPIClientTest >> happyFromFileResponse [

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
ClassificationsAPIClientTest >> testClassifyGiven [

	| client answerJSON |

	client := ClassificationsAPIClient
		          accessingAPIsWith: self restfulAPIClient
		          authenticatedWith: '1234'.
	self configureHttpClientToRespondWith: self happyFromExamplesResponse.

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
	self configureHttpClientToRespondWith: self happyFromFileResponse.

	answerJSON := client classify: 'movie is very good' lookingForExamplesIn: 'fileID'.

	self
		assert: answerJSON label equals: 'Positive';
		assert: ( answerJSON model beginsWith: 'ada' );
		assert: ( ( answerJSON at: #search_model ) beginsWith: 'ada' );
		assert: answerJSON object equals: 'classification';
		assert: ( answerJSON at: #selected_examples ) size equals: 2
]

{ #category : #tests }
ClassificationsAPIClientTest >> testDefaultUrl [

	| client url |

	client := ClassificationsAPIClient
		          accessingAPIsWith: self restfulAPIClient
		          authenticatedWith: '1234'.
	self httpClient whenSend: #url: evaluate: [ :urlReceived | url := urlReceived ].
	self configureHttpClientToRespondWith: self happyFromExamplesResponse.

	client classify: 'the weather is great' given: ( Array
			  with: #( 'the grass is green' 'happy' )
			  with: #( 'el cielo está lindo' 'happy' )
			  with: #( 'the soil is rotten' 'sad' ) ).

	self assert: url equals: 'https://api.openai.com/v1/classifications' asUrl
]
