// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Based} from "../Based/Based.sol";
/*import {VRFv2Consumer} from "../../Based/VRFv2Consumer.sol";*/

contract TwentyOne is Based /*, VRFv2Consumer*/ {
    Based public based;
    /*VRFv2Consumer public vrfv2Consumer;*/
    /******************** ERROR ********************/
    error ContestIsntExist(uint256 contestRank);
    error ContestAlreadyExist(uint256 contestRank);
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
    /******************** CONSTRUCTOR ********************/
    /*constructor() VRFv2Consumer(11139) {}*/
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
    /******************** RECEIVE ********************/
    receive() external payable {}
    /******************** FALLBACK ********************/
    fallback() external payable {}
    /******************** MODIFIERS ********************/
    modifier ifContestExist(uint256 contestRank) {
        require(isContestExist[contestRank], "Contest isnt exist");
        _;
    }
    modifier ifContestant(uint256 contestRank) {
        require(isContestExist[contestRank], "Contest isnt exist");
        uint256 contestIndex = getContestIndexFromContestRank[contestRank];
        require(
            twentyOneContests[contestIndex].contestant1Address == msg.sender ||
                twentyOneContests[contestIndex].contestant2Address ==
                msg.sender,
            "Invalid contestant entrance"
        );
        _;
    }
    modifier alreadyContestant(uint256 contestRank) {
        uint256 contestIndex = getContestIndexFromContestRank[contestRank];
        require(
            twentyOneContests[contestIndex].contestant1Address != msg.sender ||
                twentyOneContests[contestIndex].contestant2Address !=
                msg.sender,
            "Invalid contestant entrance"
        );
        _;
    }
    modifier ifItsNotFinished(uint256 contestRank) {
        uint256 contestIndex = getContestIndexFromContestRank[contestRank];
        address _contestant1Address = twentyOneContests[contestIndex]
            .contestant1Address;
        address _contestant2Address = twentyOneContests[contestIndex]
            .contestant2Address;
        bool _isContestant1Finished = twentyOneContests[contestIndex]
            .isContestant1Finished;
        bool _isContestant2Finished = twentyOneContests[contestIndex]
            .isContestant2Finished;
        require(
            msg.sender == _contestant1Address ||
                msg.sender == _contestant2Address,
            "Not a contestant"
        );
        if (msg.sender == _contestant1Address)
            require(
                !twentyOneContests[contestIndex].isContestant1Finished,
                "Contestant1 finished drawing cards"
            );
        else if (msg.sender == _contestant2Address)
            require(
                !twentyOneContests[contestIndex].isContestant2Finished,
                "Contestant2 finished drawing cards"
            );
        _;
    }
    modifier ifAceDraw(uint256 contestRank) {
        uint256 contestIndex = getContestIndexFromContestRank[contestRank];
        address _contestant1Address = twentyOneContests[contestIndex]
            .contestant1Address;
        address _contestant2Address = twentyOneContests[contestIndex]
            .contestant2Address;
        uint256 contestant1LastDrawedNumber = twentyOneContests[contestIndex]
            .contestant1DrawedNumbers
            .length - 1;
        uint256 contestant2LastDrawedNumber = twentyOneContests[contestIndex]
            .contestant2DrawedNumbers
            .length - 1;
        if (msg.sender == _contestant1Address) {
            require(
                twentyOneContests[contestIndex].contestant1DrawedNumbers[
                    contestant1LastDrawedNumber
                ] == 1,
                "Contestant1 didnt draw ace"
            );
        } else if (msg.sender == _contestant2Address) {
            require(
                twentyOneContests[contestIndex].contestant1DrawedNumbers[
                    contestant2LastDrawedNumber
                ] == 1,
                "Contestant2 didnt draw ace"
            );
        }
        _;
    }
    /******************** FUNCTIONS ********************/
    function createContest(uint256 _enterPrice) public payable {
        /*************** RANK CREATION ***************/
        uint256 contestRank = 12;
        /*************** REVERT ***************/
        // in order to query it needs to be created first so it would query, is it created before or not
        require(!isContestExist[contestRank], "Contest already exist");
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
        increasingNumber++;
        getContestIndexFromContestRank[contestRank] = increasingNumber;
        /*************** EVENT ***************/
        emit ContestCreated(contestRank);
        /*************** TRANSFER ***************/
        payable(Based.CONTRACT_OWNER).transfer(msg.value);
        /*************** RETURNS ***************/
    }
    function enterContest(
        uint256 _rank
    ) public payable ifContestExist(_rank) alreadyContestant(_rank) {
        /*************** VARIABLES ****************/
        uint256 contestIndex = getContestIndexFromContestRank[_rank] - 1;
        address _creator = twentyOneContests[contestIndex].creator;
        bool _end = twentyOneContests[contestIndex].end;
        address _contestant1Address = twentyOneContests[contestIndex]
            .contestant1Address;
        address _contestant2Address = twentyOneContests[contestIndex]
            .contestant2Address;
        uint256 contestEnterPrice = twentyOneContests[contestIndex].enterPrice;
        /*************** REVERT ****************/
        require(!_end, "Contest is end");
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
    function drawCard(uint256 _rank) public ifContestant(_rank) {
        /*************** CALLING ****************/
        uint256 contestIndex = getContestIndexFromContestRank[_rank] - 1;
        /*************** VARIABLES ****************/
        address _contestant1Address = twentyOneContests[contestIndex]
            .contestant1Address;
        address _contestant2Address = twentyOneContests[contestIndex]
            .contestant2Address;
        /*************** REVERT ****************/
        /*************** DRAWING ****************/
        uint256 _drawedNumber = 12 % 10;
        /*************** STRUCT ****************/
        // if drawed number  == 1 önce gelicek sorguda 1 değilse hiç diğer sorgulara girmeden ekleme ve turn değiştirme yapıcak
        require(
            msg.sender == _contestant1Address ||
                msg.sender == _contestant2Address,
            "a"
        );
        if (msg.sender == _contestant1Address) {
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
        } else if (msg.sender == _contestant2Address) {
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
        /*************** RETURN ***************/
    }
    function determineAcesFate(
        uint256 _rank,
        uint256 acesFate
    ) public ifAceDraw(_rank) {
        uint256 contestIndex = getContestIndexFromContestRank[_rank] - 1;
        address contestant1Address = twentyOneContests[contestIndex]
            .contestant1Address;
        uint256 lastDrawedNumber;
        if (msg.sender == contestant1Address) {
            lastDrawedNumber =
                twentyOneContests[contestIndex]
                    .contestant1DrawedNumbers
                    .length -
                1;
            if (acesFate == 11)
                twentyOneContests[contestIndex].contestant1DrawedNumbers[
                    lastDrawedNumber
                ] = 11;
            twentyOneContests[contestIndex].isContestant1Turn = false;
            twentyOneContests[contestIndex].isContestant2Turn = true;
        } else {
            if (acesFate == 11)
                twentyOneContests[contestIndex].contestant2DrawedNumbers[
                    lastDrawedNumber
                ] = 11;
            twentyOneContests[contestIndex].isContestant1Turn = true;
            twentyOneContests[contestIndex].isContestant2Turn = false;
        }
    }
    function finishDrawing(uint256 _rank) public ifContestant(_rank) {
        /*************** CALLING ****************/
        uint256 contestIndex = getContestIndexFromContestRank[_rank] - 1;
        /*************** REVERT ****************/
        require(
            twentyOneContests[contestIndex].contestant1Address == msg.sender ||
                twentyOneContests[contestIndex].contestant2Address ==
                msg.sender,
            "Invalid contestant entrance"
        );
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
