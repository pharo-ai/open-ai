# How to generate the example files

In order to use the examples provided in `OpenAIExamples`,
you'll need to have some examples files available locally.

To create all required files you can execute

```smalltalk
OpenAIExamples new generateExampleFiles
```

This will create, inside the *open-ai* directory:

- answers-example.jsonl
- classifications-example.jsonl
- file-that-will-be-deleted.jsonl
- fine-tune-example.jsonl
- search-example.jsonl

```smalltalk
OpenAIExamples new generateExampleFiles .
OpenAIExamples new deleteAllFiles .

OpenAIExamples new answers .
OpenAIExamples new answersFromFile .

OpenAIExamples new search .
OpenAIExamples new searchFromFile .

OpenAIExamples new completions .

OpenAIExamples new classifications .
OpenAIExamples new classificationsFromFileWithoutLabels .
OpenAIExamples new classificationsFromFile .

OpenAIExamples new downloadAndRemoveFile .

OpenAIExamples new files .
```
