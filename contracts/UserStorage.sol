//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IUserManager} from "./interface/IUserManager.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract UserStorage is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    IUserManager userManager;

    mapping(address => EnumerableSet.AddressSet) userCampaigns; // user => campaigns
    mapping(address => uint256) userTotalDonations; // user => total donated
    mapping(address => mapping(address => uint256)) userDonations; // user => token => amount

    constructor() Ownable(_msgSender()) {}

    modifier onlyUserManager() {
        require(_msgSender() == address(userManager), "Error: must be manager");
        _;
    }

    function setupUserManager(IUserManager _userManager) external onlyOwner {
        require(address(_userManager) != address(0), "Error: address(0)");
        userManager = _userManager;
    }

    function save(
        address _campaign,
        address _user,
        address _token,
        uint256 _amount,
        uint256 _amountConvert
    ) external onlyUserManager {
        userCampaigns[_user].add(_campaign);
        userTotalDonations[_user] += _amountConvert;
        userDonations[_user][_token] += _amount;
    }

    function getCampaignsLength(address _user) public view returns (uint256){
        return userCampaigns[_user].length();
    }

    function getCampaigns(
        address _user,
        uint256 _startIndex,
        uint256 _count
    ) external view returns (address[] memory){
        address[] memory campaignList;

        uint256 campaignsLength = getCampaignsLength(_user);
        
        if (campaignsLength > 0 && _startIndex < campaignsLength) {
            if (campaignsLength - _startIndex < _count)
                _count = campaignsLength - _startIndex;
            campaignList = new address[](_count);

            for (uint256 i = 0; i < _count; i++) {
                campaignList[i] = userCampaigns[_user].at(_startIndex + i);
            }
        }
        return (campaignList);
    }
}
