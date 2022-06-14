Class {
	#name : #FilesAPIClientTest,
	#superclass : #APIClientTest,
	#category : #'Open-AI-Model-Tests'
}

{ #category : #private }
FilesAPIClientTest >> deleteResponse [

	^ self jsonOkResponseWith: '{
   "object":"file",
   "id":"fileID",
   "deleted":true
}'
]

{ #category : #private }
FilesAPIClientTest >> filesResponse [

	^ self jsonOkResponseWith: '{
   "object":"list",
   "data":[
      {
         "object":"file",
         "id":"file-KxXjJO4w9wJcQHSrHGXrCntf",
         "purpose":"classifications",
         "filename":"classification-example.jsonl",
         "bytes":288,
         "created_at":1652987363,
         "status":"processed",
         "status_details":null
      },
      {
         "object":"file",
         "id":"file-y6VFEI58R1FOWCsMeWoJU8k4",
         "purpose":"fine-tune",
         "filename":"fine-tune-example.jsonl",
         "bytes":67,
         "created_at":1652987364,
         "status":"processed",
         "status_details":null
      },
      {
         "object":"file",
         "id":"file-Z4GcDYCQBPRq5su5WNmc5HHz",
         "purpose":"answers",
         "filename":"answers-example.jsonl",
         "bytes":225,
         "created_at":1652987361,
         "status":"processed",
         "status_details":null
      },
      {
         "object":"file",
         "id":"file-MirWmjyEYAgxvdkY3wHTdA9S",
         "purpose":"search",
         "filename":"search-example.jsonl",
         "bytes":388,
         "created_at":1652987366,
         "status":"processed",
         "status_details":null
      }
   ]
}'
]

{ #category : #private }
FilesAPIClientTest >> restfulAPIClient [

	^ RESTfulAPIClient
		  buildingHttpClientWith: [ self httpClient ]
		  cachingIn: ExpiringCache onLocalMemory
]

{ #category : #tests }
FilesAPIClientTest >> testDeleteFileIdentifiedBy [

	| client answerJSON url |

	client := FilesAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	self httpClient whenSend: #url: evaluate: [ :urlReceived | url := urlReceived ].
	self configureHttpClientToRespondWith: self deleteResponse.

	answerJSON := client deleteFileIdentifiedBy: 'fileID'.

	self
		assert: answerJSON object equals: 'file';
		assert: answerJSON deleted;
		assert: answerJSON id equals: 'fileID'.

	self assert: url equals: 'https://api.openai.com/v1/files/fileID' asUrl
]

{ #category : #tests }
FilesAPIClientTest >> testIdForProcessedIntendedForWaiting [

	| client parts fileReference |

	client := FilesAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	parts := OrderedCollection new.
	self httpClient whenSend: #addPart: evaluate: [ :entityReceived | parts add: entityReceived ].
	self configureHttpClientToRespondWith: self uploadResponse.
	fileReference := 'open-ai-test-file.jsonl' asFileReference.

	fileReference createFile.
	[ 
	self
		assert: ( client idForProcessed: fileReference intendedFor: 'answers' waiting: 4 seconds )
		equals: 'fileID'.
	self assert: parts size equals: 2.
	self
		assert: ( parts first headers at: 'Content-Disposition' ) equals: 'form-data;name="purpose"';
		assert: parts first entity string equals: 'answers'.
	self
		assert: ( parts last headers at: 'Content-Disposition' )
		equals: 'form-data;name="file";filename="open-ai-test-file.jsonl"'.
	self
	] ensure: [ fileReference delete ]
]

{ #category : #tests }
FilesAPIClientTest >> testListFiles [

	| client url answerJSON |

	client := FilesAPIClient accessingAPIsWith: self restfulAPIClient authenticatedWith: '1234'.
	self httpClient whenSend: #url: evaluate: [ :urlReceived | url := urlReceived ].
	self configureHttpClientToRespondWith: self filesResponse.

	answerJSON := client listFiles.

	self assert: url equals: 'https://api.openai.com/v1/files' asUrl.
	self
		assert: answerJSON object equals: 'list';
		assert: ( answerJSON at: #data ) size equals: 4.
	( answerJSON at: #data ) doWithIndex: [ :item :index | 
		self
			assert: item object equals: 'file';
			assert: item id notEmpty;
			assert: item purpose notEmpty;
			assert: ( item filename endsWith: '.jsonl' );
			assert: item bytes strictlyPositive;
			assert: item status equals: 'processed';
			assert: ( item at: #created_at ) strictlyPositive;
			assert: ( item at: #status_details ) isNil
		]
]

{ #category : #private }
FilesAPIClientTest >> uploadResponse [

	^ self jsonOkResponseWith: '{
   "object":"file",
   "id":"fileID",
   "purpose":"answers",
   "filename":"answers-example.jsonl",
   "bytes":225,
   "created_at":1652989991,
   "status":"processed",
   "status_details":null
}'
]
