// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {ERC2771Context} from "@openzeppelin/contracts/metatx/ERC2771Context.sol";
import {ERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import {Context} from "@openzeppelin/contracts/utils/Context.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {IERC20Metadata} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Metadata.sol";
import {IERC20Permit} from "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";

/**
 * @title VND Token
 * @dev Complete ERC20 token with:
 * - ERC20Permit: Gasless approvals via signatures (EIP-2612)
 * - ERC2771Context: Meta-transactions via trusted forwarder
 * - Minter role system: Controlled token minting
 * - Owner management: Administrative functions
 *
 * Features:
 * - Gasless transactions for any function
 * - Gasless approvals via permit
 * - Role-based minting permissions
 * - Batch minting for efficiency
 * - Full OpenZeppelin v5 compatibility
 */
contract VND is ERC20, ERC20Permit, ERC2771Context, Ownable {
    // ============ STATE VARIABLES ============

    /// @dev Mapping to track addresses with minting permissions
    mapping(address => bool) public minters;

    // ============ EVENTS ============

    /// @dev Emitted when minter permissions are updated
    event MinterUpdated(address indexed minter, bool isMinter);

    // ============ CONSTRUCTOR ============

    /**
     * @dev Constructor
     * @param name Token name
     * @param symbol Token symbol
     * @param trustedForwarder Address of the trusted forwarder for meta-transactions
     * @param initialOwner Address of the initial contract owner
     */
    constructor(
        string memory name,
        string memory symbol,
        address trustedForwarder,
        address initialOwner
    )
        ERC20(name, symbol)
        ERC20Permit(name)
        ERC2771Context(trustedForwarder)
        Ownable(initialOwner)
    {
        // Set the initial owner as a minter
        minters[initialOwner] = true;
        emit MinterUpdated(initialOwner, true);
    }

    // ============ MODIFIERS ============

    /**
     * @dev Modifier to restrict function access to minters only
     */
    modifier onlyMinter() {
        require(minters[_msgSender()], "VND: caller is not a minter");
        _;
    }

    // ============ CONTEXT OVERRIDES ============

    /**
     * @dev Override _msgSender to use ERC2771Context
     * This ensures meta-transactions work properly by returning the original sender
     * instead of the trusted forwarder address
     */
    function _msgSender()
        internal
        view
        virtual
        override(Context, ERC2771Context)
        returns (address)
    {
        return ERC2771Context._msgSender();
    }

    /**
     * @dev Override _msgData to use ERC2771Context
     * This ensures meta-transactions work properly by handling calldata correctly
     */
    function _msgData()
        internal
        view
        virtual
        override(Context, ERC2771Context)
        returns (bytes calldata)
    {
        return ERC2771Context._msgData();
    }

    /**
     * @dev Override _contextSuffixLength to use ERC2771Context
     * This ensures meta-transactions work properly by handling context suffix
     */
    function _contextSuffixLength()
        internal
        view
        virtual
        override(Context, ERC2771Context)
        returns (uint256)
    {
        return ERC2771Context._contextSuffixLength();
    }

    /**
     * @dev Override nonces to resolve conflict between ERC20Permit
     * Uses ERC20Permit's nonce implementation for permit functionality
     */
    function nonces(
        address owner
    ) public view virtual override(ERC20Permit) returns (uint256) {
        return ERC20Permit.nonces(owner);
    }

    // ============ MINTER MANAGEMENT ============

    /**
     * @dev Set up minter permissions (owner only)
     * @param _minter Address to grant/revoke minting permissions
     * @param _isMinter True to grant minting permission, false to revoke
     */
    function setupMinter(address _minter, bool _isMinter) external onlyOwner {
        require(_minter != address(0), "VND: minter cannot be zero address");

        minters[_minter] = _isMinter;
        emit MinterUpdated(_minter, _isMinter);
    }

    /**
     * @dev Check if an address has minting permissions
     * @param _address Address to check
     * @return bool True if address is a minter
     */
    function isMinter(address _address) external view returns (bool) {
        return minters[_address];
    }

    // ============ MINTING FUNCTIONS ============

    /**
     * @dev Mint tokens to specified address (minter only)
     * @param _to Address to receive the minted tokens
     * @param _amount Amount of tokens to mint (in wei)
     */
    function mintTo(address _to, uint256 _amount) external {
        require(_to != address(0), "VND: mint to zero address");
        require(_amount > 0, "VND: mint amount must be greater than 0");

        _mint(_to, _amount);
    }

    /**
     * @dev Batch mint tokens to multiple addresses (minter only)
     * More gas efficient than multiple individual mints
     * @param _recipients Array of addresses to receive tokens
     * @param _amounts Array of amounts to mint (must match recipients length)
     */
    function batchMintTo(
        address[] calldata _recipients,
        uint256[] calldata _amounts
    ) external onlyMinter {
        require(
            _recipients.length == _amounts.length,
            "VND: arrays length mismatch"
        );
        require(_recipients.length > 0, "VND: empty arrays");

        for (uint256 i = 0; i < _recipients.length; i++) {
            require(_recipients[i] != address(0), "VND: mint to zero address");
            require(_amounts[i] > 0, "VND: mint amount must be greater than 0");

            _mint(_recipients[i], _amounts[i]);
        }
    }

    // ============ VIEW FUNCTIONS ============

    /**
     * @dev Get comprehensive token information in a single call
     * Useful for frontend applications to get all token details at once
     */
    function getTokenInfo()
        external
        view
        returns (
            string memory tokenName,
            string memory tokenSymbol,
            uint8 tokenDecimals,
            uint256 tokenTotalSupply,
            address tokenOwner,
            address tokenTrustedForwarder
        )
    {
        return (
            name(),
            symbol(),
            decimals(),
            totalSupply(),
            owner(),
            trustedForwarder()
        );
    }

    /**
     * @dev Get minter status for multiple addresses in a single call
     * @param _addresses Array of addresses to check
     * @return Array of boolean values indicating minter status
     */
    function areMinters(
        address[] calldata _addresses
    ) external view returns (bool[] memory) {
        bool[] memory results = new bool[](_addresses.length);

        for (uint256 i = 0; i < _addresses.length; i++) {
            results[i] = minters[_addresses[i]];
        }

        return results;
    }

    /**
     * @dev Emergency function to recover any ERC20 tokens sent to this contract by mistake
     * Cannot recover VND tokens (prevents owner from stealing user funds)
     * @param tokenAddress Address of the token to recover
     * @param to Address to send recovered tokens to
     * @param amount Amount of tokens to recover
     */
    function emergencyRecoverToken(
        address tokenAddress,
        address to,
        uint256 amount
    ) external onlyOwner {
        require(
            tokenAddress != address(this),
            "VND: cannot recover VND tokens"
        );
        require(to != address(0), "VND: recovery address cannot be zero");
        require(
            tokenAddress != address(0),
            "VND: token address cannot be zero"
        );

        IERC20(tokenAddress).transfer(to, amount);
    }
}
