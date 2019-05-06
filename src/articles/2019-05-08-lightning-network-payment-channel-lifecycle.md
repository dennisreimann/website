---
title: The Payment Channel Lifecycle
subtitle: ⚡️ Lightning Network explained
ogImage: lightning-network
lang: en
tags:
  - Lightning Network
  - Bitcoin
---

The Lightning Network is a second layer scaling solution for Bitcoin and similar cryptocurrencies.
It promises faster transactions and lower fees, enabled by a network of bidirectional payment channels.
This post shows the lifecycle of a Lightning Network payment channel.

It all starts out by "branching off the blockchain into the Lightning Network" by funding a payment channel.
A high-level overview looks like this:

![Lifecycle of a Lightning Network payment channel](/files/lightning-network/payment-channel-lifecycle.svg)

 Let's zoom in …

## The funding transaction

<mark>The funding transaction creates a multisignature wallet and signs three transactions but only broadcasts one to the blockchain.</mark>
The remaining two are the *Commitment Transactions* each peer holds.
After sufficient block confirmations the channel is considered open.

![Funding transaction](/files/lightning-network/funding-transaction.svg)

The commitment transactions can be thought of as "balance sheets", that will be for later use in a channel closing transaction.
Each peer holds a secret used to generate a hash for his commitment transaction.

Note: Right now, only a single party can commit funds for opening a new channel.
Future versions of the [Lightning Network specification](https://github.com/lightningnetwork/lightning-rfc) will allow for dual-funded payment channels.

## Commitment Transactions

Bob sends Alice an invoice about 4 mBTC, which she pays.
<mark>This exchanges the current transaction hash and previous secret, also called the *revocation key*.</mark>
Each new commitment transaction invalidates old ones as the secret can be used to revoke them.

![Commitment transaction nr. 1](/files/lightning-network/commitment-transaction-1.svg)

After the first fund-exchanging commitment transaction, Alice's state says:

- 4 mBTC for Bob and
- either: 6 mBTC for Alice after 1000 blocks
- or: 6 mBTC for Bob if he knows Alice's secret

Bob's commitment transaction is the exact counterpart to Alice's state:

- 6 mBTC for Alice and
- either: 4 mBTC for Bob after 1000 blocks
- or: 4 mBTC for Alice if she knows Bob's secret

This is fun – let's transact once more and see what this seemingly magical *1000 block waiting period* (roughly 7 days) is about!

![Commitment transaction nr. 2](/files/lightning-network/commitment-transaction-2.svg)

Afterwards Alice's state says:

- 8 mBTC for Bob and
- either: 2 mBTC for Alice after 1000 blocks
- or: 2 mBTC for Bob if he knows Alice's secret

The 1000 block wait time becomes important when closing a payment channel …

## Closing a payment channel

There are multiple possibilities of how a payment channel in the Lightning Network can be closed.
Let's start with the simplest and usual way …

### Mutual channel close

This is the best case scenario:
<mark>A cooperative close initiated by both peers broadcasting their current commitment transactions happens immediately.</mark>
The multisignature wallet spends the funds back on-chain and both peers should be happy.

![Mutual closing of a payment channel](/files/lightning-network/closing-transaction-mutual.svg)

### Force closing a channel

Let's say Alice disappears and Bob has to unilaterally close to get his funds on-chain.
In this case he has to undergo the 1000 block wait time (~7 days), which gives Alice the chance to come back and maybe revoke to this.

![Forced closing of a payment channel](/files/lightning-network/closing-transaction-forced.svg)

Speaking of …

### What happens in case of a false close?

Let's say Alice broadcasts an outdated state that favors her.
This might be intended (pretty mean, that's what we call fraud) or accidentally (having an incorrect channel state, restored from backup).

![False close of a payment channel](/files/lightning-network/closing-transaction-false.svg)

<mark>The 1000 block wait time gives Bob the chance to remedy the breach:
He knows and reveals the secret/revocation key for Alice's outdated transaction.</mark>
Alice will suffer a harsh punishment as discovering the fraud attempt results in a complete seizure of funds.
10 mBTC go to Bob!

![Breach remedy of a false closing transaction](/files/lightning-network/closing-transaction-remedy.svg)

Alright, that's the shortest version of an explanation I can think of.
Hope I explained this well enough and the diagrams make it approachable even for not too technical people.
On the other side I also hope it doesn't oversimplify too much of the concepts.
