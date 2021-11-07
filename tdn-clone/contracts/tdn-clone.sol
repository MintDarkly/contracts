pragma solidity 0.8.7;

import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";

/*
    Questions:
        * what is a reentrancy guard?
        * can we cap the amount a wallet has?
        * how do I query an external resource to get allowable addresses? Do I put it on IPFS?
        * how do the functions access the msg.value?
*/

contract TieDyeNinjasClone is ERC721Enumerable, Ownable {
    bool public mintingActive = false;

    uint256 public pricePerNFT = 1 ether; // 1 ETH each, otherwise defaults to wei
    uint256 public tokenIndex = 0; // Current token ID
    uint256 public totalTokenSupply = 5;
    uint256 public maxTokensPerPurchaseTransaction = 1; // Can we cap the amount per address?
    uint256 public minimumTokensPerPuchaseTransaction = 1;

    constructor() ERC721("Tie Dye Ninjas Clone", "TDNC") {}

    function purchase(uint256 numTokensToPurchase) public payable {
        require(numTokensToPurchase <= maxTokensPerPurchaseTransaction, "Puchase amount exceeds max amount");
        require(numTokensToPurchase >= minimumTokensPerPuchaseTransaction, "Purchase amount must equal or exceed minimum amount");
        require(mintingActive, "Minting must be active");

        // is msg inhereited?
        require(pricePerNFT * numTokensToPurchase == msg.value, "Must provide exact value of ETH");


        // is msgSender inherited?
        for (uint256 i = 0; i < numTokensToPurchase; i++) {
            _mintToken(_msgSender());
        }
    }

    // can't be just _mint, because this overwrites inherited _mint
    function _mintToken(address mintAddress) private {
        tokenIndex++; // can we use counters instead?
        require(!_exists(tokenIndex), "Token already exists");
        // is this function inherited?, yes by ERC-721
        _safeMint(mintAddress, tokenIndex);
    }

    // Return True/False if a token with the ID provided has been minted
    function exists(uint tokenId) external view returns (bool) {
        // inherited from:
        // https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC721/ERC721.sol
        return _exists(tokenId);
    }


}