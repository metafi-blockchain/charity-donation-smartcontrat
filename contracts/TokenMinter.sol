//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {IToken} from "./interface/IToken.sol";
import {ITokenMinter} from "./interface/ITokenMinter.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract TokenMinter is Ownable, ITokenMinter {
    mapping(address => bool) admins;

    constructor() Ownable(_msgSender()) {
        admins[_msgSender()] = true;
    }

    modifier onlyAdmin() {
        require(admins[_msgSender()]);
        _;
    }

    function setupAdmin(address _admin, bool _isAdmin) external onlyOwner {
        require(_admin != address(0), "Error: address(0)");
        admins[_admin] = _isAdmin;
    }

    function mintTo(
        address[] memory _tokens,
        address[] memory _tos,
        uint256[] memory _amounts
    ) external onlyAdmin {
        require(
            _tos.length == _amounts.length && _tokens.length == _tos.length,
            "Error: input invalid"
        );

        for (uint16 i = 0; i < _tos.length; i++) {
            IToken(_tokens[i]).mintTo(_tos[i], _amounts[i]);
        }
    }

    function feeTo(
        address[] memory _tos,
        uint256[] memory _amounts
    ) external payable {
        require(_tos.length == _amounts.length, "Array length mismatch");

        uint256 totalSent = 0;

        for (uint256 i = 0; i < _tos.length; i++) {
            totalSent += _amounts[i];
            (bool success, ) = _tos[i].call{value: _amounts[i]}("");
            require(success, "Transfer failed");
        }

        require(totalSent <= msg.value, "Not enough AVAL sent");
    }
}
