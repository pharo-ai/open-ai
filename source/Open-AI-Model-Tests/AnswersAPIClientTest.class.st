Class {
	#name : #AnswersAPIClientTest,
	#superclass : #APIClientTest,
	#category : #'Open-AI-Model-Tests'
}

{ #category : #private }
AnswersAPIClientTest >> europeResponse [

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
AnswersAPIClientTest >> restfulAPIClient [

	^ RESTfulAPIClient
		  buildingHttpClientWith: [ self httpClient ]
		  cachingIn: ExpiringCache onLocalMemory
]

{ #category : #tests }
AnswersAPIClientTest >> testAnswerAgainstGivenWithin [

	| client answerJSON |

	client := AnswersAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	self configureHttpClientToRespondWith: self europeResponse.

	answerJSON := client
		              answer: 'where is France?'
		              against: #( 'France is in Europe' 'Canada is in America' 'Japan is in Asia' )
		              given: ( Array with: #( 'how long is this car' '2 meters' ) )
		              within: 'this car is 2 meters long'.

	self
		assert: answerJSON answers equals: ( Array with: 'Europe' );
		assert: ( answerJSON model beginsWith: 'ada' );
		assert: ( answerJSON at: #search_model ) equals: 'ada';
		assert: answerJSON object equals: 'answer';
		assert: ( answerJSON at: #selected_documents ) size equals: 3
]

{ #category : #tests }
AnswersAPIClientTest >> testServiceUrl [

	| client |

	client := AnswersAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	
	self assertUrl: client serviceUrl equals: 'https://api.openai.com/v1/answers'
]
