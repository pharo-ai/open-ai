Class {
	#name : #OpenAIExamples,
	#superclass : #Object,
	#category : #'Open-AI-Examples'
}

{ #category : #accessing }
OpenAIExamples >> advancedTweetClassificationViaCompletion [

	| apiClient seedText response |

	"https://beta.openai.com/examples/default-adv-tweet-classifier"
	apiClient := self completionsAPIClient.
	apiClient
		changeMaximumNumberOfTokensTo: 60;
		changeModelTo: 'text-davinci-002';
		changeTemperatureTo: 0.
	seedText := 'Classify the sentiment in these tweets:

1. "I can''t stand homework"
2. "This sucks. I''m bored 😠"
3. "I can''t wait for Halloween!!!"
4. "My cat is adorable ❤️❤️"
5. "I hate chocolate"

Tweet sentiment ratings:'.

	response := apiClient complete: seedText.

	^ '<1s><2s>' expandMacrosWith: seedText with: ( ( response at: 'choices' ) first at: 'text' )
]

{ #category : #accessing }
OpenAIExamples >> answers [

	| response |

	response := self answersAPIClient
		            answer: 'where is France?'
		            against: #( 'France is in Europe' 'Canada is in America' 'Japan is in Asia' )
		            given: ( Array with: #( 'how long is this car' '2 meters' ) )
		            within: 'this car is 2 meters long'.

	^ self cleanDelimitersFrom: ( response at: 'answers' )
]

{ #category : #'private - accessing' }
OpenAIExamples >> answersAPIClient [

	| apiClient |

	apiClient := AnswersAPIClient
		             accessingAPIsWith: RESTfulAPIClient cachingOnLocalMemory
		             authenticatedWith: self apiKey.
	apiClient
		changeModelTo: 'ada';
		changeSearchEngineTo: 'ada';
		stopAt: #( '\n' '<|endoftext|>' ).

	^ apiClient
]

{ #category : #'private - accessing' }
OpenAIExamples >> answersExampleFileReference [

	^ self examplesDirectory / 'answers-example.jsonl'
]

{ #category : #'private - accessing' }
OpenAIExamples >> answersFileId [

	^ self idForFileNamed: self answersExampleFileReference intendedFor: 'answers'
]

{ #category : #accessing }
OpenAIExamples >> answersFromFile [

	| id apiClient response |

	id := self answersFileId.

	apiClient := self answersAPIClient.
	apiClient returnUpTo: 5.

	response := apiClient
		            answer: 'where is France?'
		            querying: id
		            given: ( Array with: #( 'how long is this car' '2 meters' ) )
		            within: 'this car is 2 meters long'.

	^ self cleanDelimitersFrom: ( response at: 'answers' )
]

{ #category : #'private - accessing' }
OpenAIExamples >> apiKey [

	^ 'open-ai/apikey.secret' asFileReference contents
]

{ #category : #'private - processing' }
OpenAIExamples >> ask: apiClient toCancelFineTuneIdentifiedBy: fineTune [

	^ fineTune status = 'cancelled'
		  ifTrue: [ 'The fine tune <1s> has already been canceled.' expandMacrosWith: fineTune id ]
		  ifFalse: [ apiClient cancelFineTuneIdentifiedBy: fineTune id ]
]

{ #category : #'private - processing' }
OpenAIExamples >> ask: apiClient toDelete: modelName relatedTo: fineTune [

	^ [ apiClient deleteFineTunedModelNamed: modelName ]
		  on: HTTPClientError notFound
		  do: [ :ex | 
			  ex return:
				  ( 'The model <1s> has already been deleted but the related fine tune <2s> is still listed, it should be purged eventually by Open AI.'
					    expandMacrosWith: modelName
					    with: fineTune id )
			  ]
]

{ #category : #accessing }
OpenAIExamples >> classifications [

	| apiClient response |

	apiClient := self classificationsAPIClient.
	apiClient labelAsOneOf: #( 'happy' 'sad' ).

	response := apiClient classify: 'the weather is great' given: ( Array
			              with: #( 'the grass is green' 'happy' )
			              with: #( 'the sky is pretty' 'happy' )
			              with: #( 'the soil is rotten' 'sad' ) ).
	^ response at: 'label'
]

{ #category : #'private - accessing' }
OpenAIExamples >> classificationsAPIClient [

	| apiClient |

	apiClient := ClassificationsAPIClient
		             accessingAPIsWith: RESTfulAPIClient cachingOnLocalMemory
		             authenticatedWith: self apiKey.
	apiClient
		changeModelTo: 'ada';
		changeSearchEngineTo: 'ada'.

	^ apiClient
]

{ #category : #'private - accessing' }
OpenAIExamples >> classificationsExampleFileReference [

	^ self examplesDirectory / 'classifications-example.jsonl'
]

{ #category : #'private - accessing' }
OpenAIExamples >> classificationsFileId [

	^ self idForFileNamed: self classificationsExampleFileReference intendedFor: 'classifications'
]

{ #category : #accessing }
OpenAIExamples >> classificationsFromFile [

	| id apiClient response |

	id := self classificationsFileId.

	apiClient := self classificationsAPIClient.
	apiClient
		labelAsOneOf: #( 'Positive' 'Negative' );
		fromExamplesMatchBest: 2.

	response := apiClient classify: 'movie is very good' lookingForExamplesIn: id.
	^ response at: 'label'
]

{ #category : #accessing }
OpenAIExamples >> classificationsFromFileWithoutLabels [

	| id apiClient response |

	id := self classificationsFileId.

	apiClient := self classificationsAPIClient.
	apiClient fromExamplesMatchBest: 2.

	response := apiClient classify: 'movie is very good' lookingForExamplesIn: id.
	^ response at: 'label'
]

{ #category : #'private - accessing' }
OpenAIExamples >> classifyUsing: aFineTune [

	| apiClient seedText response |

	apiClient := self completionsAPIClient.
	apiClient
		changeModelTo: ( aFineTune at: #fine_tuned_model );
		returnLikelyTokensUpTo: 2;
		changeMaximumNumberOfTokensTo: 1.
	seedText := 'https://t.co/f93xEd2 Excited to share my latest blog post! ->'.

	response := apiClient complete: seedText.

	^ ( ( ( response at: 'choices' ) detect: [ :choice | choice index = 0 ] ) at: 'text' ) trimBoth
]

{ #category : #'private - processing' }
OpenAIExamples >> classifyUsingNewestAmong: eligible [

	| sorted |

	sorted := eligible sorted: [ :a :b | ( a at: #fine_tuned_model ) >= ( b at: #fine_tuned_model ) ].

	^ self classifyUsing: sorted first
]

{ #category : #'private - accessing' }
OpenAIExamples >> cleanDelimitersFrom: anAnswerCollection [

	^ anAnswerCollection collect: [ :answer | ( answer substrings: '===' ) first trimBoth ]
]

{ #category : #accessing }
OpenAIExamples >> completions [

	| apiClient seedText response |

	apiClient := self completionsAPIClient.
	apiClient changeMaximumNumberOfTokensTo: 1.
	seedText := 'This is the day'.

	response := apiClient complete: seedText.

	^ '<1s><2s>' expandMacrosWith: seedText with: ( ( response at: 'choices' ) first at: 'text' )
]

{ #category : #'private - accessing' }
OpenAIExamples >> completionsAPIClient [

	| apiClient |

	apiClient := CompletionsAPIClient
		             accessingAPIsWith: RESTfulAPIClient cachingOnLocalMemory
		             authenticatedWith: self apiKey.
	apiClient changeModelTo: 'ada'.

	^ apiClient
]

{ #category : #'private - processing' }
OpenAIExamples >> considerPreparingFineTuneExampleBasedOn: fineTunes [

	| pending |

	pending := fineTunes reject: [ :fineTune | #( succeeded cancelled ) includes: fineTune status ].

	^ pending
		  ifEmpty: [ 
			  self prepareExampleFineTune.
			  'No pending nor finished fine tune found. A new job has been launched. Wait a few minutes, then try again.'
			  ]
		  ifNotEmpty: [ 'No fine tune was ready for use yet. Wait a few minutes, then try again ' ]
]

{ #category : #'private - processing' }
OpenAIExamples >> convertToLinuxLineEndings: aString [

	^ ( aString copyReplaceAll: String crlf with: String lf ) copyReplaceAll: String cr with: String lf
]

{ #category : #'private - processing' }
OpenAIExamples >> createAnswersExampleFile [

	self
		write: '{"text": "France is in Europe", "metadata": "country with french people"}
{"text": "Canada is in America", "metadata": "country with canadian people"}
{"text": "Japan is in Asia", "metadata": "country with japanese people"}'
		to: self answersExampleFileReference
]

{ #category : #'private - processing' }
OpenAIExamples >> createClassificationsExampleFile [

	self
		write:
			'{"text": "good film, but very glum.", "label": "Positive", "metadata": {"source":"example.com"}}
{"text": "i sympathize with the plight of these families, but the movie doesn''t do a very good job conveying the issue at hand.", "label": "Negative", "metadata": {"source":"example.com"}}'
		to: self classificationsExampleFileReference
]

{ #category : #'private - processing' }
OpenAIExamples >> createExamplesDirectory [

	self examplesDirectory createDirectory
]

{ #category : #'private - processing' }
OpenAIExamples >> createFileThatWillBeDeleted [

	self
		write: '{"prompt": "<prompt text>", "completion": "<ideal generated text>"}'
		to: self fileThatWillBeDeletedReference
]

{ #category : #'private - processing' }
OpenAIExamples >> createFineTuneExampleFile [

	self
		write: '{"prompt":"Overjoyed with the new iPhone! ->", "completion":" positive"}
{"prompt":"@lakers disappoint for a third straight night https://t.co/38EFe43 ->", "completion":" negative"}'
		to: self fineTuneExampleFileReference
]

{ #category : #'private - processing' }
OpenAIExamples >> createSearchExampleFile [

	self
		write: '{"text": "a cat is happy", "metadata": "a type of feline"}
{"text": "a dog is hungry", "metadata": "a type of canine"}
{"text": "a car is loud", "metadata": "a type of vehicle"}
{"text": "a building is tall", "metadata": "a type of location"}
{"text": "a vehicle is fast", "metadata": "a type of transport"}
{"text": "a person is smart", "metadata": "a type of sentient being"}'
		to: self searchExampleFileReference
]

{ #category : #accessing }
OpenAIExamples >> deleteAllFiles [

	"Use with extreme caution!"

	| apiClient |

	apiClient := self filesAPIClient.
	^ apiClient listFiles data collect: [ :file | apiClient deleteFileIdentifiedBy: file id ]
]

{ #category : #accessing }
OpenAIExamples >> deleteAllFineTunes [

	"Use with extreme caution!"

	| apiClient |

	apiClient := self fineTuneAPIClient.
	^ apiClient listFineTunes collect: [ :fineTune | 
		  | modelName |

		  "fine_tuned_model returns null/nil until processing is completed"
		  modelName := fineTune at: #fine_tuned_model.

		  modelName
			  ifNil: [ self ask: apiClient toCancelFineTuneIdentifiedBy: fineTune ]
			  ifNotNil: [ self ask: apiClient toDelete: modelName relatedTo: fineTune ]
		  ]
]

{ #category : #'private - testing' }
OpenAIExamples >> does: apiClient considerAsReady: fineTune [

	^ fineTune status = 'succeeded' and: [ self does: apiClient knowAboutModelOf: fineTune ]
]

{ #category : #'private - testing' }
OpenAIExamples >> does: apiClient knowAboutModelOf: fineTune [

	^ [ 
	  apiClient modelNamed: ( fineTune at: #fine_tuned_model ).
	  true
	  ]
		  on: HTTPClientError notFound
		  do: [ :ex | ex return: false ]
]

{ #category : #accessing }
OpenAIExamples >> downloadAndDeleteFile [

	"All attempts at downloading give the same 400 error:
	Not allowed to download files of purpose: <THE PURPOSE SENT>"

	| id |

	id := self idForFileNamed: self fileThatWillBeDeletedReference intendedFor: 'fine-tune'.
	^ self filesAPIClient deleteFileIdentifiedBy: id
]

{ #category : #'private - accessing' }
OpenAIExamples >> examplesDirectory [

	^ 'open-ai' asFileReference
]

{ #category : #'private - accessing' }
OpenAIExamples >> fileThatWillBeDeletedReference [

	^ self examplesDirectory / 'file-that-will-be-deleted.jsonl'
]

{ #category : #accessing }
OpenAIExamples >> files [

	| apiClient files |

	apiClient := self filesAPIClient.
	files := apiClient listFiles.
	^ files data
		  ifEmpty: [ 
			  Array with: ( apiClient
					    idForProcessed: self fineTuneExampleFileReference
					    intendedFor: 'fine-tune'
					    waiting: 4 seconds )
			  ]
		  ifNotEmpty: [ files ]
]

{ #category : #'private - accessing' }
OpenAIExamples >> filesAPIClient [

	^ FilesAPIClient
		  accessingAPIsWith: RESTfulAPIClient cachingOnLocalMemory
		  authenticatedWith: self apiKey
]

{ #category : #'private - accessing' }
OpenAIExamples >> fineTuneAPIClient [

	^ FineTuneAPIClient
		  accessingAPIsWith: RESTfulAPIClient cachingOnLocalMemory
		  authenticatedWith: self apiKey
]

{ #category : #'private - accessing' }
OpenAIExamples >> fineTuneExampleFileReference [

	^ self examplesDirectory / 'fine-tune-example.jsonl'
]

{ #category : #'private - accessing' }
OpenAIExamples >> fineTuneFileId [

	^ self idForFileNamed: self fineTuneExampleFileReference intendedFor: 'fine-tune'
]

{ #category : #accessing }
OpenAIExamples >> fineTunedSentimentAnalysis [

	| apiClient fineTunes ready |

	"The final result is answering https instead of a classification, most likely because there are only 2 examples instead of 200"
	apiClient := self fineTuneAPIClient.
	fineTunes := apiClient listFineTunes.

	ready := fineTunes select: [ :fineTune | self does: apiClient considerAsReady: fineTune ].

	^ ready
		  ifNotEmpty: [ self classifyUsingNewestAmong: ready ]
		  ifEmpty: [ self considerPreparingFineTuneExampleBasedOn: fineTunes ]
]

{ #category : #processing }
OpenAIExamples >> generateExampleFiles [

	self createExamplesDirectory.
	self createAnswersExampleFile.
	self createClassificationsExampleFile.
	self createFileThatWillBeDeleted.
	self createFineTuneExampleFile.
	self createSearchExampleFile
]

{ #category : #'private - accessing' }
OpenAIExamples >> idForFileNamed: aFileReference intendedFor: aPurpose [

	| fileName filesAPIClient files |

	fileName := aFileReference basename.
	filesAPIClient := self filesAPIClient.
	files := filesAPIClient listFiles.

	^ files data
		  detect: [ :file | file filename = fileName ]
		  ifFound: [ :file | file id ]
		  ifNone: [ 
		  filesAPIClient idForProcessed: aFileReference intendedFor: aPurpose waiting: 20 seconds ]
]

{ #category : #'private - processing' }
OpenAIExamples >> prepareExampleFineTune [

	| fileId apiClient |

	fileId := self fineTuneFileId.

	apiClient := self fineTuneAPIClient.
	apiClient changeSuffixTo: 'example'.

	apiClient trainUsing: fileId
]

{ #category : #accessing }
OpenAIExamples >> search [

	| documents response |

	documents := #( cat dog car building vehicle person ).
	response := self searchAPIClient search: 'bulldog' against: documents.
	
	^ ( self sortByScoreDataIn: response ) collect: [ :result | 
		  documents at: ( result at: 'document' ) + 1 ]
]

{ #category : #'private - accessing' }
OpenAIExamples >> searchAPIClient [

	| apiClient |

	apiClient := SearchAPIClient
		             accessingAPIsWith: RESTfulAPIClient cachingOnLocalMemory
		             authenticatedWith: self apiKey.
	apiClient changeModelTo: 'ada'.

	^ apiClient
]

{ #category : #'private - accessing' }
OpenAIExamples >> searchExampleFileReference [

	^ self examplesDirectory / 'search-example.jsonl'
]

{ #category : #'private - accessing' }
OpenAIExamples >> searchFileId [

	^ self idForFileNamed: self searchExampleFileReference intendedFor: 'search'
]

{ #category : #accessing }
OpenAIExamples >> searchFromFile [

	| id apiClient response |

	id := self searchFileId.

	apiClient := self searchAPIClient.
	apiClient returnUpTo: 5.

	response := apiClient search: 'the dog feels happy in a building where some person lives' in: id.
	^ ( self sortByScoreDataIn: response ) collect: [ :result | result text ]
]

{ #category : #'private - accessing' }
OpenAIExamples >> sortByScoreDataIn: response [

	^ ( response at: 'data' ) sorted: [ :a :b | ( a at: 'score' ) >= ( b at: 'score' ) ]
]

{ #category : #accessing }
OpenAIExamples >> spanishBondTweetClassificationViaCompletion [

	| apiClient seedText response |

	apiClient := self completionsAPIClient.
	apiClient
		changeMaximumNumberOfTokensTo: 60;
		changeModelTo: 'text-davinci-002';
		changeTemperatureTo: 0.
	seedText := 'Classify the sentiment in these tweets:

1. "Si, prefiero opciones con más cupón. AE38, AL41 y los 2037 de PBA mis preferidos. Igual si la cosa va bien los de mayor apreciación van a ser los bonos cortos (#TARGET y #AL30). Obviamente lo mismo para sus equivalentes ley NY."
2. "q feo ese $TARGET, lo conozco?"
3. "#AL30D $TARGET vuela"
4. "Que mejor manera de arrancar las vacaciones que el norte en máximos y el TARGET subiendo por sexta jornada seguida"
5. "Mi hijo solo salió a comprar TARGET como todos los días y me lo fundieron. La madre de un trader fundido pide justicia."

Tweet sentiment ratings:'.

	response := apiClient complete: seedText.

	^ '<1s><2s>' expandMacrosWith: seedText with: ( ( response at: 'choices' ) first at: 'text' )
]

{ #category : #accessing }
OpenAIExamples >> tweetsInSpanishReferringToBonds [

	| apiClient seedText response |

	apiClient := self completionsAPIClient.
	apiClient
		changeMaximumNumberOfTokensTo: 60;
		changeModelTo: 'text-davinci-002';
		changeTemperatureTo: 0.
	seedText := 'Determine which of these tweets refer to financial bonds:

1. "Borrachita al29%"
2. "Pero no paga nada de cupón. Es como una acción. Cómo ves el AE38 o el AL41?"
3. "#dolar AL30(ci) MEP 190.71 Cable 189.97 GD30(ci) MEP 190.76 Cable 190.09 (BM+LELIQ+Pases)/Reservas al 29/03 196.24 Nación +30% +35% 192.64"
4. "Buena semana para los D después de mucho tiempo!! El #AL30 que la semana pasada tocó los 27 y una tir de 30,8%, cierra en 30,7 y 28,5%!"
5. "Este medio periodístico..... Es una farza.... Esta. Asustados porque petro no llega al30% de votos"

Bond tweets:'.

	response := apiClient complete: seedText.

	^ ( response at: 'choices' ) first at: 'text'
]

{ #category : #'private - processing' }
OpenAIExamples >> write: aString to: aFileReference [

	aFileReference writeStreamDo: [ :stream | 
		stream nextPutAll: ( self convertToLinuxLineEndings: aString ) ]
]
