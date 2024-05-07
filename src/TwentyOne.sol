// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Based} from "./Based.sol";
import {VRFv2Consumer} from "./VRFv2Consumer.sol";

// openzeppelin math
// openzeppelin ownable (maybe)

/* PROBLEMS */
// cant see drawed numbers for both sides
// when 2 contestants there is give 2 errors contest is full and alredy joined

import {Based} from "./Based.sol";

contract TwentyOne is Based {
    Based public based;
    /******************** ERROR ********************/
    error ContestIsntExist(uint256 contestRank);
    error ContestIsFull(uint256 contestRank);
    error ContestIsEnd(uint256 contestRank);
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
    /******************** STRUCT ********************/
    struct TwentyOneContest {
        address creator;
        uint256 rank;
        uint256 enterPrice;
        uint256 collectedPrice;
        address contestant1Address;
        address contestant2Address;
        uint256[] contestant1DrawedNumbers;
        uint256[] contestant2DrawedNumbers;
        bool isContestant1Turn;
        bool isContestant2Turn;
        bool isContestant1Finished;
        bool isContestant2Finished;
        bool end;
    }
    TwentyOneContest[] public twentyOneContests;
    struct TwentyOneContestant {
        address contestant;
        uint256[] drawedNumbers;
        bool isTurn;
        bool isFinished;
    }
    /******************** CONSTRUCTOR ********************/
    constructor() /*VRFv2ConsumerBase(11139) */ {

    }
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
        uint256 contestRank = uint256(
            keccak256(
                abi.encodePacked(
                    tx.origin,
                    blockhash(block.number - 1),
                    block.timestamp
                )
            )
        );
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
        address _creator = twentyOneContests[contestIndex].creator;
        bool _end = twentyOneContests[contestIndex].end;
        address _contestant1Address = twentyOneContests[contestIndex]
            .contestant1Address;
        address _contestant2Address = twentyOneContests[contestIndex]
            .contestant2Address;
        uint256 contestEnterPrice = twentyOneContests[contestIndex].enterPrice;
        /*************** REVERT ****************/
        require(isContestExist[_rank], "ContestIsntExist");
        require(!_end, "Contest is end");
        require(
            msg.sender != _contestant1Address,
            "InvalidContestant1Entrance"
        );
        require(
            msg.sender != _contestant2Address,
            "InvalidContestant2Entrance"
        );
        // query is contestant in the contest or not first then full or not
        require(
            _contestant1Address == address(0) ||
                _contestant2Address == address(0),
            "Contest is full"
        );
        // yarışmada 2 kişi dolmadan ilk kişinin üzerine biri gelmesin hatasını alttaki 2 satrıda çözemedim if else olur gibi
        require(
            msg.value == contestEnterPrice,
            "Invalid contest entrance price"
        );
        /*************** STRUCT ****************/
        if (_contestant1Address == address(0)) {
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
        payable(_creator).transfer((msg.value * 1) / 10);
    }
    function drawCard(uint256 _rank) public {
        /*************** CALLING ****************/
        uint256 contestIndex = getContestIndexFromContestRank[_rank];
        /*************** VARIABLES ****************/
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
                !twentyOneContests[contestIndex].isContestant1Finished,
                "Contestant1 finished drawing cards"
            );
            require(
                twentyOneContests[contestIndex].isContestant1Turn,
                "InvalidContestant1Turn"
            );
        } else if (
            msg.sender == twentyOneContests[contestIndex].contestant2Address
        ) {
            require(
                !twentyOneContests[contestIndex].isContestant2Finished,
                "Contestant2 finished drawing cards"
            );
            require(
                twentyOneContests[contestIndex].isContestant2Turn,
                "InvalidContestant2Turn"
            );
        }
        /*************** DRAWING ****************/
        uint256 _drawedNumber = uint256(
            keccak256(
                abi.encodePacked(
                    tx.origin,
                    blockhash(block.number - 1),
                    block.timestamp
                )
            )
        ) % 10;
        /*************** STRUCT ****************/
        // if drawed number  == 1 önce gelicek sorguda 1 değilse hiç diğer sorgulara girmeden ekleme ve turn değiştirme yapıcak
        if (msg.sender == twentyOneContests[contestIndex].contestant1Address) {
            if (_drawedNumber == 1) {
                twentyOneContests[contestIndex].isContestant1Turn = true;
                twentyOneContests[contestIndex].isContestant2Turn = false;
            } else {
                twentyOneContests[contestIndex].isContestant1Turn = false;
                twentyOneContests[contestIndex].isContestant2Turn = true;
            }
            twentyOneContests[contestIndex].contestant1DrawedNumbers.push(
                _drawedNumber
            );
        } else if (
            msg.sender == twentyOneContests[contestIndex].contestant2Address
        ) {
            if (_drawedNumber == 1) {
                twentyOneContests[contestIndex].isContestant1Turn = false;
                twentyOneContests[contestIndex].isContestant2Turn = true;
            } else {
                twentyOneContests[contestIndex].isContestant1Turn = true;
                twentyOneContests[contestIndex].isContestant2Turn = false;
            }
            twentyOneContests[contestIndex].contestant2DrawedNumbers.push(
                _drawedNumber
            );
        }
        /*************** MAPPING ***************/
        /*************** EVENT ***************/
        emit ContestantDrawedACard(_drawedNumber);
        /*************** TRANSFER ***************/
    }
    function determineAcesFate(uint256 _rank, uint256 acesFate) public {
        uint256 contestIndex = getContestIndexFromContestRank[_rank];
        require(isContestExist[_rank], "ContestIsntExist");
        address _contestant1Address = twentyOneContests[contestIndex]
            .contestant1Address;
        uint256 lastDrawedNumber;
        if (msg.sender == _contestant1Address) {
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
        /*************** RETURNS ****************/
    }
}
