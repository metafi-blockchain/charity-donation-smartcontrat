//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {
    EnumerableSet
} from "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import {AccessControl} from "@openzeppelin/contracts/access/AccessControl.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IManager} from "./interface/IManager.sol";
import {Campaign} from "./Campaign.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract CampaingManager is IManager, AccessControl, Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");
    EnumerableSet.AddressSet campaigns;
    mapping(string => address) idToCampaign;

    // ERC-2771 support
    address public trustedForwarder;

    event CreateCampaignEvent(
        string id,
        uint256 startTime,
        uint256 endTime,
        uint256 target,
        uint256 time
    );
    event SetupAdminEvent(address campaign, address admin, uint256 time);
    event TrustedForwarderUpdated(
        address oldForwarder,
        address newForwarder,
        uint256 time
    );
    event CampaignStoppedByManager(address campaign, uint256 time);
    event CampaignResumedByManager(address campaign, uint256 time);

    constructor(address _trustedForwarder) Ownable(_msgSender()) {
        require(
            _trustedForwarder != address(0),
            "Error: trusted forwarder address(0)"
        );

        _grantRole(DEFAULT_ADMIN_ROLE, _msgSender());
        // _setRoleAdmin(ADMIN_ROLE,DEFAULT_ADMIN_ROLE);
        _grantRole(ADMIN_ROLE, _msgSender());

        trustedForwarder = _trustedForwarder;
    }

    modifier onlyAdmin() {
        require(
            hasRole(ADMIN_ROLE, _msgSender()),
            "Error: must have admin role"
        );
        _;
    }

    /**
     * @dev Create a new campaign with ERC-2771 support
     * @param _id Unique campaign identifier
     * @param _startTime Campaign start timestamp (0 = no start time)
     * @param _endTime Campaign end timestamp (0 = no end time)
     * @param _target Target donation amount (0 = no target)
     * @param _admin Campaign admin address
     * @param _token Token contract address (must support IERC20 and optionally IERC20Permit)
     * @return address The deployed campaign contract address
     */
    function createCampaign(
        string calldata _id,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _target,
        address _admin,
        address _token
    ) public onlyAdmin returns (address) {
        require(idToCampaign[_id] == address(0), "Error: ID invalid");
        require(_admin != address(0), "Error: admin address(0)");
        require(_token != address(0), "Error: token address(0)");

        Campaign campaign = new Campaign(
            _startTime,
            _endTime,
            _target,
            _admin,
            _token, // Token address
            address(this), // Manager address
            trustedForwarder // Use configurable trusted forwarder
        );

        campaigns.add(address(campaign));
        idToCampaign[_id] = address(campaign);

        emit CreateCampaignEvent(
            _id,
            _startTime,
            _endTime,
            _target,
            block.timestamp
        );
        return address(campaign);
    }

    /**
     * @dev Create multiple campaigns in batch
     */
    function createCampaigns(
        string[] calldata _ids,
        uint256[] calldata _startTimes,
        uint256[] calldata _endTimes,
        uint256[] calldata _targets,
        address[] calldata _admins,
        address[] calldata _tokens
    ) public onlyAdmin {
        require(
            _ids.length == _startTimes.length &&
                _ids.length == _endTimes.length &&
                _ids.length == _targets.length &&
                _ids.length == _admins.length &&
                _ids.length == _tokens.length,
            "Error: Input invalid"
        );
        for (uint16 i = 0; i < _ids.length; i++) {
            createCampaign(
                _ids[i],
                _startTimes[i],
                _endTimes[i],
                _targets[i],
                _admins[i],
                _tokens[i]
            );
        }
    }

    /**
     * @dev Update campaign configuration
     */
    function setupCampaignConfig(
        address payable _campaign,
        uint256 _startTime,
        uint256 _endTime,
        uint256 _target
    ) external onlyAdmin {
        require(campaigns.contains(_campaign), "Error: campaign invalid");
        Campaign(_campaign).setupConfig(_startTime, _endTime, _target);
    }

    /**
     * @dev Emergency stop a campaign
     */
    function pauseCampaign(address payable _campaign) external onlyAdmin {
        require(campaigns.contains(_campaign), "Error: campaign invalid");
        Campaign(_campaign).pause();
        emit CampaignStoppedByManager(_campaign, block.timestamp);
    }

    /**
     * @dev Resume a stopped campaign
     */
    function unpauseCampaign(address payable _campaign) external onlyAdmin {
        require(campaigns.contains(_campaign), "Error: campaign invalid");
        Campaign(_campaign).unpause();
        emit CampaignResumedByManager(_campaign, block.timestamp);
    }

    /**
     * @dev Update trusted forwarder for future campaigns
     * @param _newTrustedForwarder New trusted forwarder address
     */
    function updateTrustedForwarder(
        address _newTrustedForwarder
    ) external onlyAdmin {
        require(
            _newTrustedForwarder != address(0),
            "Error: trusted forwarder address(0)"
        );
        require(
            _newTrustedForwarder != trustedForwarder,
            "Error: same forwarder address"
        );

        address oldForwarder = trustedForwarder;
        trustedForwarder = _newTrustedForwarder;

        emit TrustedForwarderUpdated(
            oldForwarder,
            _newTrustedForwarder,
            block.timestamp
        );
    }

    /**
     * @dev Get trusted forwarder address
     */
    function getTrustedForwarder() external view returns (address) {
        return trustedForwarder;
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
        require(_admin != address(0), "Error: admin address(0)");
        Campaign(_campaign).setupAdmin(_admin);

        emit SetupAdminEvent(_campaign, _admin, block.timestamp);
    }

    function exist(address _campaign) external view returns (bool) {
        return campaigns.contains(_campaign);
    }

    function getCampaignInfo(
        address _campaign
    )
        external
        view
        returns (
            uint256 startTime,
            uint256 endTime,
            uint256 target,
            address admin,
            uint8 status, // Cast from enum to uint8
            uint256 totalDonation,
            uint256 countDonation,
            address campaignTrustedForwarder,
            bool supportsPermit,
            bool isPaused
        )
    {
        require(campaigns.contains(_campaign), "Error: campaign invalid");

        Campaign campaign = Campaign(_campaign);

        // Get basic campaign info
        (
            startTime,
            endTime,
            target,
            admin,
            ,
            totalDonation,
            countDonation
        ) = campaign.info();

        // Get ERC-2771 and additional info
        campaignTrustedForwarder = campaign.getTrustedForwarder();
        supportsPermit = campaign.supportsPermit();
        isPaused = campaign.isPaused();
        status = uint8(campaign.getStatus());
    }

    /**
     * @dev Check if campaigns support meta-transactions
     * @param _campaigns Array of campaign addresses
     * @return Array of booleans indicating meta-transaction support
     */
    function checkMetaTransactionSupport(
        address[] calldata _campaigns
    ) external view returns (bool[] memory) {
        bool[] memory supported = new bool[](_campaigns.length);

        for (uint256 i = 0; i < _campaigns.length; i++) {
            if (campaigns.contains(_campaigns[i])) {
                try Campaign(_campaigns[i]).getTrustedForwarder() returns (
                    address forwarder
                ) {
                    supported[i] = (forwarder != address(0));
                } catch {
                    supported[i] = false;
                }
            } else {
                supported[i] = false;
            }
        }

        return supported;
    }
}
