// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract SleepScoreNFT is ERC721, Ownable {
    using Strings for uint256;

    string private baseURI;
    mapping(uint256 => string) private tokenURIs;
    uint256 private _tokenIdCounter = 0;

    event SleepScoreNFTMinted(address indexed user, uint256 tokenId, string scoreType);

    constructor(string memory _baseURI) ERC721("SleepScoreNFT", "SSNFT") {
        baseURI = _baseURI;
    }

    function mintSleepScore(address user, uint8 weeks, uint8 score) external onlyOwner {
        require(weeks >= 1 && weeks <= 4, "Weeks count must be between 1 and 4");
        require(score >= 60 && score <= 100, "Score must be between 60 and 100");

        uint256 newTokenId = _tokenIdCounter + 1;
        _tokenIdCounter = newTokenId;

        _mint(user, newTokenId);
        
        string memory scoreType = string(abi.encodePacked(weeks.toString(), " weeks + ", score.toString(), " score"));
        tokenURIs[newTokenId] = string(abi.encodePacked(baseURI, newTokenId.toString()));
        
        emit SleepScoreNFTMinted(user, newTokenId, scoreType);
    }

    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        return tokenURIs[tokenId];
    }

    function setBaseURI(string calldata _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }
}
