//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IRateManager} from "./interface/IRateManager.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract RateManager is IRateManager, AccessControl, Ownable {
    bytes32 private constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    mapping(address => uint256) rates;

    constructor() Ownable(_msgSender()) {
        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _grantRole(ADMIN_ROLE, _msgSender());
    }

    modifier onlyAdmin() {
        require(
            hasRole(ADMIN_ROLE, _msgSender()),
            "Error: must have admin role"
        );
        _;
    }

    function convert(
        address _token,
        uint256 _amount
    ) external view returns (uint256) {
        return rates[_token] * _amount;
    }

    function setupRate(address _token, uint256 _rate) external onlyAdmin {
        rates[_token] = _rate;
    }
}
