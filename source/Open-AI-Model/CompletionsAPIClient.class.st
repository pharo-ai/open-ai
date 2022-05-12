Class {
	#name : #CompletionsAPIClient,
	#superclass : #OpenAIApiClient,
	#instVars : [
		'maximumNumberOfTokens',
		'engineId'
	],
	#category : #'Open-AI-Model'
}

{ #category : #configuring }
CompletionsAPIClient >> changeEngineTo: anEngineId [

	"https://beta.openai.com/docs/engines
Davinci - $0.0600 per 1K tokens - Good at: Complex intent, cause and effect, summarization for audience
Curie - $0.0060 per 1K tokens - Good at: Language translation, complex classification, text sentiment, summarization
Babbage - $0.0012 per 1K tokens - Good at: Moderate classification, semantic search classification
Ada - $0.0008 per 1K tokens - Parsing text, simple classification, address correction, keywords"

	engineId := anEngineId
]

{ #category : #configuring }
CompletionsAPIClient >> changeMaximumNumberOfTokensTo: aNumber [

	"max_tokens integer Optional Defaults to 16
	The maximum number of tokens to generate in the completion.
	The token count of your prompt plus max_tokens cannot exceed the model's context length. Most models have a context length of 2048 tokens (except davinci-codex, which supports 4096)."

	maximumNumberOfTokens := aNumber
]

{ #category : #processing }
CompletionsAPIClient >> complete: aString [

	^ self postContaining: ( self completionsParametersPrompting: aString )
]

{ #category : #'private - accessing' }
CompletionsAPIClient >> completionsParametersPrompting: aString [

	^ Dictionary new
		  at: 'prompt' put: aString;
		  at: 'max_tokens' put: maximumNumberOfTokens;
		  yourself
]

{ #category : #'private - accessing' }
CompletionsAPIClient >> endpoint [

	^ 'completions'
]

{ #category : #initialization }
CompletionsAPIClient >> initializeAccessingAPIsWith: apiClient authenticatedWith: anAPIKey [

	super initializeAccessingAPIsWith: apiClient authenticatedWith: anAPIKey.

	self changeMaximumNumberOfTokensTo: 1.
	
	"Defaulting to the cheapest model"
	self changeEngineTo: 'ada'.
]

{ #category : #'private - accessing' }
CompletionsAPIClient >> serviceUrl [

	^ self openAIUrl / 'engines' / engineId / self endpoint
]
