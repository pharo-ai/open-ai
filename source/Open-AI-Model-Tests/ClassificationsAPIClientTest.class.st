Class {
	#name : #ClassificationsAPIClientTest,
	#superclass : #TestCase,
	#category : #'Open-AI-Model-Tests'
}

{ #category : #tests }
ClassificationsAPIClientTest >> testServiceUrl [

	| client |

	client := ClassificationsAPIClient authenticatedWith: ''.
	self assertUrl: client serviceUrl equals: 'https://api.openai.com/v1/classifications'
]
