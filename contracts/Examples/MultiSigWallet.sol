// SPDX-License-Identifier: None

pragma solidity ^0.8.9;


/* 
    Basic idea of multi sig wallet is to submit a transaction for approval from multiple owners to spend money.
    transaction can't be executed if enough owners didn't approve that. Need to specify owners and required
    approvals while deploying contract
 */
contract MultiSigWallet{
    event Deposit(address indexed sender, uint amount);
    event Submit(uint indexed txId);
    event Approve(address indexed owner, uint indexed txId);
    event Revoke(address indexed owner, uint indexed txId);
    event Execute(uint indexed txId);

    struct Transaction{
        address to;
        uint value;
        bytes data;
        bool executed;
    }
    
    address[] public owners;
    mapping(address=> bool) public isOwner;
    uint public required;

    Transaction[] public transactions;

    // txId=>owner=>approved
    mapping(uint=>mapping(address=>bool)) public approved;


    modifier onlyOwner(){
        require(isOwner[msg.sender],"Not owner");
        _;
    }
    modifier txExists(uint _txId){
        require(_txId<transactions.length,"tx doesn't exist");
        _;
    }
    modifier notApproved(uint _txId){
        require(!approved[_txId][msg.sender],"tx already approved");
        _;
    }
    
    modifier notExecuted(uint _txId){
        require(!transactions[_txId].executed,"tx already executed");
        _;
    }
    modifier readyToAddOwner(address _owner){
        require(_owner!=address(0),"invalid owner");
        require(!isOwner[_owner],"owner is not unique");
        _;
    }

    constructor(address[] memory _owners, uint _required){
        require(owners.length>0,"Owners required");
        require(_required>0&&required<=_owners.length,"Invalid required number of owners");

        for(uint i;i<_owners.length;i++){
            _addOwner(_owners[i]);
        }
        required=_required;
    }

    function _addOwner(address _owner) internal readyToAddOwner(_owner){
        isOwner[_owner]=true;
        owners.push(_owner);
    }

    receive() external payable{
        emit Deposit(msg.sender, msg.value);
    }

    
    function updateRequired(uint _required) external onlyOwner{
        required=_required;
    }

    
    
    function newOwner(address _owner) external onlyOwner{
        _addOwner(_owner);
    }
    function submit(address _to, uint _value, bytes calldata _data) external onlyOwner{
        transactions.push(Transaction({
            to:_to,
            value:_value,
            data:_data,
            executed:false
        }));

        emit Submit(transactions.length-1);
    }
    function approve(uint _txId) external onlyOwner txExists(_txId) notApproved(_txId) notExecuted(_txId){
        approved[_txId][msg.sender]=true;
        emit Approve(msg.sender, _txId);
    }

    function _getApprovalCount(uint _txId) private view returns (uint count){
        for(uint i;i<owners.length;i++){
            if(approved[_txId][owners[i]]){
                count+=1;
            }
        }
    }

    function execute(uint _txId) external txExists(_txId) notExecuted(_txId){
        require(_getApprovalCount(_txId)>=required,"approvals < required");
        
        Transaction storage transaction = transactions[_txId];
        
        transaction.executed=true;
        
        (bool success,) = transaction.to.call{value:transaction.value}(transaction.data);
        
        require(success, "tx failed");

        emit Execute(_txId);
    }
    function revoke(uint _txId) external onlyOwner txExists(_txId) notExecuted(_txId){
        require(approved[_txId][msg.sender],"tx not approved");
        
        approved[_txId][msg.sender]=false;

        emit Revoke(msg.sender,_txId);
    }
}