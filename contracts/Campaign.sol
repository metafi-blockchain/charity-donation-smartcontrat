//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ICampaign} from "./interface/ICampaign.sol";
import {IManager} from "./interface/IManager.sol";
import {IRateManager} from "./interface/IRateManager.sol";
import {IUserManager} from "./interface/IUserManager.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IRateManager} from "./interface/IRateManager.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Pausable} from "@openzeppelin/contracts/utils/Pausable.sol";

contract Campaign is ICampaign, ReentrancyGuard, Pausable {
    uint256 public startTime;
    uint256 public endTime;
    address public admin;
    uint256 public target;
    IManager public manager;

    IERC20 public token;
    uint256 public totalDonation;
    uint256 public countDonation;

    event DonationEvent(
        address user,
        uint256 amount,
        string message,
        uint256 time
    );

    event WithdrawEvent(address admin, uint256 amount, uint256 time);

    event SetupAdminEvent(address newAdmin, address oldAdmin);

    modifier onlyAdmin() {
        require(admin == msg.sender, "Error: must have admin role");
        _;
    }

    modifier onlyManager() {
        require(address(manager) == msg.sender, "Error: must be manager");
        _;
    }

    constructor(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _target,
        address _admin,
        IERC20 _token,
        address _manager
    ) {
        if (_endTime != 0) {
            require(_endTime > _startTime, "Error: time invalid");
        }
        require(_admin != address(0), "Error: address(0)");
        require(_manager != address(0), "Error: address(0)");
        require(address(_token) != address(0), "Error: address(0)");

        startTime = _startTime; // 0 => no start time
        endTime = _endTime; //  0 => no end time
        target = _target; // 0 => no target
        admin = _admin;
        token = _token;
        manager = IManager(_manager);
    }

    modifier validCampaign() {
        require(getStatus() == Status.ON_GOING, "Error: Status invalid");
        _;
    }

    function donate(
        uint256 _amount,
        string memory _message
    ) public nonReentrant whenNotPaused validCampaign {
        require(_amount > 0, "Error: Amount must be greater than zero");

        // Transfer tokens from sender to this contract

        IERC20(token).transferFrom(msg.sender, address(this), _amount);

        // Update campaign

        totalDonation += _amount;
        countDonation += 1;

        emit DonationEvent(msg.sender, _amount, _message, block.timestamp);
    }

    function setupAdmin(address _admin) external onlyManager {
        require(_admin != admin, "Error: same address");

        emit SetupAdminEvent(_admin, admin);
        admin = _admin;
    }

    function withdraw(uint256 _amount) external onlyAdmin {
        token.transfer(admin, _amount);

        emit WithdrawEvent(admin, _amount, block.timestamp);
    }

    function setupConfig(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _target
    ) external onlyManager {
        if (_endTime != 0) {
            require(_endTime > _startTime, "Error: time invalid");
        }

        startTime = _startTime; // 0 => no start time
        endTime = _endTime; //  0 => no end time
        target = _target; // 0 => no target
    }

    function getStatus() public view returns (Status) {
        if (startTime > block.timestamp) return Status.WAITING;
        if (endTime != 0 && endTime < block.timestamp) return Status.FINISHED;
        if (target > 0 && totalDonation >= target)
            return Status.COMPLETE_TARGET;
        if (paused()) return Status.PAUSED;
        return Status.ON_GOING;
    }

    function info()
        external
        view
        returns (uint256, uint256, uint256, address, Status, uint256, uint256)
    {
        return (
            startTime,
            endTime,
            target,
            admin,
            getStatus(),
            totalDonation,
            countDonation
        );
    }
}
