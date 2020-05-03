pragma solidity ^0.6.6;
import "./../ownership/Ownable.sol";

contract Killable is Ownable {
  function kill() onlyOwner {
    selfdestruct(owner);
  }
}
