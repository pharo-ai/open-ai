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

The example methods return an object that extract the relevant answer
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
OpenAIExamples new search .
OpenAIExamples new searchFromFile .

### Completions API

Examples using the [Completions API](https://beta.openai.com/docs/api-reference/completions)
OpenAIExamples new completions .

### Classifications API

Examples using the [Classifications API](https://beta.openai.com/docs/api-reference/classifications)

OpenAIExamples new classifications .
OpenAIExamples new classificationsFromFileWithoutLabels .
OpenAIExamples new classificationsFromFile .

