Class {
	#name : #FilesAPIClient,
	#superclass : #OpenAIApiClient,
	#category : #'Open-AI-Model'
}

{ #category : #'class initialization' }
FilesAPIClient class >> initialize [

	<ignoreForCoverage>
	| extensionsMap |

	extensionsMap := ZnMimeType extensionsMap.
	extensionsMap at: 'jsonl' ifAbsentPut: [ ZnMimeType applicationOctetStream ]
]

{ #category : #'private - accessing' }
FilesAPIClient >> endpoint [

	^ 'files'
]

{ #category : #processing }
FilesAPIClient >> idForProcessed: aFileReference intendedFor: aPurpose waiting: aTime [

	| id |

	id := ( self upload: aFileReference intendedFor: aPurpose ) at: 'id'.

	^ self wait: aTime forProcessingOf: id thenDo: [ id ]
]

{ #category : #processing }
FilesAPIClient >> listFiles [

	^ client getAt: self serviceUrl
		  configuredBy: [ :request | request headers setBearerTokenTo: apiKey ]
		  withSuccessfulResponseDo: [ :response | NeoJSONObject fromString: response ]
]

{ #category : #processing }
FilesAPIClient >> removeFileIdentifiedBy: aFileId [

	^ client deleteAt: self serviceUrl / aFileId
		  configuredBy: [ :request | request headers setBearerTokenTo: apiKey ]
		  withSuccessfulResponseDo: [ :response | NeoJSONObject fromString: response ]
]

{ #category : #'private - processing' }
FilesAPIClient >> retrieveFileIdentifiedBy: aFileId [

	^ client getAt: self serviceUrl / aFileId
		  configuredBy: [ :request | request headers setBearerTokenTo: apiKey ]
		  withSuccessfulResponseDo: [ :response | NeoJSONObject fromString: response ]
]

{ #category : #'private - accessing' }
FilesAPIClient >> serviceUrl [

	^ self openAIUrl / self endpoint
]

{ #category : #'private - processing' }
FilesAPIClient >> upload: aFileReference intendedFor: aPurpose [

	^ client
		  postAt: self serviceUrl
		  configuredBy: [ :request | 
			  ( request headers setBearerTokenTo: apiKey ) + ( request body multiPart: [ :parts | 
				    parts
					    fieldNamed: 'purpose' pairedTo: aPurpose;
					    fieldNamed: 'file' attaching: aFileReference
				    ] )
			  ]
		  withSuccessfulResponseDo: [ :response | NeoJSONObject fromString: response ]
]

{ #category : #'private - processing' }
FilesAPIClient >> wait: aTime forProcessingOf: aFileId thenDo: aBlock [

	| wasProcessed |

	wasProcessed := Retry
		                value: [ ( self retrieveFileIdentifiedBy: aFileId ) status = 'processed' ]
		                configuredBy: [ :retry | 
			                retry
				                when: [ :alreadyProcessed | alreadyProcessed not ];
				                upTo: aTime seconds timesEvery: 1 second
			                ].
	^ wasProcessed
		  ifTrue: aBlock
		  ifFalse: [ Error signal: 'Took too long to process, try again later' ]
]
