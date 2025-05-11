//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {ICampaign} from "./interface/ICampaign.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ICurrencyConvert} from "./interface/ICurrencyConvert.sol";
import {EnumerableSet} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Campaign is ICampaign {
    using EnumerableSet for EnumerableSet.AddressSet;

    string public name;
    uint256 public startTime;
    uint256 public endTime;
    address public admin;
    address public manager;

    EnumerableSet.AddressSet donors;
    ICurrencyConvert currencyConvert;

    struct Donation {
        address token;
        uint256 amount;
        uint256 amountConvert;
        uint256 time;
    }

    mapping(address => uint256) balances; // token => total donated
    mapping(address => uint256) withdraws;
    mapping(address => uint256) userTotalDonations; // user => total donated
    mapping(address => mapping(address => uint256)) userDonations; // user => token => amount
    mapping(address => Donation[]) userDonationsDetail; // user => donation

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
        require(manager == msg.sender, "Error: must be manager");
        _;
    }

    constructor(
        string memory _name,
        uint256 _startTime,
        uint256 _endTime,
        address _admin,
        address _manager,
        ICurrencyConvert _currencyConvert
    ) {
        if (_endTime != 0) {
            require(_endTime > _startTime, "Error: time invalid");
        }
        require(_admin != address(0), "Error: address(0)");
        require(_manager != address(0), "Error: address(0)");
        require(address(_currencyConvert) != address(0), "Error: address(0)");

        name = _name;
        startTime = _startTime;
        endTime = _endTime; //  0 => no end time
        admin = _admin;
        manager = _manager;
        currencyConvert = _currencyConvert;
    }

    modifier validCampaign() {
        require(block.timestamp >= startTime, "Error: Campaign not start yet");
        if (endTime != 0) {
            require(block.timestamp <= endTime, "Error: Campaign closed");
        }
        _;
    }

    function donate(
        address _token,
        uint256 _amount
    ) external payable validCampaign {
        if (msg.value != 0) {
            _token = address(0);
            _amount = msg.value;
        }
        require(_amount > 0, "Error: Amount must be greater than zero");
        uint256 amountConvert = currencyConvert.convert(_token, _amount);
        require(amountConvert > 0, "Error: Token not support");

        // Transfer tokens from sender to this contract
        if (_token != address(0)) {
            IERC20(_token).transferFrom(msg.sender, address(this), _amount);
        }

        // Update campaign
        balances[_token] += _amount;
        donors.add(msg.sender);
        userTotalDonations[msg.sender] += amountConvert;
        userDonations[msg.sender][_token] += _amount;
        userDonationsDetail[msg.sender].push(
            Donation({
                token: _token,
                amount: _amount,
                amountConvert: amountConvert,
                time: block.timestamp
            })
        );

        emit DonationEvent(
            msg.sender,
            _token,
            _amount,
            amountConvert,
            block.timestamp
        );
    }

    function setupAdmin(address _admin) external onlyManager {
        require(_admin != address(0), "Error: address(0)");
        require(_admin != admin, "Error: same address");

        emit SetupAdminEvent(_admin, admin);
        admin = _admin;
    }

    function withdraw(address _token, uint256 _amount) external onlyAdmin {
        require(
            balances[_token] - withdraws[_token] >= _amount,
            "Error: insufficient amount"
        );

        IERC20(_token).transferFrom(address(this), admin, _amount);

        emit WithdrawEvent(admin, _token, _amount, block.timestamp);
    }

    function getDonors(
        uint256 _startIndex,
        uint256 _count
    ) public returns (address[] memory, uint256[] memory) {
        address[] memory donorList;
        uint256[] memory amountList;

        uint256 donorsLength = donors.length();
        if (donorsLength > 0 && _startIndex < donorsLength) {
            if (donorsLength - _startIndex < _count)
                _count = donorsLength - _startIndex;
            donorList = new address[](_count);
            amountList = new uint256[](_count);

            for (uint256 i = 0; i < _count; i++) {
                address donor = donors.at(_startIndex + i);
                donorList[i] = donor;
                amountList[i] = userTotalDonations[donor];
            }
        }
        return (donorList, amountList);
    }

    function getDonorsLength() public view returns (uint256) {
        return donors.length();
    }
}
