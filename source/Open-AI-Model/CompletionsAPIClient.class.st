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

	"integer Optional Defaults to 16
	The maximum number of tokens to generate in the completion.
	The token count of your prompt plus max_tokens cannot exceed the model's context length. Most models 	have a context length of 2048 tokens (except for the newest models, which support 4096).
	
	https://beta.openai.com/docs/guides/fine-tuning/classification	
	For clasification tasks, choose classes that map to a single token. At inference time, specify max_tokens=1 since you only need the first token for classification."

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

{ #category : #configuring }
CompletionsAPIClient >> changeTemperatureTo: aNumber [

	"number Optional Defaults to 1
	What sampling temperature to use. Higher values means the model will take more risks.
	Try 0.9 for more creative applications, and 0 (argmax sampling) for ones with a well-defined answer.
	We generally recommend altering this or top_p but not both."

	parametersTemplate at: 'temperature' put: aNumber
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

{ #category : #configuring }
CompletionsAPIClient >> returnLikelyTokensUpTo: aNumber [

	"integer Optional
	Defaults to null
	Include the log probabilities on the logprobs most likely tokens, as well the chosen tokens. For example, if logprobs is 5, the API will return a list of the 5 most likely tokens. The API will always return the logprob of the sampled token, so there may be up to logprobs+1 elements in the response.
	The maximum value for logprobs is 5. If you need more than this, please contact support@openai.com and describe your use case.
	
	https://beta.openai.com/docs/guides/fine-tuning/classification	
	For clasification tasks, to get class log probabilities you can specify logprobs=5 (for 5 classes) when using your model"

	parametersTemplate at: 'logprobs' put: aNumber
]

{ #category : #'private - accessing' }
CompletionsAPIClient >> serviceUrl [

	^ self openAIUrl / self endpoint
]
