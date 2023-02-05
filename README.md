# Node ChatGPT Starter kit

1. [Differences between the OpenAI documentation and this starter kit](#differences-between-openai-documentation-and-this-starter-kit)
2. [Features](#features)
3. [Getting Started](#getting-started)
4. [Acknowledgements and future directions](#acknowledgements-and-future-direction)
5. [Warning about model usage](#warning-about-model-usage)
6. [Alternative repositories](#alternative-repositories)
7. [Contributing](#contributing)
8. [License](#license)

## Differences between OpenAI documentation and this starter kit

By itself, the model does not have any conversational support, so this library uses a cache to store conversations and pass them to the model as context. This allows you to have persistent conversations with ChatGPT in a nearly identical way to the official website.

## Features

- Includes an API server you can run to use ChatGPT in non-Node.js applications.
- Includes a `ChatGPTClient` class that you can use in your own Node.js applications.
- Replicates chat threads from the official ChatGPT website (with conversation IDs and message IDs), with persistent conversations using [Keyv](https://www.npmjs.com/package/keyv).
  - Conversations are stored in memory by default, but you can optionally [install a storage adapter](https://www.npmjs.com/package/keyv#usage) to persist conversations to a database.
  - The `keyv-file` adapter is also included in this package, and can be used to store conversations in a JSON file if you're using the API server or CLI (see `settings.example.js`).
- Supports configurable prompt prefixes, and custom names for the user and ChatGPT.
  - In essence, this allows you to turn ChatGPT into a different character.
  - This is currently only configurable on a global level, but the original author had planned to add support for per-conversation customization.

## Getting Started

### Prerequisites

- Node.js
- npm
- [OpenAI API key](https://platform.openai.com/account/api-keys)

## Usage

### Option 1: Importing the ChatGPTClient class

```JS
import ChatGPTClient from "../src/ChatGPTClient.js";

const clientOptions = {
  modelOptions: {
    model: 'text-davinci-003',
  },
  // (Optional) Set custom instructions instead of "You are ChatGPT...".
  // promptPrefix: 'You are Bob, a cowboy in Western times...',
  // (Optional) Set a custom name for the user
  // userLabel: 'User',
  // (Optional) Set a custom name for ChatGPT
  // chatGptLabel: 'ChatGPT',
  // (Optional) Set to true to enable `console.debug()` logging
  debug: false,
};

const cacheOptions = {
  // Options for the Keyv cache, see https://www.npmjs.com/package/keyv
  // This is used for storing conversations, and supports additional drivers (conversations are stored in memory by default)
  // For example, to use a JSON file (`npm i keyv-file`) as a database:
  // store: new KeyvFile({ filename: 'cache.json' }),
};

const chatGptClient = new ChatGPTClient('OPENAI_API_KEY', clientOptions, cacheOptions);

const response = await chatGptClient.sendMessage('Hello!');
console.log(response); // { response: 'Hi! How can I help you today?', conversationId: '...', messageId: '...' }

const response2 = await chatGptClient.sendMessage('Write a poem about cats.', { conversationId: response.conversationId, parentMessageId: response.messageId });
console.log(response2.response); // Cats are the best pets in the world.

const response3 = await chatGptClient.sendMessage('Now write it in French.', { conversationId: response2.conversationId, parentMessageId: response2.messageId });
console.log(response3.response); // Les chats sont les meilleurs animaux de compagnie du monde.
```

### Option 2. Deploying the API Server

You can install and run the server locally:

1. Clone this repository
2. Install dependencies with `npm install`
3. Modify `settings.js` in the root directory as desired. `settings.example.js` is a good template to start with
4. Create a `.env` file in the root folder and add your OpenAI API key. It is git-ignored.
   ```bash
   # .env
   OPENAI_API_KEY=<your key here>
   ```
5. Start the server using `npm start` or `npm run server`

A postman collection and postman environment has been added to demonstrate how to send requests to the API:

- ChatGPT-collection.postman_collection.json
- ChatGPT-environment.postman_environment.json

In brief, to interact with the API, you can send a HTTP POST request to the `localhost:3000/conversation` with a body of this structure:

```JSON
{
    "message": "Hello, how are you today?",
    "conversationId": "your-conversation-id (optional)",
    "parentMessageId": "your-parent-message-id (optional)"
}
```

The server will return a JSON object containing ChatGPT's response:

```JSON
{
    "response": "I'm doing well, thank you! How are you?",
    "conversationId": "your-conversation-id",
    "messageId": "response-message-id"
}
```

If the request is unsuccessful, the server will return a JSON object with an error message and a status code of 503.

If there was an error sending the message to ChatGPT:

```JSON
{
    "error": "There was an error communicating with ChatGPT."
}
```

Configuring `settings.js` to be `debug:true`, will log issues with the connection to OpenAI.

### Modifying the settings.js file

```JS
module.exports = {
  chatGptClient: {
    // (Optional) Parameters as described in https://platform.openai.com/docs/api-reference/completions
    modelOptions: {
      // model options: https://platform.openai.com/docs/models/gpt-3
      model: 'text-davinci-003',
    },
    // (Optional) Set custom instructions instead of "You are ChatGPT...".
    // promptPrefix: 'You are Bob, a cowboy in Western times...',
    // (Optional) Set a custom name for the user
    // userLabel: 'User',
    // (Optional) Set a custom name for ChatGPT
    // chatGptLabel: 'ChatGPT',
    // (Optional) Set to true to enable `console.debug()` logging
    debug: false,
  },
  // Options for the Keyv cache, see https://www.npmjs.com/package/keyv
  // This is used for storing conversations, and supports additional drivers (conversations are stored in memory by default)
  cacheOptions: {},
  // The port the server will run on (optional, defaults to 3000)
  port: 3000,
  // If set, ChatGPTClient will use `keyv-file` to store conversations to this JSON file instead of in memory.
  // `cacheOptions.store` will override this if set
  storageFilePath: './cache.json',
};
```

## Caveats (unedited from the original author)

Since `text-chat-davinci-002-20221122` is ChatGPT's raw model, I had to do my best to replicate the way the official ChatGPT website uses it. After extensive testing and comparing responses, I believe that the model used by ChatGPT has some additional fine-tuning.  
This means my implementation or the raw model may not behave exactly the same in some ways:

- Conversations are not tied to any user IDs, so if that's important to you, you should implement your own user ID system.
- ChatGPT's model parameters (temperature, frequency penalty, etc.) are unknown, so I set some defaults that I thought would be reasonable.
- Conversations are limited to roughly the last 3000 tokens, so earlier messages may be forgotten during longer conversations.
  - This works in a similar way to ChatGPT, except I'm pretty sure they have some additional way of retrieving context from earlier messages when needed (which can probably be achieved with embeddings, but I consider that out-of-scope for now).
- It is well known that, as part of the fine-tuning, ChatGPT had the following preamble:

  > "You are ChatGPT, a large language model trained by OpenAI. You answer as concisely as possible for each response (e.g. don’t be verbose). It is very important that you answer as concisely as possible, so please remember this. If you are generating a list, do not have too many items. Keep the number of items short.  
  > Knowledge cutoff: 2021-09  
  > Current date: 2023-01-31"

  As OpenAI updates ChatGPT, this preamble may also change. The default prompt prefix in my implementation attempts to replicate a similar behavior to the current ChatGPT model.

## Acknowledgements and future direction

This is originally a fork of https://github.com/waylaidwanderer/node-chatgpt-api.

Additional acknowledgements to @queercat for identifying the issue of needing to specific `host: 0.0.0.0` for fastify to work in Docker as per https://github.com/fastify/fastify-cli/issues/57. The initial Dockerfile in this repo is also based on the work at https://github.com/queercat/gpt-api-docker

Changes will be primarily focused on:

- use as a starter kit
- addressing security vulnerabilities
- respecting the terms and conditions of OpenAI usage

## Warning about model usage

The original implementation of this package uses a GPT model(s) that is used by the ChatGPT web portal. This model was not publicly offered by OpenAI. Using this model circumvented the cost (in the form of OpenAI credits) associated with making requests to the OpenAI API. I do NOT recommend using that model. Instead, please use the official options provided at https://platform.openai.com/docs/models/overview. Note that these will consume OpenAI credits.

The model used by the original author is `text-chat-davinci-002-20221122` as of the time of forking. It was extracted from network requests as per comments from the original author. We will be removing reference to that model while doing this cleanup. It will however remain in git history.

## Alternative repositories

There is a python implementation at https://github.com/acheong08/ChatGPT. We may or may not have time to review and clean up that implementation. The python implementation appears to be more fully-featured.

## Contributing

If you'd like to contribute to this project, please create a pull request with a detailed description of your changes.

## License

This project is licensed under the MIT License.
