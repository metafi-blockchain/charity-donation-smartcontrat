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

    function setupStorage(IUserStorage _userStorage) external onlyOwner {
        require(address(_userStorage) != address(0), "Error: address(0)");
        userStorage = _userStorage;
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
        returns (uint256, uint256, address[] memory, uint256[] memory)
    {
        return userStorage.getItem(_user);
    }
}
