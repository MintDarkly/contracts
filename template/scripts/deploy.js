
const { ethers } = require("hardhat");

async function main() {
    const contract = await ethers.getContractFactory("TemplateNFT")
  
    // Start deployment, returning a promise that resolves to a contract object
    const deployedContract = await contract.deploy()
    console.log("\nContract deployed to address:", deployedContract.address, "\n")
  }
  
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error)
      process.exit(1)
    })
  