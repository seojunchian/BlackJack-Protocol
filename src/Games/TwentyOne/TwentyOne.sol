// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// tier 1 , 21 - only 1 player
// tier 2 , 21 - multiple players

import {VRFv2Consumer} from "../../Imports.sol";
import {Contest} from "../../Imports.sol";

contract TwentyOne is Contest {
    Contest public contest;
    VRFv2Consumer public vrfv2Consumer;

    error InvalidContestCreationPrice(
        bytes32 contestName,
        uint256 receivedPrice,
        uint256 contestCreationPrice
    );

    event ContestCreated(bytes32 name, uint256 multiply, uint256 enterPrice);

    struct TwentyOneContest {
        uint256 rank;
        address owner;
        address winner;
        uint256 multiply;
        uint256 enterPrice;
        uint256[] randomNumbers;
    }
    TwentyOneContest[] private twentyOneContests;

    // contest index finding
    uint256 increasingNumber;
    mapping(string contestName => uint256 getcontestIndexFromIncreasingNumber)
        public getContestIndexFromContestName;

    mapping(bytes32 name => mapping(address => uint256[] randomNumbers))
        public RandomNumbersOfGivenAddressFromContestName;

    mapping(address contestantAddress => bytes32[] contestName)
        public enteredContests;

    function createContest(
        string memory _name,
        uint256 _multiply,
        uint256 _enterPrice
    ) public payable {
        /**
         * add more continuous variables so it would return diffrent value for everyone
         * if contest tryed to be created at the time names could be same, so add more continuous variables
         */
        bytes32 name = bytes32(keccak256(abi.encode(_name, block.timestamp)));

        if (msg.value != contest.CONTEST_CREATION_PRICE())
            revert InvalidContestCreationPrice(name, msg.value, _enterPrice);

        uint256[] memory _randomNumbers;
        twentyOneContests.push(
            TwentyOneContest(
                name,
                msg.sender,
                address(0),
                _multiply,
                _enterPrice,
                _randomNumbers
            )
        );

        increasingNumber++;
        getContestIndexFromContestName[name] = increasingNumber;

        emit ContestCreated(name, _multiply, _enterPrice);
    }

    function enterContest() public {
        uint256 contestIndex = getContestIndexFromContestName[name] - 1;
    }
}
