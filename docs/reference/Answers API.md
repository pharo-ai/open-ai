# Answers API

Offers access to the [features mentioned here](https://beta.openai.com/docs/api-reference/answers).

The API can be accessed using the class `AnswersAPIClient`.

## Instance Creation

To create a Files API client, you need a *RESTful API Client*
and an *OpenAI API key*.

You can obtain a *RESTful API Client* by evaluating: `RESTfulAPIClient cachingOnLocalMemory`.

You should be able to obtain an API Key by following the [steps mentioned here](../how-to/how-to-run-examples.md).
Afterwards you can access the key by sending
`'open-ai/apikey.secret' asFileReference contents`.

So to create the Answers API Client you can evaluate:

```smalltalk
| restfulClient apiKey answersAPIClient |

restfulClient := RESTfulAPIClient cachingOnLocalMemory.
apiKey := 'open-ai/apikey.secret' asFileReference contents.

answersAPIClient := AnswersAPIClient
                     accessingAPIsWith: restfulClient
                     authenticatedWith: apiKey
```

## Public protocol

### answer: *question* against: *documents* given: *examples* within: *context*

Executes a POST call to obtain the answer to the question indicated.
A collection of strings is used as the document list,
where the information will be looked up.
Aditionally you must provide a question-answer example,
along with a context that contains the document
that would have been relevant to answer the example.

As specified [here](https://beta.openai.com/docs/api-reference/answers/create),
the response will include an *anwsers* element which will contain
the possible answers to the question.

As an example, suppose you want to present the Answers API
with the query `where is France?`.

You need to provide several documents that might contain the answer.
The example will provide 3 sentences:
`France is in Europe` and `Canada is in America` and `Japan is in Asia`.

Also an example must be chosen,
with a logic similar to the one you are expecting the API to apply.

You can tell the API that given the document
`this car is 2 meters long` and the question
`how long is this car?` the answer is `2 meters`.

The above example with be written as follows:

```smalltalk
answersAPIClient answer: 'where is France?'
                 against: #('France is in Europe'
                            'Canada is in America'
                            'Japan is in Asia' )
                 given: ( Array with: #( 'how long is this car?' '2 meters' ) )
                 within: 'this car is 2 meters long'.
```

### changeSearchEngineTo: *engine id*

The *model* and *search moodel* are separate parameters in the API.
The wrapper defaults to **Ada** for both
to minimize the default cost of using the API client.

### changeEngineTo: *engine id*

The *model* and *search moodel* are separate parameters in the API.
The wrapper defaults to **Ada** for both
to minimize the default cost of using the API client.
