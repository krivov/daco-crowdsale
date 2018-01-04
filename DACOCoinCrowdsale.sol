pragma solidity ^0.4.15;

/**
 * @title SafeMath
 * @dev Math operations with safety checks that throw on error
 */
library SafeMath {
  function mul(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }

  function div(uint256 a, uint256 b) internal constant returns (uint256) {
    // assert(b > 0); // Solidity automatically throws when dividing by 0
    uint256 c = a / b;
    // assert(a == b * c + a % b); // There is no case in which this doesn't hold
    return c;
  }

  function sub(uint256 a, uint256 b) internal constant returns (uint256) {
    assert(b <= a);
    return a - b;
  }

  function add(uint256 a, uint256 b) internal constant returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

/**
 * @title ERC20Basic
 * @dev Simpler version of ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/179
 */
contract ERC20Basic {
  uint256 public totalSupply;
  function balanceOf(address who) public constant returns (uint256);
  function transfer(address to, uint256 value) public returns (bool);
  event Transfer(address indexed from, address indexed to, uint256 value);
}

/**
 * @title ERC20 interface
 * @dev see https://github.com/ethereum/EIPs/issues/20
 */
contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public returns (bool);
  function approve(address spender, uint256 value) public returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 value);
}

/**
 * @title Basic token
 * @dev Basic version of StandardToken, with no allowances.
 */
contract BasicToken is ERC20Basic {
  using SafeMath for uint256;

  mapping(address => uint256) balances;

  /**
  * @dev transfer token for a specified address
  * @param _to The address to transfer to.
  * @param _value The amount to be transferred.
  */
  function transfer(address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[msg.sender]);

    // SafeMath.sub will throw if there is not enough balance.
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    Transfer(msg.sender, _to, _value);
    return true;
  }

  /**
  * @dev Gets the balance of the specified address.
  * @param _owner The address to query the the balance of.
  * @return An uint256 representing the amount owned by the passed address.
  */
  function balanceOf(address _owner) public constant returns (uint256 balance) {
    return balances[_owner];
  }

}


/**
 * @title Ownable
 * @dev The Ownable contract has an owner address, and provides basic authorization control
 * functions, this simplifies the implementation of "user permissions".
 */
contract Ownable {
  address public owner;


  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);


  /**
   * @dev The Ownable constructor sets the original `owner` of the contract to the sender
   * account.
   */
  function Ownable() {
    owner = msg.sender;
  }


  /**
   * @dev Throws if called by any account other than the owner.
   */
  modifier onlyOwner() {
    require(msg.sender == owner);
    _;
  }


  /**
   * @dev Allows the current owner to transfer control of the contract to a newOwner.
   * @param newOwner The address to transfer ownership to.
   */
  function transferOwnership(address newOwner) onlyOwner public {
    require(newOwner != address(0));
    OwnershipTransferred(owner, newOwner);
    owner = newOwner;
  }

}

/**
 * @title Standard ERC20 token
 *
 * @dev Implementation of the basic standard token.
 * @dev https://github.com/ethereum/EIPs/issues/20
 * @dev Based on code by FirstBlood: https://github.com/Firstbloodio/token/blob/master/smart_contract/FirstBloodToken.sol
 */
contract StandardToken is ERC20, BasicToken {

  mapping (address => mapping (address => uint256)) internal allowed;


  /**
   * @dev Transfer tokens from one address to another
   * @param _from address The address which you want to send tokens from
   * @param _to address The address which you want to transfer to
   * @param _value uint256 the amount of tokens to be transferred
   */
  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(_to != address(0));
    require(_value <= balances[_from]);
    require(_value <= allowed[_from][msg.sender]);

    balances[_from] = balances[_from].sub(_value);
    balances[_to] = balances[_to].add(_value);
    allowed[_from][msg.sender] = allowed[_from][msg.sender].sub(_value);
    Transfer(_from, _to, _value);
    return true;
  }

  /**
   * @dev Approve the passed address to spend the specified amount of tokens on behalf of msg.sender.
   *
   * Beware that changing an allowance with this method brings the risk that someone may use both the old
   * and the new allowance by unfortunate transaction ordering. One possible solution to mitigate this
   * race condition is to first reduce the spender's allowance to 0 and set the desired value afterwards:
   * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
   * @param _spender The address which will spend the funds.
   * @param _value The amount of tokens to be spent.
   */
  function approve(address _spender, uint256 _value) public returns (bool) {

    // To change the approve amount you first have to reduce the addresses`
    //  allowance to zero by calling `approve(_spender, 0)` if it is not
    //  already 0 to mitigate the race condition described here:
    //  https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
    require((_value == 0) || (allowed[msg.sender][_spender] == 0));

    allowed[msg.sender][_spender] = _value;
    Approval(msg.sender, _spender, _value);
    return true;
  }

  /**
   * @dev Function to check the amount of tokens that an owner allowed to a spender.
   * @param _owner address The address which owns the funds.
   * @param _spender address The address which will spend the funds.
   * @return A uint256 specifying the amount of tokens still available for the spender.
   */
  function allowance(address _owner, address _spender) public constant returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

  /**
   * approve should be called when allowed[_spender] == 0. To increment
   * allowed value is better to use this function to avoid 2 calls (and wait until
   * the first transaction is mined)
   * From MonolithDAO Token.sol
   */
  function increaseApproval (address _spender, uint _addedValue) public returns (bool success) {
    allowed[msg.sender][_spender] = allowed[msg.sender][_spender].add(_addedValue);
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

  function decreaseApproval (address _spender, uint _subtractedValue) public returns (bool success) {
    uint oldValue = allowed[msg.sender][_spender];
    if (_subtractedValue > oldValue) {
      allowed[msg.sender][_spender] = 0;
    } else {
      allowed[msg.sender][_spender] = oldValue.sub(_subtractedValue);
    }
    Approval(msg.sender, _spender, allowed[msg.sender][_spender]);
    return true;
  }

}




/**
 * @title Mintable token
 * @dev Simple ERC20 Token example, with mintable token creation
 * @dev Issue: * https://github.com/OpenZeppelin/zeppelin-solidity/issues/120
 * Based on code by TokenMarketNet: https://github.com/TokenMarketNet/ico/blob/master/contracts/MintableToken.sol
 */

contract MintableToken is StandardToken, Ownable {
  event Mint(address indexed to, uint256 amount);
  event MintFinished();

  bool public mintingFinished = false;


  modifier canMint() {
    require(!mintingFinished);
    _;
  }

  /**
   * @dev Function to mint tokens
   * @param _to The address that will receive the minted tokens.
   * @param _amount The amount of tokens to mint.
   * @return A boolean that indicates if the operation was successful.
   */
  function mint(address _to, uint256 _amount) onlyOwner canMint public returns (bool) {
    totalSupply = totalSupply.add(_amount);
    balances[_to] = balances[_to].add(_amount);
    Mint(_to, _amount);
    Transfer(0x0, _to, _amount);
    return true;
  }

  /**
   * @dev Function to stop minting new tokens.
   * @return True if the operation was successful.
   */
  function finishMinting() onlyOwner public returns (bool) {
    mintingFinished = true;
    MintFinished();
    return true;
  }
}


/**
 * @title Pausable
 * @dev Base contract which allows children to implement an emergency stop mechanism.
 */
contract Pausable is Ownable {
  event Pause();
  event Unpause();

  bool public paused = false;


  /**
   * @dev Modifier to make a function callable only when the contract is not paused.
   */
  modifier whenNotPaused() {
    require(!paused);
    _;
  }

  /**
   * @dev Modifier to make a function callable only when the contract is paused.
   */
  modifier whenPaused() {
    require(paused);
    _;
  }

  /**
   * @dev called by the owner to pause, triggers stopped state
   */
  function pause() onlyOwner whenNotPaused public {
    paused = true;
    Pause();
  }

  /**
   * @dev called by the owner to unpause, returns to normal state
   */
  function unpause() onlyOwner whenPaused public {
    paused = false;
    Unpause();
  }
}

contract PausableToken is StandardToken, Pausable {

  function transfer(address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transfer(_to, _value);
  }

  function transferFrom(address _from, address _to, uint256 _value) public whenNotPaused returns (bool) {
    return super.transferFrom(_from, _to, _value);
  }

  function approve(address _spender, uint256 _value) public whenNotPaused returns (bool) {
    return super.approve(_spender, _value);
  }

  function increaseApproval(address _spender, uint _addedValue) public whenNotPaused returns (bool success) {
    return super.increaseApproval(_spender, _addedValue);
  }

  function decreaseApproval(address _spender, uint _subtractedValue) public whenNotPaused returns (bool success) {
    return super.decreaseApproval(_spender, _subtractedValue);
  }
}


contract DACOToken is MintableToken, PausableToken {
  string public constant name = "DACO Coin";
  string public constant symbol = "DACO";
  uint8 public constant decimals = 18;
}



/**
 * @title RefundVault
 * @dev This contract is used for storing funds while a crowdsale
 * is in progress. Supports refunding the money if crowdsale fails,
 * and forwarding it if crowdsale is successful.
 */
contract RefundVault is Ownable {
  using SafeMath for uint256;

  enum State { Active, Refunding, Closed }

  mapping (address => uint256) public deposited;
  address public wallet;
  State public state;

  event Closed();
  event RefundsEnabled();
  event Refunded(address indexed beneficiary, uint256 weiAmount);

  function RefundVault(address _wallet) {
    require(_wallet != 0x0);
    wallet = _wallet;
    state = State.Active;
  }

  function deposit(address investor) onlyOwner public payable {
    require(state == State.Active);
    deposited[investor] = deposited[investor].add(msg.value);
  }

  function close() onlyOwner public {
    require(state == State.Active);
    state = State.Closed;
    Closed();
    wallet.transfer(this.balance);
  }

  function enableRefunds() onlyOwner public {
    require(state == State.Active);
    state = State.Refunding;
    RefundsEnabled();
  }

  function refund(address investor) public {
    require(state == State.Refunding);
    uint256 depositedValue = deposited[investor];
    deposited[investor] = 0;
    investor.transfer(depositedValue);
    Refunded(investor, depositedValue);
  }
}


/**
 * @title Crowdsale
 * @dev Modified contract for managing a token crowdsale.
 * DACOCoinCrowdsale have pre-sale and main sale periods, where investors can make
 * token purchases and the crowdsale will assign them tokens based
 * on a token per ETH rate and the system of bonuses.
 * Funds collected are forwarded to a wallet as they arrive.
 * pre-sale and main sale periods both have caps defined in tokens
 */

contract DACOCoinCrowdsale is Ownable {

  using SafeMath for uint256;

  struct Bonus {
    uint bonusEndTime;
    uint timePercent;
    uint bonusMinAmount;
    uint amountPercent;
  }

  // minimum amount of funds to be raised in weis
  uint256 public goal;

  // DACO token emission
  uint256 public tokenEmission;

  // refund vault used to hold funds while crowdsale is running
  RefundVault public vault;

  // true for finalised crowdsale
  bool public isFinalized;

  // The token being sold
  MintableToken public token;

  // start and end timestamps where pre-investments are allowed (both inclusive)
  uint256 public preSaleStartTime;
  uint256 public preSaleEndTime;

  // start and end timestamps where main-investments are allowed (both inclusive)
  uint256 public mainSaleStartTime;
  uint256 public mainSaleEndTime;

  // maximum amout of wei for pre-sale and main sale
  uint256 public preSaleWeiCap;
  uint256 public mainSaleWeiCap;

  // address where funds are collected
  address public wallet;

  // address where final 10% of funds will be collected
  address public tokenWallet;

  // how many token units a buyer gets per wei
  uint256 public rate;

  // amount of raised money in wei
  uint256 public weiRaised;

  Bonus[] public preSaleBonuses;
  Bonus[] public mainSaleBonuses;

  uint256 public preSaleMinimumWei;
  uint256 public defaultPercent;

  /**
   * event for token purchase logging
   * @param purchaser who paid for the tokens
   * @param beneficiary who got the tokens
   * @param value weis paid for purchase
   * @param amount amount of tokens purchased
   */
  event TokenPurchase(address indexed purchaser, address indexed beneficiary, uint256 value, uint256 amount);
  event FinalisedCrowdsale(uint256 totalSupply, uint256 minterBenefit);

  function DACOCoinCrowdsale(uint256 _preSaleStartTime, uint256 _preSaleEndTime, uint256 _preSaleWeiCap, uint256 _mainSaleStartTime, uint256 _mainSaleEndTime, uint256 _mainSaleWeiCap, uint256 _goal, uint256 _rate, address _wallet, address _tokenWallet) public {

    //require(_goal > 0);

    // can't start pre-sale in the past
    require(_preSaleStartTime >= now);

    // can't start main sale in the past
    require(_mainSaleStartTime >= now);

    // can't start main sale before the end of pre-sale
    require(_preSaleEndTime < _mainSaleStartTime);

    // the end of pre-sale can't happen before it's start
    require(_preSaleStartTime < _preSaleEndTime);

    // the end of main sale can't happen before it's start
    require(_mainSaleStartTime < _mainSaleEndTime);

    require(_rate > 0);
    require(_preSaleWeiCap > 0);
    require(_mainSaleWeiCap > 0);
    require(_wallet != 0x0);
    require(_tokenWallet != 0x0);

    preSaleMinimumWei = 0;
    defaultPercent = 0;

    tokenEmission = 75000000 ether;

    preSaleBonuses.push(Bonus({bonusEndTime: 3600 * 24 * 2, timePercent: 20, bonusMinAmount: 8500 ether, amountPercent: 25}));
    preSaleBonuses.push(Bonus({bonusEndTime: 3600 * 24 * 4, timePercent: 20, bonusMinAmount: 0, amountPercent: 0}));
    preSaleBonuses.push(Bonus({bonusEndTime: 3600 * 24 * 6, timePercent: 15, bonusMinAmount: 0, amountPercent: 0}));
    preSaleBonuses.push(Bonus({bonusEndTime: 3600 * 24 * 7, timePercent: 10, bonusMinAmount: 20000 ether, amountPercent: 15}));

    mainSaleBonuses.push(Bonus({bonusEndTime: 3600 * 24 * 7,  timePercent: 9, bonusMinAmount: 0, amountPercent: 0}));
    mainSaleBonuses.push(Bonus({bonusEndTime: 3600 * 24 * 14, timePercent: 6, bonusMinAmount: 0, amountPercent: 0}));
    mainSaleBonuses.push(Bonus({bonusEndTime: 3600 * 24 * 21, timePercent: 4, bonusMinAmount: 0, amountPercent: 0}));
    mainSaleBonuses.push(Bonus({bonusEndTime: 3600 * 24 * 28, timePercent: 0, bonusMinAmount: 0, amountPercent: 0}));

    preSaleStartTime = _preSaleStartTime;
    preSaleEndTime = _preSaleEndTime;
    preSaleWeiCap = _preSaleWeiCap;
    mainSaleStartTime = _mainSaleStartTime;
    mainSaleEndTime = _mainSaleEndTime;
    mainSaleWeiCap = _mainSaleWeiCap;
    goal = _goal;
    rate = _rate;
    wallet = _wallet;
    tokenWallet = _tokenWallet;

    isFinalized = false;

    token = new DACOToken();
    vault = new RefundVault(wallet);
  }

  // fallback function can be used to buy tokens
  function () payable {
    buyTokens(msg.sender);
  }

  // low level token purchase function
  function buyTokens(address beneficiary) public payable {

    require(beneficiary != 0x0);
    require(msg.value != 0);
    require(!isFinalized);

    uint256 weiAmount = msg.value;

    validateWithinPeriods();
    validateWithinCaps(weiAmount);

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    uint256 percent = getBonusPercent(tokens, now);

    // add bonus to tokens depends on the period
    uint256 bonusedTokens = applyBonus(tokens, percent);

    // update state
    weiRaised = weiRaised.add(weiAmount);
    token.mint(beneficiary, bonusedTokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, bonusedTokens);

    forwardFunds();
  }

  // owner can mint tokens during crowdsale withing defined caps
  function mintTokens(address beneficiary, uint256 weiAmount, uint256 forcePercent) external onlyOwner returns (bool) {

    require(forcePercent <= 100);
    require(beneficiary != 0x0);
    require(weiAmount != 0);
    require(!isFinalized);

    validateWithinCaps(weiAmount);

    uint256 percent = 0;

    // calculate token amount to be created
    uint256 tokens = weiAmount.mul(rate);

    if (forcePercent == 0) {
      percent = getBonusPercent(tokens, now);
    } else {
      percent = forcePercent;
    }

    // add bonus to tokens depends on the period
    uint256 bonusedTokens = applyBonus(tokens, percent);

    // update state
    weiRaised = weiRaised.add(weiAmount);
    token.mint(beneficiary, bonusedTokens);
    TokenPurchase(msg.sender, beneficiary, weiAmount, bonusedTokens);
  }

  // set new dates for pre-salev (emergency case)
  function setPreSaleDates(uint256 _preSaleStartTime, uint256 _preSaleEndTime) public onlyOwner returns (bool) {
    require(!isFinalized);
    require(_preSaleStartTime < _preSaleEndTime);
    preSaleStartTime = _preSaleStartTime;
    preSaleEndTime = _preSaleEndTime;
    return true;
  }

  // set new dates for main-sale (emergency case)
  function setMainSaleDates(uint256 _mainSaleStartTime, uint256 _mainSaleEndTime) public onlyOwner returns (bool) {
    require(!isFinalized);
    require(_mainSaleStartTime < _mainSaleEndTime);
    mainSaleStartTime = _mainSaleStartTime;
    mainSaleEndTime = _mainSaleEndTime;
    return true;
  }

  // set token on pause
  function pauseToken() external onlyOwner {
    require(!isFinalized);
    DACOToken(token).pause();
  }

  // unset token's pause
  function unpauseToken() external onlyOwner {
    DACOToken(token).unpause();
  }

  // @return true if main sale event has ended
  function mainSaleHasEnded() external constant returns (bool) {
    return now > mainSaleEndTime;
  }

  // @return true if pre sale event has ended
  function preSaleHasEnded() external constant returns (bool) {
    return now > preSaleEndTime;
  }

  // send ether to the fund collection wallet
  function forwardFunds() internal {
    //wallet.transfer(msg.value);
    vault.deposit.value(msg.value)(msg.sender);
  }

  // we want to be able to check all bonuses in already deployed contract
  // that's why we pass currentTime as a parameter instead of using "now"
  function getBonusPercent(uint256 tokens, uint256 currentTime) public constant returns (uint256 percent) {
    //require(currentTime >= preSaleStartTime);
    uint i = 0;
    bool isPreSale = currentTime >= preSaleStartTime && currentTime <= preSaleEndTime;
    if (isPreSale) {
      uint256 preSaleDiffInSeconds = currentTime.sub(preSaleStartTime);
      for (i = 0; i < preSaleBonuses.length; i++) {
        if (preSaleDiffInSeconds <= preSaleBonuses[i].bonusEndTime) {
          if (preSaleBonuses[i].bonusMinAmount > 0 && tokens >= preSaleBonuses[i].bonusMinAmount) {
            return preSaleBonuses[i].amountPercent;
          } else {
            return preSaleBonuses[i].timePercent;
          }
        }
      }
    } else {
      uint256 mainSaleDiffInSeconds = currentTime.sub(mainSaleStartTime);
      for (i = 0; i < mainSaleBonuses.length; i++) {
        if (mainSaleDiffInSeconds <= mainSaleBonuses[i].bonusEndTime) {
          if (mainSaleBonuses[i].bonusMinAmount > 0 && tokens >= mainSaleBonuses[i].bonusMinAmount) {
            return mainSaleBonuses[i].amountPercent;
          } else {
            return mainSaleBonuses[i].timePercent;
          }
        }
      }
    }
    return defaultPercent;
  }

  function applyBonus(uint256 tokens, uint256 percent) internal constant returns (uint256 bonusedTokens) {
    uint256 tokensToAdd = tokens.mul(percent).div(100);
    return tokens.add(tokensToAdd);
  }

  function validateWithinPeriods() internal constant {
    // within pre-sale or main sale
    require((now >= preSaleStartTime && now <= preSaleEndTime) || (now >= mainSaleStartTime && now <= mainSaleEndTime));
  }

  function validateWithinCaps(uint256 weiAmount) internal constant {
    uint256 expectedWeiRaised = weiRaised.add(weiAmount);

    // within pre-sale
    if (now >= preSaleStartTime && now <= preSaleEndTime) {
      require(weiAmount >= preSaleMinimumWei);
      require(expectedWeiRaised <= preSaleWeiCap);
    }

    // within main sale
    if (now >= mainSaleStartTime && now <= mainSaleEndTime) {
      require(expectedWeiRaised <= mainSaleWeiCap);
    }
  }

  // if crowdsale is unsuccessful, investors can claim refunds here
  function claimRefund() public {
    require(isFinalized);
    require(!goalReached());
    vault.refund(msg.sender);
  }

  function goalReached() public constant returns (bool) {
    return weiRaised >= goal;
  }

  // finish crowdsale,
  // take totalSupply as 90% and mint 10% more to specified owner's wallet
  // then stop minting forever

  function finaliseCrowdsale() external onlyOwner returns (bool) {
    require(!isFinalized);
    uint256 totalSupply = token.totalSupply();
    uint256 minterBenefit = tokenEmission.mul(2).div(100);
    if (goalReached()) {
      token.mint(tokenWallet, minterBenefit);
      vault.close();
      //token.finishMinting();
    } else {
      vault.enableRefunds();
    }

    FinalisedCrowdsale(totalSupply, minterBenefit);
    isFinalized = true;
    return true;
  }

}