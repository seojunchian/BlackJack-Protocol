// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

// tier 1 , 21 - only 1 player
// tier 2 , 21 - multiple players

import {Based} from "../../Imports.sol";

contract TwentyOne is Based {
    Based public based;

    error ContestIsntExist(uint256 contestRank);
    error ContestDidntStarted(uint256 contestRank);
    error ContestAlreadyEnded(uint256 contestRank);
    error InvalidContestCreationPrice(
        uint256 receivedPrice,
        uint256 contestCreationPrice
    );
    error InvalidContestEntrancePrice(
        uint256 contestRank,
        uint256 contestPrice,
        uint256 receivedPrice
    );
    error InvalidContestEntrance(
        uint256 contestRank,
        address contestContestant
    );

    event ContestCreated(uint256 rank, uint256 multiply, uint256 enterPrice);
    event ContestStarted(uint256 rank, address contestant);
    event ContestEnded(uint256 rank, bool win, uint256 drawedNumbersSum);

    struct TwentyOneContest {
        uint256 rank; // event, error
        uint256 multiply; //
        uint256 enterPrice; // error
        uint256[] randomNumbers; //
        address owner; // drawNumber if lose send money if win get the rest of it
        address contestant; // error
        bool start; // contests.start true , error, event
        bool end;
        bool win;
    }
    TwentyOneContest[] private twentyOneContests;

    // contest index finding
    uint256 increasingNumber;
    mapping(uint256 contestRank => uint256 contestIndex)
        public getContestIndexFromContestRank;

    mapping(address contestantAddress => uint256[] contestRank)
        public enteredContestsFromContestantAddress;
    mapping(address contestantAddress => mapping(uint256 contestRank => uint256[3] drawedNumbers))
        public drawedNumbersFromContestantAddressForWantedContest;
    mapping(address contestantAddress => mapping(uint256 contestRank => uint256 drawedNumbersSum))
        public drawedNumbersSumFromContestantAddressForWantedContest;

    function createContest(
        string memory _name,
        uint256 _multiply,
        uint256 _enterPrice
    ) public payable {
        /**
         * add more continuous variables so it would return diffrent value for everyone
         * if contest tryed to be created at the time names could be same, so add more continuous variables
         */
        if (msg.value != based.CONTEST_CREATION_PRICE())
            revert InvalidContestCreationPrice(
                msg.value,
                based.CONTEST_CREATION_PRICE()
            );

        uint256 contestRank = uint256(
            keccak256(abi.encode(_name, block.timestamp))
        );
        uint256[] memory _randomNumbers;
        twentyOneContests.push(
            TwentyOneContest(
                contestRank,
                _multiply,
                _enterPrice,
                _randomNumbers,
                msg.sender,
                address(0),
                false,
                false,
                false
            )
        );

        increasingNumber++;
        getContestIndexFromContestRank[contestRank] = increasingNumber;

        emit ContestCreated(contestRank, _multiply, _enterPrice);
    }

    function enterContest(uint256 _rank) public payable {
        uint256 contestIndex = getContestIndexFromContestRank[_rank] - 1;
        uint256 contestEnterPrice = twentyOneContests[contestIndex].enterPrice;
        address contestContestant = twentyOneContests[contestIndex].contestant;
        bool contestEnd = twentyOneContests[contestIndex].end;

        if (!contestEnd) revert ContestAlreadyEnded(_rank);
        if (msg.sender != contestContestant)
            revert InvalidContestEntrance(_rank, msg.sender);
        if (msg.value != contestEnterPrice)
            revert InvalidContestEntrancePrice(
                _rank,
                contestEnterPrice,
                msg.value
            );

        enteredContestsFromContestantAddress[msg.sender].push(_rank);
        twentyOneContests[contestIndex].start = true;
        emit ContestStarted(_rank, msg.sender);
    }

    function drawNumber(uint256 _rank) public payable {
        uint256 contestIndex = getContestIndexFromContestRank[_rank] - 1;
        address contestContestant = twentyOneContests[contestIndex].contestant;
        bool contestStart = twentyOneContests[contestIndex].start;
        bool contestWin = twentyOneContests[contestIndex].win;

        // revert
        if (!contestStart) revert ContestDidntStarted(_rank);
        if (msg.sender != contestContestant)
            revert InvalidContestEntrance(_rank, contestContestant);

        // Local variables
        uint256[3] memory drawedNumbers;
        uint256 drawedNumbersSum;

        // Drawing part
        uint256 drawedNumber;
        drawedNumber++;

        // Mapping
        drawedNumbersFromContestantAddressForWantedContest[msg.sender][
            _rank
        ] = drawedNumbers;
        drawedNumbersSumFromContestantAddressForWantedContest[msg.sender][
            _rank
        ] = drawedNumbersSum;

        twentyOneContests[contestIndex].end = true;

        // event
        emit ContestEnded(_rank, contestWin, drawedNumbersSum);

        // transfer
    }
}
