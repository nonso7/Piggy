import { ethers } from "hardhat";

async function main() {
    const [deployer] = await ethers.getSigners();
    console.log("Deploying contracts with account:", deployer.address);

    // Define the allowed tokens
    const allowedTokens = [
        "0xdAC17F958D2ee523a2206206994597C13D831ec7", 
        "0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48", 
        "0x6B175474E89094C44Da98b954EedeAC495271d0F"
    ];

    // Deploy the PiggybankFactory contract
    const PiggybankFactory = await ethers.getContractFactory("PiggybankFactory");
    const factory = await PiggybankFactory.deploy(allowedTokens);

    // Wait for deployment
    await factory.waitForDeployment();

    // ✅ Get the deployed contract address correctly
    const factoryAddress = await factory.getAddress();
    console.log("PiggybankFactory deployed to:", factoryAddress);
}

main()
    .then(() => process.exit(0))
    .catch((error) => {
        console.error(error);
        process.exit(1);
    });


    //https://github.com/nonso7/Piggy
    //https://sepolia.basescan.org/address/0x75B3dc4a1a191D1Eb56322a722Bc9317a1141c03#code
