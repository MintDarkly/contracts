require('dotenv').config({path: __dirname+'/../../.env'});

const contract = require('../artifacts/contracts/template.sol/TemplateNFT.json')

const ALCHEMY_URL = process.env.ALCHEMY_URL;
const METAMASK_PRIVATE_KEY = process.env.METAMASK_PRIVATE_KEY;
const METAMASK_PUBLIC_KEY = process.env.METAMASK_PUBLIC_KEY;

const { createAlchemyWeb3 } = require("@alch/alchemy-web3")
const web3 = createAlchemyWeb3(ALCHEMY_URL)

const contractAddress = "0x9aF80611236883170eb3E734904c107Ca5c4fB66"; // address of the deployed contract 
const templateContract = new web3.eth.Contract(contract.abi, contractAddress);

const ipfsMetaDataURI = ""

const mintTemplateNFT = async () => {
    const nonce = await web3.eth.getTransactionCount(METAMASK_PUBLIC_KEY, 'latest');

    const tx = {
        'from': METAMASK_PUBLIC_KEY,
        'to': contractAddress,
        'nonce': nonce,
        'gas': 500000,
        'data': templateContract.methods.mintNFT(METAMASK_PUBLIC_KEY, ipfsMetaDataURI).encodeABI()
      };

      const signPromise = web3.eth.accounts.signTransaction(tx, METAMASK_PRIVATE_KEY)
  signPromise
    .then((signedTx) => {
      web3.eth.sendSignedTransaction(
        signedTx.rawTransaction,
        function (err, hash) {
          if (!err) {
            console.log(
              "The hash of your transaction is: ",
              hash,
              "\nCheck Alchemy's Mempool to view the status of your transaction!"
            )
          } else {
            console.log(
              "Something went wrong when submitting your transaction:",
              err
            )
          }
        }
      )
    })
    .catch((err) => {
      console.log(" Promise failed:", err)
    })
}

mintTemplateNFT();