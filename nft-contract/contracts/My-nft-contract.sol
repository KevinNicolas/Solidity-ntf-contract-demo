// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

// Dependencie: @openzeppelin/contracts
// IMPORTANTE - Puede tirar error de path, pero en realidad funciona, solamente tiene problemas con el scope de vscode
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/Counters.sol";

contract DemoNft is ERC721 {

    // Token id
    using Counters for Counters.Counter;
    Counters.Counter private _tokenIdCounter;

    // Token information
    struct TokenInfo {
        string name;
        string symbol;
        string imageUrl;
        uint8 availableQuantity;
        uint256 priceInEthers;
    }
    mapping (string => TokenInfo)  tokensInfo;

    // List of existent tokens
    struct Token {
        uint256 id;
        string tokenSymbol;
        address owner;
    }
    Token [] private tokens;


    constructor() ERC721("DemoNft", "DEM") {
        // name, symbol, imageUrl, availableQuantity, priceInEthers
        tokensInfo["FOX"] = TokenInfo("Fox nft", "FOX", "fox-nft.png", 2, 5 ether);
        tokensInfo["KIN"] = TokenInfo("Kindred nft", "KIN", "kindred-nft.png", 10, 4 ether);
        tokensInfo["JAI"] = TokenInfo("Jaina nft", "JAI", "jaina-nft.png", 10, 7 ether);
        tokensInfo["WIN"] = TokenInfo("Winner of Game", "WIN", "winner-nft.png", 1, 100 ether);
    }

    // METHODS

    function _removeToken (uint256 _id) internal {
        int indexOfId = -1;
        for (uint256 i = 0; i < tokens.length; i++) {
            if (tokens[i].id == _id) {
                indexOfId = int256(i);
                break;
            }
        }
        if (indexOfId >= 0) {
            if (tokens.length > 1) tokens[uint256(indexOfId)] = tokens[tokens.length - 1];
            tokensInfo[tokens[uint256(indexOfId)].tokenSymbol].availableQuantity++;
            tokens.pop();
        }
    }

    function mint (address _account, string memory _tokenSymbol) public returns(uint256) {
        require(tokensInfo[_tokenSymbol].availableQuantity > 0);
        require(keccak256(bytes("WIN")) != keccak256(bytes(_tokenSymbol)));

        // Create new token
        Token memory newToken = Token(_tokenIdCounter.current(), _tokenSymbol, _account);
        // Save token
        tokens.push(newToken);

        // Increment counter
        _tokenIdCounter.increment();
        // Decrease available token quantity
        tokensInfo[_tokenSymbol].availableQuantity = tokensInfo[_tokenSymbol].availableQuantity - 1;

        return newToken.id;
    }

    function obtainWinnerToken (address _account) public returns (uint256) {
        require(tokensInfo["WIN"].availableQuantity > 0);
        Token[] memory tokensOfAccount = getAllTokensOf(_account);

        int256[] memory tokensIds = new int256[](3);
        for (uint8 i = 0; i < 3; i++) tokensIds[i] = -1;
        
        for (uint256 i = 0; i < tokensOfAccount.length; i++) {
            if (keccak256(bytes(tokensOfAccount[i].tokenSymbol)) == keccak256(bytes("FOX"))) tokensIds[0] = int256(tokensOfAccount[i].id);
            else if (keccak256(bytes(tokensOfAccount[i].tokenSymbol)) == keccak256(bytes("KIN"))) tokensIds[1] = int256(tokensOfAccount[i].id);
            if (keccak256(bytes(tokensOfAccount[i].tokenSymbol)) == keccak256(bytes("JAI"))) tokensIds[2] = int256(tokensOfAccount[i].id);
        }

        require(tokensIds[0] >= 0 && tokensIds[1] >= 0 && tokensIds[2] >= 0);
        for (uint i = 0; i < 3; i++) _removeToken(uint256(tokensIds[i]));
        
        // Create new token
        Token memory newToken = Token(_tokenIdCounter.current(), "WIN", _account);
        // Save token
        tokens.push(newToken);

        // Increment counter
        _tokenIdCounter.increment();
        // Decrease available token quantity
        tokensInfo["WIN"].availableQuantity = tokensInfo["WIN"].availableQuantity - 1;
        return newToken.id;
    }

    function buyToken (address _account, string memory _tokenSymbol) public payable {
        require(msg.value >= tokensInfo[_tokenSymbol].priceInEthers);
        mint(_account, _tokenSymbol);
    }

    // GETTERS

    function getAllTokens () public view returns(Token[] memory) {
        return tokens;
    }

    function getAllTokensOf (address _account) public view returns (Token[] memory) {
        // Count match quantity
        uint256 countOfUserTokens = 0;
        for (uint i = 0; i < tokens.length; i++) if (_account == tokens[i].owner) countOfUserTokens++;
        
        // Make new array with tokens of _account
        Token[] memory tokensOfAccount = new Token[](countOfUserTokens);
        uint256 indexOfTokensOfAccount = 0;
        for (uint i = 0; i < tokens.length; i++) if (_account == tokens[i].owner && keccak256(bytes(tokens[i].tokenSymbol)) != keccak256(bytes(""))) {
          tokensOfAccount[indexOfTokensOfAccount] = tokens[i];
          indexOfTokensOfAccount++;
        }

        return tokensOfAccount;
    }

    function getTokensInfo (string memory _symbol) public view returns(TokenInfo memory) {
      return tokensInfo[_symbol];
    }

    function getWinner () public view returns (address) {
        address winner;
        for (uint256 i = 0; i < tokens.length; i++) if (keccak256(bytes(tokens[i].tokenSymbol)) == keccak256(bytes("WIN"))) {
            winner = tokens[i].owner;
            break;
        }
        return winner;
    
    }
}