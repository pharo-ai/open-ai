# Files API

Offers access to the [features mentioned here](https://beta.openai.com/docs/api-reference/files).

The API can be accessed using the class `FilesAPIClient`.

## Instance Creation

To create a Files API client, you need a *RESTful API Client*
and an *OpenAI API key*.

You can obtain a *RESTful API Client* by evaluating: `RESTfulAPIClient cachingOnLocalMemory`.

You should be able to obtain an API Key by following the [steps mentioned here](../how-to/how-to-run-examples.md).
Afterwards you can access the key by sending
`'open-ai/apikey.secret' asFileReference contents`.

So to create the Files API Client we can evaluate:

```smalltalk
| restfulClient apiKey filesAPIClient |

restfulClient := RESTfulAPIClient cachingOnLocalMemory.
apiKey := 'open-ai/apikey.secret' asFileReference contents.

filesAPIClient := FilesAPIClient
                     accessingAPIsWith: restfulClient
                     authenticatedWith: apiKey
```

## Public protocol

### listFiles

Executes a GET call to obtain the list of all files currently uploaded
to your OpenAI account.

As specified [here](https://beta.openai.com/docs/api-reference/files/list),
the response will contain a *data* element with a list of files,
where each includes information such as
id, name, size, creation stamp and purpose.

To use it, just evaluate:

```smalltalk
filesAPIClient listFiles
```

### wait: aTime forProcessingOf: aFileId thenDo: aBlock

Executes a POST call to upload a file. This requires,
apart from the reference to the desired file,
a **purpose** that OpenAI requires to know beforehand,
to confirm the format is correct for the intended API use.
The method also asks for a maximum time to wait for the file to be processed.

As specified [here](https://beta.openai.com/docs/api-reference/files/upload),
the response will contain information such as
id, name, size, creation stamp and purpose.
The *id* is obtained and used as the method return.

An undocumented (so far) feature of OpenAI is that when querying for a specific file,
a *status* is returned.
Unless the status is listed as **processed**,
the file can't be used in the other APIs.

This method will poll the status every second up to the maximum specified.
In case the status is not processed,
it will raise an Exception to let the user know.
This does not mean that OpenAI won't eventually have the file ready for use,
only that it was not so in the time period indicated.

An example using this method, in case you want to upload the file at `open-ai/answers-example.jsonl`,
to be later used with the answers API,
implies evaluating:

```smalltalk
apiClient
    idForProcessed: 'open-ai/answers-example.jsonl' asFileReference
    intendedFor: 'answers'
    waiting: 4 seconds
```

### retrieveFileIdentifiedBy: aFileId

Executes a DELETE request, to remove from your storage
the file with the *id* indicated.

You can obtain the *id* but either keeping the returned value of an upload,
or by checking the *id* attribute when listing your files
using the `listFiles` method.

As specified [here](https://beta.openai.com/docs/api-reference/files/delete),
the response will include an attribute *deleted*,
which will be *true* as long as the deletion could be completed.

As an example, if you have a file which returned the id `file-XjGxS3KTG0uNmNOK362iJua3`,
you would delete it by evaluating:

```smalltalk
apiClient retrieveFileIdentifiedBy: 'file-XjGxS3KTG0uNmNOK362iJua3'
```
