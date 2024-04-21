// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {ERC20} from "../Imports.sol";

contract LOT is ERC20 {
    ERC20 public erc20;

    mapping(address owner => uint256 balance) public s_balances;

    constructor() ERC20("LOT", "Lottery") {}
}
