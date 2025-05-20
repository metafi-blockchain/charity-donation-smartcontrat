//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IManager {
    function createCampaign(
        uint256 _id,
        string calldata _name,
        uint256 _startTime,
        uint256 _endTime,
        address _admin
    ) external returns (address);

    function setupCampaignAdmin(address payable _campaign, address _admin) external;

    function getRateManager() external returns (address);

    function getUserManager() external returns (address);

    function exist(address _campaign) external returns (bool);
}
