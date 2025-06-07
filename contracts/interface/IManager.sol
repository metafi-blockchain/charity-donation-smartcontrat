//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IManager {
    function createCampaign(
        string calldata _id,
        string calldata _name,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _target,
        address _admin
    ) external returns (address);

    function createCampaigns(
        string[] calldata _ids,
        string[] calldata _names,
        uint256[] calldata _startTimes,
        uint256[] calldata _endTimes,
        uint256[] calldata _targets,
        address[] calldata _admins
    ) external;

    function setupCampaignAdmin(
        address payable _campaign,
        address _admin
    ) external;

    function getCampaign(string calldata _id) external view returns (address);

    function getRateManager() external returns (address);

    function getUserManager() external returns (address);

    function exist(address _campaign) external returns (bool);
}
