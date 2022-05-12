Class {
	#name : #ClassificationsAPIClient,
	#superclass : #OpenAIApiClient,
	#instVars : [
		'parametersTemplate'
	],
	#category : #'Open-AI-Model'
}

{ #category : #configuring }
ClassificationsAPIClient >> changeEngineTo: anEngineId [

	"https://beta.openai.com/docs/engines
Davinci - $0.0600 per 1K tokens - Good at: Complex intent, cause and effect, summarization for audience
Curie - $0.0060 per 1K tokens - Good at: Language translation, complex classification, text sentiment, summarization
Babbage - $0.0012 per 1K tokens - Good at: Moderate classification, semantic search classification
Ada - $0.0008 per 1K tokens - Parsing text, simple classification, address correction, keywords"

	parametersTemplate at: 'model' put: anEngineId
]

{ #category : #configuring }
ClassificationsAPIClient >> changeSearchEngineTo: anEngineId [

	"https://beta.openai.com/docs/engines
Davinci - $0.0600 per 1K tokens - Good at: Complex intent, cause and effect, summarization for audience
Curie - $0.0060 per 1K tokens - Good at: Language translation, complex classification, text sentiment, summarization
Babbage - $0.0012 per 1K tokens - Good at: Moderate classification, semantic search classification
Ada - $0.0008 per 1K tokens - Parsing text, simple classification, address correction, keywords"

	parametersTemplate at: 'search_model' put: anEngineId
]

{ #category : #processing }
ClassificationsAPIClient >> classify: aString given: exampleCollection [

	^ self postContaining: ( parametersTemplate copy
			    at: 'query' put: aString;
			    at: 'examples' put: exampleCollection;
			    yourself )
]

{ #category : #processing }
ClassificationsAPIClient >> classify: aString lookingForExamplesIn: aFileId [

	^ self postContaining: ( parametersTemplate copy
			    at: 'query' put: aString;
			    at: 'file' put: aFileId;
			    yourself )
]

{ #category : #'private - accessing' }
ClassificationsAPIClient >> endpoint [

	^ 'classifications'
]

{ #category : #configuring }
ClassificationsAPIClient >> fromExamplesMatchBest: aNumber [

	"integer Optional Defaults to 200
The maximum number of examples to be ranked by Search when using file. Setting it to a higher value leads to improved accuracy but with increased latency and cost."

	parametersTemplate at: 'max_examples' put: aNumber
]

{ #category : #configuring }
ClassificationsAPIClient >> includeMetadata [

	"boolean Optional Defaults to false
	A special boolean flag for showing metadata. If set to true, each document entry in the returned JSON will contain a metadata field.
This flag only takes effect when file is set."

	parametersTemplate at: 'return_metadata' put: true
]

{ #category : #initialization }
ClassificationsAPIClient >> initializeAccessingAPIsWith: apiClient authenticatedWith: anAPIKey [

	super initializeAccessingAPIsWith: apiClient authenticatedWith: anAPIKey.
	parametersTemplate := Dictionary new.
	
	"Defaulting to the cheapest model"
	self changeEngineTo: 'ada'.
	self changeSearchEngineTo: 'ada'
]

{ #category : #configuring }
ClassificationsAPIClient >> labelAsOneOf: aLabelCollection [

	"array Optional Defaults to null
The set of categories being classified. If not specified, candidate labels will be automatically collected from the examples you provide. All the label strings will be normalized to be capitalized."

	parametersTemplate at: 'labels' put: aLabelCollection
]

{ #category : #configuring }
ClassificationsAPIClient >> raisingTemperatureTo: aNumber [

	"number Optional Defaults to 0
What sampling temperature to use. Higher values mean the model will take more risks. Try 0.9 for more creative applications, and 0 (argmax sampling) for ones with a well-defined answer."

	parametersTemplate at: 'temperature' put: aNumber
]

{ #category : #'private - accessing' }
ClassificationsAPIClient >> serviceUrl [

	^ self openAIUrl / self endpoint
]
