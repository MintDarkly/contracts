//Contract based on [https://docs.openzeppelin.com/contracts/3.x/erc721](https://docs.openzeppelin.com/contracts/3.x/erc721)
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol"; // the ERC-721 standard
import "@openzeppelin/contracts/utils/Counters.sol"; // counters than can only inc/dec in values of 1
import "@openzeppelin/contracts/access/Ownable.sol"; // access control, who do you allow to mint?
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract TemplateNFT is ERC721URIStorage, Ownable {
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIds;

    constructor() public ERC721("TemplateNFT", "TemplateNFT") {}

    /*
        the recipient -> who gets it after mint
        tokenURI -> metadata from ipfs configurable properties like name, description, image and other attributes
    */
    function mintNFT(address recipient, string memory tokenURI)
        public onlyOwner 
        returns (uint256)
    { 

        _tokenIds.increment();

        uint256 newItemId = _tokenIds.current();
        _mint(recipient, newItemId);
        _setTokenURI(newItemId, tokenURI);

        return newItemId;
    }
}