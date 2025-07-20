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

    function donate(uint256 _amount, string memory _message) external;

    // function delegateDonate(address _token, uint256 _amount, uint256 _user) external ;

    function withdraw(uint256 _amount) external;

    function setupConfig(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _target
    ) external;

    function info()
        external
        view
        returns (uint256, uint256, uint256, address, Status, uint256, uint256);
}
