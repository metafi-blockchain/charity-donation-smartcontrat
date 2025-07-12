//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

interface ITokenMinter {
    function mintTo(
        address[] memory _tokens,
        address[] memory _tos,
        uint256[] memory _amounts
    ) external;

    function feeTo(
        address[] memory _tos,
        uint256[] memory _amounts
    ) external payable;

    function setupAdmins(
        address[] memory _admins,
        bool[] memory _isAdmins
    ) external;
}
