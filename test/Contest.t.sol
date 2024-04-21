// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {Contest} from "../src/Contest.sol";

contract ContestTest is Test {
    Contest public contest;

    function setUp() public {
        contest = new Contest();
    }
}
