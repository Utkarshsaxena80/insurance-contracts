    // SPDX-License-Identifier: MIT
    pragma solidity ^0.8.8;

    import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
    import "./master.sol";
    import "./DAO.sol";
    contract InsuranceOne is ReentrancyGuard {
    
        uint256 public immutable FEE;
        address public owner;
        uint256 public  totalFund;
        struct UserInfo {
            address user;
            string name;
        }
        enum claimApproved{
            notApproved,
            approved,
            rejectedAndSentForReview
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
            bool hasNFT;
            uint256 premium;
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

        

        InsuranceDAO public DAO;
        masterContract  public master;
        constructor(uint256 fee,address _a,address _d) {
            FEE = fee;
            master=masterContract(_a);
            DAO=InsuranceDAO(_d);
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
                isRejected:false,
                hasNFT:false,
                premium:2
            });
            
            emit InsuranceCreated(msg.sender, value, deadline);
        }

        function payPremium() public payable onlyUser {
            require(insurances[msg.sender].isOpen, "No active insurance");
            require(msg.value >0, "Premium must be greater than 0");
            require(insurances[msg.sender].timesPaid<=insurances[msg.sender].paymentFreq);
            InsuranceInfo storage insurance = insurances[msg.sender];
            insurance.totalPremiumPaid += msg.value;
            insurance.totalPaymentPending -= msg.value;
            insurance.timesPaid++;

            emit PremiumPaid(msg.sender, msg.value, insurance.totalPremiumPaid);
        }

        function setDamageFactor(address user,uint256 damageFactor) public onlyUser {
            require(insurances[user].isOpen, "No active insurance for this user");
            require(damageFactor >= 0 && damageFactor <= 100, "Invalid damage factor");

            insurances[user].damageFactor = damageFactor;
            insurances[user].claimApproved = true;

        }

        function claimInsurance(uint256 damageFactor) public onlyUser nonReentrant payable  {
            uint256 payout;
            require(insurances[msg.sender].isOpen,"No active insurance");
        // require(!insurances[msg.sender].claimApproved,"Claim  approved");
            require(insurances[msg.sender].timesPaid==insurances[msg.sender].paymentFreq,"premium not paid in full");
            require(!insurances[msg.sender].isRejected,"user has rejected the claim, proceed to raise a query");
            InsuranceInfo storage insurance=insurances[msg.sender];
            setDamageFactor(msg.sender,damageFactor);
            if (master.NFT_yes_or_noStatus(msg.sender)) {
                insurance.hasNFT = true;
            }
            if(insurance.hasNFT){
                payout=(insurance.value*insurance.damageFactor*120)/10000;
            }
                else{
            payout = (insurance.value*insurance.damageFactor)/100;
            }
            require(payout>0,"cannot process payment ");
            totalFund-=payout;
            insurance.isOpen = false;
            insurance.claimApproved=true;
            (bool success, ) = payable(msg.sender).call{value: payout}("");
            require(success, "Transfer failed");
            emit InsuranceClaimed(msg.sender, payout);
        }

        function recieveFund() public payable nonReentrant{
            require(msg.value>0,"Send some ETH");
            totalFund+=msg.value;
        }

        function premiumRemaining() public view returns (uint256){
        InsuranceInfo storage insurance= insurances[msg.sender];
        return insurance.timesPaid;
        }
        function paymentRemaining() public view returns (uint256){
        InsuranceInfo storage insurance= insurances[msg.sender];
        return insurance.totalPaymentPending;
        }
        function timesRemainingToPay() public view returns (uint256){
        InsuranceInfo storage insurance= insurances[msg.sender];
        return insurance.paymentFreq-insurance.timesPaid;
        }
        function getClaimValue() public view returns(uint256) {
        //return claimValue
        }
        function rejectClaim(  
        string memory description,
        uint256 _insuranceType,
        uint256 _amountToBeSetteled) public payable{
            require(insurances[msg.sender].timesPaid==insurances[msg.sender].paymentFreq,"premium not paid in full");
            require(!insurances[msg.sender].isRejected,"user has rejected the claim, proceed to raise a query");
            //now i have to make a DAO contract which will create greivance and members will vote onn that 
            //AGRO COIN CAN BE USED FOR DAO VOTING RIGHTS 
        DAO.createProposal{value: msg.value}(
        description,
        _insuranceType,
        _amountToBeSetteled
        );
        }      
        //abhi only proposal create hua hai but we need to execute 
        //jo result nikla hai 
        function getResultOfRejectedClaims() public {
            uint256 payout;
            InsuranceInfo storage insurance=insurances[msg.sender];
            if (master.NFT_yes_or_noStatus(msg.sender)) {
                insurance.hasNFT = true;
                }

            if(master.passProposalState(msg.sender)){
                //if hasNft
                    uint256 claimAfterDaoProposal=master.rejectedValue(msg.sender);
                if(insurance.hasNFT){
                payout= (claimAfterDaoProposal*insurance.damageFactor*120)/10000;
            }
                else{
                payout= (claimAfterDaoProposal*insurance.damageFactor)/100;
            }
            }             
            else{
                if(insurance.hasNFT){
                payout = (insurance.value*insurance.damageFactor*120)/10000;
                }
                else{
                payout = (insurance.value*insurance.damageFactor)/100;
                }
            }
        //` require(payout>0,"cannot process payment");
            totalFund-=payout;
            insurance.isOpen = false;
            insurance.claimApproved=true;
            (bool success, ) = payable(msg.sender).call{value: payout}("");
            require(success, "Transfer failed");
            emit InsuranceClaimed(msg.sender, payout);
            }
        
       
        }


