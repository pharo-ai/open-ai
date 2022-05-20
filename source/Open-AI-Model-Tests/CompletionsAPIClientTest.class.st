Class {
	#name : #CompletionsAPIClientTest,
	#superclass : #APIClientTest,
	#category : #'Open-AI-Model-Tests'
}

{ #category : #private }
CompletionsAPIClientTest >> restfulAPIClient [

	^ RESTfulAPIClient
		  buildingHttpClientWith: [ self httpClient ]
		  cachingIn: ExpiringCache onLocalMemory
]

{ #category : #tests }
CompletionsAPIClientTest >> testChangeEngineTo [

	| client url |

	client := CompletionsAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	client changeEngineTo: 'davinci'.
	self httpClient whenSend: #url: evaluate: [ :urlReceived | url := urlReceived ].
	self configureHttpClientToRespondWith: self thatResponse.

	client complete: 'This is the day'.

	self assert: url equals: 'https://api.openai.com/v1/engines/davinci/completions' asUrl
]

{ #category : #tests }
CompletionsAPIClientTest >> testChangeMaximumNumberOfTokensTo [

	| client entityContentsJSON |

	client := CompletionsAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	client changeMaximumNumberOfTokensTo: 10.
	self httpClient
		whenSend: #entity:
		evaluate: [ :entityReceived | 
		entityContentsJSON := NeoJSONObject fromString: entityReceived contents ].
	self configureHttpClientToRespondWith: self thatResponse.
	client complete: 'This is the day'.

	self
		assert: entityContentsJSON prompt equals: 'This is the day';
		assert: ( entityContentsJSON at: #max_tokens ) equals: 10;
		assert: entityContentsJSON keys size equals: 2
]

{ #category : #tests }
CompletionsAPIClientTest >> testComplete [

	| client answerJSON |

	client := CompletionsAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	self configureHttpClientToRespondWith: self thatResponse.

	answerJSON := client complete: 'This is the day'.

	self withTheOnlyOneIn: answerJSON choices do: [ :choice | 
		self
			assert: choice text equals: ' that';
			assert: choice index equals: 0;
			assert: ( choice at: #logProbs ) equals: nil;
			assert: ( choice at: #finish_reason ) equals: 'length'
		].
	self
		assert: ( answerJSON model beginsWith: 'ada' );
		assert: answerJSON object equals: 'text_completion'
]

{ #category : #tests }
CompletionsAPIClientTest >> testDefaultEntity [

	| client entityContentsJSON |

	client := CompletionsAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	self httpClient
		whenSend: #entity:
		evaluate: [ :entityReceived | 
		entityContentsJSON := NeoJSONObject fromString: entityReceived contents ].
	self configureHttpClientToRespondWith: self thatResponse.
	client complete: 'This is the day'.

	self
		assert: entityContentsJSON prompt equals: 'This is the day';
		assert: ( entityContentsJSON at: #max_tokens ) equals: 1;
		assert: entityContentsJSON keys size equals: 2
]

{ #category : #tests }
CompletionsAPIClientTest >> testDefaultUrl [

	| client url |

	client := CompletionsAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	self httpClient whenSend: #url: evaluate: [ :urlReceived | url := urlReceived ].
	self configureHttpClientToRespondWith: self thatResponse.

	client complete: 'This is the day'.

	self assert: url equals: 'https://api.openai.com/v1/engines/ada/completions' asUrl
]

{ #category : #private }
CompletionsAPIClientTest >> thatResponse [

	^ self jsonOkResponseWith: '{
   "id":"cmpl-59ZjzlfD4DpNnWGYuUVeanFRfc0aP",
   "object":"text_completion",
   "created":1652964023,
   "model":"ada",
   "choices":[
      {
         "text":" that",
         "index":0,
         "logprobs":null,
         "finish_reason":"length"
      }
   ]
}'
]
