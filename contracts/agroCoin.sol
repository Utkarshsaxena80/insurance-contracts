
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.8;

import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";

contract AgroCoin is ERC20, Ownable {
    constructor(uint256 initialSupply) ERC20("AgroCoin", "$AGRO") {
        _mint(msg.sender, initialSupply);
    }

    function mint(address to, uint256 amount) public  {
        _mint(to, amount);
    }
}
