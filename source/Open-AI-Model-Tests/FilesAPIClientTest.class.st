Class {
	#name : #FilesAPIClientTest,
	#superclass : #TestCase,
	#category : #'Open-AI-Model-Tests'
}

{ #category : #tests }
FilesAPIClientTest >> testServiceUrl [

	| client |

	client := FilesAPIClient authenticatedWith: ''.
	self assertUrl: client serviceUrl equals: 'https://api.openai.com/v1/files'
]
