// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

// Importing OpenZeppelin contracts for standard functionality
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// Main contract definition inheriting from ERC721Enumerable for NFT functionality and Ownable for ownership control
contract WellNFT is ERC721Enumerable, Ownable {
    using Strings for uint256; // Using Strings library for conversion operations

    // State variable for storing the base URI of token metadata
    string private prefixURI;
    // Mapping to keep track of each token's type
    mapping(uint256 => string) private tokenType;

    // Enum to define different types of NFTs that can be minted
    enum NFTType { Step, Kcal, Distance }
    // Event to log the minting of a new token
    event TokenMinted(address indexed user, uint256 tokenId, string tokenType);

    // Custom error to handle non-existent token requests
    error NonExistentToken();

    // Constructor to initialize the contract with a base URI for token metadata
    constructor(string memory _prefixURI) ERC721("WellNFT", "WNFT") Ownable(msg.sender) {
        prefixURI = _prefixURI;
    }

    // Function to mint a new NFT based on the number of steps
    function mintStepCount(uint256 stepCount) external {
        uint256 tokenId = _mintToken(msg.sender, stepCount.toString(), NFTType.Step);
        emit TokenMinted(msg.sender, tokenId, stepCount.toString());
    }

    // Function to mint a new NFT based on the amount of kcal burned
    function mintKcal(uint256 kcal) external {
        uint256 tokenId = _mintToken(msg.sender, kcal.toString(), NFTType.Kcal);
        emit TokenMinted(msg.sender, tokenId, kcal.toString());
    }

    // Function to mint a new NFT based on the distance traveled
    function mintDistance(uint256 distance) external {
        uint256 tokenId = _mintToken(msg.sender, distance.toString(), NFTType.Distance);
        emit TokenMinted(msg.sender, tokenId, distance.toString());
    }

    // Function to retrieve the metadata URI of a specific token
    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        if (bytes(tokenType[_tokenId]).length == 0) revert NonExistentToken();
        return string(abi.encodePacked(prefixURI, _tokenId.toString(), "/metadata/", tokenType[_tokenId]));
    }

    // Function to update the base URI for metadata, only callable by the contract owner
    function setPrefixURI(string calldata _prefixURI) external onlyOwner {
        prefixURI = _prefixURI;
    }

    // Internal function to handle the common logic of minting tokens
    function _mintToken(address to, string memory typeOfToken, NFTType nftType) private returns (uint256) {
        uint256 tokenId = totalSupply() + 1; // Incrementing token ID
        _safeMint(to, tokenId); // Minting the token safely

        // Determining the complete type of the token based on NFT type and appending it to the typeOfToken
        string memory completeType;
        if (nftType == NFTType.Step) {
            completeType = string(abi.encodePacked("step_", typeOfToken));
        } else if (nftType == NFTType.Kcal) {
            completeType = string(abi.encodePacked("kcal_", typeOfToken));
        } else if (nftType == NFTType.Distance) {
            completeType = string(abi.encodePacked("distance_", typeOfToken));
        }
        tokenType[tokenId] = completeType; // Storing the complete token type

        return tokenId; // Returning the minted token ID
    }
}
