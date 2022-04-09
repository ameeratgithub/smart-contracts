# DAOs

Decentralized Autonomous Organizations are quite popular in blockchain governance and decentralized finance. These organizations (ideally) depends upon decentralized community where members vote for future of the DAO. People vote for what they believe and community can execute
proposals after enough approvals. 

There are many voting mechanisms for DAO. Most popular is quorum based voting which is simple, but has its drawbacks. Some other interesting options are Conviction Voting and Quadratic Voting.


## Quadratic Voting

Quadratic voting is good mechanism against whales. In this mechanism, donation is reduced to calculate voting power for 1 person. Although it is better approach as compared to simple quorum based voting, it is not sybil resistant. For example if voter gives 10000 tokens to a proposal, then 

> `sqrt(10000) == 100 voting power`. 

Problem is when a person divides funds among many accounts, like 100 accounts giving 100 tokens, then 

> `100*sqrt(100) == 1000 voting power`

 which is 10x more than only 1 account. New approach is to use `x*sqrt(x)` which is sybil resistant, but gives more power to whales. For example

> `10000*sqrt(10000)== 1,000,000 voting power`

but 

> `100*sqrt(100)*100 == 100,000 voting power`

where whale can have 10x more voting power than individuals.

I've created a simple DAO based on NEW quadratic voting mechanism. DAO has following features

- Users can create a proposal about what community should do (what needs to be implemented)
- Users can vote "for" or "against" the proposal
- Users can get voting powers by donating to any proposal
- Users can contribute to DAO (and can withdraw tokens if needed)
- "for" voters can execute a proposal

[Probabilistic Quadratic Voting](https://d3lab-dao.gitbook.io/pqv/) is better approach to prevent sybil attacks while limiting whales. 
It invovles chainlink VRF to get random number to compute probability. It's better but complex approach to implement
