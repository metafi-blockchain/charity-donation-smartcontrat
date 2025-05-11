//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IManager {
    function createCampaign(
        string memory _name,
        // address _creator,
        uint256 _startTime,
        uint256 _endTime
    ) external;

    function setupCampaignAdmin(address _campaign, address _admin) external;
}
