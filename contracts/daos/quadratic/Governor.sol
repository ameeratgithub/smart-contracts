// SPDX-License-Identifier:  MIT

pragma solidity ^0.8.9;
import {IVoter} from "./Voter.sol";

interface IGovernor {
    event Voted(
        address _voter,
        uint256 _proposalId,
        uint256 _amount,
        uint256 _votingPower
    );

    event ProposalCreated(address _creator, uint256 _proposalId);

    function createProposal(
        string calldata _title,
        string calldata _description
    ) external returns (bool);
}

contract Governor is IGovernor {
    enum ProposalState {
        Started,
        Rejected,
        Executed,
        Ended
    }
    struct Proposal {
        string title;
        string description;
        ProposalState state;
        uint32 startedAt;
        uint32 endsAt;
        uint256 forVotes;
        uint256 againstVotes;
        mapping(address => bool) voted;
        mapping(address => bool) forVoted;
        address[] voters;
        address creator;
    }

    uint256 private _currentProposalId;

    mapping(uint256 => Proposal) private _proposals;

    // Proposal[] private _proposalsList;

    IVoter private _voterContract;

    uint256 private _proposalRequiredBalance = 1000 * 10**18; // 1000 Tokens Required to create proposal

    uint32 private _proposalDuration = 60 * 60 * 24 * 7 * 30;

    modifier proposalExists(uint256 _proposalId) {
        require(
            _proposalId <= _currentProposalId,
            "Governor: Invalid Proposal"
        );
        _;
    }
    modifier proposalStarted(uint256 _proposalId) {
        require(
            _proposals[_proposalId].state == ProposalState.Started,
            "Governor: Proposal hasn't Started"
        );
        _;
    }
    modifier notEnded(uint256 _proposalId) {
        require(
            _proposals[_proposalId].endsAt >= block.timestamp,
            "Governor: Proposal Ended"
        );
        _;
    }
    modifier forVoted(uint256 _proposalId) {
        require(
            _proposals[_proposalId].forVoted[msg.sender],
            "Governor: Vote for proposal"
        );
        _;
    }

    constructor(address _voterContractAddress) {
        _voterContract = IVoter(_voterContractAddress);
    }

    function _updateRequiredProposalBalance(uint256 _tokens)
        private
        returns (bool)
    {
        require(_tokens > 0, "Governor: Invalid tokens");
        _proposalRequiredBalance = _tokens;
        return true;
    }

    function _updateProposalDuration(uint32 _newDuration)
        private
        returns (bool)
    {
        require(
            _newDuration >= (60 * 60 * 24 * 7),
            "Governor: Too small limit"
        );
        _proposalDuration = _newDuration;
        return true;
    }

    function createProposal(
        string calldata _title,
        string calldata _description
    ) external returns (bool) {
        require(
            _voterContract.voterBalance(msg.sender) > _proposalRequiredBalance,
            "Governor: Not enough contribution"
        );

        Proposal storage proposal = _proposals[_currentProposalId];

        proposal.title = _title;
        proposal.description = _description;

        proposal.state = ProposalState.Started;

        proposal.startedAt = uint32(block.timestamp);
        proposal.endsAt = proposal.startedAt + _proposalDuration;

        proposal.creator = msg.sender;

        _currentProposalId++;

        emit ProposalCreated(msg.sender, _currentProposalId);

        return true;
    }

    function vote(
        uint256 _proposalId,
        bool _for,
        uint256 _amount
    )
        external
        proposalExists(_proposalId)
        proposalStarted(_proposalId)
        notEnded(_proposalId)
        returns (bool)
    {
        Proposal storage proposal = _proposals[_proposalId];

        require(
            !proposal.voted[msg.sender],
            "Governor::vote: User already voted"
        );

        (bool success, uint256 votingPower) = _voterContract.vote(
            msg.sender,
            address(this),
            _amount
        );

        require(success, "Governor: Error while voting");

        proposal.voters.push(msg.sender);
        proposal.voted[msg.sender] = true;

        if (_for) {
            proposal.forVotes += votingPower;
            proposal.forVoted[msg.sender] = true;
        } else {
            proposal.againstVotes += votingPower;
        }

        emit Voted(msg.sender, _proposalId, _amount, votingPower);

        return true;
    }

    function execute(uint256 _proposalId)
        external
        proposalExists(_proposalId)
        proposalStarted(_proposalId)
        notEnded(_proposalId)
        forVoted(_proposalId)
        returns (bool)
    {
        Proposal storage proposal = _proposals[_proposalId];

        require(_canExecute(proposal), "Governor: Not enough votes");

        proposal.state = ProposalState.Executed;

        return true;
    }

    function _canExecute(Proposal storage _proposal)
        internal
        view
        returns (bool)
    {
        uint256 totalVotes = _proposal.forVotes + _proposal.againstVotes;
        uint256 forVotes = (_proposal.forVotes * 100) / totalVotes;
        uint256 againstVotes = (_proposal.againstVotes * 100) / totalVotes;
        return (forVotes - againstVotes) >= 10;
    }
}
