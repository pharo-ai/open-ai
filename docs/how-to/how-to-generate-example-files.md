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
