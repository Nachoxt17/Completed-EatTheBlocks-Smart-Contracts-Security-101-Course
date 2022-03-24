// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { ETBToken } from "./EtbToken.sol";

contract EtbDex {
  address public owner;
  ETBToken private _etbToken;
  uint256 public fee;

  constructor(address _token) {
    owner = msg.sender;
    _etbToken = ETBToken(_token);
  }

  modifier onlyOwner() {
    require(msg.sender == owner, "Restricted Access");
    _;
  }

  function buyTokens() external payable {
    require(msg.value > 0, "Should send ETH to buy tokens");
    require(_etbToken.balanceOf(owner) - msg.value >= 0, "Not enough tokens to sell");
    _etbToken.transferFrom(owner, msg.sender, msg.value - calculateFee(msg.value));
  }

  function sellTokens(uint256 _amount) external {
    require(_etbToken.balanceOf(msg.sender) - _amount >= 0, "Not enough tokens");

    payable(msg.sender).send(_amount);

    _etbToken.burn(msg.sender, _amount);
    _etbToken.mint(_amount);
  }

  function setFee(uint256 _fee) external onlyOwner() {
    fee = _fee;
  }

  function calculateFee(uint256 _amount) internal view returns (uint256) {
    return (_amount * fee) / 100;
  }

  function withdrawFees() external onlyOwner() {
    payable(owner).send(address(this).balance);
  }
}
