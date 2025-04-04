const { expect } = require("chai");
const { ethers } = require("hardhat");
const { TASK_FLATTEN_GET_FLATTENED_SOURCE_AND_METADATA } = require("hardhat/builtin-tasks/task-names");

// describe("InsuranceOne", function () {
//     let InsuranceOne, insuranceOne, owner, user1, user2;
//     const FEE = ethers.parseEther("0.1");

//     beforeEach(async function () {
//         [owner, user1, user2] = await ethers.getSigners();
//         InsuranceOne = await ethers.getContractFactory("InsuranceOne");
//         insuranceOne = await InsuranceOne.deploy(FEE);
//         await insuranceOne.waitForDeployment();
//     });

//     it("Should register a user", async function () {
//         await insuranceOne.connect(user1).registerUser("Alice");
//         const userInfo = await insuranceOne.users(user1.address);
//         expect(userInfo.name).to.equal("Alice");
//     });

//     it("Should create insurance", async function () {
//         await insuranceOne.connect(user1).registerUser("Alice");
//         await insuranceOne.connect(user1).createInsurance(
//             ethers.parseEther("1"),
//             Math.floor(Date.now() / 1000) + 86400, // 1 day from now
//             30,
//             { value: FEE }
//         );
        
//         const insurance = await insuranceOne.insurances(user1.address);
//         expect(insurance.isOpen).to.equal(true);
//     });

//     it("Should allow premium payments", async function () {
//         await insuranceOne.connect(user1).registerUser("Alice");
//         await insuranceOne.connect(user1).createInsurance(
//             ethers.parseEther("1"),
//             Math.floor(Date.now() / 1000) + 86400,
//             30,
//             { value: FEE }
//         );

//         await insuranceOne.connect(user1).payPremium({ value: ethers.parseEther("0.2") });
//         const insurance = await insuranceOne.insurances(user1.address);
//         expect(insurance.totalPremiumPaid).to.equal(ethers.parseEther("0.2"));
//     });

//     it("Should set damage factor and approve claim", async function () {
//         await insuranceOne.connect(user1).registerUser("Alice");
//         await insuranceOne.connect(user1).createInsurance(
//             ethers.parseEther("1"),
//             Math.floor(Date.now() / 1000) + 86400,
//             30,
//             { value: FEE }
//         );

//         await insuranceOne.connect(user1).setDamageFactor(user1.address, 50);
//         const insurance = await insuranceOne.insurances(user1.address);
//         expect(insurance.damageFactor).to.equal(50);
//         expect(insurance.claimApproved).to.equal(true);
//     });

//     it("Should allow insurance claim payout", async function () {
//       await insuranceOne.connect(user1).registerUser("Alice");
  
//       await insuranceOne.connect(user1).createInsurance(
//           ethers.parseEther("1"),
//           Math.floor(Date.now() / 1000) + 86400,
//           3,
//           { value: FEE }
//       );
  
//       console.log("Insurance created");
//       await insuranceOne.connect(user1).payPremium({ value: ethers.parseEther("0.2") });
//       await insuranceOne.connect(user1).payPremium({ value: ethers.parseEther("0.2") });
//       await insuranceOne.connect(user1).payPremium({ value: ethers.parseEther("0.2") });
      
  
//       await insuranceOne.connect(user1).setDamageFactor(user1.address, 50);
//       console.log("Damage factor set");
  
//       // Ensure the contract has enough balance to pay the user
//       await insuranceOne.connect(owner).recieveFund({
//            // Use `.target` instead of `.address` in Ethers v6
//           value: ethers.parseEther("200"),
//       });
  
//       console.log("Contract funded for payout");
  
//       await expect(
//           insuranceOne.connect(user1).claimInsurance(50)
//       ).to.emit(insuranceOne, "InsuranceClaimed");
  
//       console.log("Insurance claim successful");
//   });
  
// });
// describe("LandNFT Contract", function () {
//     let LandNFT, landNFT, owner, user1, user2;
//     const fee = ethers.parseEther("0.01"); 
  
//     beforeEach(async function () {
//       [owner, user1, user2] = await ethers.getSigners();
  
//       LandNFT = await ethers.getContractFactory("LandNFT");
//       landNFT = await LandNFT.deploy(fee);
//       await landNFT.waitForDeployment();
//     });
  
//     it("Should deploy the contract and set the minting fee", async function () {
//       expect(await landNFT.feeForNFT()).to.equal(fee);
//     });
  
//     it("Should allow a user to mint an NFT", async function () {
//         const tx = await landNFT.connect(user1).mintLandNFT(
//             100, 
//             200, 
//             "28.7041", 
//             "77.1025", 
//             "ipfs://example-image", 
//             { value: fee }
//         );
//         await tx.wait();
    
//         const userNftId = await landNFT.NFTData(user1.address);
//         const userNFTDetails = await landNFT.getLandDetails(userNftId);
    
//         console.log("Minted NFT ID:", userNftId);
        
//         expect(userNftId).to.be.greaterThan(0);
//         expect(userNFTDetails.tokenId).to.equal(userNftId);
//         expect(userNFTDetails.owner).to.equal(user1.address);
//         expect(userNFTDetails.width).to.equal(100); // Fix width type
//     });
    
//     it("Should not allow minting without enough fee", async function () {
//       await expect(
//         landNFT.connect(user1).mintLandNFT(
//           100, 
//           200, 
//           "28.7041", 
//           "77.1025", 
//           "ipfs://example-image", 
//           { value: ethers.parseEther("0.005") }
//         )
//       ).to.be.revertedWith("Not enough fee");
//     });
  
//     it("Should retrieve the details of an NFT", async function () {
//       const tx = await landNFT.connect(user1).mintLandNFT(
//         50, 
//         100, 
//         "28.7041", 
//         "77.1025", 
//         "ipfs://test-image", 
//         { value: fee }
//       );
//       await tx.wait();
  
//       const tokenId = await landNFT.NFTData(user1.address);
//       const land = await landNFT.getLandDetails(tokenId);
  
//       expect(land.owner).to.equal(user1.address);
//       expect(land.imageURI).to.equal("ipfs://test-image");
//     });
  
//     it("Should return all NFTs", async function () {
//       await landNFT.connect(user1).mintLandNFT(
//         100,   
//         200, 
//         "28.7041", 
//         "77.1025", 
//         "ipfs://example1", 
//         { value: fee }
//       );
  
//       await landNFT.connect(user2).mintLandNFT(
//         150, 
//         250, 
//         "30.7333", 
//         "76.7794", 
//         "ipfs://example2", 
//         { value: fee }
//       );
  
//       const allNfts = await landNFT.getAllNfts();
//       expect(allNfts.length).to.equal(2);
//        const tokenId1= await landNFT.NFTData(user1.address); 
//        const tokenId2=await landNFT.NFTData(user2.address);
//        console.log(tokenId1);
//       const check= await landNFT.getLandDetails(tokenId1);
//       const check2=await landNFT.getLandDetails(tokenId2);
     
//       expect(check.owner).to.equal(user1.address);
//       expect(check2.owner).to.equal(user2.address);
//       console.log(await landNFT.getAllNfts());

//     });
  
//     it("Should retrieve a user's NFT details", async function () {
//       const tx = await landNFT.connect(user1).mintLandNFT(
//         120, 
//         220, 
//         "26.8467", 
//         "80.9462", 
//         "ipfs://user-nft", 
//         { value: fee }
//       );
//       await tx.wait();
  
//       const tokenId = await landNFT.NFTData(user1.address);
//       const userNft = await landNFT.getLandDetails(tokenId);
  
//       expect(userNft.latitude).to.equal("26.8467");
//       expect(userNft.imageURI).to.equal("ipfs://user-nft");
//     });
  
// });

// describe("InsuranceDAO", function () {
//   let InsuranceDAO, dao, Token, token;
//   let owner, user1, user2,user3 ;
//   const FEE = ethers.parseEther("1");

//   beforeEach(async () => {
//     [owner, user1, user2,user3] = await ethers.getSigners();

//     Token = await ethers.getContractFactory("AgroCoin"); // Replace with your actual ERC20 token name
//     token = await Token.deploy(100000);
//     await token.waitForDeployment();
//     console.log("token deployed");
//     console.log(await token.getAddress())

//     await token.mint(user1.address, ethers.parseEther("1000"));
//     await token.mint(user2.address, ethers.parseEther("1000"));

//     InsuranceDAO = await ethers.getContractFactory("InsuranceDAO");
//     dao = await InsuranceDAO.deploy(await token.getAddress(), FEE);
//     await dao.waitForDeployment();
//   });

//   it("should allow a user to join DAO by paying the fee", async () => {
//     await expect(
//       dao.connect(user1).joinDAO({ value: FEE })
//     ).to.emit(dao, "DAO_Joined").withArgs(user1.address);
//   });

//   it("should allow a DAO member to create a proposal", async () => {
//     await dao.connect(user1).joinDAO({ value: FEE });

//     await expect(
//       dao.connect(user1).createProposal(
//         "Proposal to approve insurance claim",
//         1,
//         500,
//         { value: FEE }
//       )
//     ).to.emit(dao, "ProposalCreated").withArgs(1, "Proposal to approve insurance claim");
//   });

//   it("should allow voting on a proposal using governance tokens", async () => {
//     await dao.connect(user1).joinDAO({ value: FEE });

//     await dao.connect(user1).createProposal("Sample Proposal", 1, 1000, { value: FEE });
//     await token.connect(user1).approve(await dao.getAddress(), ethers.parseEther("100"));
//     await token.connect(user2).approve(await dao.getAddress(), ethers.parseEther("100"));

//     await expect(
//       dao.connect(user2).voteOnProposal(1, true, ethers.parseEther("100"))
//     ).to.emit(dao, "Voted").withArgs(1, user2.address, true, ethers.parseEther("100"));

//     const proposal = await dao.proposals(1);
//     expect(proposal.votesFor).to.equal(ethers.parseEther("100"));
//   });

//   it("should not allow voting twice on same proposal", async () => {
//     await dao.connect(user1).joinDAO({ value: FEE });
//     await dao.connect(user1).createProposal("Test", 1, 200, { value: FEE });

//     await token.connect(user1).approve(await dao.getAddress(), ethers.parseEther("100"));
//     await dao.connect(user1).voteOnProposal(1, true, ethers.parseEther("100"));

//     await expect(
//       dao.connect(user1).voteOnProposal(1, false, ethers.parseEther("50"))
//     ).to.be.revertedWith("Already voted");
//   });

//   it("should reject vote if user has insufficient balance", async () => {
//     await dao.connect(user1).joinDAO({ value: FEE });
//     await dao.connect(user1).createProposal("Low balance vote", 1, 200, { value: FEE });

//     await token.connect(user3).approve(await dao.getAddress(), ethers.parseEther("1000"));

//     await expect(
//       dao.connect(user3).voteOnProposal(1, true, ethers.parseEther("500"))
//     ).to.be.revertedWith("Not enough tokens to vote");
//   });
// });

describe("final full working",function (){
   


    //beforeEach(
      //first user registers
      //then buys a insurance
      //pays for premium
      //creates NFT
   // )
    //accepts the claim(
    //hasNft
    //no nft
      //)
    //rejects the claim 
    //users votes on proposal
    //final payout 

    let InsuranceOne, insuranceOne, owner, user1, user2,user3;
    let Master,master,DAO,dao,Token,token;
    let NFT,nft;

    const FEE = ethers.parseEther("0.1");
    const DAOfee = ethers.parseEther("0.5");
    const NFTfee=ethers.parseEther("0.2");

    //first deploy master
    //then deploy DAO
    beforeEach(async function (){
      [owner, user1, user2,user3] = await ethers.getSigners();
      Master=await ethers.getContractFactory("masterContract");
      master= await Master.deploy();
      await master.waitForDeployment();

      //deploy governance token
    Token = await ethers.getContractFactory("AgroCoin"); 
    token = await Token.deploy(100000);
    await token.waitForDeployment();

     //deploy DAO 
    DAO= await ethers.getContractFactory("InsuranceDAO");
    dao= await DAO.deploy(await token.getAddress(),DAOfee,await master.getAddress());
    await dao.waitForDeployment();    
    
    //deploy NFT contract 
    
    NFT= await ethers.getContractFactory("LandNFT");
    nft= await NFT.deploy(NFTfee,await master.getAddress());

   //now deploy insuranceOne
    InsuranceOne= await ethers.getContractFactory("InsuranceOne");
    insuranceOne= await InsuranceOne.deploy(FEE,await master.getAddress(),await dao.getAddress());
   
   //registers
   await insuranceOne.connect(user1).registerUser("Alice");
   const userInfo = await insuranceOne.users(user1.address);
   expect(userInfo.name).to.equal("Alice");

   //buys an insurance
   await insuranceOne.connect(user1).createInsurance(
    ethers.parseEther("1"),
    Math.floor(Date.now() / 1000) + 86400, 
    3,
    { value: FEE }
    );

    
    const insurance = await insuranceOne.insurances(user1.address);
    expect(insurance.isOpen).to.equal(true);
    
    //pays premium 
    await insuranceOne.connect(user1).payPremium({ value: ethers.parseEther("0.2") });
    await insuranceOne.connect(user1).payPremium({ value: ethers.parseEther("0.2") });
    await insuranceOne.connect(user1).payPremium({ value: ethers.parseEther("0.2") });
    let ins = await insuranceOne.insurances(user1.address);

    console.log("After premium:", ins.totalPremiumPaid.toString(), "timesPaid:", ins.timesPaid.toString());
      await insuranceOne.connect(owner).recieveFund({
           value: ethers.parseEther("200"),
       });
     expect(await insuranceOne.totalFund()).to.equal(ethers.parseEther("200"));
     expect(await ins.totalPremiumPaid).to.equal(ethers.parseEther("0.6"));

    })
    it("procedes via the NFT, accpet claim route",async function (){
      const tx = await nft.connect(user1).mintLandNFT(
                     100, 
                     200, 
                     "28.7041", 
                     "77.1025", 
                     "ipfs://example-image", 
                    { value: NFTfee }
                );
               await tx.wait();
            
               const userNftId = await nft.NFTData(user1.address);
               const userNFTDetails = await nft.getLandDetails(userNftId);
               expect(userNftId).to.be.greaterThan(0);
               expect(userNFTDetails.tokenId.toString()).to.equal(userNftId.toString());
               expect(userNFTDetails.owner).to.equal(user1.address);
               expect(userNFTDetails.width).to.equal(100);

                // sets damage factor and approve claim 
                      await insuranceOne.connect(user1).setDamageFactor(user1.address, 50);
                       const ins2 = await insuranceOne.insurances(user1.address);
                      expect(ins2.damageFactor).to.equal(50);
                      expect(ins2.claimApproved).to.equal(true);

                      await expect(
                        insuranceOne.connect(user1).claimInsurance(50)
                       ).to.emit(insuranceOne, "InsuranceClaimed");

                       expect(await insuranceOne.totalFund()).to.equal(ethers.parseEther("199.4"));

    })
    it("no nft and claim normally", async function (){
      await insuranceOne.connect(user1).setDamageFactor(user1.address, 50);
      const ins2 = await insuranceOne.insurances(user1.address);
     expect(ins2.damageFactor).to.equal(50);
     expect(ins2.claimApproved).to.equal(true);

     await expect(
       insuranceOne.connect(user1).claimInsurance(50)
      ).to.emit(insuranceOne, "InsuranceClaimed");

      expect(await insuranceOne.totalFund()).to.equal(ethers.parseEther("199.5"));

    })

    it("rejects makes proposal and people vote",async function (){
      await expect(
        insuranceOne.connect(user1).rejectClaim(
          "I disagree with the claim outcome",
          1,
          ethers.parseEther("0.5"),
          { value: ethers.parseEther("0.5") } 
        )
      ).to.emit(dao, "ProposalCreated");

      //mint governance tokens 
    await token.mint(user1.address,ethers.parseEther("100"));
    await token.mint(user2.address,ethers.parseEther("100"));
    await token.mint(user3.address,ethers.parseEther("100"));

    await token.connect(user1).approve(dao.getAddress(), ethers.parseEther("10"));
     await token.connect(user2).approve(dao.getAddress(), ethers.parseEther("10"));
     await token.connect(user3).approve(dao.getAddress(), ethers.parseEther("10"));

  // Users vote

     await dao.connect(user1).voteOnProposal(0, true, ethers.parseEther("2"));
     await dao.connect(user2).voteOnProposal(0, false, ethers.parseEther("1"));
     await dao.connect(user3).voteOnProposal(0, true, ethers.parseEther("2"));
    
    // console.log(await master.rejectClaim[user1.address]);
     await dao.connect(owner).processPassedProposals(0);
     console.log(await master.rejectedValue(user1.address));
     const tx = await insuranceOne.connect(user1).getResultOfRejectedClaims();
   
     
   });

    })

    







