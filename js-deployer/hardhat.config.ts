/**
 * @type import('hardhat/config').HardhatUserConfig
 */

 import "@nomiclabs/hardhat-waffle";

 import { readFileSync } from 'fs';
 
 const secrets = JSON.parse(readFileSync("secrets.json").toString());
 const infuraId = secrets["infura_id"];
 const accounts_keys = secrets["accounts"];
 
 export const defaultNetwork = "hardhat";

 export const networks = {

   hardhat: {
     chainId: 1337
   },
 
   mumbai: {
     // Infura
     url: "https://matic-mumbai.chainstacklabs.com/",
     accounts: [accounts_keys["mumbai_network"]],
     chainId: 80001,
     live: true,
     saveDeployments: true,
     tags: ["staging"],
     gasMultiplier: 2,
   },

   ropsten: {
     url: `https://ropsten.infura.io/v3/${infuraId}`,
     accounts: [accounts_keys["ropsten_network"]],
     chainId: 3,
     live: true,
     saveDeployments: true,
     tags: ["staging"],
     gasPrice: 5000000000,
     gasMultiplier: 2,
   },

   rinkeby: {
     url: `https://rinkeby.infura.io/v3/${infuraId}`,
     accounts: [accounts_keys["rinkeby_network"]],
     chainId: 4,
     live: true,
     saveDeployments: true,
     tags: ["staging"],
     gasPrice: 5000000000,
     gasMultiplier: 2,
   },

   matic: {
     // Infura
     url: "https://rpc-mainnet.maticvigil.com",
     accounts: [accounts_keys["matic_network"]]
   },

   heco: {
     url: "https://http-mainnet.hecochain.com",
     accounts: [accounts_keys["heco_network"]],
     chainId: 128,
     live: true,
     saveDeployments: true,
   },
 };

 module.exports = {
  solidity: {
    version: "0.8.3",
    settings: {
      optimizer: {
        enabled: true,
        runs: 1000,
      },
    },
  },
};