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
    struct Donation {
        address token;
        uint256 amount;
        uint256 amountConvert;
        uint256 time;
    }

    struct User {
        uint256 totalDonation;
        mapping(address => uint256) donationPerToken;
        Donation[] donations;
    }

    string public name;
    uint256 public startTime;
    uint256 public endTime;
    address public admin;
    uint256 public target;
    IManager public manager;

    uint256 public totalDonation;

    address[] public tokenList;
    address[] public userAddressList;

    mapping(address => uint256) balances; // token => amount
    mapping(address => uint256) withdraws; //token => amount
    mapping(address => User) users;

    event DonationEvent(
        address user,
        address token,
        uint256 amount,
        uint256 amountConvert,
        uint256 time
    );

    event WithdrawEvent(
        address admin,
        address token,
        uint256 amount,
        uint256 time
    );

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
        string memory _name,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _target,
        address _admin,
        address _manager
    ) {
        if (_endTime != 0) {
            require(_endTime > _startTime, "Error: time invalid");
        }
        require(_admin != address(0), "Error: address(0)");
        require(_manager != address(0), "Error: address(0)");

        name = _name;
        startTime = _startTime; // 0 => no start time
        endTime = _endTime; //  0 => no end time
        target = _target; // 0 => no target
        admin = _admin;
        manager = IManager(_manager);
    }

    modifier validCampaign() {
        // require(block.timestamp >= startTime, "Error: Campaign not start yet");
        // if (endTime != 0) {
        //     require(block.timestamp <= endTime, "Error: Campaign closed");
        // }
        require(getStatus() == Status.ON_GOING, "Error: Status invalid");
        _;
    }

    function donate(
        address _token,
        uint256 _amount
    ) public payable nonReentrant whenNotPaused validCampaign {
        if (msg.value != 0) {
            _token = address(0);
            _amount = msg.value;
        }
        require(_amount > 0, "Error: Amount must be greater than zero");

        address rateManager = manager.getRateManager();
        uint256 amountConvert = IRateManager(rateManager).convert(
            _token,
            _amount
        );

        require(amountConvert > 0, "Error: Token not support");

        // Transfer tokens from sender to this contract
        if (_token != address(0)) {
            IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        }

        // Update campaign
        if (balances[_token] == 0) tokenList.push(_token);
        if (users[msg.sender].totalDonation == 0)
            userAddressList.push(msg.sender);

        totalDonation += amountConvert;
        balances[_token] += _amount;
        users[msg.sender].totalDonation += amountConvert;
        users[msg.sender].donationPerToken[_token] += _amount;
        users[msg.sender].donations.push(
            Donation({
                token: _token,
                amount: _amount,
                amountConvert: amountConvert,
                time: block.timestamp
            })
        );

        // Update user manager
        address userManager = manager.getUserManager();
        IUserManager(userManager).donate(
            msg.sender,
            _token,
            _amount,
            amountConvert
        );

        emit DonationEvent(
            msg.sender,
            _token,
            _amount,
            amountConvert,
            block.timestamp
        );
    }

    receive() external payable {
        donate(address(0), msg.value);
    }

    function setupAdmin(address _admin) external onlyManager {
        require(_admin != admin, "Error: same address");

        emit SetupAdminEvent(_admin, admin);
        admin = _admin;
    }

    function withdraw(address _token, uint256 _amount) external onlyAdmin {
        require(
            balances[_token] - withdraws[_token] >= _amount,
            "Error: insufficient amount"
        );

        if (_token == address(0)) {
            (bool success, ) = payable(admin).call{value: _amount}("");
            require(success, "Error: Withdraw failed");
            // payable(admin).transfer(_amount);
        } else {
            IERC20(_token).transfer(admin, _amount);
        }

        withdraws[_token] += _amount;

        emit WithdrawEvent(admin, _token, _amount, block.timestamp);
    }

    function getUsers()
        public
        view
        returns (address[] memory, uint256[] memory)
    {
        uint256[] memory amountList;

        uint256 length = getUsersLength();

        amountList = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            amountList[i] = users[userAddressList[i]].totalDonation;
        }

        return (userAddressList, amountList);
    }

    function getUsersLength() public view returns (uint256) {
        return userAddressList.length;
    }

    function getDonationsLength(address _user) public view returns (uint256) {
        return users[_user].donations.length;
    }

    function getDonations(
        address _user
    )
        public
        view
        returns (
            address[] memory,
            uint256[] memory,
            uint256[] memory,
            uint256[] memory
        )
    {
        address[] memory tokens;
        uint256[] memory amounts;
        uint256[] memory amountConverts;
        uint256[] memory times;

        uint256 donationsLength = getDonationsLength(_user);

        tokens = new address[](donationsLength);
        amounts = new uint256[](donationsLength);
        amountConverts = new uint256[](donationsLength);
        times = new uint256[](donationsLength);

        for (uint256 i = 0; i < donationsLength; i++) {
            tokens[i] = users[_user].donations[i].token;
            amounts[i] = users[_user].donations[i].amount;
            amountConverts[i] = users[_user].donations[i].amountConvert;
            times[i] = users[_user].donations[i].time;
        }

        return (tokens, amounts, amountConverts, times);
    }

    function getBalances()
        external
        view
        returns (uint256, address[] memory, uint256[] memory, uint256[] memory)
    {
        uint256 length = tokenList.length;
        uint256[] memory balanceList = new uint256[](length);
        uint256[] memory withdrawList = new uint256[](length);

        for (uint256 i = 0; i < length; i++) {
            balanceList[i] = balances[tokenList[i]];
            withdrawList[i] = withdraws[tokenList[i]];
        }

        return (totalDonation, tokenList, balanceList, withdrawList);
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
        returns (string memory, uint256, uint256, uint256, address, Status)
    {
        return (name, startTime, endTime, target, admin, getStatus());
    }
}
