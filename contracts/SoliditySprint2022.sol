// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import "@openzeppelin/contracts/interfaces/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/cryptography/MerkleProof.sol";
import "./Clones.sol";
import "./Cryptography.sol";
import "./MerkleTree.sol";
import "./Create2Contract.sol";

interface ISupportsInterface {
    function supportsInterface(bytes4 interfaceId) external view returns(bool); 
}

contract SoliditySprint2022 is Ownable {

    bool public live;
    bool public timeExtended = false;

    mapping(address => uint) public scores;
    mapping(address => mapping(uint => bool)) public progress;

    mapping(address => uint) public entryCount;
    mapping(address => bool) public signers;
    mapping(uint => uint) public solves;
    mapping(bytes32 => bool) public usedLeaves;

    mapping(address => uint) public totallyLegitMapping;

    Create2Contract public template;
    uint salt = 0;

    address public immutable weth;
    bytes32 public immutable merkleRoot;

    uint public startTime;

    event registration(address indexed teamAddr, string name);

    constructor(address _weth) {

        template = new Create2Contract();
        weth = _weth;

        bytes32[] memory numbers = new bytes32[](20);
        for (uint x = 0; x < 20; x++) {
            numbers[x] = bytes32(keccak256(abi.encodePacked(x)));
        }
        
        merkleRoot = MerkleTree.getRoot(numbers);
    }

    function start() public onlyOwner {
        startTime = block.timestamp;
        live = true;
    }

    function stop() public onlyOwner {
        live = false;
    }

    function extendTime() public onlyOwner {
        timeExtended = true;
    }

    modifier isLive {
        require(live);

        if (timeExtended) {
            require(block.timestamp < startTime + 3 hours);
        }
        else {
            require(block.timestamp < startTime + 2 hours);

        }
        _;
    }

    function registerTeam(string memory team) public isLive {
        emit registration(msg.sender, team);
    }

    function givePoints(uint challengeNum, address team, uint points) internal {

        progress[team][challengeNum] = true;

        if (challengeNum != 23) {
            scores[team] += (points - solves[challengeNum]);
        }
        solves[challengeNum]++;
    }

    function f0(bool val) public isLive {
        uint fNum = 0;
        require(!progress[msg.sender][fNum]);

        require(!val);

        givePoints(fNum, msg.sender, 200);
    }

    function f1() public payable isLive {
        uint fNum = 1;

        require(!progress[msg.sender][fNum]);

        require(msg.value == 10 wei);
        givePoints(fNum, msg.sender, 400);
    }

    function f2(uint val) public isLive {
        uint fNum = 2;
        require(!progress[msg.sender][fNum]);
        
        uint256 guess = uint256(keccak256(abi.encodePacked(val, msg.sender)));

        require(guess % 5 == 0);

        givePoints(fNum, msg.sender, 600);

    }

    function f3(uint data) public isLive {
        uint fNum = 3;
        uint xorData = data ^ 0x987654321;

        require(!progress[msg.sender][fNum]);

        require(xorData == 0xbeefdead);
        givePoints(fNum, msg.sender, 800);

    }


    function f4(address destAddr) public isLive {
        uint fNum = 4;
        require(!progress[msg.sender][fNum]);

        require(destAddr == address(this));
        givePoints(fNum, msg.sender, 1000);

    }

    function f5(address destAddr) public isLive {
        uint fNum = 5;
        require(!progress[msg.sender][fNum]);

        require(destAddr == msg.sender);

        givePoints(fNum, msg.sender, 1200);

    }

    function f6(address destAddr) public isLive {
        uint fNum = 6;
        require(!progress[msg.sender][fNum]);

        require(destAddr == owner());

        givePoints(fNum, msg.sender, 1400);

    }

    function f7() public isLive {
        uint fNum = 7;
        require(!progress[msg.sender][fNum]);

        require(gasleft() > 6_969_420);

        givePoints(fNum, msg.sender, 1600);

    }


    function f8(bytes calldata data) public isLive {
        uint fNum = 8;
        require(!progress[msg.sender][fNum]);

        require(data.length == 32);

        givePoints(fNum, msg.sender, 1800);

    }

    function f9(bytes memory data) public isLive {
        uint fNum = 9;

        require(!progress[msg.sender][fNum]);

        data = abi.encodePacked(msg.sig, data);
        require(data.length == 32);

        givePoints(fNum, msg.sender, 2000);

    }


    function f10(int num1, int num2) public isLive {
        uint fNum = 10;
        require(!progress[msg.sender][fNum]);

        require(num1 < 0 && num2 > 0);
        unchecked {
            int num3 = num1 - num2;
            require(num3 > 10);
        }

        givePoints(fNum, msg.sender, 2200);

    }

    function f11(int num1, int num2) public isLive {
        uint fNum = 11;
        require(!progress[msg.sender][fNum]);

        require(num1 > 0 && num2 > 0, "Numbers must be greater than zero");
        unchecked {
            int num3 = num1 + num2;
            require(num3 < -10);
        }

        givePoints(fNum, msg.sender, 2400);

    }

    function f12(bytes memory data) public isLive {
        uint fNum = 12;

        require(!progress[msg.sender][fNum]);


        (bool success, bytes memory returnData) = address(this).call(data);
        require(success);
        
        require(keccak256(returnData) == keccak256(abi.encode(0xdeadbeef)));

        givePoints(fNum, msg.sender, 2600);
    }

    function f13(address team) public isLive {
        uint fNum = 13;

        require(!progress[team][fNum]);

        // require(msg.sender.code.length == 0, "No contracts this time!");
        require(msg.sender != tx.origin);

        if (entryCount[team] == 0) {
            entryCount[team]++;
            (bool sent, ) = msg.sender.call("");
            require(sent);
        }

        givePoints(fNum, team, 2800);
    }

    function f14(address team) public isLive {
        uint fNum = 14;

        require(!progress[team][fNum]);

        require(msg.sender.code.length == 0);
        require(msg.sender != tx.origin);

        if (entryCount[team] == 0) {
            entryCount[team]++;
            (bool sent, ) = msg.sender.call("");
            require(sent);
        }

        givePoints(fNum, team, 3000);
    }


    function f15(address team, address expectedSigner, bytes memory signature) external isLive {
        uint fNum = 15;

        require(!progress[team][fNum]);

        bytes32 digest = keccak256("I don't like sand. It's course and rough and it gets everywhere");
        
        address signer = Cryptography.recover(digest, signature);

        require(signer != address(0));

        require(signer == expectedSigner);
        require(!signers[signer]);

        signers[signer] = true;
        givePoints(fNum, team, 3200);
    }

    function f16(address team) public isLive {
        uint fNum = 16;
        require(!progress[team][fNum]);

        require(ISupportsInterface(msg.sender).supportsInterface(type(IERC20).interfaceId), "msg sender does not support interface");
    
        givePoints(fNum, team, 3400);
    }

    function f17(address newContract, address team) public isLive {
        uint fNum = 17;
        require(!progress[team][fNum]);

        address clone = Clones.cloneDeterministic(address(template), keccak256(abi.encode(msg.sender)));
        require(newContract == clone);

        givePoints(fNum, team, 3600);
    }

    function f18(address team) public isLive {
        uint fNum = 18;
        require(!progress[team][fNum]);

        require(IERC20(weth).balanceOf(msg.sender) > 1e9 wei);

        givePoints(fNum, team, 3800);
    }

    function f19(address team) public isLive {
        uint fNum = 19;
        require(!progress[team][fNum]);

        IERC20(weth).transferFrom(msg.sender, address(this), 1e9 wei);

        givePoints(fNum, team, 4000);
    }

    function f20(address team, bytes32[] calldata proof, bytes32 leaf) public isLive {
        uint fNum = 20;
        require(!progress[team][fNum]);
        require(!usedLeaves[leaf]);

        require(MerkleProof.verify(proof, merkleRoot, leaf));

        usedLeaves[leaf] = true;

        givePoints(fNum, team, 4200);

    }

    function f21(address team, uint value) public isLive {
        uint fNum = 21;

        require(!progress[team][fNum]);

        uint result;

        assembly {
            mstore(0, team)
            mstore(32, 1)
            let hash := keccak256(0, 64)
            result := sload(hash)
        }

        require(result == value);

        givePoints(fNum, team, 4400);
    }
    
    function f22(address team, bytes calldata data, bytes32 hashSlingingSlasher) public isLive {
        uint fNum = 22;
        require(!progress[team][fNum]);

        bytes32 hashData = keccak256(data);
        address sender = msg.sender;

        assembly {
            let size := extcodesize(sender)
            if eq(size, 0) {
                revert(0,0)
            }

            if eq(sender, origin()) {
                revert(0,0)
            }

            if gt(xor(hashData, hashSlingingSlasher), 0) {
                revert(0,0)
            }

            extcodecopy(sender, 0, 0, size)
            let exthash := keccak256(0, size)

            if gt(xor(exthash, hashData), 0) {
                revert(0,0)
            }
        }

        givePoints(fNum, team, 4600);
    }

    function f23(address team, uint value) public isLive {

        uint fNum = 23;
        require(!progress[team][fNum]);

         assembly {
            mstore(0, team)
            mstore(32, 1)
            let hash := keccak256(0, 64)
            let result := sload(hash)

            mstore(0, team)
            mstore(32, 1)
            hash := keccak256(0, 64)
            sstore(hash, value)

            mstore(0, team)
            mstore(32, 1)
            hash := keccak256(0, 64)
            let result3 := sload(hash)

            if gt(xor(result3, add(result, add(mul(23, 200), 200))), 0) {
                revert(0, 0)
            }
        }

        givePoints(fNum, team, 4800);
    }

    function internalChallengeHook() public view isLive returns (uint) {
        require(msg.sender == address(this));
        return 0xdeadbeef;
    }
}