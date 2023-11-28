// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721Enumerable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

// error nonExistentToken();

contract WellNFT is ERC721Enumerable, Ownable(msg.sender) {
    using Strings for uint256;

    string private prefixURI;

    struct Entry {
        uint256 dailyGoal;
        uint256 timestamp;
    }

    struct userData {
        address user;
        Entry[] entries;
    }

    mapping(address => userData) public userDataHistory;

    mapping(uint256 => string) public tokenType;

    Entry[] public entries;
    
    constructor(string memory _prefixURI) ERC721("WellNFT", "WNFT") {
        prefixURI = _prefixURI;
    }

    function uintToString(uint256 value) public pure returns (string memory) {
        return value.toString();
    }

    function getUserHistory(address userAddress) public view returns (Entry[] memory) {
        return userDataHistory[userAddress].entries;
    }

    function firstMint(address userAddress) public {
    require(userDataHistory[userAddress].entries.length == 0, "Not the first access");
    uint256 tokenId = totalSupply() + 1;
    _safeMint(msg.sender, tokenId);
    tokenType[tokenId] = "welcome";
    Entry memory newEntry = Entry({
        dailyGoal: 5000,  // or any other value you want to set
        timestamp: block.timestamp
    });
    // userDataHistory[userAddress].user = userAddress;
    userDataHistory[userAddress].entries.push(newEntry);
    }

    function getLastGoal(address userAddress) public view returns (uint256) {
        uint256 entriesCount = userDataHistory[userAddress].entries.length;
        require(entriesCount > 0, "No entries found for this address");
        Entry memory lastEntry = userDataHistory[userAddress].entries[entriesCount - 1];
        return lastEntry.dailyGoal;
    }

    function mint(uint256 stepCount) public {
    address userAddress = msg.sender;
    uint256 lastGoalValue = getLastGoal(userAddress);
    require(stepCount >= lastGoalValue, "Value to compare is less than the goal");
    uint256 tokenId = totalSupply() + 1;
    _safeMint(msg.sender, tokenId);
    tokenType[tokenId] = uintToString(lastGoalValue);

    // Update the last goal directly without calling another function
    Entry memory newEntry = Entry({
        dailyGoal: stepCount,  // New goal based on the stepCount
        timestamp: block.timestamp
    });
    userDataHistory[userAddress].entries.push(newEntry);
    }


    function tokenURI(
        uint256 _tokenId
    ) public view virtual override returns (string memory) {
        return
            string(
                abi.encodePacked(
                    prefixURI,
                    Strings.toString(_tokenId),
                    "/metadata", tokenType[_tokenId]  // Include the type in the URI
                )
            );
    }

    function setPrefixURI(string memory _prefixURI) public onlyOwner {
        prefixURI = _prefixURI;
    }

    function firstGoal(uint256 stepCount, address userAddress) public onlyOwner {
        uint256 goal = 0;
        uint256 lastGoalValue = getLastGoal(userAddress);
        if (stepCount < 5000) {
            goal = 5000;
        } if (stepCount >= 5000 && lastGoalValue < 6000) {
            goal = 6000;
        }
        if (stepCount >= lastGoalValue) {
            Entry memory newEntry = Entry({
            dailyGoal: goal,  // or any other value you want to set
            timestamp: block.timestamp
            });
            mint(stepCount);
            userDataHistory[userAddress].entries.push(newEntry);
        }
    }

    function lastGoal(uint256 stepCount, address userAddress) public onlyOwner {
        uint256 goal = 0;
        uint256 lastGoalValue = getLastGoal(userAddress);
        if (stepCount < 5000) {
            goal = 5000;
        } if (stepCount >= 5000 && stepCount < 6000 && lastGoalValue == 5000) {
            goal = 6000;
        } if (stepCount >= 6000 && stepCount < 7000 && lastGoalValue == 6000) {
            goal = 7000;
        } if (stepCount >= 7000 && stepCount < 8000 && lastGoalValue == 7000) {
            goal = 8000;
        } if (stepCount >= 8000 && lastGoalValue == 8000) {
            goal = lastGoalValue + 1000;
        }
        if (stepCount >= lastGoalValue) {
            Entry memory newEntry = Entry({
            dailyGoal: goal,  // or any other value you want to set
            timestamp: block.timestamp
            });
            userDataHistory[userAddress].entries.push(newEntry);
        } 
    }

    //maybe not needed
    function updateGoal(uint256 _newGoal, address userAddress) public onlyOwner {
        if (_newGoal > getLastGoal(userAddress)) {
            Entry memory newEntry = Entry({
            dailyGoal: _newGoal,  // or any other value you want to set
            timestamp: block.timestamp
            });
            userDataHistory[userAddress].entries.push(newEntry);
        } 
    }
}
