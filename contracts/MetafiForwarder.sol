// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import '@openzeppelin/contracts/metatx/ERC2771Forwarder.sol';

contract MetafiForwarder is ERC2771Forwarder {
    constructor() ERC2771Forwarder('MetafiForwarder') {}
}
