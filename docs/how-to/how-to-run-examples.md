# How to run the examples

## How to generate the example files

In order to use the examples provided in `OpenAIExamples`,
you'll need to have some examples files available locally.

To create all required files you can execute:

```smalltalk
OpenAIExamples new generateExampleFiles
```

This will create, inside the *open-ai* directory:

- answers-example.jsonl
- classifications-example.jsonl
- file-that-will-be-deleted.jsonl
- fine-tune-example.jsonl
- search-example.jsonl

## How to configure your API key

Before running the examples, you must provide a valid API key.

1. [Sign up](https://beta.openai.com/signup) for an OpenAI account.

2. Go to your
[API keys](
https://beta.openai.com/account/api-keys
)
and click on the *Create new secret key* button.

3. Click on the *Copy* link next to your recently created key.

4. Create a file named *apikey.secret* in the *open-ai* directory.

5. Paste the copied key into the file, then save it.

## How to invoke the APIs with the examples

Several examples are provided which show a possible use case for the diferent APIs.

The example methods return an object that extracts the relevant answer
from  the full API respose.
This is intended for the examples to illustrate how to navigate the structure
of the responses of the different APIs wrapped.

### Files API

Examples using the [Files API](https://beta.openai.com/docs/api-reference/files)

OpenAI offers by default 1 GB storage *per organization*.
For individual users this means 1 GB as well.
There is no cost associated with managing files.
This means that running the examples in this section will not reduce
your free balance.

Files are uploaded asynchronously. 
Uploading returns a *File ID* than can be used later to check the file status.
You can't use a file until it's status is **processed**.

All uploads in the examples will wait up to 20 seconds, polling every second,
until the upload is complete.

The uploading method in the examples `OpenAIExamples>>#idForFileNamed:intendedFor:`
checks whether a file with the same name was already uploaded.
If it's already there, it does not re-upload it.
Since OpenAI allows multiple files with the same name,
failing to check first would result in an ever increasing use of your storage.

Running `OpenAIExamples new files` will list the files currently registered.
In case you have not yet made any upload, the example will upload `open-ai/fine-tune-example.jsonl`.

Running `OpenAIExamples new downloadAndRemoveFile` will upload `open-ai/file-that-will-be-deleted.jsonl`.
After uploading is complete, the file will be deleted.
This is just meant to show the steps to both upload and delete a file.

Running `OpenAIExamples new deleteAllFiles` will **delete all files**
declared to your OpenAI account.
**Always use this example with caution**.

### Answers API

Examples using the [Answers API](https://beta.openai.com/docs/api-reference/answers)

Running `OpenAIExamples new answers` will ask *where is France?'*
using as context the information `France is in Europe` and
`Canada is in America` and `Japan is in Asia`.
To explain to OpenAI how to extract information from context,
it will provide the example that given the context `this car is 2 meters long`
and the question `how long is this car` the answer should be `2 meters`.
This use case does not employ the Files API, all processing is done in the moment.

Running `OpenAIExamples new answersFromFile` will do the same,
 but the context is provided by the file `answers-example.jsonl`.
The file is uploaded, and then the question is asked to OpenAI.

### Search API

Examples using the [Search API](https://beta.openai.com/docs/api-reference/searches)

Running `OpenAIExamples new search` will try to find `bulldog` in the list  
`cat dog car building vehicle person`.
The result is the list ordered by how closely they match the query.

Running `OpenAIExamples new searchFromFile` will first upload the file `search-example.jsonl`,
then present the query `the dog feels happy in a building where some person lives`.
The result is the list of *documents* listed in the file sorted by
relevance to the query.

### Completions API

Examples using the [Completions API](https://beta.openai.com/docs/api-reference/completions)

Running `OpenAIExamples new completions` will ask for the next word
after the sequence `This is the day`.
Note that you can easily ask for more words by changing
the collaborator sent to `changeMaximumNumberOfTokensTo:`.
Keep in mind that this will increase the cost of each run of the example
since more *tokens* will be generated.

The completions API benefits from using the more complex (and expensive) OpenAI engines.
To try them out in the example, add:

```smalltalk
apiClient changeEngineTo: 'davinci'.
```

If you do this, it is also a good idea to increase the numbers of tokens
as explained before.

Remember that the DaVinci engine is **75 times more expensive**
than the default Ada engine.

### Classifications API

Examples using the [Classifications API](https://beta.openai.com/docs/api-reference/classifications)

Running `OpenAIExamples new classifications` will ask OpenAI to classify
the sentence `the weather is great` as either `happy` OR `sad`,
considering the samples `the grass is green` is `happy`,
`the sky is pretty` is `happy` and `the soil is rotten` is `sad`.

Running `OpenAIExamples new classificationsFromFile` will upload the examples
in the file `classifications-example.jsonl`,
then ask to classify the sentence `movie is very good`
as either `Positive` or `Negative`.

Running `OpenAIExamples new classificationsFromFileWithoutLabels` will also
upload the file and present the query `movie is very good`.
Only this time no classification options are provided.
OpenAI is free to choose how to classify the sentence,
based on its pre-training in interpreting text.
