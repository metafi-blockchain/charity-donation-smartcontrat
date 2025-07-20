//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

interface IManager {
    function createCampaign(
        string calldata _id,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _target,
        address _admin,
        IERC20 _token
    ) external returns (address);

    function createCampaigns(
        string[] calldata _ids,
        uint256[] calldata _startTimes,
        uint256[] calldata _endTimes,
        uint256[] calldata _targets,
        address[] calldata _admins,
        IERC20[] calldata _tokens
    ) external;

    function setupCampaignAdmin(
        address payable _campaign,
        address _admin
    ) external;

    function setupCampaignConfig(
        address payable _campaign,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _target
    ) external;

    function getCampaign(string calldata _id) external view returns (address);

    function getRateManager() external returns (address);

    function getUserManager() external returns (address);

    function exist(address _campaign) external returns (bool);
}
