// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Counters.sol";
import "./master.sol";

contract LandNFT is ERC721URIStorage, Ownable{

    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;
    uint256 public feeForNFT;
        
    //initalize with the master contract address when deployed
    //also of the all 3 insurance addressess

    struct Land {
        uint256 tokenId;
        address owner;
        uint256 width;
        uint256 length;
        string latitude;
        string longitude;
        string imageURI; 
    }
  masterContract  public master;
    mapping(uint256 => Land) public lands;
    mapping(address=>uint256) public NFTData;//tokenId
    uint256[] private landIds;

    event LandNFTMinted(address indexed owner, uint256 indexed tokenId, string imageURI);

    constructor(uint256 _fee,address _a) ERC721("LandNFT","LAND") {
        master=masterContract(_a);
        feeForNFT=_fee;
    }

    function mintLandNFT(
        uint256 width,
        uint256 length,
        string memory latitude,
        string memory longitude,
        string memory imageURI 
    ) public payable {
        require(msg.value>=feeForNFT,"Not enough fee");
        require(bytes(imageURI).length>0, "Image URI is required");

        _tokenIds.increment();
        uint256 newTokenId = _tokenIds.current();
        _mint(msg.sender, newTokenId);
        _setTokenURI(newTokenId, imageURI); 
        lands[newTokenId] = Land({
            tokenId: newTokenId,
            owner: msg.sender,
            width: width,
            length: length,
            latitude: latitude,
            longitude: longitude,
            imageURI: imageURI
        });

          master.setAddressHasNFT(msg.sender); 
            NFTData[msg.sender]=newTokenId;
            landIds.push(newTokenId); 
        emit LandNFTMinted(msg.sender,newTokenId,imageURI);
        
    }

    function getLandDetails(uint256 tokenId) public view returns (Land memory) {
        require(_exists(tokenId), "Token does not exist");
        return lands[tokenId];
    }


    //function updateOnInsuranceOneContract() public{}
    
    //  function getNftDetailsOfAUser( uint256 tokenId) public view returns (Land memory){
    //    require(NFTData[msg.sender]!=0,"user doesn't have an NFT");
    //    require(_exists(tokenId),"No nft exts ts");
    //    return lands[tokenId]; 
    //  }

     function getAllNfts() public view returns (Land[] memory){
        Land[] memory allLands = new Land[](landIds.length);
        for (uint256 i = 0; i < landIds.length; i++) {
            allLands[i] = lands[landIds[i]];
        }
        return allLands;

     }
   
}


//@note -- for cross-contract data-transfer

// // Contract A stores the data
// contract A {
//     uint public sharedData;

//     function setSharedData(uint _data) external {
//         sharedData = _data;
//     }
// }

// // Contract B accesses Contract A's data
// contract B {
//     A contractA;

//     constructor(address _a) {
//         contractA = A(_a); // Initialize with Contract A's address
//     }

//     function readData() external view returns (uint) {
//         return contractA.sharedData(); // Calls Contract A's public variable getter
//     }

//     function writeData(uint _data) external {
//         contractA.setSharedData(_data); // Calls Contract A's function
//     }
// }
// function getFarmDetails(uint256 tokenId) public view returns (FarmDetails memory) {
//     require(_exists(tokenId), "Token does not exist");
//     return farmMetadata[tokenId];
// }
//


 ///const farmDetails = await nftContract.getFarmDetails(1);
// document.getElementById("farmImage").src = farmDetails.imageUrl;
// document.getElementById("farmName").innerText = farmDetails.name;
// document.getElementById("farmArea").innerText = farmDetails.area + " acres";
