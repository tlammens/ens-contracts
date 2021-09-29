pragma solidity >=0.8.4;
pragma experimental ABIEncoderV2;

import "hardhat/console.sol";

interface ENS {
  function resolver(bytes32 node) external view returns(address);
}

contract UniversalResolver {
  ENS ens;
  
  constructor(ENS _ens) {
    ens = _ens;
  }
  
  function multicall(bytes[] calldata inputs) external returns (bytes[] memory ret) {
    ret = new bytes[](inputs.length);
    for(uint256 i = 0; i < inputs.length; i++) {
      (, bytes memory result) = _resolve(inputs[i]);
      ret[i] = result;
    }
    return ret;
  }
  
  fallback (bytes calldata input) external returns (bytes memory _output) {
    (bool success, bytes memory result) = _resolve(input);
    if(success) {
      return result;
    } else {
      assembly {
        revert(add(result, 32), mload(result))
      }
    }
  }
  
  function _resolve(bytes memory input) internal returns (bool, bytes memory) {
    require(input.length >= 36, "Input too short");
    bytes32 node;
    console.log("_resolve input");
    console.logBytes(input);
    assembly {
      node := mload(add(input, 36))
    }
    console.log("_resolve node");
    console.logBytes32(node);
    address resolver = ens.resolver(node);
    console.log("_resolve resolver");
    console.logAddress(resolver);
    return resolver.call(input);
  }
}
