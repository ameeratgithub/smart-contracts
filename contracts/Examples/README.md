# Solidity Tips

We can create efficient and gas saving smart contracts, by implementing some best practices. Points below are my
small effort to share some tips to developers. I'll try to update this repo frequently.

- Using constants in solidity is gas efficient solution, because they are not going to change in future.

- Custom errors in solidity 0.8, are gas efficient (i.e. `error Unathorized(address caller); revert Unathorized(caller)`)

- After The DAO's attack, withdrawl pattern on user request is considered as best approach. For example, smart contract will not transfer funds (either using for loop or for 1 person) automatically. User has to request(call) withdrawl (withdraw function) to get funds

- Function modifiers can be "sandwiched". For example 
     ```
	modifier m(uint _a){
		_a*=2;
		_;
		_a+=2; 
	}
    ```

- `calldata` used as function inputs storage (instead of `memory`), can save gas. For example, if you mark memory variable, and pass it to another function, variable will be copied. `calldata` doesn't make a copy of variable, hence saves some gas.

- We can call external function as `this.externalFunction()`. `this` keyword will act as other contract, hence there will not be
compilation error. But this is gas inefficient, so use public instead.

- We can set `immutable` variables only once, when contract is deployed (in constructor). They are gas efficient as compared to regular state variables

- `payable(owner).transfer(_amount)` would cost more gas, because it is reading state variable. we can use `payable(msg.sender).transfer(_amount)` to save some gas

- `private` modifier can save some gas, because it is not accessble from anywhere

