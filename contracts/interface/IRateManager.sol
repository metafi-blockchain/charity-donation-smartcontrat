//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IRateManager {
    function convert(
        address _token,
        uint256 _amount
    ) external returns (uint256);
}
