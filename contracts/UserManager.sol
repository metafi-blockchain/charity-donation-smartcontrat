//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IUserStorage} from "./interface/IUserStorage.sol";
import {IUserManager} from "./interface/IUserManager.sol";
import {ICampaign} from "./interface/ICampaign.sol";
import {IManager} from "./interface/IManager.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract UserManager is IUserManager, Ownable {
    IUserStorage userStorage;
    IManager manager;

    constructor(IUserStorage _userStorage) Ownable(_msgSender()) {
        require(address(_userStorage) != address(0), "Error: address(0)");

        userStorage = _userStorage;
    }

    modifier onlyCampaign(address _campaign) {
        require(manager.exist(_campaign));
        _;
    }

    modifier onlyManager() {
        require(_msgSender() == address(manager), "Error: must be manager");
        _;
    }

    function setupManager(IManager _manager) external onlyOwner {
        require(address(_manager) != address(0), "Error: address(0)");
        manager = _manager;
    }

    function setupStorage(IUserStorage _userStorage) external onlyOwner {
        require(address(_userStorage) != address(0), "Error: address(0)");
        userStorage = _userStorage;
    }

    function create(address _campaign, address _admin) external onlyManager {
        userStorage.save(_campaign, _admin);
    }

    function donate(
        address _user,
        uint256 _amount
    ) external onlyCampaign(_msgSender()) {
        userStorage.save(_msgSender(), _user, _amount);
        // TODO: raking, give NFT
    }

    function getUserInfo(
        address _user
    )
        external
        view
        returns (
            uint256,
            uint256,
            address[] memory,
            uint256[] memory,
            address[] memory,
            uint256[] memory,
            uint256
        )
    {
        (
            uint256 totalDonation,
            uint256 countDonation,
            address[] memory campaigns,
            uint256[] memory amountDonations,
            address[] memory ownCampaigns
        ) = userStorage.getItem(_user);

        uint256 totalAmountRaised = 0;
        uint256[] memory amountRaiseds = new uint256[](ownCampaigns.length);
        for (uint16 i = 0; i < ownCampaigns.length; i++) {
            (, , , , , , uint256 totalRaised, , ) = ICampaign(ownCampaigns[i])
                .info();
            totalAmountRaised += totalRaised;
            amountRaiseds[i] = totalRaised;
        }

        return (
            totalDonation,
            countDonation,
            campaigns,
            amountDonations,
            ownCampaigns,
            amountRaiseds,
            totalAmountRaised
        );
    }
}
