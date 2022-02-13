import { ethers } from "hardhat";

async function main() {
  const listingPrice = parseInt(process.env.REACT_APP_LISTING_PRICE);

  const NFTMarketContract = await ethers.getContractFactory("NFTMarket");
  const nftMarket = await NFTMarketContract.deploy(listingPrice);
  await nftMarket.deployed();
  
  console.log("nftMarket.address=", nftMarket.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
