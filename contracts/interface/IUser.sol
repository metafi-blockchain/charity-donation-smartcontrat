//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUser {
    function getCampaigns(
        uint256 _startIndex,
        uint256 _count
    ) external view returns (uint256, uint256);

    function getCampaignsLength() external view returns (uint256);
}
