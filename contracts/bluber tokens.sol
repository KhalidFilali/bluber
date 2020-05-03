pragma solidity ^0.6.6;
contract owned {
    address public owner;

    function owned() public {
        owner = msg.sender;
    }

    modifier onlyOwner {
        require(msg.sender == owner);
        _;
    }

    function transferOwnership(address newOwner) onlyOwner public {
        owner = newOwner;
    }
}

interface tokenRecipient { function receiveApproval(address _from, uint256 _value, address _token, bytes _extraData) public; }

contract TokenERC20 is owned {
    // Public variable delcaration
    string public name;
    string public symbol;
    uint8 public decimals = 18;
    uint256 public totalSupply;

    // This creates an array with all balances
    mapping (address => uint256) public balanceOf;
    mapping (address => mapping (address => uint256)) public allowance;

    // This generates a public event on the blockchain that will notify clients
    event Transfer(address indexed from, address indexed to, uint256 value);

    // This notifies clients about the amount burnt
    event Burn(address indexed from, uint256 value);

    //constructor
    function TokenERC20(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) public {
        totalSupply = initialSupply * 10 ** uint256(decimals);  // Update total supply with the decimal amount
        balanceOf[msg.sender] = totalSupply;                // Give the creator all initial tokens
        name = tokenName;                                   // Set the name for display purposes
        symbol = tokenSymbol;
    }

    function _transfer(address _from, address _to, uint _value) internal {
        require(_to != 0x0);
        // Check if the sender has enough in their wallet
        require(balanceOf[_from] >= _value);
        require(balanceOf[_to] + _value > balanceOf[_to]);
        // Save this for payment history
        uint previousBalances = balanceOf[_from] + balanceOf[_to];
        // Subtract from the sender
        balanceOf[_from] -= _value;
        // Add the same to the recipient
        balanceOf[_to] += _value;
        Transfer(_from, _to, _value);
// bug checking
        assert(balanceOf[_from] + balanceOf[_to] == previousBalances);
    }

    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint256 _value) public returns (bool success) {
        require(_value <= allowance[_from][msg.sender]);     // Check allowance
        allowance[_from][msg.sender] -= _value;
        _transfer(_from, _to, _value);
        return true;
    }


    function approve(address _spender, uint256 _value) public
        returns (bool success) {
        allowance[msg.sender][_spender] = _value;
        return true;
    }

    /**
     * Set allowance for other address and notify
     *
     * Allows `_spender` to spend no more than `_value` tokens in your behalf, and then ping the contract about it
     *
     * @param _spender The address authorized to spend
     * @param _value the max amount they can spend
     * @param _extraData some extra information to send to the approved contract
     */
    function approveAndCall(address _spender, uint256 _value, bytes _extraData)
        public
        returns (bool success) {
        tokenRecipient spender = tokenRecipient(_spender);
        if (approve(_spender, _value)) {
            spender.receiveApproval(msg.sender, _value, this, _extraData);
            return true;
        }
    }


    function burn(uint256 _value) onlyOwner public returns (bool success) {
        require(balanceOf[msg.sender] >= _value);   // Check if the sender has enough
        balanceOf[msg.sender] -= _value;            // Subtract from the sender
        totalSupply -= _value;                      // Updates totalSupply
        Burn(msg.sender, _value);
        return true;
    }


    function burnFrom(address _from, uint256 _value) onlyOwner public returns (bool success) {
        require(balanceOf[_from] >= _value);                // Check if the targeted balance is enough
        require(_value <= allowance[_from][msg.sender]);    // Check allowance
        balanceOf[_from] -= _value;                         // Subtract from the targeted balance
        allowance[_from][msg.sender] -= _value;             // Subtract from the sender's allowance
        totalSupply -= _value;                              // Update totalSupply
        Burn(_from, _value);
        return true;
    }
}

/******************************************/
/*       ADVANCED TOKEN STARTS HERE       */
/******************************************/
contract StrideToken is TokenERC20 {
    uint256 public sellPrice;
    uint256 public buyPrice;
    address[100] public bidAddresses;
    uint bidAddressCounter = 0;
    uint miningReward = 2;
    int distanceToReward = 20;

    /* List of registered drivers */
    mapping (address => int) isDriver;

    mapping (address => int) miningCounter;

    mapping (address => uint) reputations;

    mapping (address => bool) public frozenAccount;

    struct Bid {
        int coordinate1;
        int coordinate2;
        int coordinate3;
        int coordinate4;
        uint token;
        address bidAddress;
        address driverAddress;
        bool accepted;
        int distanceSquared;
        int pathLength;
    }

    struct Driver {
        address driverAddress;
        uint reputation;
    }

    mapping (address => Bid) public activeBids;

    //This generates a public event on the blockchain that will notify clients//
    event FrozenFunds(address target, bool frozen);

    function StrideToken(
        uint256 initialSupply,
        string tokenName,
        string tokenSymbol
    ) TokenERC20(initialSupply, tokenName, tokenSymbol) public {}

    function getBidc1(address bidID) constant returns(int){
        return(activeBids[bidID].coordinate1);
    }

    function getBidc2(address bidID) constant returns(int){
        return(activeBids[bidID].coordinate2);
    }

    function getBidc3(address bidID) constant returns(int){
        return(activeBids[bidID].coordinate3);
    }

    function getBidc4(address bidID) constant returns(int){
        return(activeBids[bidID].coordinate4);
    }

    function getBidToken(address bidID) constant returns(uint){
        return(activeBids[bidID].token);
    }

    function getBidAddress(address bidID) constant returns(address){
        return(activeBids[bidID].bidAddress);
    }

    function getBidDriverAddress(address bidID) constant returns(address){
        return(activeBids[bidID].driverAddress);
    }

    function getBidAccepted(address bidID) constant returns(bool){
        return(activeBids[bidID].accepted);
    }

    function getBidDistanceSquared(address bidID) constant returns(int){
        return(activeBids[bidID].distanceSquared);
    }

    function getBidPathLength(address bidID) constant returns(int){
        return(activeBids[bidID].pathLength);
    }

    function setMiningReward(uint newReward) onlyOwner returns(string){
        miningReward = newReward;
        return("Updated mining");
    }

    function getMiningReward() constant returns(uint reward){
        return(miningReward);
    }

    function setDistanceToReward(int newDistance) onlyOwner returns(string){
        distanceToReward = newDistance;
        return("Distance to next reward updated");
    }

    function getDistanceToReward() constant returns(int){
        return(distanceToReward);
    }
    function postBid(int _coordinate1, int _coordinate2, int _coordinate3, int _coordinate4, int length, uint _token) payable returns(bool) {
        if(msg.value >= 0.25 ether){
            bidAddresses[bidAddressCounter] = msg.sender;
            bidAddressCounter += 1;
            int distanceVectorX = _coordinate3 - _coordinate1;
            int distanceVectorY = _coordinate4 - _coordinate2;
            int totalDistanceSquared = (distanceVectorY * distanceVectorY) + (distanceVectorX * distanceVectorX);
            activeBids[msg.sender] = Bid(_coordinate1, _coordinate2, _coordinate3, _coordinate4, _token, msg.sender, 0x0, false, totalDistanceSquared, length);
            return true;
        }
        return false;
    }
    /* This modifier checks that the message sender is a registered driver */
    modifier driverExists() {
        if(isDriver[msg.sender] != 1){
            throw;
        }
        _;
    }

    function getBid(uint _index) driverExists constant returns(address) {
        if (activeBids[bidAddresses[_index]].token != 0) {
            return bidAddresses[_index];
        }
        return 0x0;
    }
    function getBidStatus() constant returns(Driver) {
        if(activeBids[msg.sender].accepted == true){
            return(Driver(activeBids[msg.sender].driverAddress, reputations[activeBids[msg.sender].driverAddress]));
        }
        return(Driver(0x0, 0));
    }
    function takeBid(address _bidAddress) driverExists returns(bool) {
        if(activeBids[_bidAddress].token != 0){
            activeBids[_bidAddress].accepted = true;
            activeBids[_bidAddress].driverAddress = msg.sender;
            return true;
        }
        return false;
    }
    function confirmBid(address _driver) returns(bool) {
        approve(_driver, activeBids[msg.sender].token);
    }
    function addDriver(address driverAddress) returns(bool) {
        if(isDriver[driverAddress] == 1){
            return false;
        }
        isDriver[driverAddress] = 1;
        return true;
    }

    /* This executes the logic to verify that the trip was fulfilled */
    function rideVerification(address _takenBid, int _distance) payable driverExists returns(bool) {
        if(msg.value >= 0.25 ether) {
            bool success;
            int distance = 0;
            int distanceRatio = (100 * _distance) / (100 * activeBids[_takenBid].distanceSquared);
            //location verification logic
            //if 95% or more of the distance was traveled, driver gets paid in full
            if(distanceRatio >= 95){
                distance = activeBids[_takenBid].pathLength;
                success = true;
            }
            else {
                distance = (distanceRatio * activeBids[_takenBid].pathLength) / 100;
                success = true;
            }
            //return success or fail
            if(success){
                transferFrom(activeBids[_takenBid].bidAddress, activeBids[_takenBid].driverAddress, activeBids[_takenBid].token);
                miningCounter[activeBids[_takenBid].driverAddress] += distance;
                while (miningCounter[activeBids[_takenBid].driverAddress] >= distanceToReward) {
                    balanceOf[activeBids[_takenBid].driverAddress] += miningReward;
                    miningCounter[activeBids[_takenBid].driverAddress] -= distanceToReward;
                }
                return true;
            }
            return false;
        }
        return false;
    }

    function _transfer(address _from, address _to, uint _value) internal {
        require (_to != 0x0);
        require (balanceOf[_from] > _value);                // Check if the sender has enough
        require (balanceOf[_to] + _value > balanceOf[_to]); // Check for overflows
        require(!frozenAccount[_from]);                     // Check if sender is frozen
        require(!frozenAccount[_to]);                       // Check if recipient is frozen
        balanceOf[_from] -= _value;                         // Subtract from the sender
        balanceOf[_to] += _value;                           // Add the same to the recipient
        Transfer(_from, _to, _value);
    }
    function mintToken(address target, uint256 mintedAmount) onlyOwner public {
        balanceOf[target] += mintedAmount;
        totalSupply += mintedAmount;
        Transfer(0, this, mintedAmount);
        Transfer(this, target, mintedAmount);
    }
    function freezeAccount(address target, bool freeze) onlyOwner public {
        frozenAccount[target] = freeze;
        FrozenFunds(target, freeze);
    }

    function setPrices(uint256 newSellPrice, uint256 newBuyPrice) onlyOwner public {
        sellPrice = newSellPrice;
        buyPrice = newBuyPrice;
    }

    //Buy tokens from contract by sending ether
    function buy() payable public {
        uint amount = msg.value / buyPrice;               // calculates the amount
        _transfer(this, msg.sender, amount);              // makes the transfers
    }

    function sell(uint256 amount) public {
        require(this.balance >= amount * sellPrice);      // checks if the contract has enough ether to buy
        _transfer(msg.sender, this, amount);              // makes the transfers
        msg.sender.transfer(amount * sellPrice);          // sends ether to the seller
    }
}
