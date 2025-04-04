//SPDX-License-Identifier:MIT
pragma solidity ^0.8.8;
contract masterContract{

    mapping(address=>bool) public  NFT_yes_or_no;
    mapping (address =>uint) public  userInsurance;//stores userInsurance choice
    mapping(address=>uint256)  public NFTDetails;
    mapping(address=>bool)  public rejectedClaim;

    mapping(address=>uint256) public rejectedValue; 
    
    
    function putUserInfo(uint256 choice) public  {
     userInsurance[msg.sender]=choice;
    }
    function getUserInfo() public view returns (uint256){
      return userInsurance[msg.sender];
    }
    function setAddressHasNFT(address user) public {
      require(!NFT_yes_or_no[user],"already has nft");
        NFT_yes_or_no[user]=true;
    }
    function NFT_yes_or_noStatus(address user) public view returns (bool) {
    return NFT_yes_or_no[user];
    }
    function getProposalStateAfterRejection(bool _status,address user,uint256 _rejectedValue) public returns (bool ){
            //get From DAO.sol
         rejectedValue[user]=_rejectedValue;
         rejectedClaim[user]=_status;
    }
    function passProposalState(address user) public  view returns(bool answer){                    
    return rejectedClaim[user];    //to the isnuranceOne.sol
    }
    function passProposalValue(address user) public view returns(uint256){
      return rejectedValue[user];
    }

}