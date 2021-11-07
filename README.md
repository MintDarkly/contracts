Put each new contract in its own folder.

Name the contract and its folder the same name.  Keep scripts for deployment and test in `scripts` folder.

Let's aim for each package.json having:
* `yarn compile`, to compile the contract code
* `yarn deploy`, to deploy the contract
* `yarn mint`, to mint the contract 

Notes:
* everything is hardcoded to the Ropsten network right now, we'll need to add functionality to deploy to multiple networks.  
* ^ this means that you'll need to create a metamask wallet and switch it over to this devnet
* to fund your wallet on Ropsten, visit this [link](https://faucet.ropsten.be/)