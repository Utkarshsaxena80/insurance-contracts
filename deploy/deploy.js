const {network,getNamedAccounts,deployments}=require("hardhat");
const { networkConfig, developmentChains } = require("../helper-hardhat-config.js");

module.exports=async()=>{
    const {deploy,log}=deployments;
    const {deployer}=await getNamedAccounts();
    const chainId=network.config.chainId;
    log(`Network: ${network.name} (Chain ID: ${chainId})`);
    log(`Deployer: ${deployer}`);
     const FEE = ethers.parseEther("0.1");
        const DAOfee = ethers.parseEther("0.5");
        const NFTfee=ethers.parseEther("0.2");

    try{
         const masterContract= await deploy("masterContract",{
            from :deployer,
            args:[],
            log:true,
            waitConfirmations:networkConfig[chainId]?.blockConfirmation||1,
         });
         log(` Contract  "master" deployed to: ${masterContract.address}`);
         log("=================================================\n");
         const AgroCoin= await deploy("AgroCoin",{
            from :deployer,
            args:[1000],
            log:true,
            waitConfirmations:networkConfig[chainId]?.blockConfirmation||1,
         });
         log(` Contract  "Agro" deployed to: ${AgroCoin.address}`);
         log("=================================================\n");
         const InsuranceDAO= await deploy("InsuranceDAO",{
            from :deployer,
            args:[AgroCoin.address,DAOfee,masterContract.address],
            log:true,
            waitConfirmations:networkConfig[chainId]?.blockConfirmation||1,
         });
         log(` Contract  "DAO" deployed to: ${InsuranceDAO.address}`);
         log("=================================================\n");
        
         const LandNFT= await deploy("LandNFT",{
            from :deployer,
            args:[NFTfee,masterContract.address],
            log:true,
            waitConfirmations:networkConfig[chainId]?.blockConfirmation||1,
         });
         log(` Contract  "NFT" deployed to: ${LandNFT.address}`);
         log("=================================================\n");
          
         const insuranceOne= await deploy("InsuranceOne",{
            from :deployer,
            args:[FEE,masterContract.address,InsuranceDAO.address],
            log:true,
            waitConfirmations:networkConfig[chainId]?.blockConfirmation||1,
         });
         log(` Contract  "insurance" deployed to: ${insuranceOne.address}`);
         log("=================================================\n");

    }catch(error){
        console.log(error);
    }

}

module.exports.tags=["deployment"];