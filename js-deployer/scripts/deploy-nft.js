const { ethers } = require("hardhat");

async function main() {
  const contractName = process.env.REACT_APP_CONTRACT_NAME;
  const marketAddress = process.env.REACT_APP_MARKET_ADDRESS;
  const nftName = process.env.REACT_APP_NFT_NAME;
  const nftSymbol = process.env.REACT_APP_NFT_SYMBOL;

  const nftContract = await ethers.getContractFactory(contractName);
  const nft = await nftContract.deploy(marketAddress, nftName, nftSymbol);
  await nft.deployed();
  
  console.log("nft.address="+nft.address);
}

main()
  .then(() => process.exit(0))
  .catch(error => {
    console.error(error);
    process.exit(1);
  });
