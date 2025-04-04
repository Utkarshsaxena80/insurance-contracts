// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
contract insuranceTWO is ReentrancyGuard{
   
    uint256 public immutable FEE;
    address public owner;

    struct UserInfo {
        address user;
        string name;
    }

    struct InsuranceInfo {
        bool isOpen;
        uint256 value;
        uint256 deadline;
        uint256 paymentFreq;
        uint256 totalPremiumPaid;
        uint256 totalPaymentPending;
        uint256 timesPaid;
        uint256 damageFactor; 
        bool claimApproved;
        bool isRejected;
    }

    mapping(address => UserInfo) public users;
    mapping(address => InsuranceInfo) public insurances;
    
    event InsuranceCreated(address indexed user, uint256 value, uint256 deadline);
    event PremiumPaid(address indexed user, uint256 amount, uint256 totalPaid);
    event InsuranceClaimed(address indexed user, uint256 amount);
    event ClaimReviewed(address indexed user, uint256 damageFactor, bool approved);

    modifier onlyUser() {
        require(users[msg.sender].user != address(0), "User not registered");
        _;
    }
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor(uint256 fee) {
        FEE = fee;
        owner = msg.sender;
    }

    function registerUser(string memory name) public {
        require(users[msg.sender].user == address(0), "User already registered");
        users[msg.sender] = UserInfo(msg.sender, name);
    }

    function createInsurance(uint256 value, uint256 deadline, uint256 paymentFreq) public payable onlyUser {
        require(msg.value >= FEE, "Send enough money to create insurance");
        require(!insurances[msg.sender].isOpen, "Insurance already exists");

        insurances[msg.sender] = InsuranceInfo({
            isOpen: true,
            value: value,
            deadline: deadline,
            paymentFreq: paymentFreq,
            totalPremiumPaid: 0,
            totalPaymentPending: value,
            timesPaid: 0,
            damageFactor: 0,
            claimApproved: false,
            isRejected:false
        });
        
        emit InsuranceCreated(msg.sender, value, deadline);
    }

    function payPremium() public payable onlyUser {
        require(insurances[msg.sender].isOpen, "No active insurance");
        require(msg.value > 0, "Premium must be greater than 0");

        InsuranceInfo storage insurance = insurances[msg.sender];
        insurance.totalPremiumPaid += msg.value;
        insurance.totalPaymentPending -= msg.value;
        insurance.timesPaid++;

        emit PremiumPaid(msg.sender, msg.value, insurance.totalPremiumPaid);
    }

    function setDamageFactor(address user, uint256 damageFactor) public onlyUser {
        require(insurances[user].isOpen, "No active insurance for this user");
        require(damageFactor >= 0 && damageFactor <= 100, "Invalid damage factor");

        insurances[user].damageFactor = damageFactor;
        insurances[user].claimApproved = true;

    }

    function claimInsurance() public onlyUser nonReentrant {
        require(insurances[msg.sender].isOpen,"No active insurance");
        require(insurances[msg.sender].claimApproved,"Claim not approved");

        InsuranceInfo storage insurance=insurances[msg.sender];
        uint256 payout = (insurance.value*insurance.damageFactor)/100;
        insurance.isOpen = false;

        (bool success, ) = payable(msg.sender).call{value: payout}("");
        require(success, "Transfer failed");

        emit InsuranceClaimed(msg.sender, payout);
    }
}