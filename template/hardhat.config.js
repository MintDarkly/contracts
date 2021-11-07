/**
* @type import('hardhat/config').HardhatUserConfig
*/
require('dotenv').config({path: __dirname+'/../.env'});
console.log(__dirname+'/../.env')
require("@nomiclabs/hardhat-ethers");
const { ALCHEMY_URL, METAMASK_PRIVATE_KEY } = process.env;
module.exports = {
   solidity: "0.8.0",
   defaultNetwork: "ropsten",
   networks: {
      hardhat: {},
      ropsten: {
         url: ALCHEMY_URL,
         accounts: [`0x${METAMASK_PRIVATE_KEY}`]
      }
   },
}