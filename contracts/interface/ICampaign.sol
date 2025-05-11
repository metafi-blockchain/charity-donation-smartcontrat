//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICampaign {
    function donate(address _token, uint256 _amount) external;

    function withdraw(address _token, uint256 _amount) external;

    function getDonors(
        uint256 _startIndex,
        uint256 _count
    ) external returns (address[] memory, uint256[] memory);

    function getDonorsLength() external view returns (uint256);
}
