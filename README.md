# Useful Smart Contracts

This repository contains examples of tested gas efficient smart contracts, demonstrating best practices and
basic ideas to implement DApps.

## DAOs

I've created a simple DAO based on quadratic voting mechanism. This is better approach as compared to simple quorum based voting. Users can show interest in what they believe.  DAO has following features

- Users can create a proposal about what community should do (what needs to be implemented)
- Users can vote "for" or "against" the proposal
- Users can vote more than 1 time according to quadratic nature of voting (i.e. (votes**2) * 100) 
    - 1st vote will require 100 Tokens
    - 2nd vote will require 400 Tokens
    - 3rd vote will require 900 Tokens
    - 4th vote will require 1600 Tokens, and so on...
- Users can contribute to DAO (and can withdraw tokens if needed)
- "for" voters can execute a proposal

Simple Quadratic Voting also vulnerable to sybil attacks. Plans are to change this simple method to Probabilistic Quadratic Voting to minimize sybil attack. I'd like to add dynamic function execution in proposal, as soon as possible

## Samples

- 'Proxy Contracts' can be used to deploy any smart contract, and execute its functions, dynamically.
- 'MultiSigWallet' is simple example where multiple owners need to approve transaction, before execution
- 'DutchAuction' is where price of the nft decreases by time, to a certain limit
- 'AccessControl' is where you want to define custom roles in your smart contract
- 'Kill' shows example of deleting smart contract. Surprised? :)
- 'HTLC (Hash TimeLocked Contract)' can swap cross chain tokens via atomic swap


I tried to use best practices in these examples. More examples are on the way :)