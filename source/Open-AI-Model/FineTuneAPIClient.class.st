Class {
	#name : #FineTuneAPIClient,
	#superclass : #OpenAIApiClient,
	#instVars : [
		'parametersTemplate'
	],
	#category : #'Open-AI-Model'
}

{ #category : #processing }
FineTuneAPIClient >> cancelFineTuneIdentifiedBy: aFineTuneId [

	^ client
		  postAt: self serviceUrl / aFineTuneId / 'cancel'
		  configuredBy: [ :request | request headers setBearerTokenTo: apiKey ]
		  withSuccessfulResponseDo: [ :response | NeoJSONObject fromString: response ]
]

{ #category : #configuring }
FineTuneAPIClient >> changeModelTo: aModelId [

	"string Optional
	Defaults to curie
	The name of the base model to fine-tune. You can select one of 'ada', 'babbage', 'curie', or 'davinci'."

	parametersTemplate at: 'model' put: aModelId
]

{ #category : #configuring }
FineTuneAPIClient >> changeNumberOfClassesTo: aNumber [

	"integer Optional
	Defaults to null
	The number of classes in a classification task.
	This parameter is required for multiclass classification."

	parametersTemplate at: 'classification_n_classes' put: aNumber
]

{ #category : #configuring }
FineTuneAPIClient >> changeSuffixTo: aString [

	"string Optional
	Defaults to null
	A string of up to 40 characters that will be added to your fine-tuned model name.
	For example, a suffix of 'custom-model-name' would produce a model name like ada:ft-your-org:custom-model-name-2022-02-15-04-21-04."

	parametersTemplate at: 'suffix' put: aString
]

{ #category : #configuring }
FineTuneAPIClient >> computeClassificationMetrics [

	"boolean Optional
	Defaults to false
	If set, we calculate classification-specific metrics such as accuracy and F-1 score using the validation set at the end of every epoch. These metrics can be viewed in the results file.
	In order to compute classification metrics, you must provide a validation_file. Additionally, you must specify classification_n_classes for multiclass classification or classification_positive_class for binary classification."

	parametersTemplate at: 'compute_classification_metrics' put: true
]

{ #category : #processing }
FineTuneAPIClient >> deleteFineTuneNamed: aFineTuneModel [

	^ client
		  deleteAt: self openAIUrl / 'models' / aFineTuneModel
		  configuredBy: [ :request | request headers setBearerTokenTo: apiKey ]
		  withSuccessfulResponseDo: [ :response | NeoJSONObject fromString: response ]
]

{ #category : #'private - accessing' }
FineTuneAPIClient >> endpoint [

	^ 'fine-tunes'
]

{ #category : #initialization }
FineTuneAPIClient >> initializeAccessingAPIsWith: apiClient authenticatedWith: anAPIKey [

	super initializeAccessingAPIsWith: apiClient authenticatedWith: anAPIKey.
	parametersTemplate := Dictionary new.
	
	"Defaulting to the cheapest model"
	self changeModelTo: 'ada'.
]

{ #category : #processing }
FineTuneAPIClient >> listFineTunes [

	^ client
		  getAt: self serviceUrl
		  configuredBy: [ :request | request headers setBearerTokenTo: apiKey ]
		  withSuccessfulResponseDo: [ :response | ( NeoJSONObject fromString: response ) data ]
]

{ #category : #processing }
FineTuneAPIClient >> retrieveFineTuneIdentifiedBy: aFineTuneId [

	^ client getAt: self serviceUrl / aFineTuneId
		  configuredBy: [ :request | request headers setBearerTokenTo: apiKey ]
		  withSuccessfulResponseDo: [ :response | NeoJSONObject fromString: response ]
]

{ #category : #'private - accessing' }
FineTuneAPIClient >> serviceUrl [

	^ self openAIUrl / self endpoint
]

{ #category : #processing }
FineTuneAPIClient >> trainUsing: aFileId [

	^ self postContaining: ( parametersTemplate copy
			    at: 'training_file' put: aFileId;
			    yourself )
]

{ #category : #configuring }
FineTuneAPIClient >> validateUsing: aFileId [

	"string Optional
	The ID of an uploaded file that contains validation data.
	If you provide this file, the data is used to generate validation metrics periodically during fine-tuning. These metrics can be viewed in the fine-tuning results file. Your train and validation data should be mutually exclusive.
	Your dataset must be formatted as a JSONL file, where each validation example is a JSON object with the keys 'prompt' and 'completion'. Additionally, you must upload your file with the purpose fine-tune."

	parametersTemplate at: 'validation_file' put: aFileId
]
