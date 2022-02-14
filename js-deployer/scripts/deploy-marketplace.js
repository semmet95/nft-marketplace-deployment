const { ethers } = require("hardhat");

async function main() {
  const listingPrice = parseInt(process.env.REACT_APP_LISTING_PRICE);
  const contractName = parseInt(process.env.REACT_APP_CONTRACT_NAME);

  const NFTMarketContract = await ethers.getContractFactory(contractName);
  const nftMarket = await NFTMarketContract.deploy(listingPrice);
  await nftMarket.deployed();
  
  console.log("nftMarket.address="+nftMarket.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
