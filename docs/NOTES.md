## Warning about model usage

The original implementation of this package uses a GPT model(s) that is used by the ChatGPT web portal. This model was not publicly offered by OpenAI. Using this model circumvented the cost (in the form of OpenAI credits) associated with making requests to the OpenAI API. I do NOT recommend using that model. Instead, please use the official options provided at https://platform.openai.com/docs/models/overview. Note that these will consume OpenAI credits.

The model used by the original author is `text-chat-davinci-002-20221122` as of the time of forking. It was extracted from network requests as per comments from the original author. We will be removing reference to that model while doing this cleanup. It will however remain in git history.

## Alternative repositories

There is a python implementation at https://github.com/acheong08/ChatGPT. We may or may not have time to review and clean up that implementation. The python implementation appears to be more fully-featured.

## Caveats

Below is unedited commentary from the original forked repository

    Since `text-chat-davinci-002-20221122` is ChatGPT's raw model, I had to do my best to replicate the way the official ChatGPT website uses it. After extensive testing and comparing responses, I believe that the model used by ChatGPT has some additional fine-tuning.
    This means my implementation or the raw model may not behave exactly the same in some ways:

    - Conversations are not tied to any user IDs, so if that's important to you, you should implement your own user ID system.
    - ChatGPT's model parameters (temperature, frequency penalty, etc.) are unknown, so I set some defaults that I thought would be reasonable.
    - Conversations are limited to roughly the last 4000 tokens, so earlier messages may be forgotten during longer conversations.
      - This works in a similar way to ChatGPT, except I'm pretty sure they have some additional way of retrieving context from earlier messages when needed (which can probably be achieved with embeddings, but I consider that out-of-scope for now).
    - It is well known that, as part of the fine-tuning, ChatGPT had the following preamble:

      > "You are ChatGPT, a large language model trained by OpenAI. You answer as concisely as possible for each response (e.g. don’t be verbose). It is very important that you answer as concisely as possible, so please remember this. If you are generating a list, do not have too many items. Keep the number of items short.
      > Knowledge cutoff: 2021-09
      > Current date: 2023-01-31"

      As OpenAI updates ChatGPT, this preamble may also change. The default prompt prefix in my implementation attempts to replicate a similar behavior to the current ChatGPT model.
