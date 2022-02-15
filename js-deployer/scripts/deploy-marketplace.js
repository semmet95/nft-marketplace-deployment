const { ethers } = require("hardhat");

async function main() {
  const listingPrice = parseInt(process.env.REACT_APP_LISTING_PRICE);
  const contractName = process.env.REACT_APP_CONTRACT_NAME;

  const nftMarketContract = await ethers.getContractFactory(contractName);
  const nftMarket = await nftMarketContract.deploy(listingPrice);
  await nftMarket.deployed();
  
  console.log("nftMarket.address="+nftMarket.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
