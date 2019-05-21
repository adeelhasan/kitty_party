pragma solidity >=0.4.21 <0.6.0;

import "./RestrictedToOwner.sol";

contract CircuitBreaker is RestrictedToOwner{
  enum CircuitBreakerState {Halted, NoEmergency, RedAlert}

  CircuitBreakerState private circuitBreakerState = CircuitBreakerState.NoEmergency;

  modifier notInEmergency(){require(circuitBreakerState == CircuitBreakerState.NoEmergency,"no emergency"); _;}
  modifier inEmergency(){require(circuitBreakerState != CircuitBreakerState.NoEmergency, "not in emergency"); _;}
  modifier inRedAlert(){require(circuitBreakerState == CircuitBreakerState.RedAlert, "in red alert"); _;}

  //events
  event CircuitBreakerStopped();
  event CircuitBreakerInRedAlert();
  event CircuitBreakerEmergencyEnded();

  function setCirctuitBreakerToRedAlert() public notInEmergency restrictedToOwner{
    circuitBreakerState = CircuitBreakerState.RedAlert;
    emit CircuitBreakerInRedAlert();
  }

  function setCircuitBreakerEmergencyFinished() public inEmergency restrictedToOwner{
    circuitBreakerState = CircuitBreakerState.NoEmergency;
    emit CircuitBreakerEmergencyEnded();
  }

  function setCircuitBreakerToStopped() public restrictedToOwner{
    circuitBreakerState = CircuitBreakerState.Halted;
    emit CircuitBreakerStopped();
  }
}