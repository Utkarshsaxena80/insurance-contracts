// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "./master.sol";
import "./agroCoin.sol";

contract InsuranceDAO is ReentrancyGuard {
    address public immutable governanceToken;
    address public owner;
    uint256 public proposalCount;
    uint256 public FEE;

    struct Proposal {
        address proposer;
        uint256 id;
        string description;
        uint256 votesFor;
        uint256 votesAgainst;
        uint256 insuranceType;
        bool executed;
        uint256 amountToBeSetteled;

    }

    address[] DAO_Members;
    mapping(address=>bool) isDAOMember;

    mapping(uint256 => Proposal) public proposals;
    mapping(address => mapping(uint256 => bool)) public hasVoted;

    event ProposalCreated(uint256 id, string description);
    event Voted(uint256 proposalId, address voter, bool voteFor, uint256 amount);
    event ProposalExecuted(uint256 id, bool passed);
    event DAO_Joined(address indexed user);

    modifier onlyOwner() {
        require(msg.sender==owner, "Only owner can perform this action");
        _;
    }

    masterContract public master;
    AgroCoin public token;

    constructor(address _governanceToken,uint256 _fee,address _a) {
        
        //the token.sol file should be deployed first 
        governanceToken = _governanceToken;
        owner = msg.sender;
        FEE=_fee;
        master=masterContract(_a);
        //token=AgroCoin(_t);
    }

    function joinDAO() public payable{
        require(msg.value>=FEE,"Didnt send enough fee to join DAO");
        require(!isDAOMember[msg.sender],"already a DAO member");
        DAO_Members.push(msg.sender);
        isDAOMember[msg.sender]=true;
        emit DAO_Joined(msg.sender);
    }

    function createProposal(
    string memory description,
    uint256 _insuranceType,
    uint256 _amountToBeSetteled) public  payable{

        require(msg.value>=FEE,"Not enough eth");
       // require(token.balanceOf(msg.sender)>=100*10**18, "Need at least 100 tokens to create a proposal");
        proposalCount++;
        proposals[proposalCount] = Proposal({
            proposer:msg.sender,
            id: proposalCount,
            description: description,
            votesFor: 0,
            votesAgainst: 0,
            insuranceType: _insuranceType,
            executed: false,
            amountToBeSetteled: _amountToBeSetteled
        });
        emit ProposalCreated(proposalCount, description);
    }

    function voteOnProposal(uint256 proposalId, bool voteFor, uint256 amount) public nonReentrant {
        require(proposals[proposalId].id == proposalId, "Proposal does not exist");
        require(!hasVoted[msg.sender][proposalId], "Already voted");  
        IERC20 token = IERC20(governanceToken);
        require(token.balanceOf(msg.sender)>=amount, "Not enough tokens to vote");
        require(token.transferFrom(msg.sender, address(this), amount), "Token transfer failed");
        if (voteFor) {
            proposals[proposalId].votesFor+= amount;
        } else {
            proposals[proposalId].votesAgainst+= amount;
        }
        hasVoted[msg.sender][proposalId] = true;
        uint256 votesRequiredToPass=4;
        emit Voted(proposalId, msg.sender, voteFor, amount);
    }

function processPassedProposals(uint256 proposalId) public {
    require(proposals[proposalId].id == proposalId, "Proposal does not exist");
    
    uint256 totalVotes = proposals[proposalId].votesFor + proposals[proposalId].votesAgainst;
    require(totalVotes>=4, "Not enough votes to process");

    if (proposals[proposalId].votesFor > proposals[proposalId].votesAgainst) {
        master.getProposalStateAfterRejection(true, proposals[proposalId].proposer, proposals[proposalId].amountToBeSetteled);
    } else {
        master.getProposalStateAfterRejection(false, proposals[proposalId].proposer, proposals[proposalId].amountToBeSetteled);
    }
}
     
}
