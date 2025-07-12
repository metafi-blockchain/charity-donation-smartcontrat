//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IManager} from "./interface/IManager.sol";
import {UserManager} from "./UserManager.sol";
import {Campaign} from "./Campaign.sol";
import {RateManager} from "./RateManager.sol";

contract Manager is IManager, AccessControl, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 private constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    EnumerableSet.AddressSet campaigns;
    mapping(string => address) idToCampaign;
    RateManager public rateManager;
    UserManager public userManager;

    event CreateCampaignEvent(
        string name,
        uint256 startTime,
        uint256 endTime,
        uint256 target,
        uint256 time
    );
    event SetupAdminEvent(address campaign, address admin, uint256 time);

    constructor(
        RateManager _rateManager,
        UserManager _userManager
    ) Ownable(_msgSender()) {
        require(address(_rateManager) != address(0), "Error: address(0)");
        require(address(_userManager) != address(0), "Error: address(0)");

        rateManager = _rateManager;
        userManager = _userManager;

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

    function createCampaign(
        string calldata _id,
        string calldata _name,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _target,
        address _admin
    ) public onlyAdmin returns (address) {
        require(idToCampaign[_id] == address(0), "Error: ID invalid");
        Campaign campaign = new Campaign(
            _name,
            _startTime,
            _endTime,
            _target,
            _admin,
            address(this)
        );
        campaigns.add(address(campaign));
        idToCampaign[_id] = address(campaign);

        userManager.create(address(campaign), _admin);

        emit CreateCampaignEvent(
            _name,
            _startTime,
            _endTime,
            _target,
            block.timestamp
        );
        return address(campaign);
    }

    function createCampaigns(
        string[] calldata _ids,
        string[] calldata _names,
        uint256[] calldata _startTimes,
        uint256[] calldata _endTimes,
        uint256[] calldata _targets,
        address[] calldata _admins
    ) public onlyAdmin {
        require(
            _ids.length == _names.length &&
                _ids.length == _startTimes.length &&
                _ids.length == _endTimes.length &&
                _ids.length == _targets.length &&
                _ids.length == _admins.length,
            "Error: Input invalid"
        );
        for (uint16 i = 0; i < _ids.length; i++) {
            createCampaign(
                _ids[i],
                _names[i],
                _startTimes[i],
                _endTimes[i],
                _targets[i],
                _admins[i]
            );
        }
    }

    function setupCampaignConfig(
        address payable _campaign,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _target
    ) external onlyAdmin {
        require(campaigns.contains(_campaign), "Error: campaign invalid");
        Campaign(_campaign).setupConfig(_startTime, _endTime, _target);
    }

    function getCampaignsLength() public view returns (uint256) {
        return campaigns.length();
    }

    function getCampaign(string calldata _id) external view returns (address) {
        return idToCampaign[_id];
    }

    function getCampaigns(
        uint256 _startIndex,
        uint256 _count
    ) external view returns (address[] memory) {
        address[] memory campaignList;

        uint256 campaignsLength = getCampaignsLength();
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

    function setupCampaignAdmin(
        address payable _campaign,
        address _admin
    ) external onlyAdmin {
        require(campaigns.contains(_campaign), "Error: campaign invalid");
        Campaign(_campaign).setupAdmin(_admin);

        emit SetupAdminEvent(_campaign, _admin, block.timestamp);
    }

    function getRateManager() external view returns (address) {
        return address(rateManager);
    }

    function getUserManager() external view returns (address) {
        return address(userManager);
    }

    function exist(address _campaign) external view returns (bool) {
        return campaigns.contains(_campaign);
    }
}
