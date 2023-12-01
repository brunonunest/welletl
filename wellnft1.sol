// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract WellNFT is ERC721Enumerable, Ownable {
    using Strings for uint256;

    string private prefixURI;

    struct Entry {
        uint256 dailyGoal;
        uint256 timestamp;
    }

    struct UserData {
        Entry[] entries;
    }

    mapping(address => UserData) private userDataHistory;
    mapping(uint256 => string) private tokenType;

    error NonExistentToken();
    error NotFirstAccess();
    error NoEntriesFound();
    error GoalNotMet(uint256 requiredGoal);

    event GoalUpdated(address indexed user, uint256 newGoal);
    event TokenMinted(address indexed user, uint256 tokenId);

    constructor(string memory _prefixURI) ERC721("WellNFT", "WNFT") Ownable(msg.sender) {
    prefixURI = _prefixURI;
    }

    function firstMint(address userAddress) external {
        UserData storage user = userDataHistory[userAddress];
        if (user.entries.length > 0) revert NotFirstAccess();

        uint256 tokenId = _mintToken(userAddress, "welcome", 5000);
        emit TokenMinted(userAddress, tokenId);
    }

    function mint(uint256 stepCount) external {
    UserData storage user = userDataHistory[msg.sender];
    uint256 lastGoalValue = getLastGoal(msg.sender);

    if (stepCount < lastGoalValue) revert GoalNotMet(lastGoalValue);

    uint256 tokenId = _mintToken(msg.sender, lastGoalValue.toString(), stepCount);
    emit TokenMinted(msg.sender, tokenId);

    // Update the user's entries with the new goal
    user.entries.push(Entry({dailyGoal: stepCount, timestamp: block.timestamp}));
    }


    function getLastGoal(address userAddress) public view returns (uint256) {
        UserData storage user = userDataHistory[userAddress];
        uint256 entriesCount = user.entries.length;
        if (entriesCount == 0) revert NoEntriesFound();

        return user.entries[entriesCount - 1].dailyGoal;
    }

    function tokenURI(uint256 _tokenId) public view override returns (string memory) {
    if (bytes(tokenType[_tokenId]).length == 0) revert NonExistentToken();

    return string(abi.encodePacked(prefixURI, _tokenId.toString(), "/metadata/", tokenType[_tokenId]));
    }


    function setPrefixURI(string calldata _prefixURI) external onlyOwner {
        prefixURI = _prefixURI;
    }

    function _mintToken(address to, string memory typeOfToken, uint256 newGoal) private returns (uint256) {
        uint256 tokenId = totalSupply() + 1;
        _safeMint(to, tokenId);

        tokenType[tokenId] = typeOfToken;

        userDataHistory[to].entries.push(Entry({dailyGoal: newGoal, timestamp: block.timestamp}));
        emit GoalUpdated(to, newGoal);

        return tokenId;
    }
}
