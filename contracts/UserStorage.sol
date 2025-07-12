//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IUserManager} from "./interface/IUserManager.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";

contract UserStorage is Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    IUserManager userManager;

    struct StorageItem {
        // EnumerableSet.AddressSet campaigns;
        address[] campaigns;
        address[] ownCampaigns;
        mapping(address => uint256) amountDonation; // campaign => amount
        mapping(address => uint256) amountTotal; // campaign => total amount
        uint256 totalDonation;
        uint256 countDonation;
    }

    mapping(address => StorageItem) storageItems;

    // mapping(address => EnumerableSet.AddressSet) userCampaigns; // user => campaigns
    // mapping(address => uint256) userTotalDonations; // user => total donated
    // mapping(address => mapping(address => uint256)) userDonations; // user => token => amount

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
        uint256 _amountConvert
    ) external onlyUserManager {
        if (storageItems[_user].amountDonation[_campaign] == 0) {
            storageItems[_user].campaigns.push(_campaign);
        }

        storageItems[_user].amountDonation[_campaign] += _amountConvert;
        storageItems[_user].totalDonation += _amountConvert;
        storageItems[_user].countDonation += 1;
    }

    function save(address _campaign, address _admin) external onlyUserManager {
        storageItems[_admin].ownCampaigns.push(_campaign);
    }

    function getItem(
        address _user
    )
        external
        view
        returns (
            uint256,
            uint256,
            address[] memory,
            uint256[] memory,
            address[] memory
        )
    {
        StorageItem storage item = storageItems[_user];
        uint256 length = item.campaigns.length;

        uint256[] memory amountDonations = new uint256[](length);
        for (uint256 i = 0; i < length; i++) {
            amountDonations[i] = item.amountDonation[item.campaigns[i]];
        }

        return (
            item.totalDonation,
            item.countDonation,
            item.campaigns,
            amountDonations,
            item.ownCampaigns
        );
    }
}
