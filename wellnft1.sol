// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract WellNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string private prefixURI;
    mapping(uint256 => string) private tokenType;

    error NonExistentToken();

    event TokenMinted(address indexed user, uint256 tokenId, string tokenType);

    constructor(string memory _prefixURI) ERC721("WellNFT", "WNFT") Ownable(msg.sender) {
        prefixURI = _prefixURI;
    }

    // Simplified mint function for steps
    function mint(uint256 stepCount) external {
        uint256 tokenId = _mintToken(msg.sender, stepCount.toString());
        emit TokenMinted(msg.sender, tokenId, stepCount.toString());
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
        if (bytes(tokenType[_tokenId]).length == 0) revert NonExistentToken();
        return string(abi.encodePacked(prefixURI, _tokenId.toString(), "/metadata/", tokenType[_tokenId]));
    }

    function setPrefixURI(string calldata _prefixURI) external onlyOwner {
        prefixURI = _prefixURI;
    }

    function _mintToken(address to, string memory typeOfToken) private returns (uint256) {
        uint256 tokenId = totalSupply() + 1;
        _safeMint(to, tokenId);
        tokenType[tokenId] = typeOfToken;

        return tokenId;
    }
}
