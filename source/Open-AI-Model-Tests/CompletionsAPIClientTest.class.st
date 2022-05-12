Class {
	#name : #CompletionsAPIClientTest,
	#superclass : #TestCase,
	#category : #'Open-AI-Model-Tests'
}

{ #category : #tests }
CompletionsAPIClientTest >> testServiceUrl [

	| client |

	client := CompletionsAPIClient authenticatedWith: ''.
	self assertUrl: client serviceUrl equals: 'https://api.openai.com/v1/engines/ada/completions'
]
