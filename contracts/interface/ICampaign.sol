//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICampaign {
    function donate(address _token, uint256 _amount) external payable;

    function withdraw(address _token, uint256 _amount) external;

    function getUsers() external returns (address[] memory, uint256[] memory);

    // function getUsersLength() external view returns (uint256);
}
