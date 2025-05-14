//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    address manager;

    constructor() ERC20("VND", "VND") {}

    modifier onlyManager() {
        require(msg.sender == manager);
        _;
    }

    function setupManager(address _manager) external  {
        require(_manager != address(0), "Error: address(0)");
        manager = _manager;
    }

    function mintTo(address _to, uint256 _amount) external  {
        _mint(_to, _amount);
    }
}
