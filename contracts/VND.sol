//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {IToken} from "./interface/IToken.sol";

contract VND is ERC20, Ownable, IToken {
    mapping(address => bool) minters;

    constructor() ERC20("VND", "VND") Ownable(_msgSender()) {
        minters[_msgSender()] = true;
    }

    modifier onlyMinter() {
        require(minters[_msgSender()]);
        _;
    }

    function setupMinter(address _minter, bool _isMinter) external onlyOwner {
        require(_minter != address(0), "Error: address(0)");
        minters[_minter] = _isMinter;
    }

    function mintTo(address _to, uint256 _amount) external onlyMinter {
        _mint(_to, _amount);
    }
}
