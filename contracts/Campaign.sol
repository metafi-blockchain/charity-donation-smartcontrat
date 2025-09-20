//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ICampaign} from "./interface/ICampaign.sol";
import {IManager} from "./interface/IManager.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import {ERC2771Context} from "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {Address} from "@openzeppelin/contracts/utils/Address.sol";

contract Campaign is ICampaign, ReentrancyGuard, ERC2771Context {
    using Address for address;

    uint256 public startTime;
    uint256 public endTime;
    address public admin;
    uint256 public target;
    IManager public manager;

    IERC20 public token; // For standard ERC20 functions
    IERC20Permit public tokenPermit; // For permit functions
    uint256 public totalDonation;
    uint256 public countDonation;

    bool public isPaused;

    event DonationEvent(
        address user,
        uint256 amount,
        string message,
        uint256 time
    );

    event WithdrawEvent(address admin, uint256 amount, uint256 time);

    event SetupAdminEvent(address newAdmin, address oldAdmin);

    modifier onlyAdmin() {
        require(admin == _msgSender(), "Error: must have admin role"); // Use _msgSender() for ERC-2771
        _;
    }

    modifier onlyManager() {
        require(address(manager) == _msgSender(), "Error: must be manager"); // Use _msgSender() for ERC-2771
        _;
    }

    constructor(
        uint256 _startTime,
        uint256 _endTime,
        uint256 _target,
        address _admin,
        address _token,
        address _manager,
        address _trustedForwarder
    ) ERC2771Context(_trustedForwarder) {
        // Initialize ERC2771Context
        if (_endTime != 0) {
            require(_endTime > _startTime, "Error: time invalid");
        }
        require(_admin != address(0), "Error: address(0)");
        require(_manager != address(0), "Error: address(0)");
        require(_token != address(0), "Error: address(0)");
        require(
            _trustedForwarder != address(0),
            "Error: trusted forwarder address(0)"
        );

        startTime = _startTime; // 0 => no start time
        endTime = _endTime; //  0 => no end time
        target = _target; // 0 => no target
        admin = _admin;
        token = IERC20(_token);
        tokenPermit = IERC20Permit(_token); // Both point to same contract
        manager = IManager(_manager);
    }

    modifier validCampaign() {
        require(getStatus() == Status.ON_GOING, "Error: Status invalid");
        _;
    }

    function multicall(
        bytes[] calldata data
    ) external returns (bytes[] memory results) {
        results = new bytes[](data.length);
        for (uint256 i = 0; i < data.length; i++) {
            results[i] = address(this).functionDelegateCall(data[i]);
        }
    }

    /**
     * @dev Standard donation function that requires prior token approval
     * @param _amount Amount of tokens to donate
     * @param _message Donation message
     */
    function donate(
        uint256 _amount,
        string memory _message
    ) public nonReentrant validCampaign {
        require(_amount > 0, "Error: Amount must be greater than zero");

        address donor = _msgSender();

        // Transfer tokens from real sender to this contract
        token.transferFrom(donor, address(this), _amount);

        // Update campaign
        totalDonation += _amount;
        countDonation += 1;

        emit DonationEvent(donor, _amount, _message, block.timestamp);
    }

    /**
     * @dev Donation function with EIP-2612 permit support (gasless approval)
     * @param _amount Amount of tokens to donate
     * @param _message Donation message
     * @param deadline Permit deadline
     * @param v Permit signature parameter
     * @param r Permit signature parameter
     * @param s Permit signature parameter
     */
    function donateWithPermit(
        uint256 _amount,
        string memory _message,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public nonReentrant validCampaign {
        require(_amount > 0, "Error: Amount must be greater than zero");

        address donor = _msgSender(); // Get real sender

        // Execute permit to approve this contract to spend donor's tokens
        tokenPermit.permit(
            donor, // owner
            address(this), // spender (this campaign contract)
            _amount, // value
            deadline, // deadline
            v,
            r,
            s // signature
        );

        // Transfer tokens from donor to this contract
        IERC20(token).transferFrom(donor, address(this), _amount);

        // Update campaign
        totalDonation += _amount;
        countDonation += 1;

        emit DonationEvent(donor, _amount, _message, block.timestamp);
    }

    /**
     * @dev Batch donation with multiple permits (for advanced use cases)
     * @param amounts Array of donation amounts
     * @param messages Array of donation messages
     * @param deadline Permit deadline (same for all)
     * @param v Array of permit signature v parameters
     * @param r Array of permit signature r parameters
     * @param s Array of permit signature s parameters
     */
    function batchDonateWithPermit(
        uint256[] memory amounts,
        string[] memory messages,
        uint256 deadline,
        uint8[] memory v,
        bytes32[] memory r,
        bytes32[] memory s
    ) public nonReentrant validCampaign {
        require(
            amounts.length == messages.length,
            "Error: Array length mismatch"
        );
        require(
            amounts.length == v.length &&
                v.length == r.length &&
                r.length == s.length,
            "Error: Signature array length mismatch"
        );

        address donor = _msgSender();
        uint256 totalAmount = 0;

        // Calculate total amount
        for (uint256 i = 0; i < amounts.length; i++) {
            require(amounts[i] > 0, "Error: Amount must be greater than zero");
            totalAmount += amounts[i];
        }

        // Execute permit for total amount
        tokenPermit.permit(
            donor,
            address(this),
            totalAmount,
            deadline,
            v[0],
            r[0],
            s[0]
        );

        // Process each donation
        for (uint256 i = 0; i < amounts.length; i++) {
            IERC20(token).transferFrom(donor, address(this), amounts[i]);

            totalDonation += amounts[i];
            countDonation += 1;

            emit DonationEvent(donor, amounts[i], messages[i], block.timestamp);
        }
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
        if (isPaused) return Status.PAUSED;
        if (startTime > block.timestamp) return Status.WAITING;
        if (endTime != 0 && endTime < block.timestamp) return Status.FINISHED;
        if (target > 0 && totalDonation >= target)
            return Status.COMPLETE_TARGET;

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

    /**
     * @dev Check if the token supports EIP-2612 permit
     * @return bool True if token supports permit
     */
    function supportsPermit() external view returns (bool) {
        try tokenPermit.DOMAIN_SEPARATOR() returns (bytes32) {
            return true;
        } catch {
            return false;
        }
    }

    /**
     * @dev Get the trusted forwarder address
     * @return address The trusted forwarder address
     */
    function getTrustedForwarder() external view returns (address) {
        return trustedForwarder();
    }

    // Required overrides for ERC2771Context
    function _msgSender()
        internal
        view
        override(ERC2771Context)
        returns (address sender)
    {
        return ERC2771Context._msgSender();
    }

    function _msgData()
        internal
        view
        virtual
        override(ERC2771Context)
        returns (bytes calldata)
    {
        return ERC2771Context._msgData();
    }

    /**
     * @dev Emergency pause function (only manager)
     */
    function pause() external onlyManager {
        isPaused = true;
    }

    /**
     * @dev Emergency unpause function (only manager)
     */
    function unpause() external onlyManager {
        isPaused = false;
    }
}
