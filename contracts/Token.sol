//  SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract Token is ERC20 {
    constructor() ERC20("AIPAD", "AIPAD") {}

    function mint(uint256 _amount) public {
        _mint(msg.sender, _amount);
    }

    function mintTo(address _to, uint256 _amount) public {
        _mint(_to, _amount);
    }
}
