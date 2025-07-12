//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUserManager {
    function donate(address _user, uint256 _amount) external;

    function getUserInfo(
        address _user
    )
        external
        view
        returns (
            uint256,
            uint256,
            address[] memory,
            uint256[] memory,
            address[] memory, // Own campaigns
            uint256[] memory, // Amount raised for  a own campaign
            uint256 // total raised for all campaigns
        );
}
