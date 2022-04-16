// SPDX-License-Identifier: None

pragma solidity ^0.8.9;

contract GasGolf{
    // start - ? gas
    // use calldata - 
    // load state variables to memory
    // short circuit
    // loop increments
    // cache array length
    // load array elements to memory

    uint public total;

    


    /* 
    
    ******** sumIfEvenAndLessThan99 before gas optimization *************

    function sumIfEvenAndLessThan99(uint[]memory nums) external{
        for(uint i=0;i<nums.length;i++){
            bool isEven = nums[i]%2==0;
            bool isLessThan99=nums[i]<99;
            if(isEven&&isLessThan99){
                total+=nums[i];
            }
        }
    }
    **********************   Explaination   ******************************
    Initial gas cost: 50530
    Tip 1. Using calldata instead of memory in arguments - 48785 gas
    Tip 2. Load 'total' into memory, because writing to storage is costly - 48574 gas
    Tip 3. if isEven is false, computing isLessThan99 is unneccessary (short circuit) - 48256 gas
    Tip 4. instead of post increment, use pre increment (i.e. i++->++i) - 48226 gas
    Tip 5. cache array length instead of reading in every iteration - 48191 gas
    Tip 6. instead of reading nums[i] 3 times, load it into memory - 48029 gas  

    We're saving only little amount of gas of 2501. Current average gas price is 53.37, so we're saving
    133,478.37 gwei. This is very small amount but we only have 6 elements in our input array. It can save a lot
    more gas if we use large arrays
     */

     // inputArray: [1,2,3,4,5,100] 
    function sumIfEvenAndLessThan99(uint[] calldata nums) external{
        uint _total = total;
        uint length=nums.length;
        for(uint i=0;i<length;++i){
            uint num=nums[i];
            if(num%2==0&&num<99){
                _total+=num;
            }
        }
        total=_total;
    }
}