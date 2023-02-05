# Node ChatGPT Starter kit

- [Differences between the OpenAI documentation and this starter kit](#differences-between-openai-documentation-and-this-starter-kit)
- [Features](#features)
- [Getting Started](#getting-started)

  - [Initial setup](#initial-setup)
  - [Usage 1: Deploying the API server](#usage-1-deploying-the-api-server)
    - [Making requests to the API](#making-requests-to-the-api)
  - [Usage 2: Importing the ChatGPTClient Class](#usage-2-importing-the-chatgptclient-class)

- [Acknowledgements, Notes and future directions](#acknowledgements-notes-and-future-direction)
- [Contributing](#contributing)
- [License](#license)

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

### Initial setup

1. Sign up and obtain an OpenAI API key at https://platform.openai.com/account/api-keys
2. Install the following (if you haven't already)
   - Node.js
   - npm
3. Configuring a few files
   - Modify `settings.js` in the root directory as desired. `settings.example.js` is a good template to start with
   - Create a `.env` file in the root folder and add your OpenAI API key. It is git-ignored.
     ```bash
     # .env
     OPENAI_API_KEY=<your key here>
     ```

### Usage 1: Deploying the API server

```bash
# Either of these options will boot up the server on port 3000 on your machine
npm run start
npm run server

# Running the following will spin up a container instance with port 3000 exposed
npm run docker:build
npm run docker:run

# Running this will also spin up the container instance with port 3000 exposed. The compose file is intended to spin up other (optional) infrastructure in the future
npm run compose:up
```

#### Making requests to the API

To get started making calls to the API Server, you can import the following into Postman:

- `./postman/ChatGPT-collection.postman_collection.json`
- `./postman/ChatGPT-environment.postman_environment.json`

Basically, the collections will send a HTTP POST request to the `localhost:3000/conversation` with this JSON body structure:

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
Configuring `settings.js` to be `debug:true`, will log out issues with the connection to OpenAI.

### Usage 2: Importing the ChatGPTClient class

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

const chatGptClient = new ChatGPTClient('<OPENAI_API_KEY>', clientOptions, cacheOptions);

const response = await chatGptClient.sendMessage('Hello!');
console.log(response); // { response: 'Hi! How can I help you today?', conversationId: '...', messageId: '...' }

const response2 = await chatGptClient.sendMessage('Write a poem about cats.', { conversationId: response.conversationId, parentMessageId: response.messageId });
console.log(response2.response); // Cats are the best pets in the world.

const response3 = await chatGptClient.sendMessage('Now write it in French.', { conversationId: response2.conversationId, parentMessageId: response2.messageId });
console.log(response3.response); // Les chats sont les meilleurs animaux de compagnie du monde.
```

## Acknowledgements, Notes and Future direction

This is originally a fork of https://github.com/waylaidwanderer/node-chatgpt-api. Additional acknowledgements to @queercat for identifying the issue of needing to specific `host: 0.0.0.0` for fastify to work in Docker as per https://github.com/fastify/fastify-cli/issues/57. The initial Dockerfile in this repo was also inspired by the work at https://github.com/queercat/gpt-api-docker

Please see [./docs/NOTES.md](./docs/NOTES.md) for additional caveats and warnings

In this repository, we will be mainly working on:

- preparing a safe and friendly starter kit
- addressing security vulnerabilities
- respecting the terms and conditions of OpenAI usage

## Contributing

If you'd like to contribute to this project, please create a pull request with a detailed description of your changes.

## License

This project is licensed under the MIT License.
