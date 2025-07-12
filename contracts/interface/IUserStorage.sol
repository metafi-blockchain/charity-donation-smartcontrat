//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IUserStorage {
    function save(address _campaign, address _user, uint256 _amount) external;

    function save(address _campaign, address _admin) external;

    function getItem(
        address _user
    )
        external
        view
        returns (
            uint256,
            uint256,
            address[] memory,
            uint256[] memory,
            address[] memory
        );
}
