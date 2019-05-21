pragma solidity >=0.4.21 <0.6.0;

import "./helpers/RestrictedToOwner.sol";
import "./helpers/CircuitBreaker.sol";
import "./KittyPartyState.sol";

contract KittyPartyBase is CircuitBreaker, KittyPartyState {

  struct KittyParticipant{
    bool has_contributed_this_cycle;
    bool has_won_a_cycle;
    bool exists;
  }

  uint public amountPerParticipant;
  uint public cyclesCompleted;

  mapping(address=>KittyParticipant) participants;
  address[] participant_addresses;
  uint public numberOfParticipants;

  modifier isAParticipant(){
    require(participants[msg.sender].exists,"is a participant");
    _;
  }

  modifier hasContributedInCurrentCycle(){
    require(participants[msg.sender].has_contributed_this_cycle,"has contributed this cycle");
    _;
  }

  modifier hasNotContributedInCurrentCycle(){
    require((participants[msg.sender].exists && !participants[msg.sender].has_contributed_this_cycle),"has not contributed this cycle");
    _;
  }

  modifier hasWonACycle(){
    require(participants[msg.sender].exists && participants[msg.sender].has_won_a_cycle,"has won a cycle");
    _;
  }

  modifier hasNotWonACycle(){
    require(participants[msg.sender].exists && !participants[msg.sender].has_won_a_cycle,"has not won a cycle");
    _;
  }

  event ParticipantAdded(address indexed _participant_address);
  event KittyFinished();
  event WinnerChosenForCycle(address winner, uint cycleNumber);
  event LogGotToHere(address indexed msgSender, string label);

  constructor(uint _amount) public {
    require(_amount > 0,"send some value, cannot make a kitty with zero value");
    stage = Stages.Open;
    amountPerParticipant = _amount;
  }

  function () external payable notAtStage(Stages.Finished) notInEmergency {
    require(participants[msg.sender].has_contributed_this_cycle != true, "has already funded this cycle");
    require(msg.value == amountPerParticipant, "the correct amount should be sent");

    //participant does not exist, so add
    if (!participants[msg.sender].exists)
    {
      require(stage == Stages.Open, "kitty is not open for more participants to be added");

      participants[msg.sender] = KittyParticipant(true,false,true);
      participant_addresses.push(msg.sender);

      numberOfParticipants++;

      emit ParticipantAdded(msg.sender);
    }
    else
      participants[msg.sender].has_contributed_this_cycle = true;
  }

  function closeParticipants() external restrictedToOwner atStage(Stages.Open) {
    nextStage();
  }

  function hasEveryoneContributedThisCycle() public view atStage(Stages.InProgress) returns (bool)
  {
    for (uint i = 0; i<numberOfParticipants; i++)
    {
      if (!participants[participant_addresses[i]].has_contributed_this_cycle)
      {
        return false;
      }
    }
    return true;
  }

  function getMyStatus() external view returns (bool, bool, bool) {
    KittyParticipant memory k = participants[msg.sender];
    if (k.exists)
      return (k.has_contributed_this_cycle, k.has_won_a_cycle, k.exists);
    else
      return (false,false,false);
  }

  function refundParticipants() public inEmergency restrictedToOwner{
    //should check the balance first perhaps

    for (uint i = 0; i<numberOfParticipants; i++)
    {
      if (participants[participant_addresses[i]].has_contributed_this_cycle){
        address payable participantAddress = address(uint160(participant_addresses[i]));
        participantAddress.transfer(amountPerParticipant);
      }
    }
  }

  function completeCycle() public notInEmergency restrictedToOwner atStage(Stages.InProgress){
    require(hasEveryoneContributedThisCycle(),"Everyone should have contributed by now");

    //call a descendant implementation to get the winner.
    address winner = getWinner();

    address payable winnerThisCycle = address(uint160(winner));

    //ToDo : have to protect against overflow
    uint amountToTransfer = numberOfParticipants * amountPerParticipant;
    winnerThisCycle.transfer(amountToTransfer);
    participants[winner].has_won_a_cycle = true;
    cyclesCompleted++;

    cycleCompleted();
    emit WinnerChosenForCycle(winner, cyclesCompleted);

    for (uint i = 0; i<numberOfParticipants; i++)
    {
      participants[participant_addresses[i]].has_contributed_this_cycle = false;
    }

    //if all cycles have been called, the kittyParty is finished
    if (numberOfParticipants == cyclesCompleted)
    {
      nextStage();
      emit KittyFinished();
    }
  }

  //abstract methods
  //sub classes will define how the winner of the current cycle is chosen
  function getWinner() internal returns (address);

  //chance for subclasses to regorganize internal state on completion of a cycle
  function cycleCompleted() internal;

}
