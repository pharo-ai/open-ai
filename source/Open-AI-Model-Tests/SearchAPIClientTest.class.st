Class {
	#name : #SearchAPIClientTest,
	#superclass : #TestCase,
	#category : #'Open-AI-Model-Tests'
}

{ #category : #tests }
SearchAPIClientTest >> testServiceUrl [

	| client |

	client := SearchAPIClient authenticatedWith: ''.
	self assertUrl: client serviceUrl equals: 'https://api.openai.com/v1/engines/ada/search'
]
