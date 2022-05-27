# Files API

Offers access to the [features mentioned here](https://beta.openai.com/docs/api-reference/files).

The API can be accessed using the class `FilesAPIClient`.

To create a Files API client, you need a *RESTful API Client* and an *OpenAI API key*.

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
