// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/**
 * @title MotherTeresaAIToken
 * @notice Global Radical Compassion & Zero-Leakage Destitute Care Launchpad ($MTER)
 * @dev Direct micro-escrow protocol for hospices, leprosy dispensaries, and orphan shelters
 */
contract MotherTeresaAIToken {
    string public name = "Mother Teresa AI";
    string public symbol = "MTER";
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    uint256 public constant INITIAL_PRICE = 0.0001 ether;
    uint256 public constant CURVE_SLOPE = 1e10;

    mapping(address => uint256) public balanceOf;
    mapping(address => mapping(address => uint256)) public allowance;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event CurveMint(address indexed benefactor, uint256 tokenAmount, uint256 ethDonation);
    event ProofOfMercyDisbursement(string indexed sanctuaryType, address indexed caretaker, uint256 amountWei, bytes32 indexed careProof);

    function calculateCost(uint256 amount) public view returns (uint256) {
        uint256 currentSupply = totalSupply;
        uint256 baseCost = amount * INITIAL_PRICE;
        uint256 curveFactor = (CURVE_SLOPE * ((currentSupply + amount)**2 - currentSupply**2)) / 2e18;
        return baseCost + curveFactor;
    }

    function mint(uint256 amount) external payable returns (bool) {
        require(amount > 0, "Zero charity amount");
        uint256 cost = calculateCost(amount);
        require(msg.value >= cost, "Insufficient donation for bonding curve");

        totalSupply += amount;
        balanceOf[msg.sender] += amount;
        emit Transfer(address(0), msg.sender, amount);
        emit CurveMint(msg.sender, amount, cost);

        if (msg.value > cost) {
            payable(msg.sender).transfer(msg.value - cost);
        }
        return true;
    }

    function disburseDirectAid(
        string memory sanctuaryType,
        address caretaker,
        uint256 amount,
        bytes32 careProof
    ) external returns (bool) {
        require(balanceOf[msg.sender] >= amount, "Insufficient sanctuary treasury reserve");
        balanceOf[msg.sender] -= amount;
        balanceOf[caretaker] += amount;
        emit Transfer(msg.sender, caretaker, amount);
        emit ProofOfMercyDisbursement(sanctuaryType, caretaker, amount, careProof);
        return true;
    }
}
