//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUserManager {
    function getCampaigns(
        address _user,
        uint256 _startIndex,
        uint256 _count
    ) external view returns (address[] memory);

    function getCampaignsLength(address _user) external view returns (uint256);

    function donate(
        address _user,
        // address _campaign,
        address _token,
        uint256 _amount,
        uint256 _amountConvert
    ) external;
}
