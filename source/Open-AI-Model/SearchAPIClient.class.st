Class {
	#name : #SearchAPIClient,
	#superclass : #OpenAIApiClient,
	#instVars : [
		'parametersTemplate',
		'engineId'
	],
	#category : #'Open-AI-Model'
}

{ #category : #configuring }
SearchAPIClient >> changeEngineTo: anEngineId [

	"https://beta.openai.com/docs/engines
Davinci - $0.0600 per 1K tokens - Good at: Complex intent, cause and effect, summarization for audience
Curie - $0.0060 per 1K tokens - Good at: Language translation, complex classification, text sentiment, summarization
Babbage - $0.0012 per 1K tokens - Good at: Moderate classification, semantic search classification
Ada - $0.0008 per 1K tokens - Parsing text, simple classification, address correction, keywords"

	engineId := anEngineId
]

{ #category : #'private - accessing' }
SearchAPIClient >> endpoint [

	^ 'search'
]

{ #category : #configuring }
SearchAPIClient >> includeMetadata [

	"boolean Optional Defaults to false
A special boolean flag for showing metadata. If set to true, each document entry in the returned JSON will contain a metadata field.
This flag only takes effect when file is set."

	parametersTemplate at: 'return_metadata' put: true
]

{ #category : #initialization }
SearchAPIClient >> initializeAccessingAPIsWith: apiClient authenticatedWith: anAPIKey [

	super initializeAccessingAPIsWith: apiClient authenticatedWith: anAPIKey.
	parametersTemplate := Dictionary new.
	
	"Defaulting to the cheapest model"
	self changeEngineTo: 'ada'.
]

{ #category : #configuring }
SearchAPIClient >> returnUpTo: aNumber [

	"integer Optional Defaults to 200
The maximum number of documents to be re-ranked and returned by search.
This flag only takes effect when file is set."

	parametersTemplate at: 'max_rerank' put: aNumber
]

{ #category : #processing }
SearchAPIClient >> search: aString against: aDocumentCollection [

	^ self postContaining: ( parametersTemplate copy
			    at: 'query' put: aString;
			    at: 'documents' put: aDocumentCollection;
			    yourself )
]

{ #category : #processing }
SearchAPIClient >> search: aString in: aFileId [

	^ self postContaining: ( parametersTemplate copy
			    at: 'query' put: aString;
			    at: 'file' put: aFileId;
			    yourself )
]

{ #category : #'private - accessing' }
SearchAPIClient >> serviceUrl [

	^ self openAIUrl / 'engines' / engineId / self endpoint
]
