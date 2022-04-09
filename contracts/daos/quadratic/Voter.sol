// SPDX-License-Identifier: MIT

pragma solidity ^0.8.9;
import {IERC20} from "./ERC720.sol";

interface IVoter {
    event Contributed(address indexed _contributor, uint256 _amount);

    event ContributionWidthraw(address _owner, uint256 _amount);

    function contribute(uint256 _amount) external returns (bool);

    function vote(
        address _voter,
        uint256 _proposalId,
        address _governor
    ) external returns (bool, uint256);

    function voterBalance(address _voter) external view returns (uint256);
}

contract Voter is IVoter {
    mapping(address => uint256) private _votersBalance;
    mapping(address => bool) private _isVoter;

    address[] private _votersList;

    // Proposal ID -> Voter -> Number of Votes
    mapping(uint256 => mapping(address => uint256)) private _proposalVotes;

    IERC20 private _token;

    constructor(address _tokenAddress) {
        _token = IERC20(_tokenAddress);
    }

    function voterBalance(address _voter) external view returns (uint256) {
        return _votersBalance[_voter];
    }

    /*
     * Approve tokens for this smart contract first, to contribute
     */
    function contribute(uint256 _amount) external returns (bool) {
        require(
            _token.allowance(msg.sender, address(this)) >= _amount,
            "Voter: Approve funds to contribute"
        );

        bool success = _token.transferFrom(msg.sender, address(this), _amount);

        require(success, "Voter: Contribution transfer failed");

        _votersList.push(msg.sender);

        _isVoter[msg.sender] = true;

        _votersBalance[msg.sender] += _amount;

        emit Contributed(msg.sender, _amount);

        return true;
    }

    function releaseContributionAmount(uint256 _amount)
        external
        returns (bool)
    {
        require(
            _votersBalance[msg.sender] >= _amount,
            "Voter: Insufficient Balance"
        );

        _token.transfer(msg.sender, _amount);

        emit ContributionWidthraw(msg.sender, _amount);

        return true;
    }

    function vote(
        address _voter,
        uint256 _proposalId,
        address _governor
    ) external returns (bool, uint256) {
        // Incrementing votes by 1 to apply quadratic formula, since 0**n will be zero
        uint256 voteFactor = _proposalVotes[_proposalId][_voter] + 1;

        /*
         1 Vote = 100 Tokens
         2 Votes =  400 Tokens  
         3 Votes = 900 Tokens 
        */

        uint256 amount = (voteFactor**2) * 100;

        require(
            _votersBalance[_voter] >= amount,
            "Voter: Insufficient balance to vote"
        );

        require(
            _transferToGovernor(_governor, amount),
            "Voter: Unable to transfer vote balance"
        );

        _votersBalance[_voter] -= amount;

        return (true, amount);
    }

    function _transferToGovernor(address _governor, uint256 _amount)
        internal
        returns (bool)
    {
        require(
            _token.balanceOf(address(this)) > _amount,
            "Voter: Insufficient Balance"
        );
        require(_governor != address(0), "Voter: Invalid Treasury");

        _token.transfer(_governor, _amount);

        return true;
    }
}
