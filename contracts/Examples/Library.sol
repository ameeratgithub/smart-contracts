// SPDX-License-Identifier: None

pragma solidity ^0.8.9;

library Math{
    function max(uint _x, uint _y) internal pure returns(uint){
        return _x >= _y ? _x : _y;
    }
}

contract Test{
    function testMax(uint x,uint y) external pure returns (uint){
        return Math.max(x,y);
    }
}
library ArrayLib{
    function find(uint[] storage arr, uint _x) internal view returns(uint){
        for(uint i=0;i<arr.length;i++){
            if(arr[i]==_x){
                return i;
            }
        }
        revert("Element Not found");
    }
}
contract TestArray{
    using ArrayLib for uint[];

    uint[] public arr=[3,2,1];
    function testFind() external view returns (uint){
        // Method 1
        // return ArrayLib.find(arr,2);

        // Method 2
        return arr.find(2);
    }
}