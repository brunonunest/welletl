// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract IdentityNFT is ERC721, Ownable {
    using Strings for uint256;

    string private baseURI;
    mapping(address => uint256) public userToIdentityToken;
    uint256 private _tokenIdCounter = 0;

    event IdentityNFTMinted(address indexed user, uint256 tokenId);

    constructor(string memory _baseURI) ERC721("WIdentityNFT", "WIDNFT") Ownable(msg.sender) {
    baseURI = _baseURI;
    }

    function mintIdentityToken(address user) external onlyOwner {
        require(userToIdentityToken[user] == 0, "User already has an identity token");
        uint256 newTokenId = _tokenIdCounter + 1;
        _tokenIdCounter = newTokenId;

        _mint(user, newTokenId);
        userToIdentityToken[user] = newTokenId;

        emit IdentityNFTMinted(user, newTokenId);
    }

    // Updated tokenURI function
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(tokenId > 0 && tokenId <= _tokenIdCounter, "ERC721Metadata: URI query for nonexistent token");

        // Construct the token URI on the fly
        return string(abi.encodePacked(baseURI, tokenId.toString()));
    }

    function setBaseURI(string calldata _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    function hasIdentityToken(address user) external view returns (bool) {
        return userToIdentityToken[user] != 0;
    }
}