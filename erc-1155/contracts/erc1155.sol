pragma solidity 0.7.4;

import 'multi-token-standard/contracts/tokens/ERC1155/ERC1155.sol';
import 'multi-token-standard/contracts/tokens/ERC1155/ERC1155Metadata.sol';
import 'multi-token-standard/contracts/tokens/ERC1155/ERC1155MintBurn.sol';

contract OwnableDelegateProxy { }

contract ProxyRegistry {
  mapping(address => OwnableDelegateProxy) public proxies;
}

/*
    ███    ███ ██ ███    ██ ████████ ██████   █████  ██████  ██   ██ ██      ██    ██ 
    ████  ████ ██ ████   ██    ██    ██   ██ ██   ██ ██   ██ ██  ██  ██       ██  ██  
    ██ ████ ██ ██ ██ ██  ██    ██    ██   ██ ███████ ██████  █████   ██        ████   
    ██  ██  ██ ██ ██  ██ ██    ██    ██   ██ ██   ██ ██   ██ ██  ██  ██         ██    
    ██      ██ ██ ██   ████    ██    ██████  ██   ██ ██   ██ ██   ██ ███████    ██    

    -- .. -. - -.. .- .-. -.- .-.. -.-- 
*/

/**
 * @title ERC1155Tradable
 * ERC1155Tradable - ERC1155 contract that whitelists an operator address, has create and mint functionality, and supports useful standards from OpenZeppelin,
  like _exists(), name(), symbol(), and totalSupply()
 */
contract ERC1155Tradable is ERC1155, ERC1155MintBurn, ERC1155Metadata {
  
  string public name; // Contract name
  string public symbol; // Contract symbol
  address private contractOwner;
    
  constructor(
    string memory _name,
    string memory _symbol,
    address _contractOwner
  ) public {
    name = _name;
    symbol = _symbol;
    contractOwner = _contractOwner;
  }

  uint256 private _currentTokenID = 0;
  uint256 private _feePercentage = 5; 
  string private baseURI = '';
  
  
  struct Token {
      // Token Details
      address creator;
      uint256 currentId; // If minted now, what the token id would be
      uint256 totalSupply; // Max token supply, can only be increased
      string name;
      string symbol;
      string uri; // metadata link, updateable by creator and contract owner
      
      // Mint Details
      uint256 mintPriceWei; // Mint price in Wei, 1 ether = 1x10^18 Wei
      uint256 mintMaximum; // Max token amount per minting transaction
      uint256 mintMinimum; // Min token amount per minting transaction
      bool mintingActive; // Toggle for allowing minting
      
      // Fee Percentages
      uint256 contractOwnerFeePercentage; // 0-100 integer -> 0-100%
      uint256 tokenCreatorFeePercentage; // 0-100 integer -> 0-100%
  }
  

  mapping(uint256 => Token) public tokens; // token id -> Token details
  mapping(uint256 => address) public tokenCreators; // token id -> tokenCreator addresses

  
  function isTokenHolder(uint256 _id) public view returns (bool) {
      return balances[msg.sender][_id] > 0;
  }
  
  function isTokenCreator(uint256 _id) public view returns (bool) {
      return tokenCreators[_id] == msg.sender;
  }
  
  function isContractOwner() public view returns (bool) {
      return contractOwner == msg.sender;
  }
  
  modifier contractOwnerOnly() {
      require(isContractOwner(), "ERC1155Tradable#TokenCreatorOnly: ONLY_CONTRACT_OWNER_ALLOWED");
      _;
  }
  
  modifier tokenHoldersOnly(uint256 _id) {
      require(isTokenCreator(_id), "ERC1155Tradable#tokenHoldersOnly: ONLY_TOKEN_HOLDERS_ALLOWED");
      _;
  }
  
  modifier tokenCreatorOnly() {
      require(isContractOwner(), "ERC1155Tradable#TokenCreatorOnly: ONLY_CONTRACT_OWNER_ALLOWED");
      _;
  }
  
  modifier contractOwnerOrCreator(uint256 _id) {
      require(isContractOwner() || isTokenCreator(_id));
      _;
  }
  
  
  function AddToken(
      address _creator, 
      uint256 _totalSupply, 
      string  memory _name, 
      string memory _symbol, 
      uint256 _mintPriceWei, 
      uint256 _mintMaximum,
      uint256 _mintMinimum,
      uint256 _contractOwnerFeePercentage,
      uint256 _tokenCreatorFeePercentage
    //   uint256 _contractOwnerTokensRecieved
    ) public returns (uint256) {
        require(_contractOwnerFeePercentage <= 100, 'Owner Fees cannot exceed 100%');
        require(_tokenCreatorFeePercentage <= 100, 'Creator Fees cannot exceed 100%');
        require(_tokenCreatorFeePercentage + _contractOwnerFeePercentage <= 100, 'Total fees cannot exceed 100%');
        require(_mintMinimum > 0, 'Minting Minimum must at least 1');
        require(_mintMaximum <= _totalSupply, 'Minting maximum cannot exceed total token supply');
        
        tokenCreators[_currentTokenID] = _creator;
        Token memory newToken = Token({
            creator: _creator,
            currentId: 1,
            totalSupply: _totalSupply,
            name: _name,
            symbol: _symbol,
            uri: baseURI,
            mintPriceWei: _mintPriceWei,
            mintMaximum: _mintMaximum,
            mintMinimum: _mintMinimum,
            mintingActive: false,
            contractOwnerFeePercentage: _contractOwnerFeePercentage,
            tokenCreatorFeePercentage: _tokenCreatorFeePercentage
          });
          
        tokens[_currentTokenID] = newToken;
        
        _currentTokenID++;
        return _currentTokenID - 1;
  }

  function getCurrentTokenId() public view contractOwnerOnly returns (uint256) {
      return _currentTokenID;
  }
  
  function supportsInterface(bytes4 _interfaceId) public virtual override(ERC1155, ERC1155Metadata) pure returns (bool) {
      return true;
  }
  
  function SetMintPrice(uint256 _tokenId, uint256 _newMintPriceWei) public contractOwnerOrCreator(_tokenId) {
      tokens[_tokenId].mintPriceWei = _newMintPriceWei;
  }
  
  function SetMintingActive(uint256 _tokenId, bool _newValue) public contractOwnerOrCreator(_tokenId) {
      tokens[_tokenId].mintingActive = _newValue;
  }
  
  function GetMintingDetails(uint256 _tokenId) public view returns (uint256, uint256, uint256, bool, uint256) {
    Token memory token = tokens[_tokenId];
    uint256 availableSupply = token.totalSupply - token.currentId; 
      
    return (
         token.mintPriceWei,
         token.mintMaximum, 
         token.mintMinimum, 
         token.mintingActive,
         availableSupply
     );
  }
  
  function SetContractOwnerFeePercentage(uint256 _tokenId, uint256 _newFeePercentage) public contractOwnerOnly {
      require(_newFeePercentage <= 100, 'Owner Fees cannot exceed 100%');
      tokens[_tokenId].contractOwnerFeePercentage = _newFeePercentage;
  }
  
  function SetTokenCreatorFeePercentage(uint256 _tokenId, uint256 _newFeePercentage) public contractOwnerOrCreator(_tokenId) {
      require(_newFeePercentage <= 100, 'Creator Fees cannot exceed 100%');
      tokens[_tokenId].tokenCreatorFeePercentage = _newFeePercentage;
  }
  
  function GetFeeDetails(uint256 _tokenId) public view returns (uint256, uint256) {
    Token memory token = tokens[_tokenId];
      
    return (
        token.contractOwnerFeePercentage,
        token.tokenCreatorFeePercentage
     );
  }
  
  function SetURI(uint256 _tokenId, string memory _newURI) public contractOwnerOrCreator(_tokenId) {
      tokens[_tokenId].uri = _newURI;
  }
  
  function SetCreator(uint256 _tokenId, address _newAddress) public contractOwnerOrCreator(_tokenId) {
      tokens[_tokenId].creator = _newAddress;
  }
  
  function IncreaseSupply(uint256 _tokenId, uint256 _newSupply) public contractOwnerOrCreator(_tokenId) {
      require(_newSupply > tokens[_tokenId].totalSupply, 'Token Supply can only increase');
      tokens[_tokenId].totalSupply = _newSupply;
  }
  
  function GetTokenDetails(uint256 _tokenId) public view returns (address, uint256, uint256, string memory, string memory, string memory) {
      Token memory token = tokens[_tokenId];
      
      return (
        token.creator,
        token.currentId,
        token.totalSupply,
        token.name,
        token.symbol,
        token.uri
    );
  }
  
}