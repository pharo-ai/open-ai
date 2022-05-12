Class {
	#name : #AnswersAPIClientTest,
	#superclass : #TestCase,
	#category : #'Open-AI-Model-Tests'
}

{ #category : #tests }
AnswersAPIClientTest >> testServiceUrl [

	| client |

	client := AnswersAPIClient authenticatedWith: ''.
	self assertUrl: client serviceUrl equals: 'https://api.openai.com/v1/answers'
]
