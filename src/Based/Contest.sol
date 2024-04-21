// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {VRFv2Consumer} from "../Imports.sol";

contract Contest {
    uint256 public CONTEST_CREATION_PRICE = 1e9;
    address payable CONTRACT_OWNER =
        payable(0xcb2359487D53Db7a6886b1908293d34792901eE1);

    uint64 subscriptionId = 11139;
    constructor() {}
}
/*
    // is mapping
    mapping(string contestName => bool isExist) public isContestExist;
    mapping(address contestantAddress => mapping(string contestName => bool isIn))
        public isContestantInTheContest;

    // zero to index
    mapping(uint256 Zero => uint256 contestIndex)
        public getContestIndexFromZero;
    mapping(string contestName => uint256 contestIndexFromIncreasingNumber)
        public getContestIndexFromContestName;
    mapping(uint256 Zero => uint256 contestantIndex)
        public getContestantIndexFromZero;
    mapping(address contestantAddress => uint256 contestantIndexFromIncreasingNumber)
        public getContestantIndexFromContestantAddress;

    // get mapping contestant
    mapping(address contesantAddress => mapping(string contestName => uint256 ticketCount))

    function createContest(
        string memory _contestName,
        uint256 _maxContestant,
        uint256 _ticketPrice
    ) public payable {
        if (isContestExist[_contestName]) {
            revert ContestAlreadyExist(_contestName);
        }
        if (msg.value != CONTEST_CREATION_PRICE) {
            revert InvalidContestCreationPrice(
                msg.value,
                CONTEST_CREATION_PRICE
            );
        }

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
        payable(CONTRACT_OWNER).transfer(msg.value);
    }

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

        if (!isContestExist[_contestName])
            revert ContestIsntExist(_contestName);
        if (msg.value != contestTicketPrice * ticketAmount)
            revert InvalidTicketPrice(
                _contestName,
                msg.value,
                contestTicketPrice
            );
        if (
            contests[contestIndex].contestantsAddresses.length <
            contests[contestIndex].maxContestant
        ) revert ContestCompleted("Contest completed cannot be entered");

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

        if (
            contests[contestIndex].maxContestant ==
            contests[contestIndex].contestantsAddresses.length
        ) {
            selectLotteryWinner(_contestName);
        }

        payable(contests[contestIndex].owner).transfer(msg.value / 10);
    }

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

    // contest is
    function returnContestInfoByContestName(
        string memory _contestName
    ) public view returns (ContestStruct memory) {
        if (!isContestExist[_contestName]) {
            revert ContestIsntExist(_contestName);
        }
        uint256 contestIndex = getContestIndexFromContestName[_contestName] - 1;
        return contests[contestIndex];
    }

    // contest get
    function returnContestOwnerFromContestName(
        string memory _contestName
    ) public view returns (address) {
        if (!isContestExist[_contestName]) {
            revert ContestIsntExist(_contestName);
        }
        uint256 contestIndex = getContestIndexFromContestName[_contestName] - 1;
        return contests[contestIndex].owner;
    }

    function returnContestMaxContestantFromContestName(
        string memory _contestName
    ) public view returns (uint256) {
        if (!isContestExist[_contestName]) {
            revert ContestIsntExist(_contestName);
        }
        uint256 contestIndex = getContestIndexFromContestName[_contestName] - 1;
        return contests[contestIndex].maxContestant;
    }

    function returnContestTicketPriceFromContestName(
        string memory _contestName
    ) public view returns (uint256) {
        if (!isContestExist[_contestName]) {
            revert ContestIsntExist(_contestName);
        }
        uint256 contestIndex = getContestIndexFromContestName[_contestName] - 1;
        return contests[contestIndex].ticketPrice;
    }

    function returnContestTicketCountFromContestName(
        string memory _contestName
    ) public view returns (uint256) {
        if (!isContestExist[_contestName]) {
            revert ContestIsntExist(_contestName);
        }
        uint256 contestIndex = getContestIndexFromContestName[_contestName] - 1;
        return contests[contestIndex].ticketCount;
    }

    function returnContestContestantsAddressesFromContestName(
        string memory _contestName
    ) public view returns (address[] memory) {
        if (!isContestExist[_contestName]) {
            revert ContestIsntExist(_contestName);
        }
        uint256 contestIndex = getContestIndexFromContestName[_contestName] - 1;
        return contests[contestIndex].contestantsAddresses;
    }

    function returnContestCollectedPriceFromContestName(
        string memory _contestName
    ) public view returns (uint256) {
        if (!isContestExist[_contestName]) {
            revert ContestIsntExist(_contestName);
        }
        uint256 contestIndex = getContestIndexFromContestName[_contestName] - 1;
        return contests[contestIndex].collectedPrice;
    }

    function returnContestWinnerByContestName(
        string memory _contestName
    ) public view returns (address) {
        if (!isContestExist[_contestName]) {
            revert ContestIsntExist(_contestName);
        }
        uint256 contestIndex = getContestIndexFromContestName[_contestName] - 1;
        return contests[contestIndex].winner;
    }

    // contestant is
    function returnIsContestantInTheContest(
        address _contestantAddress,
        string memory _contestName
    ) public view returns (bool) {
        if (!isContestantInTheContest[msg.sender][_contestName]) {
            revert ContestantIsntInTheContest(_contestantAddress, _contestName);
        }
        return true;
    }

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
*/
