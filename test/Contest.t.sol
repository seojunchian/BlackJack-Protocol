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
        //uint256 contractOwnerBalance = contest.CONTRACT_OWNER.balance;
        uint256 value = 1e9;
        contest.createContest{value: value}("a", 1, 1e9);
        assertEq(contest.isContestExist("a"), true);
        assertEq(contest.getContestIndexFromZero(0), 1);
        assertEq(contest.getContestIndexFromContestName("a"), 1);
        //assertNotEq(contractOwnerBalance, contractOwnerBalance);
        contest.createContest{value: 1e9}("aa", 1, 1e9);
        assertEq(contest.isContestExist("aa"), true);
        assertEq(contest.getContestIndexFromZero(0), 2);
        assertEq(contest.getContestIndexFromContestName("aa"), 2);
    }
}
