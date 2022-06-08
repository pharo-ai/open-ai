Class {
	#name : #CompletionsAPIClient,
	#superclass : #OpenAIApiClient,
	#instVars : [
		'parametersTemplate'
	],
	#category : #'Open-AI-Model'
}

{ #category : #configuring }
CompletionsAPIClient >> changeMaximumNumberOfTokensTo: aNumber [

	"max_tokens integer Optional Defaults to 16
	The maximum number of tokens to generate in the completion.
	The token count of your prompt plus max_tokens cannot exceed the model's context length. Most models 	have a context length of 2048 tokens (except for the newest models, which support 4096)."

	parametersTemplate at: 'max_tokens' put: aNumber
]

{ #category : #configuring }
CompletionsAPIClient >> changeModelTo: aModelId [

	"https://beta.openai.com/docs/models/gpt-3
text-davinci-002	Most capable GPT-3 model. Can do any task the other models can do, often with less context. In addition to responding to prompts, also supports inserting completions within text.
text-curie-001	Very capable, but faster and lower cost than Davinci.
text-babbage-001	Capable of straightforward tasks, very fast, and lower cost.
text-ada-001	Capable of very simple tasks, usually the fastest model in the GPT-3 series, and lowest cost."

	parametersTemplate at: 'model' put: aModelId
]

{ #category : #processing }
CompletionsAPIClient >> complete: aString [

	^ self postContaining: ( self completionsParametersPrompting: aString )
]

{ #category : #'private - accessing' }
CompletionsAPIClient >> completionsParametersPrompting: aString [

	^ parametersTemplate copy
		  at: 'prompt' put: aString;
		  yourself
]

{ #category : #'private - accessing' }
CompletionsAPIClient >> endpoint [

	^ 'completions'
]

{ #category : #initialization }
CompletionsAPIClient >> initializeAccessingAPIsWith: apiClient authenticatedWith: anAPIKey [

	super initializeAccessingAPIsWith: apiClient authenticatedWith: anAPIKey.
	parametersTemplate := Dictionary new.

	self changeMaximumNumberOfTokensTo: 1.
	
	"Defaulting to the cheapest model"
	self changeModelTo: 'text-ada-001'.
]

{ #category : #'private - accessing' }
CompletionsAPIClient >> serviceUrl [

	^ self openAIUrl / self endpoint
]
