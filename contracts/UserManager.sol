//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IUserStorage} from "./interface/IUserStorage.sol";
import {IUserManager} from "./interface/IUserManager.sol";
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

    function setupManager(IManager _manager) external onlyOwner {
        require(address(_manager) != address(0), "Error: address(0)");
        manager = _manager;
    }

    function donate(
        address _user,
        address _token,
        uint256 _amount,
        uint256 _amountConvert
    ) external onlyCampaign(_msgSender()) {
        userStorage.save(_msgSender(), _user, _token, _amount, _amountConvert);
        // TODO: raking, give NFT
    }

    function getCampaignsLength(address _user) public view returns (uint256) {
        return userStorage.getCampaignsLength(_user);
    }

    function getCampaigns(
        address _user,
        uint256 _startIndex,
        uint256 _count
    ) external view returns (address[] memory) {
        return userStorage.getCampaigns(_user, _startIndex, _count);
    }
}
