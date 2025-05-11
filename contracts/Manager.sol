//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IManager} from "./interface/IManager.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
// import {User} from "./User.sol";
import {Campaign} from "./Campaign.sol";
import {CurrencyConvert} from "./CurrencyConvert.sol";

contract Manager is IManager, AccessControl, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 private constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    EnumerableSet.AddressSet campaigns;

    CurrencyConvert public currencyConvert;

    constructor(CurrencyConvert _currencyConvert) Ownable(_msgSender()) {
        currencyConvert = new CurrencyConvert();

        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(ADMIN_ROLE, _msgSender());
    }

    modifier onlyAdmin() {
        require(
            hasRole(ADMIN_ROLE, _msgSender()),
            "Error: must have admin role"
        );
        _;
    }

    function createCampaign(
        string calldata _name,
        uint256 _startTime,
        uint256 _endTime,
        address _admin
    ) external onlyAdmin {
        Campaign campaign = new Campaign(
            _name,
            _startTime,
            _endTime,
            _admin,
            address(this),
            currencyConvert
        );
        campaigns.add(address(campaign));
    }

    function getCampaignsLengh() public returns (uint256) {
        return campaigns.length();
    }

    function getCampaigns(
        uint256 _startIndex,
        uint256 _count
    ) external returns (address[] memory) {
        address[] memory campaignList;

        uint256 campaignsLength = getCampaignsLengh();
        if (campaignsLength > 0 && _startIndex < campaignsLength) {
            if (campaignsLength - _startIndex < _count)
                _count = campaignsLength - _startIndex;
            campaignList = new address[](_count);

            for (uint256 i = 0; i < _count; i++) {
                campaignList[i] = campaigns.at(_startIndex + i);
            }
        }
        return (campaignList);
    }
}
