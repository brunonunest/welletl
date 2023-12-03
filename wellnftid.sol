// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

// import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
// import "@openzeppelin/contracts/access/Ownable.sol";


import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.5.0/contracts/token/ERC721/ERC721.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.5.0/contracts/access/Ownable.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/v4.5.0/contracts/utils/Strings.sol";


// Main contract definition, inheriting from ERC721 for NFT functionality and Ownable for ownership control
contract IdentityNFT is ERC721, Ownable {
    using Strings for uint256; // Utilizing the Strings library for string conversion functions

    // State variables
    string private baseURI; // Base URI for token metadata
    mapping(address => uint256) public userToIdentityToken; // Mapping from user addresses to their identity token IDs
    mapping(uint256 => string) private tokenURIs; // Mapping from token IDs to their metadata URIs
    uint256 private _tokenIdCounter = 0; // Counter to keep track of the last token ID issued

    // Event emitted when a new identity NFT is minted
    event IdentityNFTMinted(address indexed user, uint256 tokenId);

    // Constructor to initialize the contract with a given base URI
    constructor(string memory _baseURI) ERC721("WIdentityNFT", "WIDNFT") {
        baseURI = _baseURI;
    }

    // Function to mint a new identity token for a user
    function mintIdentityToken(address user) external onlyOwner {
        require(userToIdentityToken[user] == 0, "User already has an identity token");

        uint256 newTokenId = _tokenIdCounter + 1; // Incrementing the token ID counter to get a new unique token ID
        _tokenIdCounter = newTokenId; // Updating the counter

        _mint(user, newTokenId); // Minting the token to the specified user
        userToIdentityToken[user] = newTokenId; // Mapping the user address to the new token ID
        
        string memory newTokenURI = string(abi.encodePacked(baseURI, newTokenId.toString())); // Constructing the token URI
        tokenURIs[newTokenId] = newTokenURI; // Associating the token ID with its URI

        emit IdentityNFTMinted(user, newTokenId); // Emitting the mint event
    }

    // Override for the tokenURI function to return the URI for a given token ID
    function tokenURI(uint256 tokenId) public view override returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");
        return tokenURIs[tokenId];
    }

    // Function to update the base URI for metadata, callable only by the contract owner
    function setBaseURI(string calldata _baseURI) external onlyOwner {
        baseURI = _baseURI;
    }

    // Optional function to check if a specific user has an identity token
    function hasIdentityToken(address user) external view returns (bool) {
        return userToIdentityToken[user] != 0;
    }
}
