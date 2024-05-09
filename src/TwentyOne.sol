// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Based} from "./Based.sol";
import {VRFv2Consumer} from "./VRFv2Consumer.sol";

// openzeppelin math
// openzeppelin ownable (maybe)

// start duration end time of contest

/* PROBLEMS */
// cant see drawed numbers for both sides
// when 2 contestants there is give 2 errors contest is full and alredy joined

import {Based} from "./Based.sol";

contract TwentyOne is Based {
    Based public based;
    /******************** ERROR ********************/
    error ContestIsntExist(uint256 contestRank);
    error ContestIsFull(uint256 contestRank);
    error ContestIsEnd(uint256 contestRank, address winner);
    error InvalidContestCreationPrice(
        uint256 receivedPrice,
        uint256 contestCreationPrice
    );
    error InvalidContestantEntrancePrice(
        uint256 contestRank,
        uint256 contestPrice,
        uint256 receivedPrice
    );
    error InvalidContestantEntrance(
        uint256 contestRank,
        address contestantAddress
    );
    error ContestantFinishedDrawingCardsError(address finisher);
    //
    error ItsNotContestantsTurn(address contestantAddress);
    //
    error ContestantDidntDrawAce(
        uint256 contestRank,
        address contestantAddress
    );
    /******************** EVENT ********************/
    event ContestCreated(uint256 contestRank);
    event ContestantEntered(uint256 contestRank, address contestantAddress);
    event ContestantDrawedACard(uint256 drawedCard);
    event ContestantFinishedDrawingCardsEvent(address finisher);
    event ContestWinnerDetermined(uint256 contestRank, address winner);
    /******************** STRUCT ********************/
    struct TwentyOneContest {
        address creator;
        uint256 rank;
        uint256 enterPrice;
        uint256 collectedPrice;
        // instead of struct array. write 2 stuct variable
        /** instead of */
        address contestant1Address;
        address contestant2Address;
        uint256[] contestant1DrawedNumbers;
        uint256[] contestant2DrawedNumbers;
        uint256 contestant1DrawedNumbersSum;
        uint256 contestant2DrawedNumbersSum;
        bool isContestant1Turn;
        bool isContestant2Turn;
        bool isContestant1Finished;
        bool isContestant2Finished;
        /* this */
        bool end;
    }
    TwentyOneContest[] public twentyOneContests;
    /******************** CONSTRUCTOR ********************/
    /*     constructor() VRFv2ConsumerBase(11139) {

    } */
    /******************** RECEIVE ********************/
    receive() external payable {}
    /******************** FALLBACK ********************/
    fallback() external payable {}
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

    /******************** FUNCTIONS ********************/
    function createContest(uint256 _enterPrice) public payable {
        /*************** RANK CREATION ***************/
        uint256 contestRank = increasingNumber;
        /*************** REVERT ***************/
        require(
            msg.value == Based.CONTEST_CREATION_PRICE,
            "Invalid contest creation price"
        );
        /*************** STRUCT ****************/
        uint256[] memory _contestant1DrawedNumbers;
        uint256[] memory _contestant2DrawedNumbers;
        twentyOneContests.push(
            TwentyOneContest(
                msg.sender,
                contestRank,
                _enterPrice,
                0,
                address(0),
                address(0),
                _contestant1DrawedNumbers,
                _contestant2DrawedNumbers,
                0,
                0,
                false,
                false,
                false,
                false,
                false
            )
        );
        /*************** MAPPING ***************/
        isContestExist[contestRank] = true;
        getContestIndexFromContestRank[contestRank] = increasingNumber;
        increasingNumber++;
        /*************** EVENT ***************/
        emit ContestCreated(contestRank);
        /*************** TRANSFER ***************/
        payable(Based.CONTRACT_OWNER).transfer(msg.value);
    }
    function enterContest(uint256 _rank) public payable {
        /*************** VARIABLES ****************/
        uint256 contestIndex = getContestIndexFromContestRank[_rank];
        /*************** REVERT ****************/
        require(isContestExist[_rank], "ContestIsntExist");
        require(!twentyOneContests[contestIndex].end, "Contest is end");
        require(
            msg.sender != twentyOneContests[contestIndex].contestant1Address,
            "InvalidContestant1Entrance"
        );
        require(
            msg.sender != twentyOneContests[contestIndex].contestant2Address,
            "InvalidContestant2Entrance"
        );
        // query is contestant in the contest or not first then full or not
        require(
            twentyOneContests[contestIndex].contestant1Address == address(0) ||
                twentyOneContests[contestIndex].contestant2Address ==
                address(0),
            "Contest is full"
        );
        // yarışmada 2 kişi dolmadan ilk kişinin üzerine biri gelmesin hatasını alttaki 2 satrıda çözemedim if else olur gibi
        require(
            msg.value == twentyOneContests[contestIndex].enterPrice,
            "Invalid contest entrance price"
        );
        /*************** STRUCT ****************/
        if (twentyOneContests[contestIndex].contestant1Address == address(0)) {
            twentyOneContests[contestIndex].contestant1Address = msg.sender;
            twentyOneContests[contestIndex].isContestant1Turn = true;
            twentyOneContests[contestIndex].isContestant2Turn = false;
            twentyOneContests[contestIndex].isContestant1Finished = false;
        } else {
            twentyOneContests[contestIndex].contestant2Address = msg.sender;
            twentyOneContests[contestIndex].isContestant1Turn = true;
            twentyOneContests[contestIndex].isContestant2Turn = false;
            twentyOneContests[contestIndex].isContestant2Finished = false;
        }
        twentyOneContests[contestIndex].collectedPrice += ((msg.value * 9) /
            10);
        /*************** MAPPING ***************/
        enteredContests[msg.sender].push(_rank);
        /*************** EVENT ***************/
        emit ContestantEntered(_rank, msg.sender);
        /*************** TRANSFER ***************/
        payable(twentyOneContests[contestIndex].creator).transfer(
            (msg.value * 1) / 10
        );
    }
    function drawCard(uint256 _rank) public {
        /*************** CALLING ****************/
        uint256 contestIndex = getContestIndexFromContestRank[_rank];
        /*************** VARIABLES ****************/
        /*************** REVERT ****************/
        require(isContestExist[_rank], "ContestIsntExist");
        require(!twentyOneContests[contestIndex].end, "ContestEnded");
        require(
            twentyOneContests[contestIndex].contestant1Address == msg.sender ||
                twentyOneContests[contestIndex].contestant2Address ==
                msg.sender,
            "InvalidContestantEntrance"
        );
        /*************** DRAWING ****************/
        uint256 _drawedNumber = /* uint256(
            keccak256(
                abi.encodePacked(
                    tx.origin,
                    blockhash(block.number - 1),
                    block.timestamp
                )
            )
        ) %  */ 10;
        /*************** STRUCT ****************/
        // if drawed number  == 1 önce gelicek sorguda 1 değilse hiç diğer sorgulara girmeden ekleme ve turn değiştirme yapıcak
        if (msg.sender == twentyOneContests[contestIndex].contestant1Address) {
            require(
                !twentyOneContests[contestIndex].isContestant1Finished,
                "Contestant1 finished drawing cards"
            );
            require(
                twentyOneContests[contestIndex].isContestant1Turn,
                "InvalidContestant1Turn"
            );
            require(
                (twentyOneContests[contestIndex]
                    .contestant1DrawedNumbers
                    .length - 1) != 1,
                "Contestant1DrawedAce"
            );
            if (_drawedNumber == 1) {
                twentyOneContests[contestIndex].isContestant1Turn = true;
                twentyOneContests[contestIndex].isContestant2Turn = false;
            } else {
                twentyOneContests[contestIndex].isContestant1Turn = false;
                twentyOneContests[contestIndex].isContestant2Turn = true;
            }
            twentyOneContests[contestIndex]
                .contestant1DrawedNumbersSum += _drawedNumber;
            twentyOneContests[contestIndex].contestant1DrawedNumbers.push(
                _drawedNumber
            );
        } else {
            require(
                !twentyOneContests[contestIndex].isContestant2Finished,
                "Contestant2 finished drawing cards"
            );
            require(
                twentyOneContests[contestIndex].isContestant2Turn,
                "InvalidContestant2Turn"
            );
            require(
                (twentyOneContests[contestIndex]
                    .contestant2DrawedNumbers
                    .length - 1) != 1,
                "Contestant2DrawedAce"
            );
            if (_drawedNumber == 1) {
                twentyOneContests[contestIndex].isContestant1Turn = false;
                twentyOneContests[contestIndex].isContestant2Turn = true;
            } else {
                twentyOneContests[contestIndex].isContestant1Turn = true;
                twentyOneContests[contestIndex].isContestant2Turn = false;
            }
            twentyOneContests[contestIndex]
                .contestant2DrawedNumbersSum += _drawedNumber;
            twentyOneContests[contestIndex].contestant2DrawedNumbers.push(
                _drawedNumber
            );
        }
        /*************** EVENT ***************/
        emit ContestantDrawedACard(_drawedNumber);
        /*************** TRANSFER ***************/
    }
    function determineAcesFate(uint256 _rank, uint256 acesFate) public {
        uint256 contestIndex = getContestIndexFromContestRank[_rank];
        require(isContestExist[_rank], "ContestIsntExist");
        require(!twentyOneContests[contestIndex].end, "ContestEnded");
        require(
            twentyOneContests[contestIndex].contestant1Address == msg.sender ||
                twentyOneContests[contestIndex].contestant2Address ==
                msg.sender,
            "InvalidContestantEntrance"
        );
        uint256 lastDrawedNumber;
        if (msg.sender == twentyOneContests[contestIndex].contestant1Address) {
            lastDrawedNumber =
                twentyOneContests[contestIndex]
                    .contestant1DrawedNumbers
                    .length -
                1;
            require(lastDrawedNumber == 1, "Contestant1DidntDrawAce");
            if (acesFate == 11)
                twentyOneContests[contestIndex].contestant1DrawedNumbers[
                    lastDrawedNumber
                ] = 11;
            twentyOneContests[contestIndex].isContestant1Turn = false;
            twentyOneContests[contestIndex].isContestant2Turn = true;
        } else {
            lastDrawedNumber =
                twentyOneContests[contestIndex]
                    .contestant2DrawedNumbers
                    .length -
                1;
            require(lastDrawedNumber == 1, "Contestant2DidntDrawAce");
            if (acesFate == 11)
                twentyOneContests[contestIndex].contestant2DrawedNumbers[
                    lastDrawedNumber
                ] = 11;
            twentyOneContests[contestIndex].isContestant1Turn = true;
            twentyOneContests[contestIndex].isContestant2Turn = false;
        }
        determineWinner(_rank);
    }
    function finishDrawing(uint256 _rank) public {
        /*************** CALLING ****************/
        uint256 contestIndex = getContestIndexFromContestRank[_rank];
        /*************** REVERT ****************/
        require(isContestExist[_rank], "ContestIsntExist");
        require(
            twentyOneContests[contestIndex].contestant1Address == msg.sender ||
                twentyOneContests[contestIndex].contestant2Address ==
                msg.sender,
            "InvalidContestantEntrance"
        );
        if (msg.sender == twentyOneContests[contestIndex].contestant1Address) {
            require(
                twentyOneContests[contestIndex]
                    .contestant1DrawedNumbers
                    .length -
                    1 !=
                    1,
                "Contestant draw ace and cant finish before deciding its fate"
            );
            require(
                !twentyOneContests[contestIndex].isContestant1Finished,
                "Contestant1 finished drawing cards"
            );
            require(
                twentyOneContests[contestIndex].isContestant1Turn,
                "InvalidContestant1Turn"
            );
        } else {
            require(
                twentyOneContests[contestIndex]
                    .contestant2DrawedNumbers
                    .length -
                    1 !=
                    1,
                "Contestant draw ace and cant finish before deciding its fate"
            );
            require(
                !twentyOneContests[contestIndex].isContestant2Finished,
                "Contestant2 finished drawing cards"
            );
            require(
                twentyOneContests[contestIndex].isContestant2Turn,
                "InvalidContestant2Turn"
            );
        }
        /*************** STRUCT ****************/
        if (msg.sender == twentyOneContests[contestIndex].contestant1Address)
            twentyOneContests[contestIndex].isContestant1Finished = true;
        else twentyOneContests[contestIndex].isContestant2Finished = true;
        /*************** MAPPING ****************/
        /*************** EVENT ****************/
        emit ContestantFinishedDrawingCardsEvent(msg.sender);
        /*************** TRANSFER ****************/
        determineWinner(_rank);
    }
    function determineWinner(uint256 _rank) public payable {
        /*************** CONTEST INDEX ***************/
        uint256 contestIndex = getContestIndexFromContestRank[_rank];
        /*************** REVERT ***************/
        require(isContestExist[_rank], "ContestIsntExist");
        /*************** VARIABLES ***************/
        address winner;
        /*************** QUERY WINNER ***************/
        if (
            twentyOneContests[contestIndex].isContestant1Turn &&
            twentyOneContests[contestIndex].contestant2DrawedNumbersSum > 21
        ) {
            winner = twentyOneContests[contestIndex].contestant1Address;
            twentyOneContests[contestIndex].end = true;
            payable(winner).transfer(
                twentyOneContests[contestIndex].collectedPrice
            );
        } else if (
            twentyOneContests[contestIndex].isContestant2Turn &&
            twentyOneContests[contestIndex].contestant1DrawedNumbersSum > 21
        ) {
            winner = twentyOneContests[contestIndex].contestant2Address;
            twentyOneContests[contestIndex].end = true;
            emit ContestWinnerDetermined(_rank, winner);
            payable(winner).transfer(
                twentyOneContests[contestIndex].collectedPrice
            );
        } else if (
            twentyOneContests[contestIndex].contestant1DrawedNumbersSum == 21 &&
            twentyOneContests[contestIndex].contestant2DrawedNumbersSum == 21
        ) {
            winner = twentyOneContests[contestIndex].creator;
            twentyOneContests[contestIndex].end = true;
            emit ContestWinnerDetermined(_rank, winner);
            payable(winner).transfer(
                twentyOneContests[contestIndex].collectedPrice
            );
        } else if (
            twentyOneContests[contestIndex].isContestant1Finished &&
            twentyOneContests[contestIndex].isContestant2Finished
        ) {
            if (
                twentyOneContests[contestIndex].contestant1DrawedNumbersSum >
                twentyOneContests[contestIndex].contestant2DrawedNumbersSum
            ) {
                winner = twentyOneContests[contestIndex].contestant1Address;
                twentyOneContests[contestIndex].end = true;
                emit ContestWinnerDetermined(_rank, winner);
                payable(winner).transfer(
                    twentyOneContests[contestIndex].collectedPrice
                );
            } else if (
                twentyOneContests[contestIndex].contestant2DrawedNumbersSum >
                twentyOneContests[contestIndex].contestant1DrawedNumbersSum
            ) {
                winner = twentyOneContests[contestIndex].contestant2Address;
                twentyOneContests[contestIndex].end = true;
                emit ContestWinnerDetermined(_rank, winner);
                payable(winner).transfer(
                    twentyOneContests[contestIndex].collectedPrice
                );
            }
        }
    }
}
