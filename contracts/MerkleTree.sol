pragma solidity ^0.8.9;

library MerkleTree {

    function hashLeafPairs(bytes32 left, bytes32 right) internal pure returns (bytes32 _hash) {
       assembly {
           switch lt(left, right)
           case 0 {
               mstore(0x0, right)
               mstore(0x20, left)
           }
           default {
               mstore(0x0, left)
               mstore(0x20, right)
           }
           _hash := keccak256(0x0, 0x40)
       }
    }

    function getRoot(bytes32[] memory data) public pure returns (bytes32) {
        require(data.length > 1, "won't generate root for single leaf");
        while(data.length > 1) {
            data = hashLevel(data);
        }
        return data[0];
    }

     ///@dev function is private to prevent unsafe data from being passed
    function hashLevel(bytes32[] memory data) private pure returns (bytes32[] memory) {
        bytes32[] memory result;

        // Function is private, and all internal callers check that data.length >=2.
        // Underflow is not possible as lowest possible value for data/result index is 1
        // overflow should be safe as length is / 2 always. 
        unchecked {
            uint256 length = data.length;
            if (length & 0x1 == 1){
                result = new bytes32[](length / 2 + 1);
                result[result.length - 1] = hashLeafPairs(data[length - 1], bytes32(0));
            } else {
                result = new bytes32[](length / 2);
        }
        // pos is upper bounded by data.length / 2, so safe even if array is at max size
            uint256 pos = 0;
            for (uint256 i = 0; i < length-1; i+=2){
                result[pos] = hashLeafPairs(data[i], data[i+1]);
                ++pos;
            }
        }
        return result;
    }

}
