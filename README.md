Put each new contract in its own folder.

Name the contract and its folder the same name.  Keep scripts for deployment and test in `scripts` folder.

Let's aim for each package.json having:
* `yarn compile`, to compile the contract code
* `yarn deploy`, to deploy the contract
* `yarn mint`, to mint the contract 