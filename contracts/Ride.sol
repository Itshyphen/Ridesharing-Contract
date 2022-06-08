//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Capped.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

interface IRide {
  /**
   * @dev Interface required to be implemented by the Rideshare contract, that uses this token.
   */
  function RideTokensOf(address)
    external
    view
    returns (uint256);

}

contract Ride is ERC20, Ownable {
 IRide public consumerContract;
 uint256 cap = 1000000000 * 10**18;

  constructor (IRide _contract)
    ERC20("RideSharing", "RIDE")
    Ownable()
  {
    require(address(consumerContract) == address(0x0)); // allow initialization only once.
    consumerContract = _contract;
  }


  function mint(address account) public payable {
    require(msg.value>0,"Provide eth to get RIDE Tokens");

    uint256 amount = msg.value*223100;
    _mint(account, amount);
  }

  function _mint(address account, uint256 amount) internal virtual override {
    require(super.totalSupply() + amount <= cap, "cap exceeded");
    super._mint(account, amount);
  }

 
}


