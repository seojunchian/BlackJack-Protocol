// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import "./VRFv2Consumer.sol";

// update struct

//      github - git -> create a new repo and put these file in with terminal
//      testing
// <--> let contest_creation_price attach to eth current price with 1/100 may be
//      find bugs and fix it
//      learn how to hack it
//      catch events

/**
    @title Lottery Contract
    @notice When a contest's number of contestants is full its automatically will draw the number and select the winner and send amount of money won.
    @notice A Contestant can buy more than one ticket.
 */

contract Contest {
    // unchecked
    // will attach to eth price for a specific percentage
    uint256 public CONTEST_CREATION_PRICE = 1e9;
    // checked
    address payable CONTRACT_OWNER =
        payable(0xcb2359487D53Db7a6886b1908293d34792901eE1);

    // checked
    event ContestCreated(
        address owner,
        string name,
        uint256 maxContestant,
        uint256 ticketPrice
    );
    // checked
    event TicketPurchased(
        string contestName,
        address contestantAddress,
        uint256 ticketAmount
    );
    // checked
    event ContestWinner(string contestName, address winner);

    // checked
    error ContestAlreadyExist(string contestName);
    // checked
    error ContestIsntExist(string contestName);
    // checked
    error InvalidContestCreationPrice(
        uint256 receivedPrice,
        uint256 creationPrice
    );
    // checked
    error InvalidTicketPrice(
        string contestName,
        uint256 receivedPrice,
        uint256 ticketPrice
    );
    // checked
    error ContestantIsntInTheContest(
        address contestantAddress,
        string contestName
    );
    // checked
    error ContestCompleted(string message);

    // checked
    // assert level true
    uint64 subscriptionId = 11139;
    /* VRFv2Consumer(subscriptionId)*/ constructor() {}

    // checked
    // all the struct elements will be updated in the right place
    struct ContestStruct {
        address owner;
        string name;
        uint256 maxContestant;
        uint256 ticketPrice;
        uint256 ticketCount;
        address[] contestantsAddresses;
        uint256 collectedPrice;
        address winner;
    }
    ContestStruct[] public contests;

    // checked
    // all the struct elements will be updated in the right place
    struct ContestantStruct {
        string name;
        address contestantAddress;
    }
    ContestantStruct[] public contestants;

    // checked
    // is mapping
    mapping(string contestName => bool isExist) public isContestExist;
    mapping(address contestantAddress => mapping(string contestName => bool isIn))
        public isContestantInTheContest;

    // checked
    // zero to index
    mapping(uint256 Zero => uint256 contestIndex)
        public getContestIndexFromZero;
    mapping(string contestName => uint256 contestIndexFromIncreasingNumber)
        public getContestIndexFromContestName;
    mapping(uint256 Zero => uint256 contestantIndex)
        public getContestantIndexFromZero;
    mapping(address contestantAddress => uint256 contestantIndexFromIncreasingNumber)
        public getContestantIndexFromContestantAddress;

    // checked
    // get mapping contestant
    mapping(address contesantAddress => mapping(string contestName => uint256 ticketCount))
        public getContestantsTicketsCount;

    /**
        @notice Create contest .
        @param _contestName Name of the contest. 
        @param _maxContestant Maximum contestant you want in the contest. When its reach full its gonna execute lottery function by itself.
        @param _ticketPrice Price of buying a ticket in this contest. Can buy more than one.
        @dev Contests query by their names so only 1 contest could be in the same name. Can't create 2 contest with the same name.
        @dev Contest creation price is 1/1000 ether price.
     */
    function createContest(
        string memory _contestName,
        uint256 _maxContestant,
        uint256 _ticketPrice
    ) public payable returns (bool) {
        if (isContestExist[_contestName])
            revert ContestAlreadyExist(_contestName);
        if (msg.value != CONTEST_CREATION_PRICE)
            revert InvalidContestCreationPrice(
                msg.value,
                CONTEST_CREATION_PRICE
            );

        address[] memory _contestantsAddresses;
        contests.push(
            ContestStruct(
                msg.sender,
                _contestName,
                _maxContestant,
                _ticketPrice,
                0,
                _contestantsAddresses,
                0,
                msg.sender
            )
        );

        //
        isContestExist[_contestName] = true;

        //
        getContestIndexFromZero[0]++;
        getContestIndexFromContestName[_contestName] = getContestIndexFromZero[
            0
        ];
        emit ContestCreated(
            msg.sender,
            _contestName,
            _maxContestant,
            _ticketPrice
        );
        payable(CONTRACT_OWNER).transfer(msg.value);
        return true;
    }

    /**
        @notice Purchase tickets from a contest as many as you want.
        @param _contestName Ticket to be purchased from the contest.
        @param _contestantName Contestant name to add to contestants.
        @dev Require contest name to query is contest exist.
        @dev msg.value should be same amount of ticket price of the contest * number of tickets to purchase.
     */
    function purchaseTicket(
        string memory _contestName,
        string memory _contestantName,
        uint256 ticketAmount
    ) public payable {
        uint256 contestIndex = getContestIndexFromContestName[_contestName] - 1;
        uint256 contestantIndex = getContestantIndexFromContestantAddress[
            msg.sender
        ];
        uint256 contestTicketPrice = contests[contestIndex].ticketPrice;

        /*if (!isContestExist[_contestName])
            revert ContestIsntExist(_contestName);*/
        require(isContestExist[_contestName], "Contest isnt exist");
        /*if (msg.value != contestTicketPrice * ticketAmount)
            revert InvalidTicketPrice(
                _contestName,
                msg.value,
                contestTicketPrice
            );*/
        require(
            msg.value == contestTicketPrice * ticketAmount,
            "Invalid ticket price"
        );
        /*if (
            contests[contestIndex].contestantsAddresses.length <
            contests[contestIndex].maxContestant
        ) revert ContestCompleted("Contest completed cannot be entered");*/
        require(
            contests[contestIndex].contestantsAddresses.length <
                contests[contestIndex].maxContestant,
            "Contest completed cannot be entered"
        );

        contestants.push(ContestantStruct(_contestantName, msg.sender));

        // contests
        contests[contestIndex].ticketCount += ticketAmount;
        contests[contestIndex].contestantsAddresses.push(msg.sender);
        contests[contestIndex].collectedPrice += (msg.value * 9) / 10;

        // contestant
        contestants[contestantIndex].name = _contestantName;
        contestants[contestantIndex].contestantAddress = msg.sender;

        // mapping
        getContestantIndexFromZero[0]++;
        getContestantIndexFromContestantAddress[
            msg.sender
        ] = getContestantIndexFromZero[0];
        getContestantsTicketsCount[msg.sender][_contestName] += ticketAmount;

        emit TicketPurchased(_contestName, msg.sender, ticketAmount);

        if (
            contests[contestIndex].maxContestant ==
            contests[contestIndex].contestantsAddresses.length
        ) selectLotteryWinner(_contestName);

        payable(contests[contestIndex].owner).transfer(msg.value / 10);
    }

    /**
        @notice It runs automatically.
        @param _contestName Name of the contest to draw the winner of it.
        @dev Require contest name to query is contest exist.
        @dev msg.value should be same amount of ticket price of the contest * number of tickets to purchase.
     */
    function selectLotteryWinner(
        string memory _contestName
    ) private returns (address winnerAddress) {
        uint256 contestIndex = getContestIndexFromContestName[_contestName] - 1;
        address[] memory _contestantsAddresses = contests[contestIndex]
            .contestantsAddresses;

        uint256 _ticketCount = contests[contestIndex].ticketCount;
        uint256 randomNumber = uint256(keccak256(abi.encode(block.timestamp)));
        uint256 winnerTicketNumber = randomNumber % _ticketCount;

        for (uint256 i = 0; i < _contestantsAddresses.length; i++) {
            if (
                winnerTicketNumber <=
                getContestantsTicketsCount[_contestantsAddresses[i]][
                    _contestName
                ]
            ) {
                winnerAddress = _contestantsAddresses[i];
                contests[contestIndex].winner = winnerAddress;
                emit ContestWinner(_contestName, winnerAddress);
                payable(winnerAddress).transfer(
                    contests[contestIndex].collectedPrice
                );
                return winnerAddress;
            } else {
                // was decreasing from _ticketCount which I did wrong ticketCount is not beening use in for loop
                // therefore it shouldt be the one upgrading instead the correct one is winnerAddress
                // _ticketCount         -> was the wrong one
                // winnerTicketNumber   -> fixed to this
                winnerTicketNumber -= getContestantsTicketsCount[
                    _contestantsAddresses[i]
                ][_contestName];
            }
        }
    }

    // checked
    // contest is
    function returnContestInfoByContestName(
        string memory _contestName
    ) public view returns (ContestStruct memory) {
        if (!isContestExist[_contestName])
            revert ContestIsntExist(_contestName);
        uint256 contestIndex = getContestIndexFromContestName[_contestName] - 1;
        return contests[contestIndex];
    }

    // checked
    // contest get
    function returnContestOwnerFromContestName(
        string memory _contestName
    ) public view returns (address) {
        if (!isContestExist[_contestName])
            revert ContestIsntExist(_contestName);
        uint256 contestIndex = getContestIndexFromContestName[_contestName] - 1;
        return contests[contestIndex].owner;
    }

    function returnContestMaxContestantFromContestName(
        string memory _contestName
    ) public view returns (uint256) {
        if (!isContestExist[_contestName])
            revert ContestIsntExist(_contestName);
        uint256 contestIndex = getContestIndexFromContestName[_contestName] - 1;
        return contests[contestIndex].maxContestant;
    }

    function returnContestTicketPriceFromContestName(
        string memory _contestName
    ) public view returns (uint256) {
        if (!isContestExist[_contestName])
            revert ContestIsntExist(_contestName);
        uint256 contestIndex = getContestIndexFromContestName[_contestName] - 1;
        return contests[contestIndex].ticketPrice;
    }

    function returnContestTicketCountFromContestName(
        string memory _contestName
    ) public view returns (uint256) {
        if (!isContestExist[_contestName])
            revert ContestIsntExist(_contestName);
        uint256 contestIndex = getContestIndexFromContestName[_contestName] - 1;
        return contests[contestIndex].ticketCount;
    }

    function returnContestContestantsAddressesFromContestName(
        string memory _contestName
    ) public view returns (address[] memory) {
        if (!isContestExist[_contestName])
            revert ContestIsntExist(_contestName);
        uint256 contestIndex = getContestIndexFromContestName[_contestName] - 1;
        return contests[contestIndex].contestantsAddresses;
    }

    function returnContestCollectedPriceFromContestName(
        string memory _contestName
    ) public view returns (uint256) {
        if (!isContestExist[_contestName])
            revert ContestIsntExist(_contestName);
        uint256 contestIndex = getContestIndexFromContestName[_contestName] - 1;
        return contests[contestIndex].collectedPrice;
    }

    function returnContestWinnerByContestName(
        string memory _contestName
    ) public view returns (address) {
        if (!isContestExist[_contestName])
            revert ContestIsntExist(_contestName);
        uint256 contestIndex = getContestIndexFromContestName[_contestName] - 1;
        return contests[contestIndex].winner;
    }

    // checked
    // contestant is
    function returnIsContestantInTheContest(
        address _contestantAddress,
        string memory _contestName
    ) public view returns (bool) {
        if (!isContestantInTheContest[msg.sender][_contestName])
            revert ContestantIsntInTheContest(_contestantAddress, _contestName);
        return true;
    }

    // checked
    // contestant get
    function returnContestantInfoFromContestantAddress(
        address contestantAddress
    ) public view returns (ContestantStruct memory) {
        uint256 contestantsIndex = getContestantIndexFromContestantAddress[
            contestantAddress
        ];
        return contestants[contestantsIndex];
    }

    function returnContestantNameFromContestantAddress(
        address contestantAddress
    ) public view returns (string memory) {
        uint256 contestantIndex = getContestantIndexFromContestantAddress[
            contestantAddress
        ];
        return contestants[contestantIndex].name;
    }
}
