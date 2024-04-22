// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Based} from "../../Based/Based.sol";

contract TwentyOne is Based {
    /******************** ERROR ********************/
    error ContestIsntExist(uint256 contestRank);
    error ContestAlreadyExist(uint256 contestRank);
    error ContestIsFull(uint256 contestRank);
    //
    error CompetitorIsntEntered(uint256 contestRank);
    error ContestantIsntEntered(uint256 contestRank);
    error CompetitorAlreadyEntered(uint256 contestRank);
    error ContestantAlreadyEntered(uint256 contestRank);
    //
    error ContestFinishedDrawingCard(uint256 contestRank, address drawer);
    error ContestEnded(uint256 contestRank);
    error ItsNotYourTurn();
    error InvalidContestCreationPrice(
        uint256 receivedPrice,
        uint256 contestCreationPrice
    );
    error InvalidContestEntrancePrice(
        uint256 contestRank,
        uint256 contestPrice,
        uint256 receivedPrice
    );
    error InvalidContestantEntrance(
        uint256 contestRank,
        address contestContestant
    );

    /******************** EVENT ********************/
    event ContestCreated(
        uint256 rank,
        uint256 enterPrice,
        uint256 openingTime,
        uint256 closingTime,
        uint256 playTime
    );
    event ContestFinished(uint256 rank, uint256 drawedNumbersSum);

    /******************** STRUCT ********************/
    struct TwentyOneContest {
        address creator;
        uint256 rank;
        uint256 enterPrice;
        //
        address competitor;
        bool isCompetitorEntered;
        bool isCompetitorFinished;
        address contestant;
        bool isContestantEntered;
        bool isContestantFinished;
        //
        uint256 openingTime;
        uint256 closingTime;
        uint256 playTime;
        //
        uint8[] competitorDrawedNumbers;
        uint8[] contestantDrawedNumbers;
        //
        bool end;
    }
    TwentyOneContest[] private twentyOneContests;

    /******************** MAPPING ********************/
    // contest exictence
    mapping(uint256 contestRank => bool isExist) public isContestExist;
    // contest index finding
    uint256 increasingNumber;
    mapping(uint256 contestRank => uint256 contestIndex)
        public getContestIndexFromContestRank;
    // entered contests
    mapping(address contestantAddress => uint256[] contestRank)
        public enteredContests;
    // drawed numbers from contest rank
    mapping(address contestantAddress => mapping(uint256 contestRank => uint256[3] drawedNumbers))
        public drawedNumbersFromContestantAddressForWantedContest;
    // drawed numbers sum from contest rank
    mapping(address contestantAddress => mapping(uint256 contestRank => uint256 drawedNumbersSum))
        public drawedNumbersSumFromContestantAddressForWantedContest;

    /******************** FUNCTIONS ********************/

    // if opening time pass and no one enters money wont return
    // if time is over whoever is high will win
    // create contest
    function createContest(
        uint256 _enterPrice,
        uint256 _openingTime,
        uint256 _closingTime,
        uint256 _playTime
    ) public payable {
        /*************** RANK CREATION ***************/
        // add more continuous variables so it would return diffrent value for everyone
        // if contest tryed to be created at the time names could be same, so add more continuous variables
        uint256 contestRank = uint256(
            keccak256(abi.encode(block.timestamp, block.number))
        );

        /*************** REVERT ***************/
        if (isContestExist[contestRank])
            revert ContestAlreadyExist(contestRank);

        if (msg.value != Based.CONTEST_CREATION_PRICE)
            revert InvalidContestCreationPrice(
                msg.value,
                CONTEST_CREATION_PRICE
            );

        /*************** STRUCT ****************/
        uint8[] memory _contestantDrawedNumbers;
        uint8[] memory _dealerDrawedNumbers;
        twentyOneContests.push(
            TwentyOneContest(
                msg.sender,
                contestRank,
                _enterPrice,
                msg.sender,
                false,
                false,
                msg.sender,
                false,
                false,
                _openingTime,
                _closingTime,
                _playTime,
                _dealerDrawedNumbers,
                _contestantDrawedNumbers,
                false
            )
        );

        /*************** MAPPING ***************/
        isContestExist[contestRank] = true;
        increasingNumber++;
        getContestIndexFromContestRank[contestRank] = increasingNumber;

        /*************** EVENT ***************/
        emit ContestCreated(
            contestRank,
            _enterPrice,
            _openingTime,
            _closingTime,
            _playTime
        );

        /*************** TRANSFER ***************/
        payable(Based.CONTRACT_OWNER).transfer(msg.value);
    }

    function enterContest(uint256 _rank) public payable {
        if (!isContestExist[_rank]) revert ContestIsntExist(_rank);

        uint256 contestIndex = getContestIndexFromContestRank[_rank] - 1;
        uint256 contestEnterPrice = twentyOneContests[contestIndex].enterPrice;
        bool contestEnd = twentyOneContests[contestIndex].end;
        bool isCompetitorEntered = twentyOneContests[contestIndex]
            .isCompetitorEntered;
        bool isContestantEntered = twentyOneContests[contestIndex]
            .isContestantEntered;

        if (!contestEnd) revert ContestEnded(_rank);
        if (msg.value != contestEnterPrice)
            revert InvalidContestEntrancePrice(
                _rank,
                contestEnterPrice,
                msg.value
            );
        if (isCompetitorEntered) revert CompetitorAlreadyEntered(_rank);
        if (isContestantEntered) revert ContestantAlreadyEntered(_rank);
        //
        if (isCompetitorEntered) revert CompetitorAlreadyEntered(_rank);
        else twentyOneContests[contestIndex].competitor = msg.sender;
        if (isContestantEntered) revert ContestIsFull(_rank);

        enteredContests[msg.sender].push(_rank);
    }

    function competitorDrawNumber(uint256 _rank) public {
        if (!isContestExist[_rank]) revert ContestIsntExist(_rank);
        uint256 contestIndex = getContestIndexFromContestRank[_rank] - 1;
        bool isEntered = twentyOneContests[contestIndex].isCompetitorEntered;
        if (!isEntered) revert CompetitorIsntEntered(_rank);
        address contestCompetitor = twentyOneContests[contestIndex].competitor;

        // revert
        if (msg.sender != contestCompetitor)
            revert InvalidContestantEntrance(_rank, contestCompetitor);

        // Local variables
        uint256[3] memory drawedNumbers;
        uint256 drawedNumbersSum;

        // Drawing part

        // Mapping
        drawedNumbersFromContestantAddressForWantedContest[msg.sender][
            _rank
        ] = drawedNumbers;
        drawedNumbersSumFromContestantAddressForWantedContest[msg.sender][
            _rank
        ] = drawedNumbersSum;

        twentyOneContests[contestIndex].end = true;

        // event
        emit ContestFinished(_rank, drawedNumbersSum);

        // transfer
    }

    function contestantDrawNumber(uint256 _rank) public {
        if (!isContestExist[_rank]) revert ContestIsntExist(_rank);
        uint256 contestIndex = getContestIndexFromContestRank[_rank] - 1;
        bool isEntered = twentyOneContests[contestIndex].isContestantEntered;
        if (!isEntered) revert ContestantIsntEntered(_rank);
        address contestContestant = twentyOneContests[contestIndex].contestant;

        // revert
        if (msg.sender != contestContestant)
            revert InvalidContestantEntrance(_rank, contestContestant);

        // Local variables
        uint256[3] memory drawedNumbers;
        uint256 drawedNumbersSum;

        // Drawing part

        // Mapping
        drawedNumbersFromContestantAddressForWantedContest[msg.sender][
            _rank
        ] = drawedNumbers;
        drawedNumbersSumFromContestantAddressForWantedContest[msg.sender][
            _rank
        ] = drawedNumbersSum;

        twentyOneContests[contestIndex].end = true;

        // event

        // transfer
    }
}
