// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {VRFv2Consumer} from "../../Based/VRFv2Consumer.sol";

contract TwentyOne is VRFv2Consumer {
    constructor() VRFv2Consumer(11139)
}
