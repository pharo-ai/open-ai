Class {
	#name : #AnswersAPIClient,
	#superclass : #OpenAIApiClient,
	#instVars : [
		'parametersTemplate'
	],
	#category : #'Open-AI-Model'
}

{ #category : #processing }
AnswersAPIClient >> answer: aQuestion against: aDocumentCollection given: exampleCollection within: anExampleContext [

	^ self postContaining: ( self answersParametersToAnswer: aQuestion
			    against: aDocumentCollection
			    given: exampleCollection
			    within: anExampleContext )
]

{ #category : #processing }
AnswersAPIClient >> answer: aQuestion querying: aFileId given: exampleCollection within: anExampleContext [

	^ self postContaining: ( self answersParametersToAnswer: aQuestion
			    querying: aFileId
			    given: exampleCollection
			    within: anExampleContext )
]

{ #category : #'private - accessing' }
AnswersAPIClient >> answersParametersToAnswer: aQuestion against: aDocumentCollection given: exampleCollection within: anExampleContext [

	^ parametersTemplate copy
		  at: 'question' put: aQuestion;
		  at: 'documents' put: aDocumentCollection;
		  at: 'examples' put: exampleCollection;
		  at: 'examples_context' put: anExampleContext;
		  yourself
]

{ #category : #'private - accessing' }
AnswersAPIClient >> answersParametersToAnswer: aQuestion querying: aFileId given: exampleCollection within: anExampleContext [

	^ parametersTemplate copy
		  at: 'question' put: aQuestion;
		  at: 'file' put: aFileId;
		  at: 'examples' put: exampleCollection;
		  at: 'examples_context' put: anExampleContext;
		  yourself
]

{ #category : #configuring }
AnswersAPIClient >> changeModelTo: anEngineId [

	"https://beta.openai.com/docs/engines
Davinci - $0.0600 per 1K tokens - Good at: Complex intent, cause and effect, summarization for audience
Curie - $0.0060 per 1K tokens - Good at: Language translation, complex classification, text sentiment, summarization
Babbage - $0.0012 per 1K tokens - Good at: Moderate classification, semantic search classification
Ada - $0.0008 per 1K tokens - Parsing text, simple classification, address correction, keywords"

	parametersTemplate at: 'model' put: anEngineId
]

{ #category : #configuring }
AnswersAPIClient >> changeSearchEngineTo: anEngineId [

	"https://beta.openai.com/docs/engines
Davinci - $0.0600 per 1K tokens - Good at: Complex intent, cause and effect, summarization for audience
Curie - $0.0060 per 1K tokens - Good at: Language translation, complex classification, text sentiment, summarization
Babbage - $0.0012 per 1K tokens - Good at: Moderate classification, semantic search classification
Ada - $0.0008 per 1K tokens - Parsing text, simple classification, address correction, keywords"

	parametersTemplate at: 'search_model' put: anEngineId
]

{ #category : #'private - accessing' }
AnswersAPIClient >> endpoint [

	^ 'answers'
]

{ #category : #configuring }
AnswersAPIClient >> includeMetadata [

	"boolean Optional Defaults to false
A special boolean flag for showing metadata. If set to true, each document entry in the returned JSON will contain a metadata field."

	parametersTemplate at: 'return_metadata' put: true
]

{ #category : #initialization }
AnswersAPIClient >> initializeAccessingAPIsWith: apiClient authenticatedWith: anAPIKey [

	super initializeAccessingAPIsWith: apiClient authenticatedWith: anAPIKey.
	parametersTemplate := Dictionary new.

	"Defaulting to the cheapest model"
	self changeModelTo: 'ada'.
	self changeSearchEngineTo: 'ada'
]

{ #category : #configuring }
AnswersAPIClient >> returnUpTo: aNumber [

	"integer Optional Defaults to 200
The maximum number of documents to be ranked by Search when using file. Setting it to a higher value leads to improved accuracy but with increased latency and cost."

	parametersTemplate at: 'max_rerank' put: aNumber
]

{ #category : #'private - accessing' }
AnswersAPIClient >> serviceUrl [

	^ self openAIUrl / self endpoint
]

{ #category : #configuring }
AnswersAPIClient >> stopAt: stopSequenceCollection [

	"string or array, Optional, Defaults to null
Up to 4 sequences where the API will stop generating further tokens. The returned text will not contain the stop sequence."

	parametersTemplate at: 'stop' put: stopSequenceCollection
]
