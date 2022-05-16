Class {
	#name : #OpenAIApiClient,
	#superclass : #Object,
	#instVars : [
		'apiKey',
		'client'
	],
	#category : #'Open-AI-Model'
}

{ #category : #'instance creation' }
OpenAIApiClient class >> accessingAPIsWith: apiClient authenticatedWith: anAPIKey [

	^ self new initializeAccessingAPIsWith: apiClient authenticatedWith: anAPIKey
]

{ #category : #'instance creation' }
OpenAIApiClient class >> authenticatedWith: anAPIKey [

	^ self accessingAPIsWith: RESTfulAPIClient cachingOnLocalMemory authenticatedWith: anAPIKey
]

{ #category : #testing }
OpenAIApiClient class >> isAbstract [

	<ignoreForCoverage>
	^ self =  OpenAIApiClient
]

{ #category : #initialization }
OpenAIApiClient >> initializeAccessingAPIsWith: apiClient authenticatedWith: anAPIKey [

	apiKey := anAPIKey.
	client := apiClient
]

{ #category : #'private - accessing' }
OpenAIApiClient >> openAIUrl [

	^ 'https://api.openai.com' asUrl / self openAIVersion
]

{ #category : #'private - accessing' }
OpenAIApiClient >> openAIVersion [

	^ 'v1'
]

{ #category : #'private - processing' }
OpenAIApiClient >> postContaining: aBodyContent [

	^ client postAt: self serviceUrl
		  configuredBy: [ :request | 
		  ( request headers setBearerTokenTo: apiKey ) + ( request body json: aBodyContent ) ]
		  withSuccessfulResponseDo: [ :response | NeoJSONObject fromString: response ]
]

{ #category : #'private - accessing' }
OpenAIApiClient >> serviceUrl [

	^ self subclassResponsibility
]
