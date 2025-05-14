//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUserStorage {
    function save(
        address _campaign,
        address _user,
        address _token,
        uint256 _amount,
        uint256 _amountConvert
    ) external;

    function getCampaignsLength(address _user) external view returns (uint256);

    function getCampaigns(
        address _user,
        uint256 _startIndex,
        uint256 _count
    ) external view returns (address[] memory);
}
