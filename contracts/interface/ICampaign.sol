//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICampaign {
    enum Status {
        WAITING,
        ON_GOING,
        COMPLETE_TARGET,
        FINISHED,
        PAUSED
    }

    function getStatus() external view returns (Status);

    function donate(address _token, uint256 _amount) external payable;

    // function delegateDonate(address _token, uint256 _amount, uint256 _user) external ;

    function withdraw(address _token, uint256 _amount) external;

    function setupConfig(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _target
    ) external;

    function getUsers() external returns (address[] memory, uint256[] memory);

    function getBalances()
        external
        view
        returns (
            uint256,
            uint256,
            address[] memory,
            uint256[] memory,
            uint256[] memory
        );

    function info()
        external
        view
        returns (
            string memory,
            uint256,
            uint256,
            uint256,
            address,
            Status,
            uint256,
            uint256,
            uint256
        );
}
