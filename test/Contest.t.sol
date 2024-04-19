// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.22;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {Contest} from "../src/Contest.sol";

contract ContestTest is Test {
    Contest public contest;

    function setUp() public {
        contest = new Contest();
    }

    function testCreateContest() public {
        bool successContestCreation = contest.createContest{value: 1e9}(
            "a",
            1,
            1e9
        );
        assertEq(successContestCreation, true);
        assertEq(
            contest.getContestIndexFromContestName("a"),
            contest.getContestIndexFromZero(0)
        );
    }
}
