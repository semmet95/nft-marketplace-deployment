const { ethers } = require("hardhat");

async function main() {
  const listingPrice = parseInt(process.env.REACT_APP_LISTING_PRICE);

  const NFT = await ethers.getContractFactory("NFT");
  const nft = await NFT.deploy(nftMarket.address);
  await nft.deployed();
  
  console.log("nftMarket.address="+nftMarket.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
